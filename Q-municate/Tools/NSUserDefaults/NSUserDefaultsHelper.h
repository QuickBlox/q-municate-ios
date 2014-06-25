//
//  NSUserDefaultsHalper.h
//  CASP
//
//  Created by Andrey on 13.08.13.
//  Copyright (c) 2013 2ShareNetworksBV. All rights reserved.

#import <Foundation/Foundation.h>

CG_EXTERN NSUserDefaults *defaults();
CG_EXTERN void def_init(NSDictionary *dictionary);
CG_EXTERN id def_object(NSString *key);
CG_EXTERN void def_set_object(NSString *key, NSObject *object);
CG_EXTERN void def_remove(NSString *key);
CG_EXTERN BOOL def_bool(NSString *key);
CG_EXTERN void def_set_bool(NSString *key, BOOL var);
CG_EXTERN BOOL def_int(NSString *key);
CG_EXTERN void def_set_int(NSString *key, NSInteger var);
CG_EXTERN id def_observe(NSString *key, void (^block) (id object)) ;
CG_EXTERN void def_reset();