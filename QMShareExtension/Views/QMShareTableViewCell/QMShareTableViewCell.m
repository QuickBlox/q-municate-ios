//
//  QMShareTableViewCell.m
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/5/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMShareTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "QMConstants.h"

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

@interface QMShareTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@end

@implementation QMShareTableViewCell

@synthesize checked = _checked;

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.checkmarkImageView.image = deselectedCheckImage();
}

+ (void)registerForReuseInView:(UIView *)viewForReuse {
    [self registerForReuseInTableView:(UITableView *)viewForReuse];
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
            
            if (checked) {
                
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     self.checkmarkImageView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                                 }
                                 completion:^(BOOL __unused finished) {
                                     [UIView animateWithDuration:0.2
                                                      animations:^{
                                                          self.checkmarkImageView.transform = CGAffineTransformIdentity;
                                                      }];
                                 }];
                
            }
        }
    }
}

+ (CGFloat)height {
    return 60.0;
}


@end
