//
//  QMChatLocationCell.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/4/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QMChatLocationCell <NSObject>

/**
 *  Location coordinate.
 */
@property (assign, nonatomic) CLLocationCoordinate2D locationCoordinate;

@end
