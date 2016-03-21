//
//  QMTagView.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMTagView;

/**
 *  QMTagViewDelegate protocol. Used to notify about tag view actions.
 */
@protocol QMTagViewDelegate <NSObject>

/**
 *  Notifying about tag view become first responder.
 *
 *  @param tagView QMTagView instance
 */
- (void)tagViewDidBecomeFirstResponder:(QMTagView *)tagView;

/**
 *  Notifying about tag view resign first responder.
 *
 *  @param tagView QMTagView instance
 */
- (void)tagViewDidResignFirstResponder:(QMTagView *)tagView;

/**
 *  Notifying about tag view press backspace.
 *
 *  @param tagView QMTagView instance
 */
- (void)tagViewDidPressBackspace:(QMTagView *)tagView;

@end

/**
 *  Single tag view, based on UIButton and highlight supporting. Has tag ID as a custom meta data.
 */
@interface QMTagView : UIButton <UIKeyInput>

/**
 *  Delegate instance that conforms to QMTagViewDelegate protocol.
 */
@property (weak, nonatomic) id <QMTagViewDelegate>delegate;

/**
 *  Title label of tag
 */
@property (strong, nonatomic) NSString *label;

/**
 *  Calculated preferred width
 */
@property (assign, nonatomic) CGFloat preferredWidth;

/**
 *  Custom ID of tag
 *
 *  @discussion Use any object as tag ID. Must be unique value.
 */
@property (strong, nonatomic) id tagID;

@end
