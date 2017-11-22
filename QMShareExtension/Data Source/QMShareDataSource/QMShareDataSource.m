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
#import "QMShareContactsTableViewCell.h"
#import "QMShareCollectionViewCell.h"
#import "QMSearchDataProvider.h"

static const NSUInteger kContactsSection = 0;

@interface QMShareDataSource()

@property (nonatomic, assign) BOOL alphabetizedDataSource;

@property (strong, nonatomic) NSDictionary *alphabetizedDictionary;
@property (strong, nonatomic) NSArray *sectionIndexTitles;

@end

@implementation QMShareDataSource

- (instancetype)initWithShareItems:(NSArray<id<QMShareItemProtocol>> *)shareItems
                   sortDescriptors:(NSArray <NSSortDescriptor *> *)sortDescriptors
            alphabetizedDataSource:(BOOL)alphabetized {
    
    if (self = [super init]) {
        
        _alphabetizedDataSource = alphabetized;
        _selectedItems = [NSMutableSet set];
        _sortDescriptors = sortDescriptors;
        
        [self addItems:shareItems];
    }
    
    return self;
}

- (BOOL)isEmpty {
    
    NSUInteger itemsCount = self.alphabetizedDataSource ?
    self.sectionIndexTitles.count :
    self.items.count;
    
    return itemsCount == 0;
}

- (void)updateItems:(NSArray *)items {
    
    for (id <QMShareItemProtocol> shareItem in items) {
        
        NSUInteger indexOfItem = [self.items indexOfObject:shareItem];
        
        if (indexOfItem != NSNotFound) {
            [self.items replaceObjectAtIndex:indexOfItem withObject:shareItem];
        }
    }
    
    [self sortDataSource];
}

- (void)sortDataSource {
    
    if (self.sortDescriptors.count > 0) {
        [self.items sortUsingDescriptors:self.sortDescriptors];
    }
}


- (void)configureAlphabetizedDataSource {
    
    self.alphabetizedDictionary = [QMAlphabetizer alphabetizedDictionaryFromObjects:self.items
                                                                       usingKeyPath:@"title"];
    self.sectionIndexTitles = [QMAlphabetizer indexTitlesFromAlphabetizedDictionary:self.alphabetizedDictionary];
}


- (void)selectItem:(id<QMShareItemProtocol>)item
           forView:(id <QMShareViewProtocol>)view {
    
    BOOL isSelected = [self.selectedItems containsObject:item];
    
    isSelected ?
    [self.selectedItems removeObject:item] :
    [self.selectedItems addObject:item];
    
    view ?
    [view setChecked:!isSelected
            animated:YES]
    : nil;
}

- (void)configureView:(id<QMShareViewProtocol>)shareView
             withItem:(id<QMShareItemProtocol>)item {
    
    [shareView setTitle:item.title
              avatarUrl:item.imageURL];
    BOOL checked = [self.selectedItems containsObject:item];
    [shareView setChecked:checked animated:NO];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.alphabetizedDataSource) {
        NSString *sectionIndexTitle = self.sectionIndexTitles[indexPath.section];
        return self.alphabetizedDictionary[sectionIndexTitle][indexPath.row];
    }
    else {
        return self.items[indexPath.row];
    }
}

- (void)addItems:(NSArray *)items {
    
    [super addItems:items];
    [self sortDataSource];
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
        NSUInteger idx = [self.items indexOfObject:item];
        if (idx != NSNotFound) {
            return [NSIndexPath indexPathForRow:idx inSection:0];
        }
        return nil;
    }
}

//MARK: - setters

- (void)replaceItems:(NSArray *)items {
    
    if (self.alphabetizedDataSource) {
        self.alphabetizedDictionary = [QMAlphabetizer alphabetizedDictionaryFromObjects:items
                                                                           usingKeyPath:@"title"];
        self.sectionIndexTitles = [QMAlphabetizer indexTitlesFromAlphabetizedDictionary:self.alphabetizedDictionary];
    }
    else {
        [super replaceItems:items];
    }
    
    [self sortDataSource];
}

- (void)setSortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors {
    _sortDescriptors = sortDescriptors;
    if (sortDescriptors) {
        [self sortDataSource];
    }
}

- (void)setItems:(NSMutableArray *)items {
    
    [self replaceItems:[items copy]];
}

@end

@implementation QMShareDataSource (QMCollectionViewDataSource)

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)__unused collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)__unused collectionView
     numberOfItemsInSection:(NSInteger)__unused section {
    
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QMShareCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[QMShareCollectionViewCell cellIdentifier]
                                                                                forIndexPath:indexPath];
    
    id <QMShareItemProtocol> item = [self objectAtIndexPath:indexPath];
    
    [self configureView:cell withItem:item];
    
    cell.tapBlock = ^(QMShareCollectionViewCell *__unused tappedCell) {
        [collectionView.delegate collectionView:collectionView
                       didSelectItemAtIndexPath:indexPath];
    };
    
    return cell;
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
    if (self.alphabetizedDataSource) {
        NSString *sectionKey = self.sectionIndexTitles[section];
        NSArray *contacts = self.alphabetizedDictionary[sectionKey];
        return contacts.count;
    }
    else {
        return self.items.count;
    }
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

@interface QMShareSearchControllerDataSource() <UICollectionViewDelegate>

@end

@implementation QMShareSearchControllerDataSource

- (instancetype)initWithShareItems:(NSArray<id<QMShareItemProtocol>> *)shareItems
                   sortDescriptors:(nullable NSArray<NSSortDescriptor *> *)sortDescriptors
            alphabetizedDataSource:(BOOL)alphabetized {
    
    self = [super initWithShareItems:shareItems
                     sortDescriptors:sortDescriptors
              alphabetizedDataSource:alphabetized];
    
    return self;
}

- (void)performSearch:(NSString *)searchText {
    
    [self.contactsDataSource performSearch:searchText];
    [super performSearch:searchText];
}

- (BOOL)showContactsSection {
    return self.contactsDataSource != nil;
}

- (NSString *)tableView:(UITableView *)__unused tableView
titleForHeaderInSection:(NSInteger)section {
    
    if (self.showContactsSection) {
        if (section == kContactsSection) {
            return self.contactsDataSource.items.count > 0 ? @"Contacts" : @"";
        }
        //We use fisrt section for collection view
        section = section - 1;
    }
    
    return [super tableView:tableView titleForHeaderInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {
    NSInteger numberOfSections = [super numberOfSectionsInTableView:tableView];
    return self.showContactsSection ? numberOfSections + 1 : numberOfSections;
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.showContactsSection) {
        if (section == kContactsSection) {
            return 1;
        }
        
        //We use fisrt section for collection view
        section = section - 1;
    }
    
    if (self.isEmpty) {
        return 1;
    }
    
    if (self.alphabetizedDataSource) {
        NSString *sectionKey = self.sectionIndexTitles[section];
        NSArray *contacts = self.alphabetizedDictionary[sectionKey];
        return contacts.count;
    }
    else {
        return self.items.count;
    }
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    
    if (self.showContactsSection &&
        indexPath.section == kContactsSection) {
        
        return self.contactsDataSource.items.count > 0 ?
        [QMShareContactsTableViewCell height] : 0;
    }
    return [QMShareTableViewCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.showContactsSection) {
        
        if (indexPath.section == kContactsSection) {
            
            QMShareContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMShareContactsTableViewCell cellIdentifier]
                                                                                 forIndexPath:indexPath];
            
            [self.contactsDataSource.selectedItems removeAllObjects];
            
            NSMutableSet *selectedContacts = [NSMutableSet setWithSet:self.selectedItems.copy];
            NSMutableSet *allContacts = [NSMutableSet setWithArray:self.contactsDataSource.items];
            
            [selectedContacts intersectSet:allContacts];
            
            [self.contactsDataSource.selectedItems addObjectsFromArray:selectedContacts.allObjects];
            
            cell.contactsCollectionView.dataSource = self.contactsDataSource;
            cell.contactsCollectionView.delegate = self;

            [cell.contactsCollectionView reloadData];
            
            return cell;
        }
    }
    
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

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.showContactsSection) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row
                                       inSection:indexPath.section - 1];
    }
    
    return [super objectAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForObject:(id)object {
    
    NSIndexPath *indexPath = [super indexPathForObject:object];
    
    if (self.showContactsSection) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row
                                       inSection:indexPath.section + 1];
    }
    
    return indexPath;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    id <QMShareItemProtocol> shareItem =  [self.contactsDataSource objectAtIndexPath:indexPath];
    id <QMShareViewProtocol> shareView = (id <QMShareViewProtocol>)[collectionView cellForItemAtIndexPath:indexPath];
    
    [self.contactsDataSource selectItem:shareItem
                                forView:shareView];
    [self selectItem:shareItem
             forView:nil];
    
    if (self.contactsDelegate) {
        [self.contactsDelegate contactsDataSource:self.contactsDataSource
                               didSelectRecipient:shareItem];
    }
    
}

- (BOOL)collectionView:(UICollectionView *)__unused collectionView
shouldSelectItemAtIndexPath:(NSIndexPath *)__unused indexPath {
    return YES;
}

@end
