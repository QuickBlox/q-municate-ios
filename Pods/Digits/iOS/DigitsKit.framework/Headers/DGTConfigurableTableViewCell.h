//
//  DGTConfigurableTableViewCell.h
//  DigitsKit
//
//  Copyright © 2016 Twitter Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DGTAddressBookContact;

@interface DGTConfigurableTableViewCell : UITableViewCell

/**
 * Override this method in order to configure any visual aspects of the cell.
 */
- (void)configure:(DGTAddressBookContact *)contact;

@end
