//
//  QMImageOperation.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 3/23/17.
//
//

#import "QMImageOperation.h"
#import "QBChatAttachment+QMCustomParameters.h"

@interface QMImageOperation()

@property (strong, nonatomic) AVAssetImageGenerator *generator;

@end


@implementation QMImageOperation

- (instancetype)initWithAttachment:(QBChatAttachment *)attachment
                 completionHandler:(QMImageOperationCompletionBlock)completionHandler {
    
    self = [self init];
    
    if (self) {
        
        _attachment = attachment;
        _imageOperationCompletionBlock = [completionHandler copy];
        
        self.generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:[AVAsset assetWithURL:[self.attachment remoteURL]]];
        self.generator.appliesPreferredTrackTransform = YES;
        self.generator.maximumSize = CGSizeMake(200, 200);
        
        __weak typeof(self) weakSelf = self;

        self.operationBlock = ^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
            
            AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime,
                                                               CGImageRef image,
                                                               CMTime actualTime,
                                                               AVAssetImageGeneratorResult result,
                                                               NSError *error) {
                
                UIImage *thumb = nil;
                if (result == AVAssetImageGeneratorSucceeded) {
                    thumb = [UIImage imageWithCGImage:image];
                }
                if (strongSelf.imageOperationCompletionBlock) {
                    strongSelf.imageOperationCompletionBlock(thumb, error);
                }
                
                [strongSelf complete];
            };
            

            NSArray *times = @[[NSValue valueWithCMTime:CMTimeMakeWithSeconds(2,1)]];
            [strongSelf.generator generateCGImagesAsynchronouslyForTimes:times
                                                     completionHandler:handler];
            
        };
        
        self.cancellBlock = ^{
            [weakSelf.generator cancelAllCGImageGeneration];
        };
    }
    
    return self;
}


- (void)dealloc {

}

@end
