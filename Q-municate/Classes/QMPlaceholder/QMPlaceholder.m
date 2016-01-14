//
//  QMPlaceholder.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/14/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMPlaceholder.h"

@interface QMPlaceholder()

@property (strong, nonatomic) NSCache *cache;
@property (strong, nonatomic) NSArray *colors;

@end

@implementation QMPlaceholder

+ (instancetype)instance {
    
    static QMPlaceholder *_userPlaceholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _userPlaceholder = [[QMPlaceholder alloc] init];
    });
    
    return _userPlaceholder;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.cache = [[NSCache alloc] init];
        self.cache.name = @"QMUserPlaceholer.cache";
        self.cache.countLimit = 200;
        
        self.colors =
        @[[UIColor colorWithRed:1.000 green:0.588 blue:0.000 alpha:1.000],
          [UIColor colorWithRed:0.267 green:0.859 blue:0.369 alpha:1.000],
          [UIColor colorWithRed:0.329 green:0.780 blue:0.988 alpha:1.000],
          [UIColor colorWithRed:1.000 green:0.176 blue:0.333 alpha:1.000],
          [UIColor colorWithRed:0.608 green:0.184 blue:0.682 alpha:1.000],
          [UIColor colorWithRed:0.082 green:0.584 blue:0.533 alpha:1.000],
          [UIColor colorWithRed:0.000 green:0.478 blue:1.000 alpha:1.000],
          [UIColor colorWithRed:0.804 green:0.855 blue:0.286 alpha:1.000],
          [UIColor colorWithRed:0.122 green:0.737 blue:0.823 alpha:1.000],
          [UIColor colorWithRed:0.251 green:0.329 blue:0.698 alpha:1.000]];
    }
    
    return self;
}

+ (UIImage *)placeholderWithFrame:(CGRect)frame
                            title:(NSString *)title
                           userID:(NSUInteger)userID
{
    
    NSString *key = [NSString stringWithFormat:@"%@ %@", title, NSStringFromCGSize(frame.size)];
    
    UIImage *image = [[QMPlaceholder instance].cache objectForKey:key];
    
    if (image) {
        
        return image;
    } else {
        
        UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0);
        //// Oval Drawing
        UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:frame];
        
        UIColor *userColor = [QMPlaceholder instance].colors[userID % 10];
        [userColor setFill];
        [ovalPath fill];
        
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        UIFont *font = [UIFont systemFontOfSize:frame.size.height / 2.0f];
        UIColor *textColor = [UIColor whiteColor];
        
        NSString *textContent = [[title substringToIndex:1] uppercaseString];
        
        NSDictionary *ovalFontAttributes = @{NSFontAttributeName:font ,
                                             NSForegroundColorAttributeName:textColor,
                                             NSParagraphStyleAttributeName:paragraphStyle};
        
        CGRect rect = [textContent boundingRectWithSize:frame.size
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:ovalFontAttributes context:nil];
        
        CGRect textRect = CGRectOffset(frame,
                                       0,
                                       (frame.size.height - rect.size.height) / 2);
        [textContent drawInRect:textRect withAttributes: ovalFontAttributes];
        //Get image
        UIImage *ovalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return ovalImage;
    }
    
    return image;
}

@end
