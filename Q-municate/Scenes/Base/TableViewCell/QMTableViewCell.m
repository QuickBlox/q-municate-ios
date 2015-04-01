//
//  QMTableViewCell.m
//  Q-municate
//
//  Created by Andrey Ivanov on 23.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMTableViewCell.h"

@implementation QMTableViewCell

+ (void)registerForReuseInTableView:(UITableView *)tableView {
    
    NSString *nibName = NSStringFromClass(self.class);
    UINib *nib = [UINib nibWithNibName:nibName bundle:NSBundle.mainBundle];
    NSParameterAssert(nib);
    
    NSString *cellIdentifier = [self cellIdentifier];
    NSParameterAssert(cellIdentifier);
    
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
}

+ (NSString *)cellIdentifier {
    
    return nil;
}

//- (void)awakeFromNib {
//    [super awakeFromNib];
//    
//    self.qmImageView.imageViewType = QMImageViewTypeCircle;
//}
//
//- (void)setUserImageWithUrl:(NSURL *)userImageUrl {
//    
//    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
//    
//    [self.qmImageView setImageWithURL:userImageUrl
//                          placeholder:placeholder
//                              options:SDWebImageHighPriority
//                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
//                       completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];
//}
//
//- (void)setUserImage:(UIImage *)image withKey:(NSString *)key {
//    
//    if (!image) {
//        image = [UIImage imageNamed:@"upic-placeholder"];
//    }
//    
//    [self.qmImageView sd_setImage:image withKey:key];
//}

@end
