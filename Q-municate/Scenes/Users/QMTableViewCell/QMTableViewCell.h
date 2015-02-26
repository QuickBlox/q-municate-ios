//
//  QMTableViewCell.h
//  Q-municate
//
//  Created by Andrey Ivanov on 11.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QMImageView;

@interface QMTableViewCell : UITableViewCell 

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet QMImageView *qmImageView;

- (void)setUserImageWithUrl:(NSURL *)userImageUrl;
- (void)setUserImage:(UIImage *)image withKey:(NSString *)key;

@end
