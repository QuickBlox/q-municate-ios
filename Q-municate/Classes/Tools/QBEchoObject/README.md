QBEchoObject
======

WARNING! Object only for ARC projects. No GMO.

For explanation of http://quickblox-developers.blogspot.com/2012/09/using-blocks-in-ios-sdk.html

Object that is used as a delegate for the request to QB SDK ( https://github.com/QuickBlox/SDK-ios ).
It works only for queries with context.
If the result does block transfers in the context.

Example:

    void (^block)(Result *) = ^(Result *result){
        if(result.success)
        {
            QBUUserLogInResult *loginResult = (QBUUserLogInResult *)result;
            // save user
        }
    };
    
    [QBUsers logInWithUserEmail:email password:password delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:block]];
