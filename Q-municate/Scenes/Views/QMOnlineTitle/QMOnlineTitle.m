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
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor whiteColor];

        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                     self.frame.size.height/2,
                                                                     self.frame.size.width,
                                                                     self.frame.size.height/2)];
        self.statusLabel.font = [UIFont systemFontOfSize:14];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        self.statusLabel.textColor = [UIColor colorWithWhite:1.000 alpha:0.760];
        self.statusLabel.text = @"Offline";
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.statusLabel];
    }
    
    return self;
}

@end
