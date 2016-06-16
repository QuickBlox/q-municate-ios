//
//  QMLocalVideoView.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/12/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  QMLocalVideoView class interface.
 *  Used as local video view for QMCallViewController class.
 *
 *  @see QMCallViewController class.
 */
@interface QMLocalVideoView : UIView

/**
 *  Blur effect for local video view.
 *  Default value: YES
 */
@property (assign, nonatomic) BOOL blurEffectEnabled;

/**
 *  Whether preview layer is visible or not.
 *  Default value: YES
 */
@property (assign, nonatomic) BOOL previewLayerVisible;

/**
 *  Preferred frame for local video view with interface orientation.
 *
 *  @param interfaceOrientation UIInterfaceOrientation value
 *
 *  @return Frame for a specific interface orientation
 */
+ (CGRect)preferredFrameForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

/**
 *  Init with preview layer.
 *
 *  @param previewLayer AVCaptureVideoPreviewLayer preview layer instance
 *
 *  @return QMLocalVideoView instance
 */
- (nullable instancetype)initWithPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;

@end

NS_ASSUME_NONNULL_END
