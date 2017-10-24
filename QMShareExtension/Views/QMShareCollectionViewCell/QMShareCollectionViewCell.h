//
//  QMShareCollectionViewCell.h
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/9/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMShareViewProtocol.h"

@class QMShareCollectionViewCell;

typedef void(^QMCellTapBlock)(QMShareCollectionViewCell *cell);

@interface QMShareCollectionViewCell : UICollectionViewCell <QMShareViewProtocol>
@property (nonatomic, copy) QMCellTapBlock tapBlock;

@end
