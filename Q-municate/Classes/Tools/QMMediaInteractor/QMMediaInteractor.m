//
//  QMMediaInteractor.m
//  QMPLayer
//
//  Created by Vitaliy Gurkovsky on 1/30/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import "QMServicesManager.h"
#import "QMMediaInteractor.h"
#import "EXTScope.h"
#import "QMCore.h"

@implementation QMMediaInteractor

@synthesize mediaItem = _mediaItem;
@synthesize mediaID = _mediaID;

- (void)requestForMedia {
    
}

- (void)activateMedia {
    
    if (self.mediaItem && self.mediaItem.contentType == QMMediaContentTypeAudio) {
        
        [self.playerService activateMedia:self.mediaItem sender:self];
    }
}


- (void)updateWithMedia:(QMMediaItem *)mediaItem {
    
    if (self.mediaID != mediaItem.mediaID) {
        return;
    }
    
    
    [self.output didUpdateIsActive:NO];
    
    if (mediaItem.duration > 0) {
        [self.output didUpdateDuration:mediaItem.duration];
    }
    
    
    BOOL isReady = mediaItem.isReady;
    //    
    //    if (mediaItem.contentType == QMMediaContentTypeAudio || mediaItem.contentType == QMMediaContentTypeVideo) {
    //        isReady = mediaItem.localURL.path.length && mediaItem.duration > 0;
    //    }
    //    else if (mediaItem.contentType == QMMediaContentTypeImage) {
    //        isReady = mediaItem.isReady;
    //    }
    //    
    if (mediaItem.contentType == QMMediaContentTypeVideo) {
        
        UIImage *image = mediaItem.thumbnailImage;
        [self.output didUpdateThumbnailImage:image];
    }
    
    [self.output didUpdateIsReady:isReady];
}

@end
