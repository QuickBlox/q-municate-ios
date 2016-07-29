//
//  QMCameraCapture.m
//  Q-municate
//
//  Created by Andrey Ivanov on 02.07.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMCameraCapture.h"

@interface QMCameraCapture() <AVCaptureVideoDataOutputSampleBufferDelegate> {
    
    dispatch_queue_t _captureSessionQueue;
}

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic, strong) QBRTCVideoFormat *videoFormat;
@property (nonatomic, assign) BOOL orientationHasChanged;

@property (nonatomic, assign) AVCaptureDevicePosition preferrdCameraPosition;

@end

@implementation QMCameraCapture

- (void)dealloc {
    
    self.previewLayer.session = nil;
    self.previewLayer = nil;
    self.captureDeviceInput = nil;
    [self.videoDataOutput setSampleBufferDelegate:nil queue:nil];
    
    self.captureSession = nil;
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [self removeObservers];
}

- (instancetype)init {
    
    QBRTCVideoFormat *videoFormat = [QBRTCVideoFormat defaultFormat];
    self = [self initWithVideoFormat:videoFormat position:AVCaptureDevicePositionFront];
    if (self) {}
    return self;
}

- (instancetype)initWithVideoFormat:(QBRTCVideoFormat *)videoFormat
                           position:(AVCaptureDevicePosition)position {
    self = [super init];
    
    if (self) {
        
        NSParameterAssert(videoFormat);
        NSParameterAssert(position != AVCaptureDevicePositionUnspecified);
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        _captureSessionQueue = dispatch_queue_create("com.quickblox.captureSession", DISPATCH_QUEUE_SERIAL);
        
        _videoFormat = videoFormat;
        _preferrdCameraPosition = position;
        
        _captureSession = [[AVCaptureSession alloc] init];
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
        
        _captureSession.usesApplicationAudioSession = NO;
        _captureSession.sessionPreset = AVCaptureSessionPresetInputPriority;
        
        dispatch_async(_captureSessionQueue, ^{
            
            [self->_captureSession beginConfiguration];
            NSDictionary *videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
            
            AVCaptureVideoDataOutput *captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
            
            captureVideoDataOutput.videoSettings = videoSettings;
            captureVideoDataOutput.alwaysDiscardsLateVideoFrames = NO;
            
            if ([self->_captureSession canAddOutput:captureVideoDataOutput]) {
                
                [self->_captureSession addOutput:captureVideoDataOutput];
                self->_videoDataOutput = captureVideoDataOutput;
            }
            
            [self->_captureSession commitConfiguration];
        });
        
        [self addObservers];
        
        ILog(@"%@ Init", self);
    }
    
    return self;
}

AVCaptureDevice * captureDeviceWithPosition(AVCaptureDevicePosition devicePosition) {
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices) {
        
        if (device.position == devicePosition) {
            
            return device;
        }
    }
    
    return nil;
}

- (AVCaptureDeviceInput *)captureDeviceInputWithPosition:(AVCaptureDevicePosition)devicePosition {
    
    NSError *error = nil;
    AVCaptureDeviceInput *captureDeviceInput =
    [[AVCaptureDeviceInput alloc] initWithDevice:captureDeviceWithPosition(devicePosition)
                                           error:&error];
    if (error) {
        
        ILog(@"%@ Video input error %@", self, error.localizedDescription);
        return nil;
    }
    
    return captureDeviceInput;
}

#pragma mark - Public

- (void)startSession {
    [self startSession:nil];
}

- (void)startSession:(dispatch_block_t)completion {
    
    BOOL isSimulator = NO;
    
#if (TARGET_IPHONE_SIMULATOR)
    isSimulator = YES;
#endif
    if (self.captureSession.isRunning || isSimulator) {
        
        if (completion)
            completion();
        
        return;
    }
    
    ILog(@"%@ Start capture session.", self);
    
    dispatch_async(_captureSessionQueue, ^{
        
        [self->_captureSession beginConfiguration];
        
        AVCaptureDeviceInput *captureDeviceInput = [self captureDeviceInputWithPosition:self->_preferrdCameraPosition];
        
        if (!captureDeviceInput) {
            return;
        }
        
        if (self->_captureDeviceInput) {
            
            [self->_captureSession removeInput:self->_captureDeviceInput];
        }
        
        if ([self->_captureSession canAddInput:captureDeviceInput]) {
            
            [self->_captureSession addInput:captureDeviceInput];
            self->_captureDeviceInput = captureDeviceInput;
            
            [self configureCaptureDeviceInput:self->_captureDeviceInput];
        }
        
        [self->_captureSession commitConfiguration];
        
        self->_orientationHasChanged = NO;
        
        [self updateVideoCaptureOrientation];
        
        [self->_captureSession startRunning];
        
        if (completion) {
            
            dispatch_async(dispatch_get_main_queue(), completion);
        };
    });
}

- (void)selectCameraPosition:(AVCaptureDevicePosition)cameraPosition {
    
    if (cameraPosition == AVCaptureDevicePositionUnspecified) {
        
        ILog(@"%@ Position must be specified", self);
        return;
    }
    
    dispatch_async(_captureSessionQueue, ^{
        
        AVCaptureDeviceInput *captureDeviceInput = [self captureDeviceInputWithPosition:cameraPosition];
        
        if (!captureDeviceInput) {
            return;
        }
        
        [self->_captureSession beginConfiguration];
        
        if (self->_captureDeviceInput) {
            
            [self->_captureSession removeInput:self->_captureDeviceInput];
        }
        
        if ([self->_captureSession canAddInput:captureDeviceInput]) {
            
            [self->_captureSession addInput:captureDeviceInput];
            self->_captureDeviceInput = captureDeviceInput;
            
            [self configureCaptureDeviceInput:self->_captureDeviceInput];
            
            self->_orientationHasChanged = NO;
            
            [self updateVideoCaptureOrientation];
        }
        
        [self->_captureSession commitConfiguration];
        
        self->_preferrdCameraPosition = cameraPosition;
    });
}

- (void)stopSession {
    
    if (!self.captureSession.isRunning) {
        return;
    }
    
    dispatch_async(_captureSessionQueue, ^{
        
        ILog(@"%@ Stop capture session async.", self);
        
        [self.captureSession stopRunning];
    });
}

- (void)configureCaptureDeviceInput:(AVCaptureDeviceInput *)captureDeviceInput {
    
    AVCaptureDeviceFormat *requestedFormat =
    [self bestDeviceFormatWithVideoFormat:_videoFormat
                            captureDevice:captureDeviceInput.device];
    
    AVFrameRateRange *frameRateRange;
    
    for (AVFrameRateRange *range in requestedFormat.videoSupportedFrameRateRanges) {
        
        if ((range.minFrameRate <= _videoFormat.frameRate) &&
            (_videoFormat.frameRate <= range.maxFrameRate)) {
            
            frameRateRange = range;
            break;
        }
    }
    
    CMTime maxFrameDuration = frameRateRange.maxFrameDuration;
    CMTime minFrameDuration = frameRateRange.minFrameDuration;
    
    maxFrameDuration.value = 1;
    maxFrameDuration.timescale = (CMTimeScale)floor(_videoFormat.frameRate);
    
    minFrameDuration.value = 1;
    minFrameDuration.timescale = (CMTimeScale)floor(2);
    
    NSError *error = nil;
    
    if ([captureDeviceInput.device lockForConfiguration:&error]) {
        
        captureDeviceInput.device.activeFormat = requestedFormat;
        
        captureDeviceInput.device.activeVideoMinFrameDuration = maxFrameDuration;
        captureDeviceInput.device.activeVideoMaxFrameDuration = maxFrameDuration;
        
        [captureDeviceInput.device unlockForConfiguration];
    }
}

/*
 -beginConfiguration / -commitConfiguration are AVCaptureSession's mechanism
 for batching multiple configuration operations on a running session into atomic
 updates.  After calling [session beginConfiguration], clients may add or remove
 outputs, alter the sessionPreset, or configure individual AVCaptureInput or Output
 properties.  All changes will be pended until the client calls [session commitConfiguration],
 at which time they will be applied together.  -beginConfiguration / -commitConfiguration
 pairs may be nested, and will only be applied when the outermost commit is invoked.
 */
- (void)configureSession:(dispatch_block_t)configureBlock {
    
    dispatch_block_t configureWrapper = ^{
        
        [self->_captureSession beginConfiguration];
        
        configureBlock();
        
        [self->_captureSession commitConfiguration];
    };
    
    // If we are capturing then do the configuration on the session queue.
    if (_captureSession.isRunning) {
        
        dispatch_async(_captureSessionQueue, configureWrapper);
    }
    else {
        
        configureWrapper();
    }
}

- (AVCaptureDevicePosition)currentPosition {
    
    return self.captureDeviceInput.device.position;
}

- (BOOL)hasCameraForPosition:(AVCaptureDevicePosition)cameraPosition {
    
    return captureDeviceWithPosition(cameraPosition) != nil;
}

#pragma mark - Private

- (void)addObservers {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(orientationDidChange:)
                   name:UIDeviceOrientationDidChangeNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(runtimeError:)
                   name:AVCaptureSessionRuntimeErrorNotification
                 object:nil];
}

- (void)orientationDidChange:(NSNotification *)__unused notification {
    
    dispatch_async(_captureSessionQueue, ^{
        
        self->_orientationHasChanged = YES;
        [self updateVideoCaptureOrientation];
    });
}

- (void)runtimeError:(NSNotification *)notification {
    
    NSDictionary *userInfo = notification.userInfo;
    NSError *error = userInfo[AVCaptureSessionErrorKey];
    
    ILog(@"%@ Capture session encountered runtime error. %@", self, error);
}

- (void)removeObservers {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

- (AVCaptureDeviceFormat *)bestDeviceFormatWithVideoFormat:(QBRTCVideoFormat *)videoFormat captureDevice:(AVCaptureDevice *)captureDevice {
    
    NSArray *formats = captureDevice.formats;
    
    AVCaptureDeviceFormat *bestFormat = nil;
    AVCaptureDeviceFormat *defaultFormat = nil;
    
    for (AVCaptureDeviceFormat *format in formats) {
        
        CMVideoFormatDescriptionRef formatDescription = format.formatDescription;
        CMVideoDimensions videoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
        CMPixelFormatType pixelFormatType = CMFormatDescriptionGetMediaSubType(formatDescription);
        
        if(videoDimensions.width == 640 && videoDimensions.height == 480 && pixelFormatType == videoFormat.pixelFormat) {
            
            defaultFormat = format;
        }
        
        BOOL match = (NSUInteger)videoDimensions.width == videoFormat.width &&
        (NSUInteger)videoDimensions.height == videoFormat.height &&
        pixelFormatType == videoFormat.pixelFormat;
        
        if (match) {
            
            if (!bestFormat) {
                
                bestFormat = format;
            }
            else {
                
                CGFloat fieldOfView = format.videoFieldOfView;
                BOOL isBinned = format.isVideoBinned;
                CGFloat zoomUpscaleThreshold = format.videoZoomFactorUpscaleThreshold;
                
                BOOL isBetterMatch = fieldOfView >= bestFormat.videoFieldOfView;
                isBetterMatch &= !isBinned;
                isBetterMatch &= zoomUpscaleThreshold >= bestFormat.videoZoomFactorUpscaleThreshold;
                
                if (isBetterMatch) {
                    bestFormat = format;
                }
            }
        }
    }
    
    if (bestFormat == nil) {
        bestFormat = defaultFormat;
    }
    
    //    QBRTCLogVerbose(@"%@ Best device format is: %@", self, bestFormat);
    
    return bestFormat;
}

#pragma mark - Update orientation

- (void)updateVideoCaptureOrientation {
    
    AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
    
    switch ([UIDevice currentDevice].orientation) {
            
        case UIDeviceOrientationPortrait: orientation = AVCaptureVideoOrientationPortrait; break;
        case UIDeviceOrientationPortraitUpsideDown: orientation =  AVCaptureVideoOrientationPortraitUpsideDown; break;
        case UIDeviceOrientationLandscapeLeft: orientation =  AVCaptureVideoOrientationLandscapeRight; break;
        case UIDeviceOrientationLandscapeRight: orientation =  AVCaptureVideoOrientationLandscapeLeft; break;
            
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown: {
            
            if (!_orientationHasChanged) {
                
                switch ([UIApplication sharedApplication].statusBarOrientation) {
                        
                    case UIInterfaceOrientationPortrait: orientation = AVCaptureVideoOrientationPortrait; break;
                    case UIInterfaceOrientationPortraitUpsideDown: orientation =  AVCaptureVideoOrientationPortraitUpsideDown; break;
                    case UIInterfaceOrientationLandscapeLeft: orientation =  AVCaptureVideoOrientationLandscapeLeft; break;
                    case UIInterfaceOrientationLandscapeRight: orientation =  AVCaptureVideoOrientationLandscapeRight; break;
                    case UIInterfaceOrientationUnknown: {
                        return;
                    }
                }
                
                AVCaptureConnection *connection = [_videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
                
                _previewLayer.connection.videoOrientation =
                connection.videoOrientation = orientation;
            }
            return;
        };
    }
    
    AVCaptureConnection *connection = [_videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if (connection.videoOrientation != orientation) {
        
        connection.videoOrientation = orientation;
    }
    
    if (_previewLayer.connection.videoOrientation != orientation) {
        
        _previewLayer.connection.videoOrientation = orientation;
    }
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)__unused connection {
    
    NSParameterAssert(captureOutput == self.videoDataOutput);
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    
    CMSampleTimingInfo info;
    CMSampleBufferGetSampleTimingInfo(sampleBuffer, 0, &info);
    
    QBRTCVideoFrame *videoFrame = [[QBRTCVideoFrame alloc] initWithPixelBuffer:pixelBuffer];
    int64_t timestamp = (int64_t)(CMTimeGetSeconds(info.presentationTimeStamp) * NSEC_PER_SEC);
    videoFrame.timestamp = timestamp;
    
    [super sendVideoFrame:videoFrame];
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
}

#pragma mark - Inherited

- (void)didSetToVideoTrack:(QBRTCLocalVideoTrack *)videoTrack {
    [super didSetToVideoTrack:videoTrack];
    
    dispatch_async(_captureSessionQueue, ^{
        
        [self->_videoDataOutput setSampleBufferDelegate:self queue:self.videoQueue];
    });
}

- (void)didRemoveFromVideoTrack:(QBRTCLocalVideoTrack *)videoTrack {
    [super didRemoveFromVideoTrack:videoTrack];
    
    dispatch_async(_captureSessionQueue, ^{
        
        [self->_videoDataOutput setSampleBufferDelegate:nil queue:nil];
    });
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"[CAMC]<%@ %p>", self.class, self];
}

@end
