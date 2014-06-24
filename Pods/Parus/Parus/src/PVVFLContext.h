//
//  PVVFLContext.h
//  Parus
//
//  Created by Andrey Moskvin on 8/2/13.
//
//

#import <Foundation/Foundation.h>

@interface PVVFLContext : NSObject

@property (strong) NSString* format;
@property (assign) NSLayoutFormatOptions alignmentOptions;
@property (assign) NSLayoutFormatOptions directionOptions;
@property (strong) NSDictionary* views;
@property (strong) NSDictionary* metrics;

- (NSArray *)buildConstraints;

@end
