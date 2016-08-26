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
    
    static QMPlaceholder *userPlaceholder = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        userPlaceholder = [[QMPlaceholder alloc] init];
    });
    
    return userPlaceholder;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _cache = [[NSCache alloc] init];
        _cache.name = @"QMUserPlaceholer.cache";
        _cache.countLimit = 200;
        
        _colors =
        @[[UIColor colorWithRed:1.0f green:0.588f blue:0 alpha:1.0f],
          [UIColor colorWithRed:0.267f green:0.859f blue:0.369f alpha:1.0f],
          [UIColor colorWithRed:0.329f green:0.780f blue:0.988f alpha:1.0f],
          [UIColor colorWithRed:1.0f green:0.176f blue:0.333f alpha:1.0f],
          [UIColor colorWithRed:0.608f green:0.184f blue:0.682f alpha:1.0f],
          [UIColor colorWithRed:0.082f green:0.584f blue:0.533f alpha:1.0f],
          [UIColor colorWithRed:0 green:0.478f blue:1.0f alpha:1.0f],
          [UIColor colorWithRed:0.804f green:0.855f blue:0.286f alpha:1.0f],
          [UIColor colorWithRed:0.122f green:0.737f blue:0.823f alpha:1.0f],
          [UIColor colorWithRed:0.251f green:0.329f blue:0.698f alpha:1.0f]];
    }
    
    return self;
}

+ (UIImage *)placeholderWithFrame:(CGRect)frame
                            title:(NSString *)title
                               ID:(NSUInteger)ID
{
    
    NSString *key = [NSString stringWithFormat:@"%@ %@", title, NSStringFromCGSize(frame.size)];
    
    UIImage *image = [[[[self class] instance] cache] objectForKey:key];
    
    if (image) {
        
        return image;
    }
    else {
        
        UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0);
        //// Oval Drawing
        UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:frame];
        
        UIColor *userColor = [[[self class] instance] colors][ID % 10];
        [userColor setFill];
        [ovalPath fill];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        UIFont *font = [UIFont systemFontOfSize:frame.size.height / 2.0f];
        UIColor *textColor = [UIColor whiteColor];
        
        NSString *textContent = [title substringToIndex:1].uppercaseString;
        
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
        
        if (ovalImage != nil && key != nil) {
            
            [[[[self class] instance] cache] setObject:ovalImage forKey:key];
        }
        
        return ovalImage;
    }
    
    return image;
}

@end
