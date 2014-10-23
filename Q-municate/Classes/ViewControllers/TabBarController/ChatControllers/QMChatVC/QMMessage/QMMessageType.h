//
//  QMMessageType.h
//  Q-municate
//
//  Created by Andrey Ivanov on 12.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, QMMessageType) {
    
    QMMessageTypeText,
    QMMessageTypePhoto,
    QMMessageTypeSystem,
    QMMessageTypeContactRequest
};
