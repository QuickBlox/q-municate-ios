//
//  DGTContactsInvitationDataSource.h
//  DigitsKit
//
//  Copyright © 2016 Twitter Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGTContactsFetcher.h"

@class DGTConfigurableTableViewCell;
@class DGTAddressBookContact;
@class DGTContactsInvitationDataSource;

NS_ASSUME_NONNULL_BEGIN

@protocol DGTContactsInvitationDataSourceDelegate <NSObject>

@optional

/**
 *  Implement this method if you require additional steps that are outside the
 *  scope of overriding the configure method on DGTConfigurableTableViewCell.
 */
- (void)contactsInvitationDataSource:(DGTContactsInvitationDataSource *)dataSource
                    configurableCell:(DGTConfigurableTableViewCell *)cell
                   forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

/**
 *  A drop-in class that conforms to and implements the required UITableViewDataSource protocol
 *  methods using a generic DGTConfigurableCell.
 */
@interface DGTContactsInvitationDataSource : NSObject <UITableViewDataSource>

/**
 *  A reference the the class type. The class must be a kind of DGTConfigurableTableViewCell.
 *  Only one of the cellClass or cellNibName can be set, not both.
 */
@property (nonatomic, strong, nullable) Class cellClass;

/**
 *  A reference to a UITableView that uses this class as a UITableViewDataSource.
 *  This must be set in order to use this class as a drop in for UITableViewDataSource.
 */
@property (nonatomic, strong, nullable) UITableView *tableView;

/**
 *  Responsible for fetching address book data and their current state.
 */
@property (nonatomic, strong) DGTContactsFetcher *contactsFetcher;

/**
 *  Currently the delegate only has on protocol to conform to if additional functionality
 *  is required when using a DGTConfigurableTableViewCell.
 */
@property (nonatomic, weak) id<DGTContactsInvitationDataSourceDelegate> delegate;

/**
 *  Returns an instance of a DGTContactsInvitationDataSource or nil if there is no current digits session. 
 *  This is used as a drop in for UITableViewDataSource.
 */
- (instancetype)init;

/**
 *  Returns the associated address book contact for the given index path. This method
 *  returns nil if the index is out of bounds.
 *
 *  @param index An index within the range of the contacts array.
 */
- (DGTAddressBookContact *)contactAtIndex:(NSInteger)index;

/**
 *  Fetches a list of contacts from the address book and their states from the digits api.
 *  The result is stored in contacts after the fetch request is made and the same data is
 *  also available in the parameters of DGTContactFetchCompletionBlock. The contacts
 *  parameter in DGTContactFetchCompletionBlock contains a list of contacts with either
 *  a pending, in app or invitable state. If the user has not granted contacts permissions,
 *  the completion block will pass back an error. The completion block is invoked on the main queue.
 *
 *  @param shouldFetchInAppContactsOnly (required) A boolean flag that determines if only in app contacts
 *  should be fetched.
 */
- (void)fetchContactsOnlyInApp:(BOOL)shouldFetchInAppContactsOnly
                withCompletion:(DGTContactFetchCompletionBlock)completion;

/**
 *  Implementation of tableView:cellForRowAtIndexPath: UITableViewDataSource method. 
 *  Override this to implement more custom logic with cell configuration.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Implementation of tableView:numberOfRowsInSection: UITableViewDataSource method. 
 *  Override this to implement more custom logic with multiple sections and data sources.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;


@end

NS_ASSUME_NONNULL_END
