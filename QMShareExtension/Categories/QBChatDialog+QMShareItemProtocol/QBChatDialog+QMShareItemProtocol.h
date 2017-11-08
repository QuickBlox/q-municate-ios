//
//  QBChatDialog+QMShareItemProtocol.h
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/12/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Quickblox/Quickblox.h>
#import "QMShareItemProtocol.h"

@interface QBChatDialog (QMShareItemProtocol) <QMShareItemProtocol>

@property (nonatomic, strong) QBUUser *recipient;

@end

