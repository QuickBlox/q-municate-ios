//
//  NSUserDefaultsHelper.c
//  Qmunicate
//
//  Created by Andrey Ivanov on 24.06.14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "NSUserDefaultsHelper.h"

NSUserDefaults *defaults();
void defaultsPostNotification(NSString *key);
void defaultsSave();

inline NSUserDefaults *defaults() {
    
	return [NSUserDefaults standardUserDefaults];
}

inline void defInit(NSDictionary *dictionary) {
    
	[defaults() registerDefaults:dictionary];
}

inline id defObject(NSString *key) {
    
    id obj = [defaults() objectForKey:key];
    return obj;
}

inline void defSetObject(NSString *key, NSObject *object) {
    
	[defaults() setObject:object forKey:key];
	defaultsSave();
	defaultsPostNotification(key);
}

inline void defRemove(NSString *key) {
    
    [defaults() removeObjectForKey:key];
	defaultsSave();
    defaultsPostNotification(key);
}

inline BOOL defBool(NSString *key) {
    
    return [defaults() boolForKey:key];
}

inline void defSetBool(NSString *key, BOOL var) {
    
    [defaults() setBool:var forKey:key];
    defaultsSave();
    defaultsPostNotification(key);
}

inline NSInteger defInt(NSString *key) {
    
    return [defaults() integerForKey:key];
}

inline void defSetInt(NSString *key, NSInteger var) {
    
    [defaults() setInteger:var forKey:key];
    defaultsSave();
    defaultsPostNotification(key);
}

inline id defObserve(NSString *key, void (^block) (id object)) {
    
	return [[NSNotificationCenter defaultCenter] addObserverForName:key
                                                             object:nil
                                                              queue:[NSOperationQueue mainQueue]
                                                         usingBlock:^(NSNotification *note) {
                                                             block(note.userInfo);
                                                         }];
}

inline void defReset() {
    
	NSDictionary *defaultsDictionary = [defaults() dictionaryRepresentation];
	for (NSString *key in [defaultsDictionary allKeys]) {
	    defRemove(key);
	}
}

#pragma mark

inline void defaultsPostNotification(NSString *key) {
    
    id object = defObject(key);
    NSDictionary *userInfo = object ? [NSDictionary dictionaryWithObject:object forKey:@"value"] : [NSDictionary dictionary];
	[[NSNotificationCenter defaultCenter] postNotificationName:key
                                                        object:nil
                                                      userInfo:userInfo];
}

inline void defaultsSave() {
    
	[defaults() synchronize];
}