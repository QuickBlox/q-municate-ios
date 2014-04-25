//
//  SKDigitField.m
//  SKContainerMenu
//
//  Created by Sunil on 11/05/13.
//  Copyright (c) 2013 Rakesh Patel. All rights reserved.
//

#import "SKDigitField.h"

@interface SKDigitField (){

    BOOL isActiveField;
}
-(void)addTextFieldObserver;
-(void)removeTextFieldObserver;
@end

@implementation SKDigitField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

-(void)awakeFromNib{
    
    [self initialize];
}

-(void)initialize{
    
    if (![SKDigitField isPad]) {
        [self addTextFieldObserver];
        self.keyboardType = UIKeyboardTypeNumberPad;
    }
}

-(void)addTextFieldObserver{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationWillChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

}

-(void)removeTextFieldObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
}
-(void)TextDidBeginEditing:(NSNotification*)notification{
    if ([[notification object] isEqual:self]) {
        isDigit=YES;
        double delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self addButtonToKeyboard];
        });
    }else{
        [self removeDoneButton];
    }
}

- (void)keyboardDidShow:(NSNotification *)note {
	// if clause is just an additional precaution, you could also dismiss it
    if ([self isFirstResponder]) {
        [self addButtonToKeyboard];
    }else{
        [self removeDoneButton];
    }
}

-(void)orientationWillChange{
    if (isDigit) {
        [self resignFirstResponder];
    }
}
-(void)createDigitButton{
	doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.adjustsImageWhenHighlighted = NO;
	
    
    if (IsLandscape) {
        doneButton.frame = CGRectMake(0, 122.5, IsIphone5?186.5:157.5, 39.5);
    }else{
        doneButton.frame = CGRectMake(0, 162.5, 104.5, 53.5);
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        //7.0 and above
        [doneButton.titleLabel setFont:[UIFont fontWithName:@"helvetica ligth" size:doneButton.titleLabel.font.pointSize]];
        [doneButton setTitle:@" Done" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.0) {
        if (IsLandscape) {
            doneButton.frame = CGRectMake(0, 123, IsIphone5?187:158, 39.5);
            [doneButton setImage:[UIImage imageNamed:@"DoneUp3LS.png"] forState:UIControlStateNormal];
            [doneButton setImage:[UIImage imageNamed:@"DoneDown3LS.png"] forState:UIControlStateHighlighted];
        }else{
            doneButton.frame = CGRectMake(0, 163, 105.5, 53.5);
            [doneButton setImage:[UIImage imageNamed:@"DoneUp3.png"] forState:UIControlStateNormal];
            [doneButton setImage:[UIImage imageNamed:@"DoneDown3.png"] forState:UIControlStateHighlighted];
        }

    } else {
        if (IsLandscape) {
            doneButton.frame = CGRectMake(0, 123, IsIphone5?187:158, 39.5);
            [doneButton setImage:[UIImage imageNamed:@"DoneUpLS.png"] forState:UIControlStateNormal];
            [doneButton setImage:[UIImage imageNamed:@"DoneDownLS.png"] forState:UIControlStateHighlighted];
        }else{
            doneButton.frame = CGRectMake(0, 163, 105.5, 53.5);
            [doneButton setImage:[UIImage imageNamed:@"DoneUp.png"] forState:UIControlStateNormal];
            [doneButton setImage:[UIImage imageNamed:@"DoneDown.png"] forState:UIControlStateHighlighted];
        }
    }
    
	[doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)addButtonToKeyboard{
	
    
	// create custom button
	if (doneButton) {
        [self removeDoneButton];
        isDigit=YES;

    }
	[self createDigitButton];
    
	// locate keyboard view
	if ([[[UIApplication sharedApplication] windows] count]>1) {
        UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
        UIView* keyboard;
        @autoreleasepool {
            for(int i=0; i<[tempWindow.subviews count]; i++) {
                keyboard = [tempWindow.subviews objectAtIndex:i];
                // keyboard found, add the button
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
                    if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
                        [keyboard addSubview:doneButton];
                } else {
                    if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
                        [keyboard addSubview:doneButton];
                }
                if (isDigit == false) {
                    doneButton.hidden = TRUE;
                }
            }
        }
    }
    
}

-(void)removeDoneButton{
    isDigit=NO;
    phoneTagOrNot=YES;
    [doneButton removeFromSuperview];
    doneButton=nil;
}

- (void)doneButton:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        [self.delegate textFieldShouldReturn:self];
    }else{
        [self resignFirstResponder];
    }

}

+(BOOL)isPad{
    BOOL returnValue=NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        returnValue = YES;
    }
    return returnValue;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
