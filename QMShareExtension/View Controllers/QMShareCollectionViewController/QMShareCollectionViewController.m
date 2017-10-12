//
//  QMShareCollectionViewController.m
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/9/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMShareCollectionViewController.h"
#import "QMExtensionCache.h"
#import "QMShareCollectionViewCell.h"

@protocol QMSharerableItem <NSObject>

@property (nonatomic, copy, nullable, readonly) NSString *title;
@property (nonatomic, copy, nullable, readonly) NSString *imageURL;


- (void)shareWithMessage:(QBChatMessage *)message
              completion:(void(^)(NSError *error))completion;

@end

@interface QBUUser (QMSharerable) <QMSharerableItem>

@end

@implementation QBUUser (QMSharerable)

- (NSString *)imageURL {
    return self.avatarUrl;
}

- (NSString *)title {
    
    if (self.fullName != nil) {
        return self.fullName;
    }
    else {
        return @"Unknown user";
    }
}

@end

@interface QMShareCollectionViewController () <UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@end

@implementation QMShareCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.selectedContacts = [NSMutableArray array];
    self.contacts = [NSMutableArray array];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    __weak typeof(self) weakSelf = self;
    [self allContactUsersWithCompletionBlock:^(NSArray<QBUUser *> *results, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.contacts = [NSMutableArray arrayWithArray:results];
        [strongSelf.collectionView reloadData];
        
    }];
    // Register cell classes
    
    [QMShareCollectionViewCell registerForReuseInView:self.collectionView];
    // Do any additional setup after loading the view.
}

- (void)allContactUsersWithCompletionBlock:(void(^)(NSArray<QBUUser *> *results,NSError *error))completion {
    
    NSMutableArray *userIDs = [NSMutableArray array];
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    [QMExtensionCache.contactsCache contactListItems:^(NSArray<QBContactListItem *> * _Nonnull contactListItems) {
        
        for (QBContactListItem *item in contactListItems) {
            if (item.subscriptionState != QBPresenceSubscriptionStateNone) {
                [userIDs addObject:@(item.userID)];
            }
        }
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.id IN %@",userIDs];
        
        [[QMExtensionCache.usersCache  usersWithPredicate:predicate sortedBy:@"fullName" ascending:YES] continueWithBlock:^id _Nullable(BFTask<NSArray<QBUUser *> *> * _Nonnull t) {
            if (t.faulted) {
                completion(@[],t.error);
            }
            else {
                completion(t.result,nil);
            }
            return  nil;
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.contacts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QMShareCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[QMShareCollectionViewCell cellIdentifier]
                                                                                forIndexPath:indexPath];
    
    QBUUser *user = self.contacts[indexPath.item];
    
    cell.checked = [self.selectedContacts containsObject:user];
    [cell setTitle:user.title
         avatarUrl:user.avatarUrl];
    // Configure the cell
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 80);
}

-(void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    QBUUser *item = self.contacts[indexPath.item];
    
    BOOL isSelected = [self.selectedContacts containsObject:item];
    
    QMShareCollectionViewCell *shareCell = [collectionView cellForItemAtIndexPath:indexPath];
    [shareCell setChecked:!isSelected];
    
    isSelected ?
    [self.selectedContacts removeObject:item] :
    [self.selectedContacts addObject:item];
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



@end
