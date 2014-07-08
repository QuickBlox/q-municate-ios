
//  QMChatVC.m
//  Q-municate
//
//  Created by Andrey on 11.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatVC.h"
#import "QMChatInputToolbar.h"
#import "QMMessage.h"
#import "QMChatDataSource.h"
#import "QMKeyboardController.h"
#import "QMChatToolbarContentView.h"
#import "QMChatInputTextView.h"
#import "QMChatButtonsFactory.h"
#import "AGEmojiKeyBoardView.h"
#import "Parus.h"

static void * kQMKeyValueObservingContext = &kQMKeyValueObservingContext;

@interface QMChatVC ()

<UITableViewDelegate, QMKeyboardControllerDelegate, QMChatInputToolbarDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AGEmojiKeyboardViewDataSource, AGEmojiKeyboardViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) QMChatInputToolbar *inputView;
@property (strong, nonatomic) UIView *tableViewHeaderView;
@property (strong, nonatomic) QMKeyboardController *keyboardController;

@property (weak, nonatomic) NSLayoutConstraint *toolbarHeightConstraint;
@property (weak, nonatomic) NSLayoutConstraint *toolbarBottomLayoutGuide;

@property (assign, nonatomic) CGFloat statusBarChangeInHeight;

@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *cameraButton;

@end

@implementation QMChatVC


- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureChatVC];
    
    [self registerForNotifications:YES];

    self.keyboardController = [[QMKeyboardController alloc] initWithTextView:self.inputView.contentView.textView
                                                                 contextView:self.view
                                                        panGestureRecognizer:self.tableView.panGestureRecognizer
                                                                    delegate:self];
}


- (void)dealloc {
    
    [self registerForNotifications:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self addObservers];
    [self addActionToInteractivePopGestureRecognizer:YES];
    [self.keyboardController beginListeningForKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self addActionToInteractivePopGestureRecognizer:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    [self removeObservers];
    [self.keyboardController endListeningForKeyboard];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
//    [self.view layoutIfNeeded];
    
    if (self.automaticallyScrollsToMostRecentMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollToBottomAnimated:NO];
        });
    }
    
    [self updateKeyboardTriggerPoint];
}

- (void)updateKeyboardTriggerPoint {
    
    self.keyboardController.keyboardTriggerPoint = CGPointMake(0.0f, CGRectGetHeight(self.inputView.bounds));
}

#pragma mark - Configure ChatVC

- (void)configureInputView
{
    self.cameraButton = [QMChatButtonsFactory cameraButton];
    self.sendButton = [QMChatButtonsFactory sendButton];
    
    self.inputView.contentView.leftBarButtonItem = [QMChatButtonsFactory emojiButton];
    self.inputView.contentView.rightBarButtonItem = self.cameraButton;
    self.inputView.contentView.rightBarButtonItemWidth = 26;      // 26 for camera and  44 for send button
    self.inputView.contentView.leftBarButtonItemWidth = 26;
    
    self.cameraButton = self.inputView.contentView.leftBarButtonItem;
    
}

- (void)configureChatVC {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.inputView = [[QMChatInputToolbar alloc] init];
    [self configureInputView];
    
    self.inputView.delegate = self;
    self.inputView.contentView.textView.delegate =self;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.inputView];
    
    [self configureChatContstraints];
}

- (void)configureChatContstraints {
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraints:PVGroup(@[
                                        PVTopOf(self.view).equalTo.topOf(self.tableView),
                                        PVBottomOf(self.view).equalTo.bottomOf(self.tableView),
                                        PVLeadingOf(self.view).equalTo.leadingOf(self.tableView),
                                        PVTrailingOf(self.view).equalTo.trailingOf(self.tableView)]).asArray];
    
    self.toolbarHeightConstraint = PVHeightOf(self.inputView).equalTo.constant(kQMChatInputToolbarHeightDefault).asConstraint;
    self.toolbarBottomLayoutGuide = PVBottomOf(self.inputView).equalTo.bottomOf(self.view).asConstraint;
    
    [self.view addConstraints:PVGroup(@[
                                        PVTrailingOf(self.view).equalTo.trailingOf(self.inputView),
                                        PVLeadingOf(self.view).equalTo.leadingOf(self.inputView),
                                        self.toolbarBottomLayoutGuide,
                                        self.toolbarHeightConstraint
                                        ]).asArray];
}

- (void)setDataSource:(QMChatDataSource *)dataSource {
    
    _dataSource = dataSource;
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    
    if (self.dataSource.qmChatHistory.count > 0) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataSource.qmChatHistory.count-1 inSection:0];
        
        if (indexPath > 0) {
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
            
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMMessage *message = self.dataSource.qmChatHistory[indexPath.row];
    return message.messageSize.height;
}

#pragma mark - QMKeyboardControllerDelegate

- (void)keyboardDidChangeFrame:(CGRect)keyboardFrame {
    
    CGFloat heightFromBottom = CGRectGetHeight(self.tableView.frame) - CGRectGetMinY(keyboardFrame);
    
    heightFromBottom = MAX(0.0f, heightFromBottom + self.statusBarChangeInHeight);
    
    [self setToolbarBottomLayoutGuideConstant:heightFromBottom];
}

- (void)setToolbarBottomLayoutGuideConstant:(CGFloat)constant {
    
    self.toolbarBottomLayoutGuide.constant = -constant;
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
    
    [self updateTableViewInsets];
}

- (void)updateTableViewInsets {
    
    [self setTableViewInsetsTopValue:self.topLayoutGuide.length
                         bottomValue:CGRectGetHeight(self.tableView.frame) - CGRectGetMinY(self.inputView.frame)];
}

- (void)setTableViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom {
    
    UIEdgeInsets insets = UIEdgeInsetsMake(top, 0.0f, bottom, 0.0f);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
}

- (void)removeObservers {
    
    @try {
        [self.inputView.contentView.textView removeObserver:self
                                                 forKeyPath:NSStringFromSelector(@selector(contentSize))
                                                    context:kQMKeyValueObservingContext];
    }
    @catch (NSException * __unused exception) { }
}

- (void)addObservers {

    [self.inputView.contentView.textView addObserver:self
                                          forKeyPath:NSStringFromSelector(@selector(contentSize))
                                             options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                             context:kQMKeyValueObservingContext];
}

- (void)registerForNotifications:(BOOL)registerForNotifications {
    
    if (registerForNotifications) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDidChangeStatusBarFrameNotification:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidChangeStatusBarFrameNotification
                                                      object:nil];
    }
}

- (void)addActionToInteractivePopGestureRecognizer:(BOOL)addAction {
    
    if (self.navigationController.interactivePopGestureRecognizer) {
        [self.navigationController.interactivePopGestureRecognizer removeTarget:nil
                                                                         action:@selector(handleInteractivePopGestureRecognizer:)];
        
        if (addAction) {
            [self.navigationController.interactivePopGestureRecognizer addTarget:self
                                                                          action:@selector(handleInteractivePopGestureRecognizer:)];
        }
    }
}

- (void)handleDidChangeStatusBarFrameNotification:(NSNotification *)notification {
    
    CGRect previousStatusBarFrame = [[[notification userInfo] objectForKey:UIApplicationStatusBarFrameUserInfoKey] CGRectValue];
    CGRect currentStatusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    CGFloat statusBarHeightDelta = CGRectGetHeight(currentStatusBarFrame) - CGRectGetHeight(previousStatusBarFrame);
    self.statusBarChangeInHeight = MAX(statusBarHeightDelta, 0.0f);
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        self.statusBarChangeInHeight = 0.0f;
    }
}

#pragma mark - Gesture recognizers

- (void)handleInteractivePopGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self.keyboardController endListeningForKeyboard];
            [self.inputView.contentView.textView resignFirstResponder];
            [UIView animateWithDuration:0.0
                             animations:^{
                                 [self setToolbarBottomLayoutGuideConstant:0.0f];
                             }];
        }
            break;
        case UIGestureRecognizerStateChanged:
            //  TODO: handle this animation better
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            [self.keyboardController beginListeningForKeyboard];
            break;
        default:
            break;
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    [textView becomeFirstResponder];
    
    if (self.automaticallyScrollsToMostRecentMessage) {
        [self scrollToBottomAnimated:YES];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    
#warning ToggleSendButton disabled
//    [self.inputView toggleSendButtonEnabled];
    
    if (textView.text.length > 0) {
        self.inputView.contentView.rightBarButtonItemWidth = 44.0f;
        self.inputView.contentView.rightBarButtonItem = self.sendButton;
    } else {
        self.inputView.contentView.rightBarButtonItemWidth = 26.0f;
        self.inputView.contentView.rightBarButtonItem = self.cameraButton;
    }
    [self.inputView.contentView layoutIfNeeded];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    [textView resignFirstResponder];
}

#pragma mark - Key-value observing for content size

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == kQMKeyValueObservingContext) {
        
        if (object == self.inputView.contentView.textView && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            
            CGSize oldContentSize = [[change objectForKey:NSKeyValueChangeOldKey] CGSizeValue];
            CGSize newContentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
            
            CGFloat dy = newContentSize.height - oldContentSize.height;
            
            [self adjustInputToolbarForComposerTextViewContentSizeChange:dy];
            [self updateCollectionViewInsets];
            
            if (self.automaticallyScrollsToMostRecentMessage) {
                [self scrollToBottomAnimated:NO];
            }
        }
    }
}

- (void)adjustInputToolbarForComposerTextViewContentSizeChange:(CGFloat)dy {
    
    BOOL contentSizeIsIncreasing = (dy > 0);
    
    if ([self inputToolbarHasReachedMaximumHeight]) {
        BOOL contentOffsetIsPositive = (self.inputView.contentView.textView.contentOffset.y > 0);
        
        if (contentSizeIsIncreasing || contentOffsetIsPositive) {
            [self scrollComposerTextViewToBottomAnimated:YES];
            return;
        }
    }
    
    CGFloat toolbarOriginY = CGRectGetMinY(self.inputView.frame);
    CGFloat newToolbarOriginY = toolbarOriginY - dy;
    
    //  attempted to increase origin.Y above topLayoutGuide
    if (newToolbarOriginY <= self.topLayoutGuide.length) {
        dy = toolbarOriginY - self.topLayoutGuide.length;
        [self scrollComposerTextViewToBottomAnimated:YES];
    }
    
    [self adjustInputToolbarHeightConstraintByDelta:dy];
    
    [self updateKeyboardTriggerPoint];
    
    if (dy < 0) {
        [self scrollComposerTextViewToBottomAnimated:NO];
    }
}

- (void)adjustInputToolbarHeightConstraintByDelta:(CGFloat)dy {
    
    self.toolbarHeightConstraint.constant += dy;
    
    if (self.toolbarHeightConstraint.constant < kQMChatInputToolbarHeightDefault) {
        self.toolbarHeightConstraint.constant = kQMChatInputToolbarHeightDefault;
    }
    
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

- (void)scrollComposerTextViewToBottomAnimated:(BOOL)animated {
    
    UITextView *textView = self.inputView.contentView.textView;
    CGPoint contentOffsetToShowLastLine = CGPointMake(0.0f, textView.contentSize.height - CGRectGetHeight(textView.bounds));
    
    if (!animated) {
        textView.contentOffset = contentOffsetToShowLastLine;
        return;
    }
    
    [UIView animateWithDuration:0.01
                          delay:0.01
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         textView.contentOffset = contentOffsetToShowLastLine;
                     }
                     completion:nil];
}

- (BOOL)inputToolbarHasReachedMaximumHeight {
    
    return (CGRectGetMinY(self.inputView.frame) == self.topLayoutGuide.length);
}

- (void)updateCollectionViewInsets {
    
    [self setTableViewInsetsTopValue:self.topLayoutGuide.length
                         bottomValue:CGRectGetHeight(self.tableView.frame) - CGRectGetMinY(self.inputView.frame)];
}

- (NSString *)currentlyComposedMessageText {
    
    NSString *text = self.inputView.contentView.textView.text;
    self.inputView.contentView.textView.text = [text stringByAppendingString:@" "];
    
    return self.inputView.contentView.textView.text;
}

#pragma mark - QMChatInputToolbarDelegate

- (void)chatInputToolbar:(QMChatInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender {
    
//    if (toolbar.sendButtonOnRight) {
//        [self didPressSendButton:sender
//                 withMessageText:[self currentlyComposedMessageText]
//                            date:[NSDate date]];
//    }
//    else {
//        [self didPressAccessoryButton:sender];
//    }
    
    if ((UIButton *)sender == self.sendButton) {
        [self.dataSource sendMessage:[self currentlyComposedMessageText]];
    }
    else {
        [self presentImagePicker];
    }
}

- (void)chatInputToolbar:(QMChatInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender {
    
//    if (toolbar.sendButtonOnRight) {
//        [self didPressAccessoryButton:sender];
//    }
//    else {
//        [self didPressSendButton:sender
//                 withMessageText:[self currentlyComposedMessageText]
//                            date:[NSDate date]];
//    }
    [self showEmojiKeyboard];
    
}


#pragma mark - ImagePicker & UIImagePickerControllerDelegate

- (void)presentImagePicker {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = @[(NSString *) kUTTypeImage]; //(NSString *) kUTTypeMovie
    imagePicker.allowsEditing = YES;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *editImage = info[ UIImagePickerControllerEditedImage];
        [self.dataSource sendImage:editImage];
        
    }
}


#pragma mark - Emoji

- (void)showEmojiKeyboard
{
    AGEmojiKeyboardView *emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216) dataSource:self];
    emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    emojiKeyboardView.delegate = self;
    
    self.inputView.contentView.textView.inputView = emojiKeyboardView;
    emojiKeyboardView.tintColor = [UIColor grayColor];
    
    if ([self.inputView.contentView.textView isFirstResponder]) {
        
        [self.inputView.contentView.textView reloadInputViews];
        return;
    }
    [self.inputView.contentView.textView becomeFirstResponder];
}


- (NSArray *)sectionsImages {
    return @[@"😊", @"😊",@"🎍",@"🐶",@"🏠",@"🕘", @"✔"];
}


- (UIImage *)randomImage:(NSInteger)categoryImage {
    CGSize size = CGSizeMake(30, 30);
    UIGraphicsBeginImageContextWithOptions(size , NO, 0);
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[UIFont systemFontOfSize:27] forKey:NSFontAttributeName];
    NSString * sectionImage = self.sectionsImages[categoryImage];
    [sectionImage drawInRect:CGRectMake(0, 0, 30, 30) withAttributes:attributes];

    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


#pragma mark - Emoji Data source

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage:category];
    
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage:category];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    UIImage *img = [self randomImage:6];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}


#pragma Emoji Delegate

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    NSString *textViewString = self.inputView.contentView.textView.text;
    self.inputView.contentView.textView.text = [textViewString stringByAppendingString:emoji];
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    
    self.inputView.contentView.textView.inputView = nil;
    [self.inputView.contentView.textView reloadInputViews];
}

@end
