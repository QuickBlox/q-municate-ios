//
//  QMTitleView.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/15/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTitleView.h"
#import "QMPlaceholder.h"

@interface QMTitleView ()

@property (weak, nonatomic) IBOutlet QMImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (strong, nonatomic) NSString *avatarUrl;
@property (strong, nonatomic) NSString *text;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelRightConstraint;

@end

@implementation QMTitleView

#pragma mark - setters

- (void)setAvatarUrl:(NSString *)avatarUrl {
    
    if (![_avatarUrl isEqualToString:avatarUrl]) {
        
        _avatarUrl = avatarUrl;
        UIImage *placeholder = [QMPlaceholder placeholderWithFrame:self.avatarView.bounds title:self.textLabel.text ID:self.placeholderID];
        self.avatarView.imageViewType = QMImageViewTypeCircle;
        [self.avatarView setImageWithURL:[NSURL URLWithString:avatarUrl]
                             placeholder:placeholder
                                 options:SDWebImageLowPriority
                                progress:nil
                          completedBlock:nil];
    }
}

- (void)setText:(NSString *)text {
    
    if (![_text isEqualToString:text]) {
        
        _text = text;
        self.textLabel.text = text;
        
        [self.textLabel sizeToFit];
        [self sizeToFit];
    }
}

#pragma mark - Overrides

- (CGSize)sizeThatFits:(CGSize)size {
    
    CGFloat width = 0.0;
    for (UIView *view in [self subviews]) {
        width += view.frame.size.width;
    }
    
    size.width = width + self.avatarLeftConstraint.constant + self.labelLeftConstraint.constant + self.labelRightConstraint.constant;
    return size;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    self.alpha = highlighted ? 0.3f : 1.0f;
}

@end
