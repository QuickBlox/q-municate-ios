//
//  QMInviteFriendsDataSource.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 4/4/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMInviteFriendsDataSource.h"
#warning person
//#import "QMPerson.h"
#import "QMUsersService.h"
#import "QMAddressBook.h"

@implementation QMInviteFriendsDataSource

- (id)init
{
    self = [super init];
    if (self) {
		[self _initDataSources];
	}
    return self;
}

- (void)_initDataSources
{
	_users = [NSMutableArray new];
	_checkedABContacts = [NSMutableArray new];
	_checkedFacebookUsers = [NSMutableArray new];
}

#pragma mark - Updating Sources
- (void)updateFacebookDataSource:(void(^)(NSError *error))completionBlock
{
	// Check for Active Facebook Session:
	if (![FBSession activeSession] || ![[FBSession activeSession].permissions count] || ![FBSession activeSession].isOpen) {
		[[FBSession activeSession] closeAndClearTokenInformation];
		[FBSession setActiveSession:[[FBSession alloc]initWithPermissions:@[@"basic_info", @"email", @"read_stream", @"publish_stream"]]];
	}
	if ([FBSession activeSession].state == FBSessionStateCreated) {
		[[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorWithFallbackToWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
			if (status == FBSessionStateOpen) {
				//TODO: хорошо бы вынести в отдельный метод
				[self fetchAndSaveFacebookFriendsWithBlock:^(NSError *innerError) {
					if (innerError) {
						completionBlock(innerError);
					} else {
						completionBlock(nil);
					}
				}];
			} else if (status == FBSessionStateClosedLoginFailed) {
				if ([FBSession activeSession]) {
					[FBSession setActiveSession:nil];
					completionBlock(error);
				}
			}
			return;
		}];
	} else if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded || [FBSession activeSession].state == FBSessionStateOpen) {
		//TODO: хорошо бы вынести в отдельный метод - дублирование
		[self fetchAndSaveFacebookFriendsWithBlock:^(NSError *innerError) {
			if (innerError) {
				completionBlock(innerError);
			} else {
				completionBlock(nil);
			}
		}];
	}
}

- (void)updateContactListDataSource:(void(^)(NSError *error))completionBlock
{
	// load contacts from addressBook:
	QMAddressBook *addressBook = [[QMAddressBook alloc] init];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[addressBook getAllContactsFromAddressBook:^(NSArray *contactsArray, BOOL success, NSError *error) {
			dispatch_sync(dispatch_get_main_queue(), ^{
				if (error) {
					completionBlock(error);
					return;
				}
//				[self markAsFBFriends:NO friendsData:contactsArray];
#warning me.iD
#warning QMContactList shared
//				[QMContactList shared].contactsToInvite = contactsArray;
				[self refreshAllUsersDataSource];
				completionBlock(nil);
			});
		}];
	});
}

- (void)refreshAllUsersDataSource
{
#warning me.iD
#warning QMContactList shared
//	[self.users setArray:[QMContactList shared].facebookFriendsToInvite];
//	[self.users addObjectsFromArray:[QMContactList shared].contactsToInvite];
}

#pragma mark - Work With Marks
- (void)changeStateForFacebookUsers
{
#warning me.iD
#warning QMContactList shared
//	NSArray *fbFriendsArray = [QMContactList shared].facebookFriendsToInvite;
//	if (fbFriendsArray && [fbFriendsArray count]) {
//		BOOL state = NO;
//		if ([self.checkedFacebookUsers count] < [fbFriendsArray count]) {
//			state = YES;
//			self.checkedFacebookUsers = [fbFriendsArray mutableCopy];
//		} else {
//			self.checkedFacebookUsers = nil;
//		}
//		[self changeState:state withArray:fbFriendsArray];
//	}
}

- (void)changeStateForContactUsers
{
#warning me.iD
#warning QMContactList shared
//	NSArray *contactFriendsArray = [QMContactList shared].contactsToInvite;
//	if (contactFriendsArray && [contactFriendsArray count]) {
//		BOOL state = NO;
//		if ([self.checkedABContacts count] < [contactFriendsArray count]) {
//			state = YES;
//			self.checkedABContacts = [contactFriendsArray mutableCopy];
//		} else {
//			self.checkedABContacts = nil;
//		}
//		[self changeState:state withArray:contactFriendsArray];
//	}
}
#warning person
//
//- (void)changeState:(BOOL)state withArray:(NSArray *)array
//{
//	for (QMPerson *person in array) {
//		person.checked = state;
//	}
//}
//
//- (void)changeUserState:(QMPerson *)user
//{
//	user.checked = !user.checked;
//	//TODO:adding to checked array as well.
//	if ([user.status isEqualToString:kFacebookFriendStatus]) {
//		if (!self.checkedFacebookUsers) {
//			self.checkedFacebookUsers = [NSMutableArray new];
//		}
//		if (user.checked) {
//			[self.checkedFacebookUsers addObject:user];
//		} else {
//			[self.checkedFacebookUsers removeObject:user];
//		}
//	}
//	else if ([user.status isEqualToString:kAddressBookUserStatus]) {
//		if (!self.checkedABContacts) {
//		    self.checkedABContacts = [NSMutableArray new];
//		}
//		if (user.checked) {
//			[self.checkedABContacts addObject:user];
//		} else {
//			[self.checkedABContacts removeObject:user];
//		}
//	}
//}

- (void)emptyCheckedFBUsersArray
{
    [self.checkedFacebookUsers removeAllObjects];
}

- (void)emptyCheckedABUsersArray
{
	[self.checkedABContacts removeAllObjects];
}

- (NSArray *)emailsFromContactListPersons
{
    NSMutableArray *emails = [[NSMutableArray alloc] init];
//    for (QMPerson *user in self.checkedABContacts) {
//        if (user.homeEmail != nil) {
//            [emails addObject:user.homeEmail];
//        }
//        if (user.workEmail != nil) {
//            [emails addObject:user.workEmail];
//        }
//    }
    return emails;
}

- (NSString *)emailsFromFacebookPersons
{
    NSMutableString *tagString = nil;

//    QMPerson *firstPerson = [self.checkedFacebookUsers firstObject];
//    for (QMPerson *user in self.checkedFacebookUsers) {
//        if ([user.ID isEqualToString:firstPerson.ID]) {
//            tagString = [user.ID mutableCopy];
//            continue;
//        }
//        [tagString appendString:@","];
//        [tagString appendString:user.ID];
//    }
    return tagString;
}

- (void)fetchAndSaveFacebookFriendsWithBlock:(void (^)(NSError *error))block
{
#warning me.iD
#warning QMContactList shared
//    [[QMContactList shared] fetchFriendsFromFacebookWithCompletion:^(NSArray *users, BOOL success, NSError *error) {
//        if (success) {
//            NSArray *persons = [[QMContactList shared] personsFromDictionaries:users];
//			[self markAsFBFriends:YES friendsData:persons];
//			[QMContactList shared].facebookFriendsToInvite = [persons mutableCopy];
//			[self refreshAllUsersDataSource];
//            block(nil);
//            return;
//        }
//        block(error);
//    }];
}

//- (void)markAsFBFriends:(BOOL)isFacebookFriend friendsData:(NSArray *)persons
//{
//	for (QMPerson *person in persons) {
//		person.isFacebookPerson = isFacebookFriend;
//	}
//}


@end
