//
//  QMCallInfoView.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMCallInfoView.h"
#import "QMPlaceholder.h"
#import <QMImageView.h>

/**
 *  XIB names
 */
static NSString *const kQMCallInfoXibName = @"QMCallInfoView";
static NSString *const kQMVideoCallInfoXibName = @"QMVideoCallInfoView";

@interface QMCallInfoView ()

@property (weak, nonatomic) IBOutlet QMImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@property (strong, nonatomic) UIColor *textColor;

@end

@implementation QMCallInfoView

#pragma mark - Construction

+ (instancetype)callInfoViewWithUser:(QBUUser *)user {
    
    QMCallInfoView *callInfoView = [[NSBundle mainBundle] loadNibNamed:kQMCallInfoXibName owner:self options:nil].firstObject;
    
    callInfoView.fullNameLabel.text = user.fullName ?: [NSString stringWithFormat:@"%tu", user.ID];
    
    callInfoView.avatarImageView.imageViewType = QMImageViewTypeCircle;

    [callInfoView.avatarImageView setImageWithURL:[NSURL URLWithString:user.avatarUrl]
                                            title:user.fullName
                                   completedBlock:nil];
    
    callInfoView.backgroundColor = [UIColor clearColor];
    
    return callInfoView;
}

+ (instancetype)videoCallInfoViewWithUser:(QBUUser *)user {
    
    QMCallInfoView *callInfoView =
    [[NSBundle mainBundle] loadNibNamed:kQMVideoCallInfoXibName
                                  owner:self
                                options:nil].firstObject;
    
    callInfoView.fullNameLabel.text = user.fullName ?: [NSString stringWithFormat:@"%tu", user.ID];
    
    return callInfoView;
}

#pragma mark - Static

+ (CGFloat)preferredVideoInfoViewHeight {
    
    return 77.0f;
}

#pragma mark - Setters

- (void)setBottomText:(NSString *)bottomText {
    
    if (![_bottomText isEqualToString:bottomText]) {
        
        _bottomText = [bottomText copy];
        self.bottomLabel.text = bottomText;
    }
}

- (void)setTextColor:(UIColor *)textColor {
    
    if (![_textColor isEqual:textColor]) {
        
        _textColor = textColor;
        
        self.fullNameLabel.textColor = textColor;
        self.bottomLabel.textColor = textColor;
    }
}

@end
