//
//  QMAlert.h
//  Q-municate
//
//  Created by Injoit on 5/20/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMAlert : NSObject

+ (void)showAlertWithMessage:(NSString *)message actionSuccess:(BOOL)success inViewController:(UIViewController *)viewController;

@end
