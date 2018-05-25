//
//  QBAddressBookRejectDetails.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 QBAddressBookRejectDetails class interface.
 This class represents the reject details of an address book item.
 */
@interface QBAddressBookRejectDetails : NSObject

/** The index of rejected object */
@property (nonatomic, assign) NSUInteger index;

/** The reject reason details*/
@property (nonatomic, copy) NSString *details;

@end

NS_ASSUME_NONNULL_END
