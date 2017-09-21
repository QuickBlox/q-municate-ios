//
//  QMHelpers.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

CGRect CGRectOfSize(CGSize size);

NSString *QMStringForTimeInterval(NSTimeInterval timeInterval);

NSInteger iosMajorVersion();

extern void removeControllerFromNavigationStack(UINavigationController *navC, UIViewController *vc);


//@protocol QMRestorableViewController <NSObject>
//
//@property (strong, nonatomic) NSString *restorationIdentifier;
//
//@end


/*
@interface QMRestoration : NSObject

@property (class, assign, getter=isEnabled) BOOL enabled;

+ (QMRestoration *)restoration;

- (void)addRestorableViewController:(UIViewController<QMRestorableViewController> *)restorableViewController
wirhEncodeBlock:(void(^)(NSCoder *coder))decodeBlock
                        decodeBlock:(void(^)(NSCoder *coder))decodeBlock;

- (void)removeRestorableViewController:(id <QMRestorableViewController>)restorableViewController;


@end

@interface QMRestoration()

@property (nonatomic, strong) QBMulticastDelegate *restorationMulticastDelegate;
                                     
@end

@implementation QMRestoration

static BOOL _enabled = NO;

@dynamic enabled;

+(QMRestoration *)restoration {
    
    static dispatch_once_t dispatchOnceLocker = 0;
    static QMRestoration *defaultRestoration = nil;
    dispatch_once(&dispatchOnceLocker, ^{
        defaultRestoration = [[self alloc] init];
    });
    
    return defaultRestoration;
}

- (instancetype)init {
    
    if (self = [super init]) {
        _restorationMulticastDelegate = [[QBMulticastDelegate alloc] init];
    }
    return self;
}



+ (BOOL)isEnabled {
    return _enabled;
}

+ (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
}

@end
*/
