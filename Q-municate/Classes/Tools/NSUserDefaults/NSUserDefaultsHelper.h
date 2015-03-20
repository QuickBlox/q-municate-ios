//
//  NSUserDefaultsHalper.h
//  CASP
//
//  Created by Andrey Ivanov on 13.08.13.
//  Copyright (c) 2013 2ShareNetworksBV. All rights reserved.

#import <Foundation/Foundation.h>

CG_EXTERN void defInit(NSDictionary *dictionary);
CG_EXTERN id defObject(NSString *key);
CG_EXTERN void defSetObject(NSString *key, NSObject *object);
CG_EXTERN void defRemove(NSString *key);
CG_EXTERN BOOL defBool(NSString *key);
CG_EXTERN void defSetBool(NSString *key, BOOL var);
CG_EXTERN NSInteger defInt(NSString *key);
CG_EXTERN void defSetInt(NSString *key, NSInteger var);
CG_EXTERN id defObserve(NSString *key, void (^block) (id object)) ;
CG_EXTERN void defReset();