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
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subTitle;

@end

@implementation QMSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleLabel.text = nil;
    self.subTitleLabel.text = nil;
}

#pragma mark - Setters

- (void)setTitle:(NSString *)title {
    
    if (![_title isEqualToString:title]) {
        
        _title = title;
        self.titleLabel.text = title;
    }
}

- (void)setSubTitle:(NSString *)subTitle {
    
    if (![_subTitle isEqualToString:subTitle]) {
        
        _subTitle = subTitle;
        self.subTitleLabel.text = subTitle;
    }
}

- (void)highlightTitle:(NSString *)title {
    
    NSMutableAttributedString *attributedString =
    [[NSMutableAttributedString alloc] initWithString:self.title];
    
    UIColor *highlightColor = [UIColor colorWithRed:1.000 green:0.610 blue:0.426 alpha:1.000];
    
    [attributedString beginEditing];
    
    NSRegularExpression *expression =
    [NSRegularExpression regularExpressionWithPattern:title
                                              options:NSRegularExpressionCaseInsensitive
                                                error:nil];
    //  enumerate matches
    NSRange range = NSMakeRange(0, self.title.length);
    [expression enumerateMatchesInString:self.title
                                 options:0
                                   range:range
                              usingBlock:^(NSTextCheckingResult *result,
                                           NSMatchingFlags flags,
                                           BOOL *stop)
     {
         NSRange resultRange = [result rangeAtIndex:0];
         
         [attributedString addAttribute:NSForegroundColorAttributeName
                                  value:highlightColor
                                  range:resultRange];
     }];
    /*
    [attributedString addAttribute: NSForegroundColorAttributeName
                             value:highlightColor
                             range:[self.title rangeOfString:title options:NSCaseInsensitiveSearch]];
    */
    [attributedString endEditing];
    
    self.titleLabel.attributedText = attributedString;
}

@end
