//
//  QBChatMessage+TextEncoding.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/22/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QBChatMessage+TextEncoding.h"
#import "NSString+GTMNSStringHTMLAdditions.h"
#import <objc/runtime.h>

static const char encodedTextKey;

@implementation QBChatMessage (TextEncoding)

-(NSString *)encodedText {
    
    NSString *text = objc_getAssociatedObject(self, &encodedTextKey);
    
    if (!text){
        text = [self.text gtm_stringByUnescapingFromHTML];
        objc_setAssociatedObject(self, &encodedTextKey, text, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    }
    
    return text;
}


@end
