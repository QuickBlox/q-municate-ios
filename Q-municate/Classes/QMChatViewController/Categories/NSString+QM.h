//
//  NSString+QM.h
//  QMChatViewController
//
//  Created by Injoit on 21.04.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (QM)

/**
 *  Removes [ ]+ symbols and trim whitespaces and new line characters
 *
 *  @return clean string
 */
- (NSString *)stringByTrimingWhitespace;

@end
