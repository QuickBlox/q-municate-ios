//
//  QMSelectableContactCell.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSelectableContactCell.h"

static NSString *const kQMCheckMarkDeselectedImage = @"checkmark_deselected";
static NSString *const kQMCheckMarkSelectedImage = @"checkmark_selected";

@interface QMSelectableContactCell ()

@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@end

@implementation QMSelectableContactCell

+ (NSString *)cellIdentifier {
    
    return @"QMSelectableContactCell";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.checked = NO;
}

- (void)setChecked:(BOOL)checked {
    
    _checked = checked;
    self.checkmarkImageView.image = [UIImage imageNamed:checked ? kQMCheckMarkSelectedImage : kQMCheckMarkDeselectedImage];
}

@end
