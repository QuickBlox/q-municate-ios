//
//  REActionSheet.h
//  Q-municate
//
//  Created by Andrey Ivanov on 11.08.14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class REActionSheet;

typedef void(^REActionSheetButtonAction)();
typedef void(^REActionSheetBlock)(REActionSheet  * _Nonnull actionSheet);

@interface REActionSheet : UIActionSheet

+ (void)presentActionSheetInView:(UIView * _Nonnull)view configuration:(REActionSheetBlock _Nonnull)configuration;
- (void)addButtonWithTitle:(NSString * _Nonnull)title andActionBlock:(REActionSheetButtonAction _Nonnull)block;
- (void)addDestructiveButtonWithTitle:(NSString * _Nonnull)title andActionBlock:(REActionSheetButtonAction _Nonnull)block;
- (void)addCancelButtonWihtTitle:(NSString * _Nonnull)title andActionBlock:(REActionSheetButtonAction _Nonnull)block;

@end
