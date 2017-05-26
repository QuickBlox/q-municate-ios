//
//  QMChatBaseLinkPreviewCell.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 3/31/17.
//
//

#import "QMChatCell.h"
#import "QMImageView.h"
#import "QMLinkPreviewDelegate.h"

#import <TTTAttributedLabel/TTTAttributedLabel.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMChatBaseLinkPreviewCell : QMChatCell <QMLinkPreviewDelegate>

@property (nonatomic, weak) IBOutlet TTTAttributedLabel *titleLabel;
@property (nonatomic, weak) IBOutlet TTTAttributedLabel *siteDescriptionLabel;
@property (nonatomic, weak) IBOutlet TTTAttributedLabel *urlLabel;
@property (nonatomic, weak) IBOutlet QMImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIView *linkPreviewView;
@property (weak, nonatomic) IBOutlet QMImageView *iconImageView;

@end

NS_ASSUME_NONNULL_END
