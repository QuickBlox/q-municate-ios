//
//  QMCallWindow.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 2/25/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMCallWindow.h"
#import "QMLocalVideoView.h"
#import "QMCallViewDelegate.h"
#import "QMCallViewController.h"

@interface QMCallWindow()
@end
@implementation QMCallWindow

//- (void)animateForState:(QMCallViewState)status {
//    
//    switch (status) {
//        case QMCallViewStateMaximized :{
//            
//            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//                self.rootViewController.view.frame = self.frame;
//                
//            } completion:nil];
//            break;
//        }
//        case QMCallViewStateMinimized: {
//            CGFloat x = [UIScreen mainScreen].bounds.size.width/2 - 10;
//            CGFloat y = [UIScreen mainScreen].bounds.size.height/2 - ([UIScreen mainScreen].bounds.size.width*9/32) - 10;
//            //CGPoint coordinate = CGPointMake(x, y);
//            
//            
//            [UIView animateWithDuration:0.3 animations:^{
//                //                CGRect frame = self.frame;
//                //                frame.origin =  coordinate;
//                //                frame.size = CGSizeMake(100, 100);
//                //            //    frame.size =
//                //                self.frame = frame;
//                
//                CGRect  frame  = self.rootViewController.view.frame;
//                frame.size = CGSizeMake(100, 100);
//                self.rootViewController.view.frame = frame;
//                [self.rootViewController.view setNeedsLayout];
//            }];
//            
//            
//            break;
//        }
//        case QMCallViewStateHidden: {
//            
//            break;
//        }
//        default:
//            NSAssert(NO, @"wrong QMCallViewState");
//            break;
//    }
//}
//- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    
//    // See if the hit is anywhere in our view hierarchy
//    UIView *hitTestResult = [super hitTest:point withEvent:event];
//    
//    // ABKSlideupHostOverlay view covers the pass-through touch area.  It's recognized
//    // by class, here, because the window doesn't have a pointer to the actual view object.
//    if ([hitTestResult isKindOfClass:[self class]]) {
//        return nil;
//    }
//    
//    return hitTestResult;
//}
//
////MARK:QMCallViewDelegate.h
//- (void)didMaximize {
//    
//    
//    
//    [self animateForState:QMCallViewStateMaximized];
//}
//
//
//- (void)tap:(id)sender {
//    [self didMaximize];
//}
//
//- (void)move:(UIPanGestureRecognizer *)gesture
//{
//    static CGPoint originalCenter;
//    
//    if (gesture.state == UIGestureRecognizerStateBegan)
//    {
//        originalCenter = gesture.view.center;
//        gesture.view.layer.shouldRasterize = YES;
//    }
//    if (gesture.state == UIGestureRecognizerStateChanged)
//    {
//        CGPoint translate = [gesture translationInView:gesture.view.superview];
//        gesture.view.center = CGPointMake(originalCenter.x + translate.x, originalCenter.y + translate.y);
//    }
//    if (gesture.state == UIGestureRecognizerStateEnded ||
//        gesture.state == UIGestureRecognizerStateFailed ||
//        gesture.state == UIGestureRecognizerStateCancelled)
//    {
//        gesture.view.layer.shouldRasterize = NO;
//    }
//}
//
//
//- (void)didMinimize {
//    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
//    [panRecognizer setMinimumNumberOfTouches:1];
//    [panRecognizer setMaximumNumberOfTouches:1];
//    
//    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
//    
//    [self.rootViewController.view addGestureRecognizer:panRecognizer];
//    [self.rootViewController.view addGestureRecognizer:tapRecognizer];
//    [self animateForState:QMCallViewStateMinimized];
//}
//
//- (void)didChangedViewState:(QMCallViewState)status {
//    
//}




@end
