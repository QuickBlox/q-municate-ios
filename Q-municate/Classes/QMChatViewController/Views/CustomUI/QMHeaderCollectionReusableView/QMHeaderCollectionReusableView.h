//
//  QMHeaderCollectionReusableView.h
//  QMChatViewController
//
//  Created by Injoit on 11/16/15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMHeaderCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

+ (UINib *)nib;
+ (NSString *)cellReuseIdentifier;

@end
