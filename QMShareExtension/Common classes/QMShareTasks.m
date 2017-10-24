//
//  QMShareTasks.m
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/20/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMShareTasks.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Quickblox/Quickblox.h>

#import <Bolts/Bolts.h>
#import "QBChatAttachment+QMFactory.h"
#import "NSURL+QMShareExtension.h"
#import "QBChatMessage+QMCustomParameters.h"
#import "QMBaseService.h"


@implementation QMShareTasks

+ (BFTask <QBChatMessage*> *)messageForItemProvider:(NSItemProvider *)provider {
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource new];
    
    QBChatMessage *message = [QBChatMessage message];
    
    if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeText]) {
        
        [[self taskForTextWithProvider:provider] continueWithBlock:^id _Nullable(BFTask<NSString *> * _Nonnull t) {
            if (t.error) {
                [source setError:t.error];
            }
            else {
                message.text = t.result;
                [source setResult:message];
            }
            return nil;
        }];
    }
    
    if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMovie]) {
        
        [[self taskForMovieWithProvider:provider] continueWithBlock:^id _Nullable(BFTask<NSURL *> * _Nonnull t) {
            if (t.error) {
                [source setError:t.error];
            }
            else {
                QBChatAttachment *videoAttachment =
                [QBChatAttachment videoAttachmentWithFileURL:t.result];
                
                AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:t.result options:nil];
                NSInteger duration = lround(CMTimeGetSeconds(audioAsset.duration));
                videoAttachment.duration = duration;
                
                message.attachments = @[videoAttachment];
                message.text = @"Video attachment";
                
                [source setResult:message];
            }
            
            return nil;
        }];
    }
    
    if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
        
        [[self taskForImageWithProvider:provider] continueWithBlock:^id _Nullable(BFTask<UIImage *> * _Nonnull t) {
            if (t.error) {
                [source setError:t.error];
            }
            else {
                QBChatAttachment *imageAttachment =  [QBChatAttachment imageAttachmentWithImage:t.result];
                message.attachments = @[imageAttachment];
                message.text = @"Image attachment";
                [source setResult:message];
            }
            
            return nil;
        }];
    }
    
    else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeFileURL]) {
        
        [[self taskForFileURLWithProvider:provider] continueWithBlock:^id _Nullable(BFTask<NSURL *> * _Nonnull t) {
            if (t.error) {
                [source setError:t.error];
            }
            else {
                NSURL *fileURL = t.result;
                
                NSString *fileName = [[fileURL pathComponents] lastObject];
                NSString *extension = [fileName pathExtension];
                NSString *mimeType = [self attachmentMIMETypeFromFileName:fileName];
                NSLog(@"fileName: %@, extension :%@,mimeType:%@", fileName, extension, mimeType);
            }
            
            return nil;
        }];
    }
    
    else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeText]) {
        [[self taskForTextWithProvider:provider] continueWithBlock:^id _Nullable(BFTask<NSString *> * _Nonnull t) {
            message.text = t.result;
            [source setResult:message];
            return nil;
        }];
    }
    else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
        
        [[self taskForURLWithProvider:provider] continueWithBlock:^id _Nullable(BFTask<NSURL *> * _Nonnull t) {
            NSURL *URL = t.result;
            
            if (URL.isLocationURL) {
                message.text = @"Location";
                
                [[URL location] continueWithBlock:^id _Nullable(BFTask<CLLocation *> * _Nonnull t) {
                    message.locationCoordinate = t.result.coordinate;
                    [source setResult:message];
                    return nil;
                }];
            }
            else {
                message.text = URL.absoluteString;
                [source setResult:message];
            }
            
            return nil;
        }];
    }
    
    return source.task;
}

+ (BFTask <NSString *>*)taskForTextWithProvider:(NSItemProvider *)provider {
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        [provider loadItemForTypeIdentifier:(NSString *)kUTTypeText
                                    options:nil
                          completionHandler:^(NSString * _Nullable text, NSError * _Nullable error) {
                              if (error) {
                                  [source setError:error];
                              }
                              else {
                                  [source setResult:text];
                              }
                          }];
    });
}

+ (BFTask <NSURL *>*)taskForURLWithProvider:(NSItemProvider *)provider {
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        [provider loadItemForTypeIdentifier:(NSString *)kUTTypeURL
                                    options:nil
                          completionHandler:^(NSURL * _Nullable url, NSError * _Nullable error) {
                              if (error) {
                                  [source setError:error];
                              }
                              else {
                                  [source setResult:url];
                              }
                          }];
    });
}


+ (BFTask <UIImage *>*)taskForImageWithProvider:(NSItemProvider *)provider {
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        [provider loadItemForTypeIdentifier:(NSString *)kUTTypeData
                                    options:nil
                          completionHandler:^(UIImage * _Nullable image, NSError * _Nullable error) {
                              if (error) {
                                  [source setError:error];
                              }
                              else {
                                  [source setResult:image];
                              }
                          }];
    });
}

+ (BFTask <QBChatAttachment *> *)taskForAudioWithProvider:(NSItemProvider *)provider {
    
    return [make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        [provider loadItemForTypeIdentifier:(NSString *)kUTTypeAudio
                                    options:nil
                          completionHandler:^(NSURL *url, NSError *error)
         {
             if (error)
                 [source setError:error];
             else
             {
                 [source setResult:url];
             }
         }];
    }) continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        
        NSURL *audioURL = t.result;
        if (!audioURL) {
            return nil;
        }
        
        return make_task(^(BFTaskCompletionSource * _Nonnull source) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:audioURL options:nil];
                NSInteger duration = lround(CMTimeGetSeconds(audioAsset.duration));
                NSString *mimeType = [self attachmentMIMETypeFromFileName:audioURL.absoluteString];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    QBChatAttachment *audioAttachment = [[QBChatAttachment alloc] initWithName:@"Voice Message"
                                                                                       fileURL:audioURL
                                                                                   contentType:mimeType
                                                                                attachmentType:@"audio"];
                    
                    audioAttachment.duration = duration;
                    [source setResult:audioAttachment];
                });
            });
        });
    }];
}

+ (BFTask <NSURL *> *)taskForMovieWithProvider:(NSItemProvider *)provider {
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        [provider loadItemForTypeIdentifier:(NSString *)kUTTypeMovie
                                    options:nil
                          completionHandler:^(NSURL *url, NSError *error) {
                              error ? [source setError:error] : [source setResult:url];
                          }];
    });
}

+ (BFTask <NSURL *> *)taskForFileURLWithProvider:(NSItemProvider *)provider {
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        [provider loadItemForTypeIdentifier:(NSString *)kUTTypeFileURL
                                    options:nil
                          completionHandler:^(NSURL *url, NSError *error) {
                              error ? [source setError:error] : [source setResult:url];
                              
                          }];
    });
}


+ (NSString *)attachmentMIMETypeFromFileName:(NSString *)fileName {
    
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[fileName pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    
    return (__bridge NSString *)(MIMEType);
}

@end
