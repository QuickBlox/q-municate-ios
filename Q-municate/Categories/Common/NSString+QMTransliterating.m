//
//  NSString+QMTransliterating.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 1/4/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "NSString+QMTransliterating.h"

@implementation NSString (QMTransliterating)

- (NSString *)qm_transliteratedString {
 
    return [self qm_transliteratedStringWithStrippedCombiningMarks:YES];

}

- (NSString *)qm_transliteratedStringWithStrippedCombiningMarks:(BOOL)strip {
    
    NSMutableString *mutableStringToConvert = self.mutableCopy;
    CFMutableStringRef nameRef = (__bridge CFMutableStringRef)mutableStringToConvert;
    
    //Transliterating all text possible to Latin script, e.g. Аврора Эгельс -> Avrora Égelʹs
    CFStringTransform(nameRef, NULL, kCFStringTransformToLatin, false);
    
    if (strip) {
        //Stripping combining marks, e.g. Avrora Égelʹs -> Avrora Egelʹs
        CFStringTransform(nameRef, NULL, kCFStringTransformStripCombiningMarks, false);
    }
    
    return mutableStringToConvert.copy;
}

@end
