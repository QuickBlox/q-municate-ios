//
//  QMSearchCell.m
//  Q-municate
//
//  Created by Andrey Ivanov on 23.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMSearchCell.h"

@interface QMSearchCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) NSString *title;

@end

@implementation QMSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleLabel.text = nil;
}

#pragma mark - Setters

- (void)setTitle:(NSString *)title {
    
    if (![_title isEqualToString:title]) {
        
        _title = title;
        self.titleLabel.text = title;
    }
}

- (void)highlightText:(NSString *)text {
    
    NSMutableAttributedString *attributedString =
    [[NSMutableAttributedString alloc] initWithString:self.title];
    
    [attributedString addAttribute: NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:1.000 green:0.201 blue:0.000 alpha:0.830]
                             range:[self.title.lowercaseString rangeOfString:text.lowercaseString]];
    
    self.titleLabel.attributedText = attributedString;
}

@end
