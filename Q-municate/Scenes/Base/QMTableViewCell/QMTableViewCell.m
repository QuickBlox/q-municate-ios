//
//  QMTableViewCell.m
//  Q-municate
//
//  Created by Andrey Ivanov on 23.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMTableViewCell.h"
#import "QMPlaceholder.h"
#import <QMImageView.h>

@interface QMTableViewCell ()

/**
 *  Outlets
 */
@property (weak, nonatomic) IBOutlet QMImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;

/**
 *  Cached values
 */
@property (assign, nonatomic) NSUInteger placeholderID;
@property (strong, nonatomic) NSString *avatarUrl;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *body;

@end

@implementation QMTableViewCell

+ (void)registerForReuseInTableView:(UITableView *)tableView {
    
    NSString *nibName = NSStringFromClass(self.class);
    UINib *nib = [UINib nibWithNibName:nibName bundle:NSBundle.mainBundle];
    NSParameterAssert(nib);
    
    NSString *cellIdentifier = [self cellIdentifier];
    NSParameterAssert(cellIdentifier);
    
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
}

+ (NSString *)cellIdentifier {
    
    return NSStringFromClass([self class]);
}

+ (CGFloat)height {
    return 0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _avatarImage.imageViewType = QMImageViewTypeCircle;
    _titleLabel.text = nil;
    _bodyLabel.text = nil;
}

#pragma mark - Setters

- (void)setTitle:(NSString *)title placeholderID:(NSUInteger)placeholderID avatarUrl:(NSString *)avatarUrl {
    
    if (![_title isEqualToString:title]) {
        
        _title = title;
        self.titleLabel.text = title;
    }
    
    if (_placeholderID != placeholderID || ![_avatarUrl isEqualToString:avatarUrl]) {
        
        _placeholderID = placeholderID;
        
        _avatarUrl = avatarUrl;
        
        UIImage *placeholder = [QMPlaceholder placeholderWithFrame:self.avatarImage.bounds title:self.title ID:self.placeholderID];
        
        [self.avatarImage setImageWithURL:[NSURL URLWithString:avatarUrl]
                              placeholder:placeholder
                                  options:SDWebImageLowPriority
                                 progress:nil
                           completedBlock:nil];
    }
}

- (void)setTitle:(NSString *)title {
    
    if (![_title isEqualToString:title]) {
        
        _title = title;
        self.titleLabel.text = title;
    }
}

- (void)setBody:(NSString *)body {
    
    if (![_body isEqualToString:body]) {
        
        _body = body;
        self.bodyLabel.text = body;
    }
}

@end
