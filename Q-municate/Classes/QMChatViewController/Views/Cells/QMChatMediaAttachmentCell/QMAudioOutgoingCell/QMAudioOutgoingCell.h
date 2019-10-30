//
//  QMAudioOutgoingCell.h
//  Pods
//
//  Created by Injoit on 2/13/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMMediaOutgoingCell.h"
#import "QMProgressView.h"

@interface QMAudioOutgoingCell : QMMediaOutgoingCell

@property (weak, nonatomic) IBOutlet QMProgressView *progressView;

@end
