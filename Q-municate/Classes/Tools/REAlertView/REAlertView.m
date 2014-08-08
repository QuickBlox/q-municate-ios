//
//  REAlertView.m
//  Q-municate
//
//  Created by Andrey Ivanov on 22.10.12.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "REAlertView.h"

@interface REAlertView ()

@property (assign, nonatomic) BOOL isDissmis;
@property (strong, nonatomic) NSMutableArray* buttonActions;

@end

@implementation REAlertView

- (id)init {
    
    self = [super init];
    if (self) {
		self.buttonActions = @[].mutableCopy;
		self.delegate = self;
    }
    return self;
}

- (void)addButtonWithTitle:(NSString *)title andActionBlock:(REAlertButtonAction)block {
    if (!block) {
         block = ^() {};
    }
	[self.buttonActions insertObject:[block copy] atIndex:[self addButtonWithTitle:title]];
}


- (void)dissmis {
    self.isDissmis = YES;
}

+ (void)presentAlertViewWithConfiguration:(REAlertConfiguration)configuration{
	REAlertView* alertView = [REAlertView new];
	configuration(alertView);

    if (alertView.isDissmis) {
        alertView.buttonActions = nil;
        return;
    }
	[alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
	REAlertView *reAlertView = (REAlertView *)alertView;
	REAlertButtonAction action = [reAlertView.buttonActions objectAtIndex:buttonIndex];
    if (action) { action();}
    self.buttonActions = nil;
}

@end
