//
//  Macro.h
//  Q-municate
//
//  Created by Igor Alefirenko on 22.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#ifndef Q_municate_Macro_h
#define Q_municate_Macro_h

#define IS_IPHONE_6 [UIScreen]
#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#ifdef DEBUG
#define ELog(...) do { NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__]); } while(0)
#define ILog(...) do { NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__]); } while(0)
#define VLog(...) do { NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__]); } while(0)
#define ALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__]
#else
#define ELog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#define ILog(...) do { } while (0)
#define VLog(...) do { } while (0)

#ifndef NS_BLOCK_ASSERTIONS
#define NS_BLOCK_ASSERTIONS
#endif

#define ALog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#endif

#define PLog(...) [[NSNotificationCenter defaultCenter] postNotificationName:UFAppLogInfoNotification object:[NSString stringWithFormat:__VA_ARGS__]]


#endif
