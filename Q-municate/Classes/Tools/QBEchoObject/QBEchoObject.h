//
//  QBEchoObject.h
//  QBEchoObject
//
//  Created by Glebus on 03.10.12.
//
//

#import <Foundation/Foundation.h>

/*
 * Object that is used as a delegate for the request to QB SDK ( https://github.com/QuickBlox/SDK-ios ).
 * It works only for queries with context.
 * If the result does block transfers in the context.
 *
 * Example:
 *
 *   void (^block)(Result *) = ^(Result *result){
 *      if(result.success)
 *      {
 *          QBUUserLogInResult *loginResult = (QBUUserLogInResult *)result;
 *          // save user
 *      }
 *   };
 *
 *   [QBUsers logInWithUserEmail:email password:password delegate:[GMQBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:block]];
 *
 */

@class QBResult;

typedef void (^QBResultBlock)(QBResult *);

@interface QBEchoObject : NSObject<QBActionStatusDelegate>

// Singleton instance
+ (QBEchoObject *)instance;

// Helper
+ (void *)makeBlockForEchoObject:(id)originBlock;

@end
