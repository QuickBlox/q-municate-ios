//
//  QMShareCollectionViewCell.m
//  QMShareExtension
//
//  Created by Injoit on 10/9/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMShareCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "QMImageView.h"
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

@interface QMShareCollectionViewCell() <QMImageViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;
@property (weak, nonatomic) IBOutlet QMImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation QMShareCollectionViewCell
@synthesize checked = _checked;

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.avatarImage.delegate = self;
    self.avatarImage.imageViewType = QMImageViewTypeCircle;
    self.checkmarkImageView.image = deselectedCheckImage();
    self.checkmarkImageView.hidden = YES;
}

- (void)setChecked:(BOOL)checked {
    
    if (_checked != checked) {
        
        _checked = checked;
        self.checkmarkImageView.hidden = !checked;
        self.checkmarkImageView.image = checked ? selectedCheckImage() : deselectedCheckImage();
    }
}

- (void)setTitle:(NSString *)title
       avatarUrl:(NSString *)avatarUrl {
    
    self.titleLabel.text = title;
    
    NSURL *url = [NSURL URLWithString:avatarUrl];
    [self.avatarImage setImageWithURL:url
                                title:title
                       completedBlock:nil];
    
}

- (void)imageViewDidTap:(QMImageView *)imageView {
    if (self.tapBlock) {
        self.tapBlock(self);
    }
}

- (void)setChecked:(BOOL)checked animated:(BOOL)animated {
    
    if (_checked != checked) {
        
        self.checked = checked;
        self.checkmarkImageView.hidden = !checked;
        if (animated) {
            
            CATransition *transition = [CATransition animation];
            transition.duration = kQMBaseAnimationDuration;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            
            [self.checkmarkImageView.layer addAnimation:transition forKey:nil];
        }
    }
}

+ (NSString *)cellIdentifier {
    
    return NSStringFromClass([self class]);
}

+ (void)registerForReuseInView:(UIView *)viewForReuse {
    
    NSString *nibName = NSStringFromClass([self class]);
    UINib *nib = [UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]];
    NSParameterAssert(nib);
    
    NSString *cellIdentifier = [self cellIdentifier];
    NSParameterAssert(cellIdentifier);
    NSParameterAssert([viewForReuse isKindOfClass:UICollectionView.class]);
    
    UICollectionView *collectionView = (UICollectionView *)viewForReuse;
    [collectionView registerNib:nib
     forCellWithReuseIdentifier:cellIdentifier];
}

@end
