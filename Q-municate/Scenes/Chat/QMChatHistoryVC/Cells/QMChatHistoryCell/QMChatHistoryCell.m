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

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet QMImageView *qmImgeView;

@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *subTitle;

@end

@implementation QMChatHistoryCell

+ (NSString *)cellIdentifier {
    
    return @"QMChatHistoryCell";
}

- (void)awakeFromNib {

    [super awakeFromNib];

    self.timeLabel.text = nil;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}
- (void)setTime:(NSString *)time {

    if (![_time isEqualToString:time]) {
        
        _time = time;
        self.timeLabel.text = _time;
    }
}

@end
