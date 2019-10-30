//
//  UIAlertController+QM.h
//  Q-municate
//
//  Created by Injoit on 11/20/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QMAlertControllerType) {
    QMAlertControllerTypeActivity,
    QMAlertControllerTypeProgress,
    QMAlertControllerTypeAlert
};

@interface UIViewController(QMAlertController)

- (void)presentAlertControllerWithStatus:(NSString *)status
                       buttonHandler:(dispatch_block_t)buttonTapBlock;
@end

@interface UIAlertController (QM)

+ (instancetype)qm_loadingAlertControllerWithStatus:(NSString *)status
                                        cancelBlock:(dispatch_block_t)cancelBlock;

+ (instancetype)qm_infoAlertControllerWithStatus:(NSString *)status
                                  buttonTapBlock:(dispatch_block_t)buttonTapBlock;

+ (instancetype)qm_alertControllerWithType:(QMAlertControllerType)type
                                    status:(NSString *)status
                               buttonTitle:(NSString *)buttonTitle
                            buttonTapBlock:(dispatch_block_t)buttonTapBlock;
@end
