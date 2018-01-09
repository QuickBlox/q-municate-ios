//
//  UIAlertController+QM.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/20/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "UIAlertController+QM.h"
#import "QMColors.h"

@implementation UIViewController(QMAlertController)

- (void)presentAlertControllerWithStatus:(NSString *)status
                       withButtonHandler:(dispatch_block_t)buttonTapBlock {
    
    UIAlertController *alertController =
    [UIAlertController qm_infoAlertControllerWithStatus:status
                                         buttonTapBlock:buttonTapBlock];
    
    if (self.presentedViewController) {
        [self.presentedViewController presentViewController:alertController
                                                   animated:YES
                                                 completion:nil];
    }
    else {
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end

@implementation UIAlertController (QM)

//MARK: - Publice methods

+ (instancetype)qm_loadingAlertControllerWithStatus:(NSString *)status
                                        cancelBlock:(dispatch_block_t)cancelBlock {
    
    NSString *buttonTitle = NSLocalizedString(@"QM_STR_CANCEL", nil);
    
    return [self qm_alertControllerWithType:QMAlertControllerTypeActivity
                                     status:status
                                buttonTitle:buttonTitle
                             buttonTapBlock:cancelBlock];
}


+ (instancetype)qm_infoAlertControllerWithStatus:(NSString *)status
                                  buttonTapBlock:(dispatch_block_t)buttonTapBlock {
    
    NSString *buttonTitle = NSLocalizedString(@"QM_STR_OK", nil);
    
    return [self qm_alertControllerWithType:QMAlertControllerTypeAlert
                                     status:status
                                buttonTitle:buttonTitle
                             buttonTapBlock:buttonTapBlock];
}


+ (instancetype)qm_alertControllerWithType:(QMAlertControllerType)type
                                    status:(NSString *)status
                               buttonTitle:(NSString *)buttonTitle
                            buttonTapBlock:(dispatch_block_t)buttonTapBlock {
    
    if (type == QMAlertControllerTypeProgress ||
        type == QMAlertControllerTypeActivity) {
        status = [NSString stringWithFormat:@"%@\n",status];
    }
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:nil
                                        message:status
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertActionStyle style =
    (type == QMAlertControllerTypeAlert) ? UIAlertActionStyleDefault : UIAlertActionStyleCancel;
    
    [alertController addAction:[UIAlertAction actionWithTitle:buttonTitle
                                                        style:style
                                                      handler:^(UIAlertAction * _Nonnull __unused action)
                                {
                                    buttonTapBlock ? buttonTapBlock() : nil;
                                }]];
    
    UIView *subview = [self subviewForType:type];
    
    if (subview) {
        
        [alertController.view addSubview:subview];
        
        NSArray *constraints = [alertController constraintsWithSubview:subview
                                                               forType:type];
        [alertController.view addConstraints:constraints];
    }
    
    return alertController;
}

//MARK: - Private methods

- (NSArray *)constraintsWithSubview:(UIView *)subview
                            forType:(QMAlertControllerType)type {
    
    NSArray *constraints = nil;
    
    if (type == QMAlertControllerTypeActivity) {
        
        NSDictionary *views = @{@"alertController" : self.view,
                                @"indicator" : subview};
        
        NSArray *constraintsVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[indicator]-(45)-|" options:0 metrics:nil views:views];
        NSArray *constraintsHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[indicator]|" options:0 metrics:nil views:views];
        constraints = [constraintsVertical arrayByAddingObjectsFromArray:constraintsHorizontal];
    }
    
    return constraints;
}


+ (nullable UIView *)subviewForType:(QMAlertControllerType)type {
    
    UIView *subView = nil;
    
    if (type == QMAlertControllerTypeActivity) {
        
        UIActivityIndicatorView *indicator =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indicator setUserInteractionEnabled:NO];
        [indicator startAnimating];
        indicator.color = QMSecondaryApplicationColor();
        subView = indicator;
    }
    
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    
    return subView;
}

@end
