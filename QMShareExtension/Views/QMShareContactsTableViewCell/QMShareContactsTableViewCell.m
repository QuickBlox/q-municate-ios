//
//  QMShareContactsTableViewCell.m
//  QMShareExtension
//
//  Created by Injoit on 10/13/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMShareContactsTableViewCell.h"
#import "QMShareCollectionViewCell.h"

@interface QMShareContactsTableViewCell ()

@property (weak, nonatomic) IBOutlet UICollectionView *contactsCollectionView;

@end

@implementation QMShareContactsTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [QMShareCollectionViewCell registerForReuseInView:self.contactsCollectionView];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)height {
    return 100.0;
}

@end
