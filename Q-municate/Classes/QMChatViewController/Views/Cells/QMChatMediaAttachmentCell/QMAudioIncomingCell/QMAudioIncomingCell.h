//
//  QMAudioIncomingCell.h
//  Pods
//
//  Created by Injoit on 2/13/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMMediaIncomingCell.h"
#import "QMProgressView.h"

@interface QMAudioIncomingCell : QMMediaIncomingCell

@property (weak, nonatomic) IBOutlet QMProgressView *progressView;

@end
