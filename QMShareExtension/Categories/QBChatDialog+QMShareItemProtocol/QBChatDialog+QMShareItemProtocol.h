//
//  QBChatDialog+QMShareItemProtocol.h
//  QMShareExtension
//
//  Created by Injoit on 10/12/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Quickblox/Quickblox.h>
#import "QMShareItemProtocol.h"

@interface QBChatDialog (QMShareItemProtocol) <QMShareItemProtocol>

@property (nonatomic, strong) QBUUser *recipient;

@end

