//
//  CDUser.h
//  Q-municate
//
//  Created by Andrey on 05.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CDUser : NSManagedObject

@property (nonatomic, retain) NSNumber * avatarId;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSNumber * userId;

@end
