//
//  QMSearchController.h
//  Q-municate
//
//  Created by Andrey Ivanov on 26.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

@import Foundation;
@import UIKit;

@protocol QMSearchControllerDelegate;
@protocol QMSearchResultsUpdating;
/*
 * UISearchDisplayController is deprecated in iOS 8.
 * (Note that UISearchDisplayDelegate is also deprecated.)
 * To manage the presentation of a search bar and display
 * search results in iOS 8 and later, instead use UISearchController.
 */
@interface QMSearchController : NSObject

- (instancetype)initWithContentsController:(UIViewController *)viewController;

@property(assign, nonatomic, readonly, getter=isActive) BOOL active;

@property (weak, nonatomic) id <QMSearchControllerDelegate> delegate;
@property (weak, nonatomic) id <QMSearchResultsUpdating> searchResultsUpdater;

@property(weak, nonatomic) id <UITableViewDataSource> searchResultsDataSource;
@property(weak, nonatomic) id <UITableViewDelegate> searchResultsDelegate;

@property(weak, nonatomic, readonly) UISearchBar *searchBar;
@property(weak, nonatomic, readonly) UITableView *searchResultsTableView;

@end

@protocol QMSearchResultsUpdating <NSObject>
@required
/**
 * Called when the search bar's text or scope has changed or
 * when the search bar becomes first responder.
 */
- (void)updateSearchResultsForSearchController:(QMSearchController *)searchController;

@end

@protocol QMSearchControllerDelegate <NSObject>
@optional
/**
 * These methods are called when automatic presentation or dismissal occurs.
 * They will not be called if you present or dismiss the search controller yourself.
 */
- (void)willPresentSearchController:(QMSearchController *)searchController;
- (void)didPresentSearchController:(QMSearchController *)searchController;
- (void)willDismissSearchController:(QMSearchController *)searchController;
- (void)didDismissSearchController:(QMSearchController *)searchController;

/**
 * Called after the search controller's search bar has agreed to begin editing or when 'active'
 * is set to YES. If you choose not to present the controller yourself or do not implement this
 * method, a default presentation is performed on your behalf.
 */
- (void)presentSearchController:(QMSearchController *)searchController;

@end
