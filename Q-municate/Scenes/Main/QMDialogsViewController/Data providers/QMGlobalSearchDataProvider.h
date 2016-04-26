//
//  QMGlobalSearchDataProvider.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/3/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSearchDataProvider.h"

@interface QMGlobalSearchDataProvider : QMSearchDataProvider

- (void)nextPage;

@end

@protocol QMGlobalSearchDataProviderProtocol <NSObject>

- (QMGlobalSearchDataProvider *)globalSearchDataProvider;

@end
