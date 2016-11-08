//
//  QMConstants.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#ifndef QMConstants_h
#define QMConstants_h

#ifdef DEBUG

#define ILog(...) do { NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__]); } while(0)

#else

#define ILog(...) do { } while (0)

#endif

// storyboards
static NSString *const kQMMainStoryboard = @"Main";
static NSString *const kQMChatStoryboard = @"Chat";
static NSString *const kQMSettingsStoryboard = @"Settings";

static NSString *const kQMPushNotificationDialogIDKey = @"dialog_id";
static NSString *const kQMPushNotificationUserIDKey = @"user_id";

static NSString *const kQMDialogsUpdateNotificationMessage = @"Notification message";
static NSString *const kQMContactRequestNotificationMessage = @"Contact request";
static NSString *const kQMLocationNotificationMessage = @"Location";
static NSString *const kQMCallNotificationMessage = @"Call notification";

static const CGFloat kQMBaseAnimationDuration = 0.2f;
static const CGFloat kQMSlashAnimationDuration = 0.1f;
static const CGFloat kQMDefaultNotificationDismissTime = 2.0f;
static const CGFloat kQMShadowViewHeight = 0.5f;

static const CLLocationDegrees MKCoordinateSpanDefaultValue = 250;

#endif /* QMConstants_h */
