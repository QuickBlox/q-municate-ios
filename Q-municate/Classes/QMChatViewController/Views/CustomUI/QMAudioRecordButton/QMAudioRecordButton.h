//
//  QMAudioRecordButton.h
//  Pods
//
//  Created by Injoit on 3/6/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QMAudioRecordButtonProtocol;

@interface QMAudioRecordButton : UIButton

@property (nonatomic, weak) id <QMAudioRecordButtonProtocol> delegate;

@property (nonatomic, strong) UIImageView *iconView;

- (void)animateIn;
- (void)animateOut;

@end


@protocol QMAudioRecordButtonProtocol <NSObject>

- (void)recordButtonInteractionDidBegin;
- (void)recordButtonInteractionDidCancel:(CGFloat)velocity;
- (void)recordButtonInteractionDidComplete:(CGFloat)velocity;
- (void)recordButtonInteractionDidUpdate:(CGFloat)velocity;
- (void)recordButtonInteractionDidStopped;

@end
