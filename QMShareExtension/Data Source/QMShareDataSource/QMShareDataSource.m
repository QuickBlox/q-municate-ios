//
//  QMShareDataSource.m
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/9/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMShareDataSource.h"
#import "QMShareViewProtocol.h"
#import <Quickblox/Quickblox.h>
#import "QMServicesManager.h"
#import "QMAlphabetizer.h"
#import "QMShareTableViewCell.h"
#import "QMNoResultsCell.h"
#import "QBUUser+QMShareItemProtocol.h"
#import "QBChatDialog+QMShareItemProtocol.h"

@interface QMShareDataSource()

@property (nonatomic, strong) NSMutableArray *allItems;
@property (nonatomic, assign) BOOL alphabetizedDataSource;

@property (strong, nonatomic) NSDictionary *alphabetizedDictionary;
@property (strong, nonatomic) NSArray *sectionIndexTitles;

@end

@implementation QMShareDataSource

- (instancetype)initWithShareItems:(NSArray<id<QMShareItemProtocol>> *)shareItems
            alphabetizedDataSource:(BOOL)alphabetized {
    
    if (self = [super init]) {
        
        _alphabetizedDataSource = alphabetized;
        _selectedItems = [NSMutableSet set];
        [self addItems:shareItems];
    }
    
    return self;
}

- (BOOL)isEmpty {
    
    NSUInteger itemsCount = self.alphabetizedDataSource ?
    self.sectionIndexTitles.count :
    self.allItems.count;
    
    return itemsCount == 0;
}


- (void)configureAlphabetizedDataSource {
    
    self.alphabetizedDictionary = [QMAlphabetizer alphabetizedDictionaryFromObjects:_allItems
                                                                       usingKeyPath:@"title"];
    self.sectionIndexTitles = [QMAlphabetizer indexTitlesFromAlphabetizedDictionary:self.alphabetizedDictionary];
}


- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath
                      forView:(id <QMShareViewProtocol>)view {
    
    id <QMShareItemProtocol> item = [self objectAtIndexPath:indexPath];
    
    BOOL isSelected = [self.selectedItems containsObject:item];
    
    isSelected ?
    [self.selectedItems removeObject:item] :
    [self.selectedItems addObject:item];
    
    view.checked = !isSelected;
}

- (void)configureView:(id <QMShareViewProtocol>)shareView
             withItem:(id<QMShareItemProtocol>)item {
    
    [shareView setTitle:item.title
              avatarUrl:item.imageURL];
    shareView.checked = [self.selectedItems containsObject:item];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.alphabetizedDataSource) {
        NSString *sectionIndexTitle = self.sectionIndexTitles[indexPath.section];
        return self.alphabetizedDictionary[sectionIndexTitle][indexPath.row];
    }
    else {
        return self.allItems[indexPath.row];
    }
}

- (NSIndexPath *)indexPathForObject:(id<QMShareItemProtocol>)item {
    
    if (self.alphabetizedDataSource) {
        
        NSArray *keys = self.sectionIndexTitles;
        for (NSUInteger i = 0; i < keys.count; i++) {
            NSUInteger idx = [self.alphabetizedDictionary[keys[i]] indexOfObject:item];
            if (idx != NSNotFound) {
                return [NSIndexPath indexPathForRow:idx inSection:i];
            }
        }
        return nil;
    }
    else {
        NSUInteger idx = [self.allItems indexOfObject:item];
        if (idx != NSNotFound) {
            return [NSIndexPath indexPathForRow:idx inSection:0];
        }
        return nil;
    }
}
//MARK: - setters

- (void)addItems:(NSArray *)items {
    
    [self replaceItems:items];
}

- (void)replaceItems:(NSArray *)items {
    
    if (self.alphabetizedDataSource) {
        self.alphabetizedDictionary = [QMAlphabetizer alphabetizedDictionaryFromObjects:items
                                                                           usingKeyPath:@"title"];
        self.sectionIndexTitles = [QMAlphabetizer indexTitlesFromAlphabetizedDictionary:self.alphabetizedDictionary];
    }
    else {
        [super replaceItems:items];
    }
}

- (void)setItems:(NSMutableArray *)items {
    
    [self replaceItems:[items copy]];
}

- (NSMutableArray *)items {
    
    return [self.alphabetizedDictionary.allValues mutableCopy];
}

@end

@implementation QMShareDataSource (QMTableViewDataSource)

- (NSString *)tableView:(UITableView *)__unused tableView titleForHeaderInSection:(NSInteger)section {
    
    return self.isEmpty ? @"" : (self.alphabetizedDataSource ? self.sectionIndexTitles[section] : @"");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {
    
    return self.isEmpty ? 1 : (self.alphabetizedDataSource ? self.sectionIndexTitles.count : 1);
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.isEmpty) {
        
        return 1;
    }
    
    NSString *sectionKey = self.sectionIndexTitles[section];
    NSArray *contacts = self.alphabetizedDictionary[sectionKey];
    
    return contacts.count;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    return [QMShareTableViewCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isEmpty) {
        
        QMNoResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMNoResultsCell cellIdentifier]
                                                                forIndexPath:indexPath];
        return cell;
    }
    
    QMShareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMShareTableViewCell cellIdentifier]
                                                                 forIndexPath:indexPath];
    
    id <QMShareItemProtocol> item = [self objectAtIndexPath:indexPath];
    
    [self configureView:cell withItem:item];
    
    return cell;
    
}

@end
