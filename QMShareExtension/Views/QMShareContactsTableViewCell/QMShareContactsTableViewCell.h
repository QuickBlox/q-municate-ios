//
//  QMShareContactsTableViewCell.h
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/13/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMSearchProtocols.h"
#import "QMTableViewCell.h"


@interface QMShareContactsTableViewCell : QMTableViewCell

@property (weak, nonatomic, readonly) IBOutlet UICollectionView *contactsCollectionView;

@end
