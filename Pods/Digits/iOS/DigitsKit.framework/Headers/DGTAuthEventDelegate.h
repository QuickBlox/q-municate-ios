//
//  DGTAuthEventDelegate.h
//  DigitsKit
//
//  Copyright © 2016 Twitter Inc. All rights reserved.
//
//  DGTAuthEventDelegate is a protocol that allows app using digits sdk to listen and get notified about
//  login/signup related events. It defines a number of optional methods as the callbacks to be triggered when
//  corresponding events occur.
//
//  To use it, make a class implementing this protocol (on selected callbacks) and set the authEventDelegate property
//  on [Digits sharedInstance]
//
//  Notice that the purpose of these callbacks are for notifications, not for flow controls. So app related logging/stats would
//  be good fit for the processing in these callbacks. Executions of these callback events will be dispatched to a non ios main
//  queue/thread (created by digits sdk) to follow the best practice. As a result, these callbacks shold not do any UI related
//  operations.
//
//  This feature is in beta release which means the interface can have breaking changes
//  in the future

@class DGTAuthEventDetails;

@protocol DGTAuthEventDelegate <NSObject>

@optional

/**
 *  Called when the Digits authentication flow starts.
 */
- (void)digitsAuthenticationDidBegin:(DGTAuthEventDetails *)authEventDetails;

/**
 *  Called as soon as the phone number screen appears.
 */
- (void)digitsPhoneNumberEntryScreenVisited:(DGTAuthEventDetails *)authEventDetails;

/**
 *  Called each time a phone number is submitted to Digits.
 */
- (void)digitsPhoneNumberSubmitted:(DGTAuthEventDetails *)authEventDetails;

/**
 *  Called when the phone number is accepted by Digits. This is an indication that we were able to successfully send a confirmation code to the end-user.
 */
- (void)digitsPhoneNumberSubmissionDidSucceed:(DGTAuthEventDetails *)authEventDetails;

/**
 *  Called as soon as the confirmation screen appears.
 */
- (void)digitsConfirmationCodeEntryScreenVisited:(DGTAuthEventDetails *)authEventDetails;

/**
 *  Called each time a confirmation code is submitted to Digits.
 */
- (void)digitsConfirmationCodeSubmitted:(DGTAuthEventDetails *)authEventDetails;

/**
 *  Called when the whole authentication flow succeesfully finishes.
 */
- (void)digitsAuthenticationDidComplete:(DGTAuthEventDetails *)authEventDetails;

/**
 *  Called if the -[Digits logout] method is invoked.
 */
- (void)digitsLogout:(DGTAuthEventDetails *)authEventDetails;

/**
 *  Called when the screen for 2FA pin code entrance is displayed
 */
- (void)digitsTwoFactorPinEntryScreenVisited:(DGTAuthEventDetails *)authEventDetails;

/**
 *  Called when the user taps the button to submit 2FA pin code
 */
- (void)digitsTwoFactorPinSubmitted:(DGTAuthEventDetails *)authEventDetails;

/**
 *  Called when the request to submit 2FA pin code receives a successful result from server
 */
- (void)digitsTwoFactorPinSubmissionSucceeded:(DGTAuthEventDetails *)authEventDetails;

/**
 *  Called when the screen for updating user email is displayed
 */
- (void)digitsEmailUpdateScreenVisited:(DGTAuthEventDetails *)authEventDetails;

/**
 *  Called when the user taps the button to submit email update
 */
- (void)digitsEmailUpdateSubmitted:(DGTAuthEventDetails *)authEventDetails;

/**
 *  Called when the request to submit email update request succeeds
 */
- (void)digitsEmailUpdateSubmissionSucceeded:(DGTAuthEventDetails *)authEventDetails;

/**
 *  Called when the screen for error rescue screen is displayed, which happens when the user runs into
 *  aggregate number of errors
 */
- (void)digitsErrorRescueScreenVisited:(DGTAuthEventDetails *)authEventDetails;

/**
 *  Called when the user chooses to dismiss the error rescue screen
 */
- (void)digitsUserDismissErrorRescue:(DGTAuthEventDetails *)authEventDetails;

/**
 *  Called when the user chooses to retry (with a different phone number) from the error rescue screen
 */
- (void)digitsUserRetryOnErrorRescueScreen:(DGTAuthEventDetails *)authEventDetails;

@end
