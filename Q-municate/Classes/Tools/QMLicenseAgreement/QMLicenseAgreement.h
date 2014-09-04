//
//  QMLicenseAgreement.h
//  Q-municate
//
//  Created by Andrey Ivanov on 26.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMLicenseAgreement : NSObject

+ (void)checkAcceptedUserAgreementInViewController:(UIViewController *)vc completion:(void(^)(BOOL success))completion;

@end
