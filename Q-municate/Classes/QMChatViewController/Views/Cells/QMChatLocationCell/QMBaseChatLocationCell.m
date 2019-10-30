//
//  QMBaseChatLocationCell.m
//  QMChatViewController
//
//  Created by Injoit on 7/5/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMBaseChatLocationCell.h"

@interface QMBaseChatLocationCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation QMBaseChatLocationCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.imageView.layer.cornerRadius = 4.0;
    self.imageView.layer.shouldRasterize = YES;
    self.imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.imageView.layer.masksToBounds = YES;
}

@end
