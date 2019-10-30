//
//  QMContactCell.m
//  Q-municate
//
//  Created by Injoit on 3/1/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMSearchCell.h"
#import "QMCore.h"

@interface QMSearchCell ()

@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;

@end

@implementation QMSearchCell

+ (CGFloat)height {
    
    return 50.0f;
}

//MARK: - setters

- (void)setAddButtonVisible:(BOOL)visible {
    
    self.addFriendButton.hidden = !visible;
}
 
//MARK: - action

- (IBAction)didTapAddButton {
    
    self.didAddUserBlock(self);
}

@end
