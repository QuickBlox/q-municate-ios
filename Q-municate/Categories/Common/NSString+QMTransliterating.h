//
//  NSString+QMTransliterating.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 1/4/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (QMTransliterating)

- (nullable NSString *)qm_transliteratedString;
- (nullable NSString *)qm_transliteratedStringWithStrippedCombiningMarks:(BOOL)strip;

@end
