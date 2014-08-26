//
//  QMMessageBarStyleSheetFactory.m
//  Q-municate
//
//  Created by Andrey Ivanov on 07.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMMessageBarStyleSheetFactory.h"

@interface QMMessageBarStyleSheet : NSObject <TWMessageBarStyleSheet>

@property (strong, nonatomic) UIColor *bgColor;
@property (strong, nonatomic) UIColor *strokeColor;
@property (strong, nonatomic) UIImage *icon;

- (UIColor *)backgroundColorForMessageType:(TWMessageBarMessageType)type;
- (UIColor *)strokeColorForMessageType:(TWMessageBarMessageType)type;
- (UIImage *)iconImageForMessageType:(TWMessageBarMessageType)type;

@end

@implementation QMMessageBarStyleSheet

- (instancetype)initWithBGColor:(UIColor *)bg strokeColor:(UIColor *)strokeColor icon:(UIImage *)icon {
    
    self = [super init];
    if (self) {
        
        self.bgColor = bg;
        self.strokeColor = strokeColor;
        self.icon = icon;
    }
    
    return self;
}

- (UIColor *)backgroundColorForMessageType:(TWMessageBarMessageType)type {
    return self.bgColor;
}

- (UIColor *)strokeColorForMessageType:(TWMessageBarMessageType)type {
    return self.strokeColor;
}

- (UIImage *)iconImageForMessageType:(TWMessageBarMessageType)type {
    return self.icon;
}

@end

@implementation QMMessageBarStyleSheetFactory

+ (NSObject <TWMessageBarStyleSheet> *)defaultMsgBarWithImage:(UIImage *)img {
    
    QMMessageBarStyleSheet *defSheet =
    [[QMMessageBarStyleSheet alloc] initWithBGColor:[UIColor colorWithRed:0.000 green:0.793 blue:0.357 alpha:1.000]
                                        strokeColor:[UIColor colorWithRed:0.413 green:0.695 blue:0.996 alpha:1.000]
                                               icon:img];
    return defSheet;
}



@end
