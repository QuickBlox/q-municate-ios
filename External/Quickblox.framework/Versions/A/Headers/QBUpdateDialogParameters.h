//
//  QBUpdateDialogParameters.h
//  Quickblox
//
//  Created by Anton Sokolchenko on 9/5/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 This class represents QBChatDialog update information
 You can change name, add new or remove existing occupants
 */
@interface QBUpdateDialogParameters : NSObject

/**
 @param dialogID chat dialog ID to update
 @param dialogNewName chat dialog new name
 @param addedOcupants add new occupants
 @param removedOccupants remove existing occupants
 */
+ (instancetype)updateDialogWithDialogID:(NSString *)dialogID dialogNewName:(NSString *)dialogNewName addedOccupants:(NSArray *)addedOcupants removedOccupants:(NSMutableArray *)removedOccupants;

/**
 @param dialogID chat dialog ID to update
 @param dialogNewName chat dialog new name
 @param addedOcupants add new occupants
 @param removedOccupants remove existing occupants
 */
- (instancetype)initWithDialogID:(NSString *)dialogID dialogNewName:(NSString *)dialogNewName addedOccupants:(NSArray *)addedOcupants removedOccupants:(NSMutableArray *)removedOccupants;

/**
 @param dialogID chat dialog ID to update
 @param dialogNewName chat dialog new name
 */
+ (instancetype)updateDialogWithDialogID:(NSString *)dialogID dialogNewName:(NSString *)newName;

/**
 @param dialogID chat dialog ID to update
 @param dialogNewName chat dialog new name
 */
- (instancetype)initWithDialogID:(NSString *)dialogID dialogNewName:(NSString *)dialogNewName;

/**
 @param dialogID chat dialog ID to update
 @param addedOcupants add new occupants IDS
 @param removedOccupants remove existing occupants IDS
 */
+ (instancetype)updateDialogWithDialogID:(NSString *)dialogID addedOccupants:(NSArray *)addedOcupants removedOccupants:(NSArray *)removedOccupants;

/**
 @param dialogID chat dialog ID to update
 @param addedOcupants add new occupants
 @param removedOccupants remove existing occupants
 */
- (instancetype)initWithDialogID:(NSString *)dialogID addedOccupants:(NSArray *)addedOcupants removedOccupants:(NSArray *)removedOccupants;

/// add new occupants
@property (nonatomic, strong) NSMutableArray *addedOccupants;

/// remove existing occupants
@property (nonatomic, strong) NSMutableArray *removedOccupants;

/// chat dialog ID
@property (nonatomic, strong) NSString *dialogID;

/// chat dialog new name
@property (nonatomic, strong) NSString *dialogNewName;

@end
