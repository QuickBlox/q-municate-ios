//
//  QMPhoto.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NYTPhoto.h>

@interface QMPhoto : NSObject <NYTPhoto>

@property (strong, nonatomic, readwrite) UIImage *image;
@property (strong, nonatomic, readwrite) NSData *imageData;
@property (strong, nonatomic, readwrite) UIImage *placeholderImage;
@property (strong, nonatomic, readwrite) NSAttributedString *attributedCaptionTitle;
@property (strong, nonatomic, readwrite) NSAttributedString *attributedCaptionSummary;
@property (strong, nonatomic, readwrite) NSAttributedString *attributedCaptionCredit;

@end
