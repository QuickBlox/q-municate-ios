//
//  QMAddContactProtocol.h
//  Q-municate
//
//  Created by Andrey Ivanov on 01.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#ifndef Q_municate_QMAddContactProtocol_h
#define Q_municate_QMAddContactProtocol_h

@import UIKit;

@protocol QMAddContactProtocol <NSObject>

@optional

- (void)didAddContact:(QBUUser *)contact;
- (void)didSelectContact:(QBUUser *)contact;
- (void)didDeselectContact:(QBUUser *)contact;

@end

#endif
