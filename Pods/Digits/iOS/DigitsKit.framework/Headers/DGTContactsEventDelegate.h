//
//  DGTContactsEventDelegate.h
//  DigitsKit
//
//  Copyright © 2016 Twitter Inc. All rights reserved.
//
//  DGTContactsEventDelegate is a protocol that allows app using digits sdk to listen and get notified about
//  contacts related events. It defines a number of optional methods as the callbacks to be triggered when
//  corresponding events occur.
//
//  To use it, make a class implementing this protocol (on selected callbacks) and set the contactsEventDelegate property
//  on [Digits sharedInstance]
//
//  Notice that the purpose of these callbacks are for notifications, not for flow controls. So app related logging/stats would
//  be good fit for the processing in these callbacks. Executions of these callback events will be dispatched to a non ios main
//  queue/thread (created by digits sdk) to follow the best practice. As a result, these callbacks shold not do any UI related
//  operations.
//
//  For each callback event, there is an associated event detail parameter, whose type is defined as a protocol. They
//  provide additional data regarding the event. Some of these event parameter protocols are as of now empty without any methods
//  they are defined to be a placeholder so that we can add data to these types in the future.
//
//  This feature is in beta release which means the interface can have breaking changes
//  in the future


#import <Foundation/Foundation.h>

#import "DGTErrors.h"

@protocol ContactsPermissionForDigitsImpressionDetails <NSObject>
@end

@protocol ContactsPermissionForDigitsAllowedDetails <NSObject>
@end

@protocol ContactsPermissionForDigitsDeferredDetails <NSObject>
@end

@protocol ContactsUploadStartDetails <NSObject>
@end

@protocol ContactsUploadSuccessDetails <NSObject>
// return the number of contacts the app tries to upload
- (int)totalContactsCount;
// return the number of contacts that are uploaded successfully
- (int)successContactsUploadCount;
@end

@protocol ContactsUploadFailureDetails <NSObject>
// return error code (defined in DGTErrorCode) for encountered failure during contacts upload
- (DGTErrorCode) errorCode;
@end

@protocol ContactsLookupStartDetails <NSObject>
// whether this is a lookup query with a non-nil cursor
- (BOOL)hasCursor;
@end

@protocol ContactsLookupSuccessDetails <NSObject>
// how many contacts matches are found in this query
- (int)matchCount;
@end

@protocol ContactsLookupFailureDetails <NSObject>
@end

@protocol ContactsDeletionStartDetails <NSObject>
@end

@protocol ContactsDeletionSuccessDetails <NSObject>
@end

@protocol ContactsDeletionFailureDetails <NSObject>
@end

@protocol ContactsInvitationDetails <NSObject>
@end

// external facing logger protocol for contacts related events
@protocol DGTContactsEventDelegate <NSObject>
@optional

/**
 *  Called when the contacts read permission screen is displayed.
 */
- (void)contactsPermissionForDigitsImpression:(id<ContactsPermissionForDigitsImpressionDetails>)details;

/**
 *  Called when the users allows read permission on the address book read permission screen.
 */
- (void)contactsPermissionForDigitsAllowed:(id<ContactsPermissionForDigitsAllowedDetails>)details;

/**
 *  Called when the users rejects read permission on the address book read permission screen.
 */
- (void)contactsPermissionForDigitsDeferred:(id<ContactsPermissionForDigitsDeferredDetails>)details;


/**
 *  Called when sdk starts to upload user contacts.
 */
- (void)contactsUploadStart:(id<ContactsUploadStartDetails>)details;

/**
 *  Called when we see a full success or partial success ( have >= 1 records uploaded successfully) of the 
 *  contacts upload operation.
 *  The event parameter type ContactsUploadSuccessDetails allows you to tell how many actually succeeded
 */
- (void)contactsUploadSuccess:(id<ContactsUploadSuccessDetails>)details;

/**
 *  Called when we see a full failure in sdk's contacts upload attempt: 0 contact is uploaded successfully.
 *  Notice that for partial upload success case, only contactsUploadSuccess is triggered
 */
- (void)contactsUploadFailure:(id<ContactsUploadFailureDetails>)details;

/**
 *  Called when sdk starts to fetch next page of contacts matches.
 */
- (void)contactsLookupStart:(id<ContactsLookupStartDetails>)details;

/**
 *  Called when we see contacts match query for the current page succeed. It's possible that the matchCount is
 *  0 in such an event
 */
- (void)contactsLookupSuccess:(id<ContactsLookupSuccessDetails>)details;

/**
 *  Called when we see a failure of contacts lookup request
 */
- (void)contactsLookupFailure:(id<ContactsLookupFailureDetails>)details;

/**
 *  Called when sdk starts to delete user uploaded contacts
 */
- (void)contactsDeletionStart:(id<ContactsDeletionStartDetails>)details;

/**
 *  Called the contacts deletion is successful
 */
- (void)contactsDeletionSuccess:(id<ContactsDeletionSuccessDetails>)details;

/**
 *  Called when we see a failure of contacts deletion operation
 */
- (void)contactsDeletionFailure:(id<ContactsDeletionFailureDetails>)details;

- (void)contactsInvitationImpression:(id<ContactsInvitationDetails>)details;
@end
