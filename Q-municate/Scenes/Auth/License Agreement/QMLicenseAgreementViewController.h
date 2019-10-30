//
//  QMLicenseAgreementViewController.h
//  Qmunicate
//
//  Created by Injoit on 10/07/2014.
//  Copyright © 2014 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LicenceCompletionBlock)(BOOL accepted);

@interface QMLicenseAgreementViewController : UIViewController

@property (copy, nonatomic) LicenceCompletionBlock licenceCompletionBlock;

@end
