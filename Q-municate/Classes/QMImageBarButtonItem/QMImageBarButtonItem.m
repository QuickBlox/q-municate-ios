//
//  QMImageBarButtonItem.m
//  Q-municate
//
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMImageBarButtonItem.h"

@interface QMImageBarButtonItem() <QMImageViewDelegate>

@property (nonatomic, strong, readwrite) QMImageView *imageView;
@property (nonatomic, weak)  NSLayoutConstraint *imageViewHeightConstraint;
@property (nonatomic, weak)  NSLayoutConstraint *imageViewWidthConstraint;

@end

@implementation QMImageBarButtonItem

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        [self configureCustomView];
    }
    return self;
}


- (instancetype)initWithSize:(CGSize)size {
    
    if (self = [super init]) {
        
        [self configureCustomView];
        self.size = size;
    }
    return self;
}



- (instancetype)init {
    
    if (self = [super init]) {
        [self configureCustomView];
    }
    return self;
}

- (void)configureCustomView {
    
    self.imageView = [[QMImageView alloc] init];
    self.imageView.imageViewType = QMImageViewTypeCircle;
    self.imageView.delegate = self;
    
    self.customView = self.imageView;
    
    // Autolayout is available for UIBarButtonItem from iOS 11
    if (@available(iOS 11, *)) {
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:0];
        
        [self.imageView addConstraint:self.imageViewHeightConstraint];
        
        self.imageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0
                                                                      constant:0];
        
        [self.imageView addConstraint:self.imageViewWidthConstraint];
    }
    
}


- (void)imageViewDidTap:(QMImageView *)imageView {
    
    if (self.onTapHandler) {
        self.onTapHandler(imageView);
    }
}

- (void)setImageWithURL:(NSURL *)imageURL
                  title:(NSString *)title {
    [self.imageView setImageWithURL:imageURL
                              title:title
                     completedBlock:nil];
}

- (void)setSize:(CGSize)size {
    
    // Autolayout is available for UIBarButtonItem from iOS 11
    if (@available(iOS 11, *)) {
        _imageViewWidthConstraint.constant = size.width;
        _imageViewHeightConstraint.constant = size.height;
    }
    else {
        _imageView.frame = CGRectMake(0, 0, size.width, size.height);
    }
}

- (CGSize)size {
    
    if (@available(iOS 11, *)) {
        return CGSizeMake
        (_imageViewWidthConstraint.constant,
         _imageViewHeightConstraint.constant);
    }
    else {
        _imageView.frame.size;
    }
}

@end
