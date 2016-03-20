//
//  QMTagView.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Single tag view, based on UIButton and highlight supporting. Has tag ID as a custom meta data.
 */
@interface QMTagView : UIButton <UIKeyInput>

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
