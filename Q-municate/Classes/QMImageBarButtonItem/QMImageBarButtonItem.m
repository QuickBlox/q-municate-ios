
//
//  QMImageBarButtonItem.m
//  Q-municate
//
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMImageBarButtonItem.h"
#import "QMImageView.h"

@interface QMImageBarButtonItem() <QMImageViewDelegate> {
    BOOL _hasConstraints;
}

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
    if (iosMajorVersion() >= 11) {
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
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
    
    _imageView.frame = (CGRect) {
        .origin = _imageView.frame.origin,
        .size = CGSizeMake(size.width, size.height)
    };
    
    // Autolayout is available for UIBarButtonItem from iOS 11
    if (iosMajorVersion() >= 11) {
        
        if (!_hasConstraints) {
            
            _imageViewWidthConstraint = [_imageView.widthAnchor constraintEqualToConstant:size.width];
            _imageViewWidthConstraint.active = YES;
            
            _imageViewHeightConstraint  = [_imageView.heightAnchor constraintEqualToConstant:size.height];
            _imageViewHeightConstraint.active = YES;
            
            _hasConstraints = YES;
        }
        else {
            _imageViewWidthConstraint.constant = size.width;
            _imageViewHeightConstraint.constant = size.height;
        }
    }
}

- (CGSize)size {
    return _imageView.frame.size;
}

@end
