//
//  QBChatAttachment+QMCustomParameters.m
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 3/26/17.
//
//

#import "QBChatAttachment+QMCustomParameters.h"
#import <objc/runtime.h>

/**
 *  Attachment keys
 */
NSString  *kQMAttachmentWidthKey = @"width";
NSString  *kQMAttachmentHeightKey = @"height";
NSString  *kQMAttachmentDurationKey = @"duration";
NSString  *kQMAttachmentSizeKey = @"size";

@implementation QBChatAttachment (QMCustomParameters)

- (NSURL *)localFileURL {
    return objc_getAssociatedObject(self, @selector(localFileURL));
}

- (void)setLocalFileURL:(NSURL *)localFileURL {
    objc_setAssociatedObject(self, @selector(localFileURL), localFileURL, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSData *)mediaData {
     return objc_getAssociatedObject(self, @selector(mediaData));
}

- (void)setMediaData:(NSData *)data {
    objc_setAssociatedObject(self, @selector(mediaData), data, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)image {
    return objc_getAssociatedObject(self, @selector(image));
}

- (void)setImage:(UIImage *)image {
    objc_setAssociatedObject(self, @selector(image), image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (QMAttachmentStatus)status {
    
    return [[self tAttachmentStatus] integerValue];
}

- (void)setStatus:(QMAttachmentStatus)status {
    
    [self setTAttachmentStatus:@(status)];
}

- (NSNumber *)tAttachmentStatus {
    
    return objc_getAssociatedObject(self, @selector(tAttachmentStatus));
}

- (void)setTAttachmentStatus:(NSNumber *)attachmentStatusNumber {
    
    objc_setAssociatedObject(self, @selector(tAttachmentStatus), attachmentStatusNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (QMAttachmentContentType)contentType {
    
    if ([[self tContentType] integerValue] == 0) {
        
        QMAttachmentContentType contentType = QMAttachmentContentTypeCustom;
        
        if ([self.type isEqualToString:@"audio"]) {
            contentType = QMAttachmentContentTypeAudio;
        }
        else if ([self.type isEqualToString:@"video"]) {
            
            contentType = QMAttachmentContentTypeVideo;
        }
        else if ([self.type isEqualToString:@"image"]) {
            
            contentType = QMAttachmentContentTypeImage;
        }
        
        [self setContentType:contentType];
    }
    
    return [[self tContentType] integerValue];
}

- (void)setContentType:(QMAttachmentContentType)contentType {
    [self setTContentType:@(contentType)];
}


- (NSNumber *)tContentType {
    
    return objc_getAssociatedObject(self, @selector(tContentType));
}

- (void)setTContentType:(NSNumber *)contentTypeNumber {
    
    objc_setAssociatedObject(self, @selector(tContentType), contentTypeNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSUInteger)width {
    
    return [self[kQMAttachmentWidthKey] integerValue];
}

- (void)setWidth:(NSUInteger)width {
    
    if (self.width != width) {
        self[kQMAttachmentWidthKey] = [NSString stringWithFormat:@"%ld",(unsigned long)width];
    }
}

- (NSUInteger)height {
    
    return [self[kQMAttachmentHeightKey] integerValue];
}

- (void)setHeight:(NSUInteger)height {
    
    if (self.height != height) {
        self[kQMAttachmentHeightKey] = [NSString stringWithFormat:@"%ld",(unsigned long)height];
    }
}

- (NSUInteger)size {
    
    return [self[kQMAttachmentSizeKey] integerValue];
}

- (void)setSize:(NSUInteger)size {
    
    if (self.size != size) {
        self[kQMAttachmentSizeKey] = [NSString stringWithFormat:@"%ld",(unsigned long)size];
    }
}

- (NSInteger)duration {
    
    return [self[kQMAttachmentDurationKey] integerValue];
}

- (void)setDuration:(NSInteger)duration {
    
    if (!compareNearlyEqual(self.duration, duration, sizeof(duration))) {
        
        self[kQMAttachmentDurationKey] = [NSString stringWithFormat:@"%ld",(unsigned long)duration];
    }
}

- (NSString *)stringMIMEType {
    
    NSString *stringMIMEType = nil;
    
    switch (self.contentType) {
        case QMAttachmentContentTypeAudio:
            stringMIMEType = @"audio/caf";
            break;
            
        case QMAttachmentContentTypeVideo:
            stringMIMEType = @"video/mp4";
            break;
            
        case QMAttachmentContentTypeImage:
            stringMIMEType = @"image/png";
            break;
            
        default:
            stringMIMEType = @"";
            break;
    }
    
    return stringMIMEType;
}

- (NSURL *)remoteURL {
    
    if (self.ID.length == 0) {
        return nil;
    }
    
    NSString *apiEndpoint = [QBSettings apiEndpoint];
    
    NSURLComponents *components =
    [NSURLComponents componentsWithURL:[NSURL URLWithString:apiEndpoint]
                                             resolvingAgainstBaseURL:false];
    
    components.path = [NSString stringWithFormat:@"/blobs/%@", self.ID];
    components.query = [NSString stringWithFormat:@"token=%@",[QBSession currentSession].sessionDetails.token];
    
    return components.URL;
}

- (NSString *)stringContentType {
    
    NSString *stringContentType = nil;
    
    switch (self.contentType) {
        case QMAttachmentContentTypeAudio:
            stringContentType = @"audio";
            break;
            
        case QMAttachmentContentTypeVideo:
            stringContentType = @"video";
            break;
            
        case QMAttachmentContentTypeImage:
            stringContentType = @"image";
            break;
        default:
            stringContentType = @"";
            break;
    }
    
    return stringContentType;
}


- (NSString *)extension {
    
    NSString *stringMediaType = nil;
    
    switch (self.contentType) {
        case QMAttachmentContentTypeAudio:
            stringMediaType = @"m4a";
            break;
            
        case QMAttachmentContentTypeVideo:
            stringMediaType = @"mp4";
            break;
            
        case QMAttachmentContentTypeImage:
            stringMediaType = @"png";
            break;
            
        default:
            stringMediaType = @"";
            break;
    }
    
    return stringMediaType;
}

//MARK: Helpers
bool compareNearlyEqual (float a, float b, unsigned epsilonMultiplier) {
    float epsilon;
    if (a == b)
        return true;
    
    if (a > b) {
        epsilon = scalbnf(1.0f, ilogb(a)) * FLT_EPSILON * epsilonMultiplier;
    } else {
        epsilon = scalbnf(1.0, ilogb(b)) * FLT_EPSILON * epsilonMultiplier;
    }
    
    return fabs (a - b) <= epsilon;
}


@end
