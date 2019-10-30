//
//  QMGlobalSearchDataProvider.h
//  Q-municate
//
//  Created by Injoit on 3/3/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMSearchDataProvider.h"

@interface QMGlobalSearchDataProvider : QMSearchDataProvider

- (void)nextPage;
- (void)cancel;

@end

@protocol QMGlobalSearchDataProviderProtocol <NSObject>

- (QMGlobalSearchDataProvider *)globalSearchDataProvider;

@end
