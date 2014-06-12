//
//  QMGroupDetailsController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 12/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMGroupDetailsController.h"
#import <AsyncImageView.h>

@interface QMGroupDetailsController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet AsyncImageView *groupAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *occupantsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineOccupantsCountLabel;

@end

@implementation QMGroupDetailsController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showQBChatDialogDetails:(QBChatDialog *)chatDialog
{
    if (chatDialog != nil && chatDialog.type == QBChatDialogTypeGroup) {
        
        // set group name
        self.groupNameLabel.text = chatDialog.name;
        
        // 
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
