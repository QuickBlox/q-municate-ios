//
//  QMContentPreviewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 29/05/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMContentPreviewController.h"

@interface QMContentPreviewController ()

@property (weak, nonatomic) IBOutlet UIImageView *contentView;

@end

@implementation QMContentPreviewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.contentImage != nil) {
        [self.contentView setImage:self.contentImage];
    } else if (self.imageURL != nil) {
        // TODO:
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
