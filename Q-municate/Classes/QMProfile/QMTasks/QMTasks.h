//
//  QMTasks.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  QMTasks class interface.
 *  This class provides Q-municate tasks.
 */
@interface QMTasks : NSObject

/**
 *  Update current user using update params.
 *
 *  @param updateParameters update user parameters
 *
 *  @return BFTask with QBUUser as a result
 */
+ (BFTask <QBUUser *> *)taskUpdateCurrentUser:(QBUpdateUserParameters *)updateParameters;

/**
 *  Update current user image.
 *
 *  @param userImage user image to update
 *  @param progress  progress block
 *
 *  @return BFTask with QBUUser as a result
 */
+ (BFTask <QBUUser *> *)taskUpdateCurrentUserImage:(UIImage *)userImage progress:(nullable void(^)(float progress))progress;

/**
 *  Reset password for email.
 *
 *  @param email email to reset password with
 *
 *  @return BFTask with result
 */
+ (BFTask *)taskResetPasswordForEmail:(NSString *)email;

/**
 *  Auto login if possible.
 *
 *  @return BFTask with QBUUser as a result
 */
+ (BFTask <QBUUser *> *)taskAutoLogin;

/**
 *  Fetch all data for current user.
 *
 *  @discussion Fetching all dialogs for current user and all users
 *  that conforms to dialogs and contact list.
 *
 *  @return BFTask with result
 */
+ (BFTask *)taskFetchAllData;

/**
 *  Update all contacts data.
 *
 *  @return BFTask with result
 */
+ (BFTask *)taskUpdateContacts;

@end

NS_ASSUME_NONNULL_END
