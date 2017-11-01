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
#import "QMAttachmentProvider.h"

static const NSUInteger kQMMaxFileSize = 100; //in MBs
static const CGFloat kQMMaxImageSize = 1000.0; //in pixels

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
    else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
        
        [[self taskForURLWithProvider:provider] continueWithBlock:^id _Nullable(BFTask<NSURL *> * _Nonnull urlTask) {
            NSURL *URL = urlTask.result;
            
            if (URL.isFileURL) {
                QMAttachmentProviderSettings *settings = [QMAttachmentProviderSettings new];
                settings.maxImageSize = kQMMaxImageSize;
                settings.maxFileSize = kQMMaxFileSize;
                
                [[QMAttachmentProvider attachmentWithFileURL:URL settings:settings] continueWithBlock:^id _Nullable(BFTask<QBChatAttachment *> * _Nonnull attachmentTask) {
                    if (attachmentTask.error) {
                        [source setError:attachmentTask.error];
                    }
                    else {
                        QBChatAttachment *attachment = attachmentTask.result;
                        message.attachments = @[attachment];
                        message.text =
                        [NSString stringWithFormat:@"%@ attachment",
                         attachment.type.capitalizedString];
                        [source setResult:message];
                    }
                    return nil;
                }];
            }
            else if (URL.isLocationURL) {
                message.text = @"Location";
                [[URL location] continueWithBlock:^id _Nullable(BFTask<CLLocation *> * _Nonnull locationTask) {
                    message.locationCoordinate = locationTask.result.coordinate;
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
   else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMovie] ||
            [provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeAudio] ||
            [provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeFileURL]) {
       
       [[self taskForProvider:provider] continueWithBlock:^id _Nullable(BFTask<NSURL *> * _Nonnull t) {
           if (t.error) {
               [source setError:t.error];
           }
           else {
               
               QMAttachmentProviderSettings *settings = [QMAttachmentProviderSettings new];
               settings.maxImageSize = kQMMaxImageSize;
               settings.maxFileSize = kQMMaxFileSize;
               
               [[QMAttachmentProvider attachmentWithFileURL:t.result settings:settings] continueWithBlock:^id _Nullable(BFTask<QBChatAttachment *> * _Nonnull attachmentTask) {
                   if (attachmentTask.error) {
                       [source setError:attachmentTask.error];
                   }
                   else {
                       QBChatAttachment *attachment = attachmentTask.result;
                       message.attachments = @[attachment];
                       message.text =
                       [NSString stringWithFormat:@"%@ attachment",
                        attachment.type.capitalizedString];
                       [source setResult:message];
                   }
                   return nil;
               }];
           }
           return nil;
       }];
   }
   else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
        
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
        [provider loadItemForTypeIdentifier:(NSString *)kUTTypeImage
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

+ (BFTask <NSURL *> *)taskForProvider:(NSItemProvider *)provider {
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        [provider loadItemForTypeIdentifier:(NSString *)provider.registeredTypeIdentifiers.firstObject
                                    options:nil
                          completionHandler:^(NSURL *url, NSError *error) {
                              error ? [source setError:error] : [source setResult:url];
                          }];
    });
}

@end
