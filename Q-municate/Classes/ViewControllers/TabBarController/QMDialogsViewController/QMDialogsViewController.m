//
//  QMDialogsViewController.m
//  Q-municate
//
//  Created by Andrey Ivanov on 30/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMDialogsViewController.h"
#import "QMChatViewController.h"
#import "QMCreateNewChatController.h"
#import "TWMessageBarManager.h"
#import "QMDialogsDataSource.h"
#import "QMChatReceiver.h"
#import "QMApi.h"

static NSString *const ChatListCellIdentifier = @"ChatListCell";

@interface QMDialogsViewController ()

<UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) QMDialogsDataSource *dataSource;

@end

@implementation QMDialogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.dataSource = [[QMDialogsDataSource alloc] initWithTableView:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:kChatViewSegueIdentifier sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kChatViewSegueIdentifier]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        QMChatViewController *chatController = segue.destinationViewController;
        QBChatDialog *dialog = [self.dataSource dialogAtIndexPath:indexPath];
        chatController.dialog = dialog;
        
    } else if ([segue.destinationViewController isKindOfClass:[QMCreateNewChatController class]]) {
        
    }
}

#pragma mark - Actions

- (IBAction)createNewDialog:(id)sender {
    [self performSegueWithIdentifier:@"CreateNewChatSegue" sender:nil];
}

@end
