//
//  QBDarwinNotificationCenter.h
//  Quickblox
//
//  Created by Andrey Ivanov on 30/10/2017.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A notification that enables the broadcast of information to registered observers
 between extensions or your apps.
 */
@interface QBDarwinNotificationCenter : NSObject

/**
 Returns the process’s default darwin notification center
 */
@property (nonatomic, readonly, class) QBDarwinNotificationCenter *defaultCenter;
/**
 Adds an entry to the receiver’s
 
 @param name The name of the notification for which to register the observer; that is,
 only notifications with this name are delivered to the observer.
 @param block The block to be executed when the notification is received.
 
 @return An opaque object to act as the observer.
 */
- (id <NSObject>)addObserverForName:(NSNotificationName)name usingBlock:(dispatch_block_t)block;

/**
 Removes all the entries specifying a given observer.

 @param observer The observer to remove. Must not be nil.
 */
- (void)removeObserver:(id)observer;

/**
 Posts a given notification to the receiver.

 @param name The notification to post. This value must not be nil.
 */
- (void)postNotificationName:(NSNotificationName)name;

@end

NS_ASSUME_NONNULL_END
