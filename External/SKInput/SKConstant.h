//
//  SKConstant.h
//  SKInputDemo
//
//  Created by Sunil on 02/12/13.
//  Copyright (c) 2013 Sunil Vaishnav. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "SKDigitField.h"
#import "SKDotField.h"

#define IsLandscape              UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)
#define IsIphone5     ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

