//
//  QMSeparatorCell.m
//  Q-municate
//
//  Created by Injoit on 4/7/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMSeparatorCell.h"
#import "QMShadowView.h"

@implementation QMSeparatorCell

+ (CGFloat)height {
    
    return 32.0f;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    QMShadowView *shadowView = [[QMShadowView alloc] initWithFrame:CGRectMake(0,
                                                                              0,
                                                                              CGRectGetWidth(self.frame),
                                                                              kQMShadowViewHeight)];
    [self.contentView addSubview:shadowView];
}

- (UIEdgeInsets)layoutMargins {
    
    return UIEdgeInsetsZero;
}

@end
