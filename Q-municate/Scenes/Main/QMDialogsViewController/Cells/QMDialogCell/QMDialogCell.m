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

@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *badgeText;

@end

@implementation QMDialogCell

+ (NSString *)cellIdentifier {
    
    return @"QMDialogCell";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _timeLabel.text = nil;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Setters

- (void)setTime:(NSString *)time {
    
    if (![_time isEqualToString:time]) {
        
        _time = time;
        self.timeLabel.text = time;
    }
}

- (void)setBadgeText:(NSString *)badgeText {
    
    if (![_badgeText isEqualToString:badgeText]) {
        
        _badgeText = badgeText;
        self.badgeView.badgeText = badgeText;
    }
}

- (void)setBadgeHidden:(BOOL)badgeHidden {
    
    self.badgeView.hidden = badgeHidden;
}

@end
