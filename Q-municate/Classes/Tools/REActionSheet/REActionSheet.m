//
//  REActionSheet.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.08.14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "REActionSheet.h"

@interface REActionSheet()

<UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableArray* buttonActions;

@end

@implementation REActionSheet

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (id)init {
    
    self = [super init];
    if (self) {
        
		self.buttonActions = @[].mutableCopy;
		self.delegate = self;
    }
    
    return self;
}

+ (void)presentActionSheetInView:(UIView *)view configuration:(REActionSheetBlock)configuration {
    
	REActionSheet* actionSheet = [[REActionSheet alloc] init];
	configuration(actionSheet);
	[actionSheet showInView:view];
}

- (void)addButtonWithTitle:(NSString *)title andActionBlock:(REActionSheetButtonAction)block {
    
	[self.buttonActions insertObject:[block copy] atIndex:[self addButtonWithTitle:title]];
}

- (void)addDestructiveButtonWithTitle:(NSString *)title andActionBlock:(REActionSheetButtonAction)block {
    
    NSUInteger index = [self addButtonWithTitle:title];
    [self.buttonActions insertObject:[block copy] atIndex:index];
    self.destructiveButtonIndex = index;
}

- (void)addCancelButtonWihtTitle:(NSString *)title andActionBlock:(REActionSheetButtonAction)block {
    
    NSUInteger index = [self addButtonWithTitle:title];
    [self.buttonActions insertObject:[block copy] atIndex:index];
    self.cancelButtonIndex = index;
}

#pragma mark - UIAlertViewDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    REActionSheet* tActionSheet = (REActionSheet *)actionSheet;
	REActionSheetButtonAction action = [tActionSheet.buttonActions objectAtIndex:buttonIndex];

	action();
    tActionSheet.buttonActions = nil;
}

@end
