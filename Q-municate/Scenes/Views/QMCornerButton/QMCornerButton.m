//
//  QMCornerButton.m
//  Q-municate
//
//  Created by Andrey Ivanov on 27.02.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMCornerButton.h"

@implementation QMCornerButton

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.borderWidth = 1;
    self.layer.borderColor = self.titleLabel.textColor.CGColor;
    self.layer.cornerRadius = 4;
}

@end
