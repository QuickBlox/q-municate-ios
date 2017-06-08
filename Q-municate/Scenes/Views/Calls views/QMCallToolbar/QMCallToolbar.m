//
//  QMCallToolbar.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMCallToolbar.h"

@interface QMCallToolbar ()

@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) NSMutableArray *actions;

@end

@implementation QMCallToolbar

//MARK: - Construction

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    
    _buttons = [NSMutableArray array];
    _actions = [NSMutableArray array];
    
    [self setBackgroundImage:[[UIImage alloc] init]
          forToolbarPosition:UIToolbarPositionAny
                  barMetrics:UIBarMetricsDefault];
    
    [self setShadowImage:[[UIImage alloc] init]
      forToolbarPosition:UIToolbarPositionAny];
}

//MARK: - Methods

- (void)addButton:(UIButton *)button action:(void (^)(UIButton *sender))action {
    
    [button addTarget:self
               action:@selector(pressButton:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.buttons addObject:button];
    [self.actions addObject:[action copy]];
}
- (void)removeButton:(UIButton *)button {
     NSUInteger idx = [self.buttons indexOfObject:button];
    [self.buttons removeObjectAtIndex:idx];
}
- (void)updateItemsDisplay {
    
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.items];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                        target:nil
                                                                        action:nil];
    for (UIButton *button in [self.buttons copy]) {
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        [items addObject:space];
        [items addObject:item];
    }
    
    [items addObject:space];
    [self setItems:[items copy]];
}

//MARK: - Button handler

- (void)pressButton:(UIButton *)button {
    
    NSUInteger idx = [self.buttons indexOfObject:button];
    
    void(^action)(UIButton *sender) = self.actions[idx];
    action(button);
}

@end
