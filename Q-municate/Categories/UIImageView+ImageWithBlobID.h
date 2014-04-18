//
//  UIImageView+ImageWithBlobID.h
//  Q-municate
//
//  Created by Igor Alefirenko on 25/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (ImageWithBlobID) <QBActionStatusDelegate>

- (void)loadImageWithBlobID:(NSUInteger)blobID;

@end
