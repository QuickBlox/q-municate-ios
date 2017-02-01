//
//  QMSiriDataProvider.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/15/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol QMSiriDataProviderDelegate;

@interface QMSiriDataProvider : NSObject

@property (weak,nonatomic) id <QMSiriDataProviderDelegate> delegate;

+ (instancetype)instance;

- (BOOL)isAuthorized;

@end

@protocol QMSiriDataProviderDelegate <NSObject>

- (BOOL)isAuthorized;

@end
