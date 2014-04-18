//
//  AdressBookPerson.h
//  Q-municate
//
//  Created by Igor Alefirenko on 07/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMPerson : NSObject

@property (nonatomic, strong) NSString *ID;
// FIO:
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *fullName;
// emails:
@property (nonatomic, strong) NSString *homeEmail;
@property (nonatomic, strong) NSString *workEmail;
// avatar image:
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) UIImage  *avatarImage;
// status
@property (nonatomic, strong) NSString *status;
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, assign) BOOL isFacebookPerson;


@end
