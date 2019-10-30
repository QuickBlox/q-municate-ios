//
//  QMValidationCell.h
//  Q-municate
//
//
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMValidationCell.h"

@interface QMValidationCell()

@property (weak, nonatomic) IBOutlet UILabel *validationLabel;

@end

@implementation QMValidationCell

- (void)setValidationErrorText:(NSString *)text {
    self.validationLabel.text = text;
}

@end
