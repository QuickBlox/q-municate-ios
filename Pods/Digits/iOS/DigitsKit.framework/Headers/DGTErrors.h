//
//  DGTErrors.h
//
//  Copyright (c) 2015 Twitter. All rights reserved.
//

/**
 *  The NSError domain of errors surfaced by Digits.
 */
FOUNDATION_EXPORT NSString * const DGTErrorDomain;

/**
 *  Error codes surfaced by the Digits kit.
 */
typedef NS_ENUM(NSInteger, DGTErrorCode) {
    /**
     *  Unspecified error.
     */
    DGTErrorCodeUnspecifiedError = 0,

    /**
     *  User canceled the Digits authentication flow.
     */
    DGTErrorCodeUserCanceledAuthentication = 1,

    /**
     * One of a few things may be happening:
     *   - The network is down.
     *   - The phone number is invalid or incomplete.
     *   - An unexpected server error occurred.
     */
    DGTErrorCodeUnableToAuthenticateNumber = 2,

    /**
     * User entered incorrect confirmation number too many times.
     */
    DGTErrorCodeUnableToConfirmNumber = 3,

    /**
     * User entered incorrect pin number too many times.
     */
    DGTErrorCodeUnableToAuthenticatePin = 4,

    /**
     * User canceled find contacts flow.
     */
    DGTErrorCodeUserCanceledFindContacts = 5,

    /**
     * User did not grant Digits access to their Address Book.
     */
    DGTErrorCodeUserDeniedAddressBookAccess = 6,

    /**
     * Failure to read from the AddressBook. 
     * When ABAddressBookCreateWithOptions fails to return a proper AddressBook.
     */
    DGTErrorCodeFailedToReadAddressBook = 7,

    /**
     * Legacy catch-all error for contact upload failure.
     */
    DGTErrorCodeUnableToUploadContacts = 8,

    /**
     * Something went wrong while deleting contacts.
     */
    DGTErrorCodeUnableToDeleteContacts = 9,

    /**
     * Something went wrong while looking up contact matches.
     */
    DGTErrorCodeUnableToLookupContactMatches = 10,

    /**
     * Something went wrong while attempting to save the user's email address
     */
    DGTErrorCodeUnableToCreateEmailAddress = 11,

    /**
     * Contact upload failed due to rate limiting
     */
    DGTErrorCodeUnableToUploadContactsRateLimit = 12,

    /**
     * Contact upload failed due to internal server error 0
     */
    DGTErrorCodeUnableToUploadContactsInternalServer0 = 13,

    /**
     * Contact upload failed due to internal server error 131
     */
    DGTErrorCodeUnableToUploadContactsInternalServer131 = 14,

    /**
     * Contact upload failed due to the server being unavailable
     */
    DGTErrorCodeUnableToUploadContactsServerUnavailable = 15,

    /**
     * Contact upload failed due to request entity being too large
     */
    DGTErrorCodeUnableToUploadContactsEntityTooLarge = 16,

    /**
     * Contact upload failed due to bad authentication data
     */
    DGTErrorCodeUnableToUploadContactsBadAuthentication = 17,

    /**
     * Contact upload failed due to out of bounds timestamp
     */
    DGTErrorCodeUnableToUploadContactsOutOfBoundsTimestamp = 18,

    /**
     * Contact upload failed due to generic bad request
     */
    DGTErrorCodeUnableToUploadContactsGenericBadRequest = 19,

    /**
     *  Unable to retrieve valid invitation data
     */
    DGTErrorCodeUnableToRetrieveValidInvitationData = 20,

    /**
     *  Unable to detect the branch SDK
     */
    DGTErrorCodeUnableToDetectBranchSDK = 21,

    /**
     *  Invalid parameter sent.
     */
    DGTErrorCodeInvalidParameter = 22
};
