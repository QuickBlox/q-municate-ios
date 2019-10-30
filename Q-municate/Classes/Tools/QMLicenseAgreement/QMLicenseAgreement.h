//
//  QMLicenseAgreement.h
//  Q-municate
//
//  Created by Injoit on 26.08.14.
//  Copyright © 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMLicenseAgreement : NSObject

+ (void)checkAcceptedUserAgreementInViewController:(UIViewController *)vc completion:(void(^)(BOOL success))completion;
+ (void)presentUserAgreementInViewController:(UIViewController *)vc completion:(void(^)(BOOL success))completion;

@end
