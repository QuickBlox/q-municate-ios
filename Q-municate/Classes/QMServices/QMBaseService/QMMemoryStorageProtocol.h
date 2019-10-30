//
//  QMMemoryStorageProtocol.h
//  QMServices
//
//  Created by Injoit on 28.04.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QMMemoryStorageProtocol <NSObject>

@property (nonatomic, readonly) BOOL isEmpty;
/**
 *  This method used for clean all storage data in memory
 */
- (void)free;

@end
