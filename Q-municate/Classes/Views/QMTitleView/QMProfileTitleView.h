//
//  QMProfileTitleView.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/15/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QMImageView.h>

@interface QMProfileTitleView : UIControl

@property (assign, nonatomic) NSUInteger placeholderID;

- (void)setAvatarUrl:(NSString *)avatarUrl;
- (void)setText:(NSString *)text;

@end
