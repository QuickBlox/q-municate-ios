//
//  QBChatAbstractMessage+TextEncoding.m
//  Q-municate
//
//  Created by Igor Alefirenko on 20.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QBChatAbstractMessage+TextEncoding.h"
#import "NSString+GTMNSStringHTMLAdditions.h"
#import <objc/runtime.h>

static const char encodedTextKey;

@implementation QBChatAbstractMessage (TextEncoding)

-(NSString *)encodedText {

    NSString *text = objc_getAssociatedObject(self, &encodedTextKey);
    
    if (!text){
        text = [self.text gtm_stringByUnescapingFromHTML];
        objc_setAssociatedObject(self, &encodedTextKey, text, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    }
    
    return text;
}


@end
