//
//  QMImagePreview.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 8/30/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMImageView;

@interface QMImagePreview : NSObject

+ (void)previewImageView:(QMImageView *)imageView inViewController:(UIViewController *)ivc;

@end
