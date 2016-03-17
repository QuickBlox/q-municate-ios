//
//  QMNewMessageDataSource.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/15/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSearchDataSource.h"

@interface QMNewMessageDataSource : QMSearchDataSource

@property (strong, nonatomic) NSDictionary *alphabetizedDictionary;
@property (strong, nonatomic) NSArray *sectionIndexTitles;

- (QBUUser *)userAtIndexPath:(NSIndexPath *)indexPath;

@end
