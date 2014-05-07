//
//  QMChatViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 01/04/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatViewController.h"
#import "QMChatViewCell.h"
#import "QMChatDataSource.h"
#import "QMContactList.h"
#import "QMChatService.h"

static CGFloat const kCellHeightOffset = 33.0f;

@interface QMChatViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *inputMessageView;
@property (weak, nonatomic) IBOutlet UITextField *inputMessageTextField;
@property (nonatomic, strong) QMChatDataSource *dataSource;

@end

@implementation QMChatViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.chatName;
    self.dataSource = [[QMChatDataSource alloc] init];
    [self configureInputMessageViewShadow];
    [self addKeyboardObserver];

	QBUUser *user = [QMContactList shared].me;
    user.password = [[NSUserDefaults standardUserDefaults] objectForKey:kPassword];

	[self configureNavBarButtons];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureNavBarButtons
{
	UIButton *groupInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[groupInfoButton setFrame:CGRectMake(0, 0, 30, 40)];

	[groupInfoButton setImage:[UIImage imageNamed:@"ic_info_top"] forState:UIControlStateNormal];
	[groupInfoButton setImage:[UIImage imageNamed:@"ic_info_top"] forState:UIControlStateHighlighted];
	[groupInfoButton addTarget:self action:@selector(groupInfoNavButtonAction) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *groupInfoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:groupInfoButton];
	self.navigationItem.rightBarButtonItems = @[groupInfoBarButtonItem];
}


- (void)addKeyboardObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeViewWithKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeViewWithKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)configureInputMessageViewShadow
{
    self.inputMessageView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.inputMessageView.layer.shadowOffset = CGSizeMake(0, -1.0);
    self.inputMessageView.layer.shadowOpacity = 0.5;
    self.inputMessageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:[self.inputMessageView bounds]].CGPath;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource.chatHistory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QMChatViewCell *cell = (QMChatViewCell *)[tableView dequeueReusableCellWithIdentifier:kChatViewCellIdentifier];
    NSDictionary *messageDictionary = self.dataSource.chatHistory[indexPath.row];

    [cell configureCellWithMessage:messageDictionary fromUser:nil];

    return cell;
}

// height for cell:
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = self.dataSource.chatHistory[indexPath.row];
    if (kMessageString == nil) {
        return 0;
    }
    return [QMChatViewCell cellHeightForMessage:message] + kCellHeightOffset;
}


#pragma mark - Keyboard

- (void)resizeViewWithKeyboardNotification:(NSNotification *)notification
{
    NSDictionary * userInfo = notification.userInfo;
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    BOOL isKeyboardShow = !(keyboardFrame.origin.y == [[UIScreen mainScreen] bounds].size.height);
    
    NSInteger keyboardHeight = isKeyboardShow ? - keyboardFrame.size.height +49.0f: keyboardFrame.size.height -49.0f;
    
    [UIView animateWithDuration:animationDuration delay:0.0f options:animationCurve << 16 animations:^
     {
         CGRect frame = self.view.frame;
         frame.size.height += keyboardHeight;
         self.view.frame = frame;
         
         [self.view layoutIfNeeded];
         
     } completion:nil];
}

- (IBAction)hideKeyboard
{
	[self.inputMessageTextField resignFirstResponder];
	self.inputMessageTextField.text = kEmptyString;
}

#pragma mark - Nav Bar Buttons Actions
- (void)groupInfoNavButtonAction
{
	//
}


@end
