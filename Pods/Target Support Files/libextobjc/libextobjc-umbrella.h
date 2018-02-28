#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "EXTScope.h"
#import "metamacros.h"
#import "EXTRuntimeExtensions.h"

FOUNDATION_EXPORT double libextobjcVersionNumber;
FOUNDATION_EXPORT const unsigned char libextobjcVersionString[];

