//
//  QMChatHistoryCell.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMChatHistoryCell.h"
#import "QMImageView.h"

@interface QMChatHistoryCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet QMImageView *qmImgeView;

@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subTitle;

@end

@implementation QMChatHistoryCell

- (void)awakeFromNib {

    self.timeLabel.text = nil;
    self.subTitleLabel.text = nil;
    self.titleLabel.text = nil;
}

- (void)setTitle:(NSString *)title {
    
    if (![_title isEqualToString:title]) {

        _title = title;
        self.titleLabel.text = _title;
    }
}

- (void)setSubTitle:(NSString *)subTitle {
    
    if (![_subTitle isEqualToString:subTitle]) {
        
        _subTitle = subTitle;
        self.subTitleLabel.text = _subTitle;
    }
}

- (void)setTime:(NSString *)time {

    if (![_title isEqualToString:time]) {
        
        _title = time;
        self.timeLabel.text = _time;
    }
}

- (void)highlightText:(NSString *)text {
    
    NSMutableAttributedString *attributedString =
    [[NSMutableAttributedString alloc] initWithString:self.title];
    
    [attributedString addAttribute: NSForegroundColorAttributeName
                 value:[UIColor redColor]
                 range:[self.title.lowercaseString rangeOfString:text.lowercaseString]];
    
    self.titleLabel.attributedText = attributedString;
}

- (void)setImageWithUrl:(NSString *)url {
    
}

@end
