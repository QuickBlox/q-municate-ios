//
//  QBStreamManagementCallbackObject.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/23/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBStreamManagementCallbackObject : NSObject

@property (copy) void (^callbackBlock)(BOOL);
@property (assign) NSUInteger currentNumberOfStanzasSent;

@end
