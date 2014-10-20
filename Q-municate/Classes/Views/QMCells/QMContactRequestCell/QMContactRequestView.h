//
//  QMContactRequestView.h
//  Q-municate
//
//  Created by Igor Alefirenko on 28/08/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMImageView;


@interface QMContactRequestView : UIView <QMUsersListDelegate>

@property (nonatomic, weak) id <QMUsersListDelegate> delegate;

@property (strong, nonatomic) id userData;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet QMImageView *qmImageView;

- (void)setUserImageWithUrl:(NSURL *)userImageUrl;
- (void)setUserImage:(UIImage *)image withKey:(NSString *)key;

@end
