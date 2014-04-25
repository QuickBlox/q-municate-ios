
#import "SKDotField.h"
#import "SKDigitField.h"
@implementation SKDotField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)awakeFromNib{
    [self initialize];
}

-(void)initialize{
    
    if (![SKDigitField isPad]) {
        isDot=NO;
        [self addTextFieldObserver];
        self.keyboardType = UIKeyboardTypeNumberPad;
        
        [self createDotButton];
    }
}


-(void)addTextFieldObserver{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationWillChange) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];

}
-(void)removeTextFieldObserver{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
}
-(void)TextDidBeginEditing:(NSNotification*)notification{

        if ([[notification object] isEqual:self]) {
            isDot=YES;
            double delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self addButtonToKeyboard];
            });
        }else{
            [self removeDotButton];
        }
}
- (void)keyboardDidShow:(NSNotification *)note {
	// if clause is just an additional precaution, you could also dismiss it
    if ([self isFirstResponder]) {
        [self addButtonToKeyboard];
    }else{
        [self removeDotButton];
    }
}

-(void)orientationWillChange{
    if (isDot) {
        [self resignFirstResponder];
    }
}
-(void)createDotButton{
    
    btnDot = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDot.adjustsImageWhenHighlighted = NO;
    btnDot.frame = CGRectMake(0, 163, 106, 53);
    
    if (IsLandscape) {
        btnDot.frame = CGRectMake(0, 122.5, IsIphone5?186.5:157.5, 39.5);
    }else{
        btnDot.frame = CGRectMake(0, 162.5, 104.5, 53.5);
    }

    
    if (self.strSymbol) {
        [btnDot setTitle:self.strSymbol forState:UIControlStateNormal];
    }else{
        [btnDot setTitle:@"." forState:UIControlStateNormal];
    }
    btnDot.titleLabel.font=[UIFont fontWithName:@"Helvetica Bold" size:20];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        [btnDot setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnDot.titleLabel.font=[UIFont fontWithName:@"Helvetica Bold" size:30];
    }else {
        [btnDot setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnDot.titleLabel.font=[UIFont fontWithName:@"Helvetica Bold" size:20];
    }
    [btnDot addTarget:self action:@selector(symbolButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)addButtonToKeyboard {
    // locate keyboard view
    
    if (!btnDot) {
        [btnDot removeFromSuperview];
        btnDot=nil;
    }
    [self createDotButton];
    
    
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
                        [keyboard addSubview:btnDot];
                } else {
                    if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
                        [keyboard addSubview:btnDot];
                }
            }
        }
    }
    
}

-(void)removeDotButton
{
    isDot=NO;
    [btnDot removeFromSuperview];
    btnDot.hidden=YES;
    btnDot=nil;
}

- (void)symbolButtonTapped:(id)sender {
    
    NSString *strToShow= self.strSymbol?self.strSymbol:@".";
    BOOL containDot =  [self.text rangeOfString:strToShow options:NSCaseInsensitiveSearch].location == NSNotFound ? NO : YES;
    if (!containDot) {
        self.text=[self.text stringByAppendingString:strToShow];
    }
}




@end
