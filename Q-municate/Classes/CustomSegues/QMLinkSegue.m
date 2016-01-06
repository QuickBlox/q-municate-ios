//
//  QMLinkSegue.m
//  Q-municate
//
//  Created by Andrey Ivanov on 28.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMLinkSegue.h"
#import "QMLinkViewController.h"

@interface QMLinkSegue()

@property (assign, nonatomic) BOOL modal;

@end

@implementation QMLinkSegue

- (instancetype)initWithIdentifier:(NSString *)identifier
                            source:(UIViewController *)source
                       destination:(UIViewController *)destination {
    
    QMLinkViewController *link = (id)destination;
    BOOL modal = NO;
    
    UIViewController *newDestination = nil;
    // load the user-defined runtime attributes.
    NSString * storyboardName = link.storyboardName;
    NSString * storyboardID = link.sceneIdentifier;
    modal = link.modal;
    
    NSAssert(storyboardName, @"Unable to load linked storyboard. QMLinkViewController storyboardName is nil. Forgot to set attribute in interface builder?");
    
    // Creates new destination.
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    
    if ([storyboardID length] == 0) {
        
        newDestination = [storyboard instantiateInitialViewController];
    }
    else {
        
        newDestination = [storyboard instantiateViewControllerWithIdentifier:storyboardID];
    }
    
    self = [super initWithIdentifier:identifier source:source destination:newDestination];
    
    if (self) {
        
        self.modal = modal;
    }
    
    return self;
}

- (void)perform {
    
    UIViewController *source = (UIViewController *)self.sourceViewController;
    
    if (!self.modal) {
        
        [source.navigationController pushViewController:self.destinationViewController
                                               animated:YES];
    }
    else {
        
        [source presentViewController:self.destinationViewController
                             animated:YES
                           completion:nil];
    }
}

@end
