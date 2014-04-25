//
//  SKDigitField.h
//  SKContainerMenu
//
//  Created by Sunil on 11/05/13.
//  Copyright (c) 2013 Rakesh Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKConstant.h"

@interface SKDigitField : UITextField{

    UIButton *doneButton;
    BOOL phoneTagOrNot;
    BOOL isDigit;
    
}
+(BOOL)isPad;

-(void)initialize;
@end
