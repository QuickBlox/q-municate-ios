//
//  QMLog.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 8/10/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMLog.h"

static BOOL logEnabled = YES;

void QMLogSetEnabled(BOOL enabled)
{
    logEnabled = enabled;
}

BOOL QMLogEnabled()
{
    return logEnabled;
}

void QMLog(NSString *format, ...)
{
    if (logEnabled)
    {
        va_list L;
        va_start(L, format);
        @autoreleasepool {
            NSLogv(format, L);
        }
        va_end(L);
    }
}

