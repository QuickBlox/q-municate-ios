//
//  QMCallViewDelegate.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 2/25/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, QMCallViewState);

@protocol QMCallViewDelegate  <NSObject>

- (void)didChangedViewState:(QMCallViewState)status;
- (void)didAppear;
- (void)didMinimize;
- (void)didMaximize;

@end
