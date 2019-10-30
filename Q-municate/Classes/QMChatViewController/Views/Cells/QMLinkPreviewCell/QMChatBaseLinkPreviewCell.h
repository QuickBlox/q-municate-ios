//
//  QMChatBaseLinkPreviewCell.h
//
//
//  Created by Injoit on 3/31/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//


#import "QMChatCell.h"
#import "QMImageView.h"
#import "QMLinkPreviewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMChatBaseLinkPreviewCell : QMChatCell <QMLinkPreviewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *urlLabel;
@property (nonatomic, weak) IBOutlet TTTAttributedLabel *urlDescription;
@property (nonatomic, weak) IBOutlet UIImageView *previewImageView;

- (void)setSiteURL:(NSString *)siteURL
    urlDescription:(NSString *)urlDesription
      previewImage:(UIImage *)previewImage
           favicon:(UIImage *)favicon;

@end

NS_ASSUME_NONNULL_END
