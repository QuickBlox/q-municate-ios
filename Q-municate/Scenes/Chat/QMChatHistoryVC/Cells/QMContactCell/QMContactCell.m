//
//  QMContactCell.m
//  Q-municate
//
//  Created by Andrey Ivanov on 23.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMContactCell.h"
#import "QMImageView.h"

@interface QMContactCell()

@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet QMImageView *qmImageView;

@end

@implementation QMContactCell

#pragma mark - Override

+ (NSString *)cellIdentifier {
    
    static NSString *cellIdentifier = @"QMContactCell";
    return cellIdentifier;
}

#pragma mark - Setters


#pragma mark - Actions

- (IBAction)pressAddBtn:(id)sender {
    
    [self.delegate contactCell:self onPressAddBtn:sender];
}

@end
