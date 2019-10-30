//
//  QMSLog.h
//  QMServices
//
//  Created by Injoit on 6/17/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

// NSLog is unavailable for QMServices project
// Use QMSLog instead.

#ifdef __cplusplus
extern "C" {
#endif
    
void QMSLogSetEnabled(BOOL enabled);
BOOL QMSLogEnabled(void);
void QMSLog(NSString *format, ...);
    
#ifdef __cplusplus
}
#endif
