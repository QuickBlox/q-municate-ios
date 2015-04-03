//
//  QMSearchStatusCell.m
//  Q-municate
//
//  Created by Andrey Ivanov on 25.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMSearchStatusCell.h"

@interface QMSearchStatusCell()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation QMSearchStatusCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

+ (NSString *)cellIdentifier {
    
    static NSString* cellIdentifier = @"QMSearchStatusCell";
    return cellIdentifier;
}

- (void)setShowActivityIndicator:(BOOL)showActivityIndicator {
    
    if (_showActivityIndicator != showActivityIndicator) {
        
        _showActivityIndicator = showActivityIndicator;

    }
}
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (_showActivityIndicator){
        
        [self.activityIndicator startAnimating];
    }
    else {
        
        [self.activityIndicator stopAnimating];
    }
}

@end
