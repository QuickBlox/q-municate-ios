//
//  QMKeyboardController.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 23.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Posted when the system keyboard frame changes.
 *  The object of the notification is the `QMKeyboardController` object.
 *  The `userInfo` dictionary contains the new keyboard frame for key
 *  `QMKeyboardControllerUserInfoKeyKeyboardDidChangeFrame`.
 */
FOUNDATION_EXPORT NSString * const QMKeyboardControllerNotificationKeyboardDidChangeFrame;
/**
 *  Contains the new keyboard frame wrapped in an `NSValue` object.
 */
FOUNDATION_EXPORT NSString * const QMKeyboardControllerUserInfoKeyKeyboardDidChangeFrame;

@protocol QMKeyboardControllerDelegate <NSObject>

@required
/**
 *  Tells the delegate that the keyboard frame has changed.
 *
 *  @param keyboardFrame The new frame of the keyboard in the coordinate system of the `contextView`.
 */
- (void)keyboardDidChangeFrame:(CGRect)keyboardFrame;

@end

@interface QMKeyboardController : NSObject
/**
 *  The object that acts as the delegate of the keyboard controller.
 */
@property (weak, nonatomic) id<QMKeyboardControllerDelegate> delegate;

/**
 *  The text view in which the user is editing with the system keyboard.
 */
@property (weak, nonatomic, readonly) UITextView *textView;

/**
 *  The view in which the keyboard will be shown. This should be the parent or a sibling of `textView`.
 */
@property (weak, nonatomic, readonly) UIView *contextView;

/**
 *  The pan gesture recognizer responsible for handling user interaction with the system keyboard.
 */
@property (weak, nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

/**
 *  Specifies the distance from the keyboard at which the `panGestureRecognizer`
 *  should trigger user interaction with the keyboard by panning.
 *
 *  @discussion The x value of the point is not used.
 */
@property (assign, nonatomic) CGPoint keyboardTriggerPoint;

/**
 *  Creates a new keyboard controller object with the specified textView, contextView, panGestureRecognizer, and delegate.
 *
 *  @param textView             The text view in which the user is editing with the system keyboard. This value must not be `nil`.
 *  @param contextView          The view in which the keyboard will be shown. This should be the parent or a sibling of `textView`. This value must not be `nil`.
 *  @param panGestureRecognizer The pan gesture recognizer responsible for handling user interaction with the system keyboard. This value must not be `nil`.
 *  @param delegate             The object that acts as the delegate of the keyboard controller.
 *
 *  @return An initialized `QMKeyboardController` if created successfully, `nil` otherwise.
 */
- (instancetype)initWithTextView:(UITextView *)textView
                     contextView:(UIView *)contextView
            panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
                        delegate:(id<QMKeyboardControllerDelegate>)delegate;

/**
 *  Tells the keyboard controller that it should begin listening for system keyboard notifications.
 */
- (void)beginListeningForKeyboard;

/**
 *  Tells the keyboard controller that it should end listening for system keyboard notifications.
 */
- (void)endListeningForKeyboard;

@end
