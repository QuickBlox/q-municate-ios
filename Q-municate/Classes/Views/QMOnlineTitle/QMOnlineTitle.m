//
//  QMOnlineTitle.m
//  Q-municate
//
//  Created by Andrey Ivanov on 14.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMOnlineTitle.h"

@implementation QMOnlineTitle

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    self.frame.size.width,
                                                                    self.frame.size.height/2)];
        self.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor blackColor];

        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                     self.frame.size.height/2,
                                                                     self.frame.size.width,
                                                                     self.frame.size.height/2)];
        self.statusLabel.font = [UIFont systemFontOfSize:11.0f];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        self.statusLabel.textColor = [UIColor colorWithRed:143.0f/255.0f green:142.0f/255.0f blue:148.0f/255.0f alpha:1.0f];
        self.statusLabel.text = @"Offline";
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.statusLabel];
    }
    
    return self;
}

@end
