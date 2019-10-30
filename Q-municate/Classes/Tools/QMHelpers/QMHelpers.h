//
//  QMHelpers.h
//  Q-municate
//
//  Created by Injoit on 7/19/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

CGRect CGRectOfSize(CGSize size);

NSString *QMStringForTimeInterval(NSTimeInterval timeInterval);

NSInteger iosMajorVersion(void);

extern void removeControllerFromNavigationStack(UINavigationController *navC, UIViewController *vc);
