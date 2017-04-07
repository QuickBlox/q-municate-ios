//
//  QMDialogCell.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/13/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMDialogCell.h"
#import "QMBadgeView.h"

@interface QMDialogCell ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet QMBadgeView *badgeView;

@property (copy, nonatomic) NSString *time;

@end

@implementation QMDialogCell

+ (CGFloat)height {
    
    return 72.0f;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _timeLabel.text = nil;
}

//MARK: - Setters

- (void)setTime:(NSString *)time {
    
    if (![_time isEqualToString:time]) {
        
        _time = [time copy];
        self.timeLabel.text = time;
    }
}

- (void)setBadgeNumber:(NSUInteger)badgeNumber {
    
    self.badgeView.badgeNumber = badgeNumber;
}

@end
