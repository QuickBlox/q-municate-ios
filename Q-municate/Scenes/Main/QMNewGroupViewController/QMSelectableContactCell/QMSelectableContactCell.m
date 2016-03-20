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
        
        UIImage *rawImage = [UIImage imageNamed:@"checkmark_selected"];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    
    return image;
}

static UIImage *deselectedCheckImage() {
    
    static UIImage *image = nil;
    
    if (image == nil) {
        
        UIImage *rawImage = [UIImage imageNamed:@"checkmark_deselected"];
        image = [rawImage stretchableImageWithLeftCapWidth:(int)(rawImage.size.width / 2) topCapHeight:0];
    }
    
    return image;
}

@interface QMSelectableContactCell ()

@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@end

@implementation QMSelectableContactCell

+ (NSString *)cellIdentifier {
    
    return @"QMSelectableContactCell";
}

- (void)setChecked:(BOOL)checked {
    
    _checked = checked;
    self.checkmarkImageView.image = checked ? selectedCheckImage() : deselectedCheckImage();
}

- (void)setChecked:(BOOL)checked animated:(BOOL)animated {
    
    self.checked = checked;
    
    if (animated) {
        
        CATransition *transition = [CATransition animation];
        transition.duration = kQMBaseAnimationDuration;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        
        [self.checkmarkImageView.layer addAnimation:transition forKey:nil];
    }
}

@end
