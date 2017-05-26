//
//  QMMediaPresenter.m
//  QMMediaPresenter
//
//  Created by Vitaliy Gurkovsky on 1/30/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import "QMMediaPresenter.h"
#import "QMMediaPresenterDelegate.h"
#import "QMMediaViewDelegate.h"

@implementation QMMediaPresenter

@synthesize message = _message;
@synthesize attachmentID = _attachmentID;
@synthesize view = _view;
@synthesize model = _model;

@synthesize playerService;
@synthesize mediaAssistant;
@synthesize eventHandler;

- (instancetype)initWithView:(id <QMMediaViewDelegate>)view {
    
    if (self = [super init]) {
        _view = view;
    }
    return  self;
}

- (void)didTapContainer {
    
    [self.eventHandler didTapContainer:self];
}


- (void)activateMedia {
    
    [self.playerService activateMediaWithSender:self];
}

- (void)requestForMedia {
   
    [self.mediaAssistant requestForMediaWithSender:self];
}

- (void)updateProgress:(CGFloat)progress {
    
    [self.view setProgress:progress];
}

#pragma mark - Interactor output

- (void)didUpdateIsActive:(BOOL)isActive {
    
    [self.view setIsActive:isActive];
}

- (void)didUpdateOffset:(NSTimeInterval)offset {
    
    [self.view setOffset:offset];
}

- (void)didUpdateIsReady:(BOOL)isReady {
    
    [self.view setIsReady:isReady];
    
    if (isReady) {
        
        [self.playerService requestPlayingStatus:self];
    }
    
}
- (void)didUpdateProgress:(CGFloat)progress {
    
    [self.view setProgress:progress];
}

- (void)didUpdateDuration:(NSTimeInterval)duration {
    
    [self.view setDuration:duration];
}

- (void)didUpdateCurrentTime:(NSTimeInterval)currentTime
                    duration:(NSTimeInterval)duration {
    
    [self.view setDuration:duration];
    [self.view setCurrentTime:currentTime];
}

- (void)didUpdateImage:(UIImage *)image {
    
    [self.view setImage:image];
}

- (void)didUpdateThumbnailImage:(UIImage *)image {
    
    [self.view setThumbnailImage:image];
}

- (void)didUpdateLoadingProgress:(CGFloat)loadingProgress {
    
}

- (void)didOccureUploadError:(NSError *)error {
    
}

- (void)didOccureDownloadError:(NSError *)error {
    
}

- (void)dealloc {
    
    _view = nil;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@: %p; attachmentID = %@>",
            NSStringFromClass([self class]),
            self,
            _attachmentID];
}

- (void)setModel:(QMChatModel *)model {
    
    _model = model;
    
    if (model[@"image"]) {
        [self.view setImage:model[@"image"]];
    }
    if (model[@"placeholder_image"]) {
        [self.view setThumbnailImage:model[@"placeholder_image"]];
    }
    if ([model[@"isReady"] boolValue]) {
        [self.view setIsReady:[model[@"isReady"] boolValue]];
    }
    
    if ([model[@"duration"] integerValue] > 0) {
        [self.view setIsReady:[model[@"duration"] integerValue]];
    }
    
}

@end
