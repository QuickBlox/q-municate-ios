//
//  QMLog.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 8/10/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    void QMLogSetEnabled(BOOL enabled);
    BOOL QMLogEnabled(void);
    void QMLog(NSString *format, ...);
    
#ifdef __cplusplus
}
#endif
