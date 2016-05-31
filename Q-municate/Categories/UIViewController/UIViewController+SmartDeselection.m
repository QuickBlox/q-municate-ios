//
//  UIViewController+SmartDeselection.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/31/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "UIViewController+SmartDeselection.h"

@implementation UIViewController (SmartDeselection)

- (void)qm_smoothlyDeselectRowsForTableView:(UITableView *)tableView {
    
    // Get the initially selected index paths, if any
    NSArray *selectedIndexPaths = tableView.indexPathsForSelectedRows;
    if (selectedIndexPaths == nil) {
        
        return;
    }
    
    // Grab the transition coordinator responsible for the current transition
    if (self.transitionCoordinator != nil) {
        
        // Animate alongside the master view controller's view
        UIView *view = nil;
        
        if (self.parentViewController != nil) {
            
            view = self.parentViewController.view;
        }
        
        [self.transitionCoordinator animateAlongsideTransitionInView:view animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            
            // Deselect the cells, with animations enabled if this is an animated transition
            for (NSIndexPath *indexPath in selectedIndexPaths) {
                
                [tableView deselectRowAtIndexPath:indexPath animated:[context isAnimated]];
            }
            
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            
            // If the transition was cancel, reselect the rows that were selected before,
            // so they are still selected the next time the same animation is triggered
            if ([context isCancelled]) {
                
                for (NSIndexPath *indexPath in selectedIndexPaths) {
                    
                    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
        }];
    }
    // If this isn't a transition coordinator, just deselect the rows without animating
    else {
        
        for (NSIndexPath *indexPath in selectedIndexPaths) {
            
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
}

@end
