//
//  QMTagFieldView.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMTagFieldView;

/**
 *  QMTagFieldViewDelegate protocol. Used to notify about any tag view changes.
 */
@protocol QMTagFieldViewDelegate <NSObject>

/**
 *  Protocol methods down below are required to be implemented
 */
@required

/**
 *  Notifying about tag view height changes.
 *
 *  @param tagFieldView QMTagFieldView instance
 *  @param height       new height after change
 *
 *  @discussion Use this to update frame or layout.
 */
- (void)tagFieldView:(QMTagFieldView *)tagFieldView didChangeHeight:(CGFloat)height;

/**
 *  Notifying about text field changes.
 *
 *  @param tagFieldView QMTagFieldView instance
 *  @param text         text after change
 *
 *  @discussion Use this to perform any external search based on tag field text changes.
 */
- (void)tagFieldView:(QMTagFieldView *)tagFieldView didChangeText:(NSString *)text;

/**
 *  Notifying about tag being removed from field.
 *
 *  @param tagFieldView QMTagFieldView instance
 *  @param tagID        custom ID of removed tag
 */
- (void)tagFieldView:(QMTagFieldView *)tagFieldView didDeleteTagWithID:(id)tagID;

/**
 *  Protocol methods down below are optional and can be ignored
 */
@optional

/**
 *  Notifying about changing search status.
 *
 *  @param tagFieldView        QMTagFieldView instance
 *  @param searchIsActive      whether search is active or not (text field is empty)
 *  @param byClearingTextField determines whether notification was triggered by clearing text field or not
 */
- (void)tagFieldView:(QMTagFieldView *)tagFieldView didChangeSearchStatus:(BOOL)searchIsActive byClearingTextField:(BOOL)byClearingTextField;

@end

/**
 *  Tag field view. View of multiples tag.
 */
@interface QMTagFieldView : UIView

/**
 *  Delegate instance that conforms to QMTagFieldViewDelegate protocol
 */
@property (weak, nonatomic) id<QMTagFieldViewDelegate> delegate;

/**
 *  Scroll view
 */
@property (strong, nonatomic) UIScrollView *scrollView;

/**
 *  Text field placeholder
 */
@property (strong, nonatomic) NSString *placeholder;

/**
 *  Line of tags height.
 *  Default value: 26
 */
@property (assign, nonatomic) CGFloat lineHeight;

/**
 *  Line of tags padding.
 *  Default value: 9
 */
@property (assign, nonatomic) CGFloat linePadding;

/**
 *  Spacing between line of tags.
 *  Default value: 11
 */
@property (assign, nonatomic) CGFloat lineSpacing;

/**
 *  Determines number of lines before scroll view is available.
 *  Default value: 2
 */
@property (assign, nonatomic) NSInteger maxNumberOfLines;

/**
 *  Number of already visible lines.
 */
@property (assign, nonatomic) NSInteger currentNumberOfLines;

/**
 *  Preferred height for tag view.
 *
 *  @return calculated preferred height for tag view
 */
- (CGFloat)preferredHeight;

/**
 *  Perform scroll to text field (to the end of tag view).
 *
 *  @param animated defines whether scroll should be animated or not
 */
- (void)scrollToTextField:(BOOL)animated;

/**
 *  Determines whether search is active or not (text field has text).
 *
 *  @return boolean value of active search
 */
- (BOOL)searchIsActive;

/**
 *  Clear text from text view.
 */
- (void)clearText;

/**
 *  Determines wheter tag view has first responder or not.
 *
 *  @return boolean value of tag view being first responder
 */
- (BOOL)hasFirstResponder;

/**
 *  Perform tag view transition (any layout changes) with a specific time duration.
 *
 *  @param duration duration to perform transition within
 *
 *  @discussion Use this to perform custom transition with interface orientation changes (for example)
 */
- (void)beginTransition:(NSTimeInterval)duration;

/**
 *  Add tag with title.
 *
 *  @param title    text that will be displayed on tag
 *  @param tagID    any tag ID, to determine tag with
 *  @param animated defines whether adding will be animated or not
 */
- (void)addTag:(NSString *)title tagID:(id)tagID animated:(BOOL)animated;

/**
 *  All existent tag IDs.
 *
 *  @return all existent tag ids
 */
- (NSArray *)tagIDs;

/**
 *  Remove tag with a specific ID.
 *
 *  @param tagID ID of a specific tag
 */
- (void)removeTagWithID:(id)tagID;

/**
 *  Remove tags at indexes.
 *
 *  @param indexSet index set to remove tags within
 */
- (void)removeTagsAtIndexes:(NSIndexSet *)indexSet;

@end
