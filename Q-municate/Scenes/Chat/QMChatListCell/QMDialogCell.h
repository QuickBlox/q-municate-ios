//
//  QMDialogCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 31/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTableViewCell.h"

@interface QMDialogCell : QMTableViewCell

@property (strong, nonatomic) QBChatDialog *dialog;

@end
