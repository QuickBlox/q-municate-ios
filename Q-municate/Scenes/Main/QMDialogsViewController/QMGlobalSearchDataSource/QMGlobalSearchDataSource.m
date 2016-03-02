//
//  QMGlobalSearchDataSource.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGlobalSearchDataSource.h"
#import "QMContactCell.h"

@implementation QMGlobalSearchDataSource

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [QMContactCell height];
}

@end
