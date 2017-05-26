//
//  QMBaseChatMediaAttachmentCell.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/07/17.
//
//

#import "QMChatCell.h"
#import "FFCircularProgressView.h"

#import "QMMediaViewDelegate.h"

@interface QMBaseMediaCell : QMChatCell <QMMediaViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *previewImageView;
@property (nonatomic, weak) IBOutlet UIButton *mediaPlayButton;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak) IBOutlet FFCircularProgressView *circularProgress;

- (NSString *)timestampString:(NSTimeInterval)currentTime
                  forDuration:(NSTimeInterval)duration;
- (CALayer *)maskLayerFromImage:(UIImage *)image;

@end
