//
//  QMTextField.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMTextField;

/**
 *  QMTextFieldDelegate protocol, inherits from UITextFieldDelegate. Used to notify about custom actions.
 */
@protocol QMTextFieldDelegate <UITextFieldDelegate>

/**
 *  Notifying about backspace button being pressed.
 *
 *  @param textField QMTextField instance
 */
- (void)textFieldDidPressBackspace:(QMTextField *)textField;

/**
 *  Notifying about text field did become first responder.
 *
 *  @param textField QMTextField
 */
- (void)textFieldDidBecomeFirstResponder:(QMTextField *)textField;

/**
 *  Notifying about text field did resign first responder.
 *
 *  @param textField QMTextField
 */
- (void)textFieldDidResignFirstResponder:(QMTextField *)textField;

@end

/**
 *  Custom text field with custom placeholder.
 */
@interface QMTextField : UITextField <UIKeyInput>

/**
 *  QMTextFieldDelegate that also conforms to UITextFieldDelegate
 */
@property (weak, nonatomic) id <QMTextFieldDelegate, UITextFieldDelegate>delegate;

/**
 *  Custom placeholder label
 */
@property (strong, nonatomic) UILabel *placeholderLabel;

/**
 *  Changing placeholder shown state.
 *
 *  @param showPlaceholder defines whether placeholder should be shown or not
 *  @param animated        defines whether perform this action animated or not
 */
- (void)setShowPlaceholder:(BOOL)showPlaceholder animated:(BOOL)animated;

@end
