//
//  QMOnlineTitleView.m
//  Q-municate
//
//  Created by Injoit on 3/14/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMOnlineTitleView.h"

@interface QMOnlineTitleView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *status;

@end

@implementation QMOnlineTitleView

- (void)setTitle:(NSString *)title {
    
    if (![_title isEqualToString:title]) {
        
        _title = [title copy];
        self.titleLabel.text = title;
    }
}

- (void)setStatus:(NSString *)status {
    
    if (![_status isEqualToString:status]) {
        
        _status = [status copy];
        self.statusLabel.text = status;
    }
}

@end
