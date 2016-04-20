//
//  QMSelectableContactCell.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSelectableContactCell.h"
#import <QuartzCore/QuartzCore.h>

static UIImage *selectedCheckImage() {
    
    static UIImage *image = nil;
    
    if (image == nil) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            image = [UIImage imageNamed:@"checkmark_selected"];
        });
    }
    
    return image;
}

static UIImage *deselectedCheckImage() {
    
    static UIImage *image = nil;
    
    if (image == nil) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            image = [UIImage imageNamed:@"checkmark_deselected"];
        });
    }
    
    return image;
}

@interface QMSelectableContactCell ()

@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@end

@implementation QMSelectableContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.checkmarkImageView.image = deselectedCheckImage();
}

- (void)setChecked:(BOOL)checked {
    
    if (_checked != checked) {
        
        _checked = checked;
        self.checkmarkImageView.image = checked ? selectedCheckImage() : deselectedCheckImage();
    }
}

- (void)setChecked:(BOOL)checked animated:(BOOL)animated {
    
    if (_checked != checked) {
        
        self.checked = checked;
        
        if (animated) {
            
            CATransition *transition = [CATransition animation];
            transition.duration = kQMBaseAnimationDuration;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            
            [self.checkmarkImageView.layer addAnimation:transition forKey:nil];
        }
    }
}

@end
