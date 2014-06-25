//
//  NSUserDefaultsHelper.c
//  Qmunicate
//
//  Created by Andrey on 24.06.14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "NSUserDefaultsHelper.h"

void __defaults_post_notification(NSString *key);
void __defaults_save();

inline NSUserDefaults *defaults() {
	return [NSUserDefaults standardUserDefaults];
}

inline void userDefaultsIntiWithDictionary(NSDictionary *dictionary) {
	[defaults() registerDefaults:dictionary];
}

inline id def_object(NSString *key) {
    id obj = [defaults() objectForKey:key];
    return obj;
}

inline void def_set_object(NSString *key, NSObject *object) {
	[defaults() setObject:object forKey:key];
	__defaults_save();
	__defaults_post_notification(key);
}

inline void def_remove(NSString *key) {
    [defaults() removeObjectForKey:key];
	__defaults_save();
    __defaults_post_notification(key);
}

inline BOOL def_bool(NSString *key) {
    return [defaults() boolForKey:key];
}

inline void def_set_bool(NSString *key, BOOL var) {
    [defaults() setBool:var forKey:key];
    __defaults_save();
    __defaults_post_notification(key);
}

inline BOOL def_int(NSString *key) {
    return [defaults() integerForKey:key];
}

inline void def_set_int(NSString *key, NSInteger var) {
    [defaults() setInteger:var forKey:key];
    __defaults_save();
    __defaults_post_notification(key);
}

inline id def_observe(NSString *key, void (^block) (id object)) {
    
	return [[NSNotificationCenter defaultCenter] addObserverForName:key object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                block(note.userInfo);
            }];           
}

inline void def_reset(){
	NSDictionary *defaultsDictionary = [defaults() dictionaryRepresentation];
	for (NSString *key in [defaultsDictionary allKeys]) {
	    def_remove(key);
	}
}

inline void __defaults_post_notification(NSString *key) {
    id object = def_object(key);
    NSDictionary *userInfo = object ? [NSDictionary dictionaryWithObject:object forKey:@"value"] : [NSDictionary dictionary];
	[[NSNotificationCenter defaultCenter] postNotificationName:key
                                                        object:nil
                                                      userInfo:userInfo];
}

inline void __defaults_save() {
	[defaults() synchronize];
}