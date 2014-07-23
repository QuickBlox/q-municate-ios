
//  QMChatVC.m
//  Q-municate
//
//  Created by Ivanov Andrey Ivanov on 11.06.14.
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
#import "QMSoundManager.h"
#import "Parus.h"

static void * kQMKeyValueObservingContext = &kQMKeyValueObservingContext;

@interface QMChatVC ()

<UITableViewDelegate, QMKeyboardControllerDelegate, QMChatInputToolbarDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AGEmojiKeyboardViewDataSource, AGEmojiKeyboardViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) QMChatInputToolbar *inputToolBar;
@property (strong, nonatomic) QMKeyboardController *keyboardController;

@property (weak, nonatomic) NSLayoutConstraint *toolbarHeightConstraint;
@property (weak, nonatomic) NSLayoutConstraint *toolbarBottomLayoutGuide;

@property (assign, nonatomic) CGFloat statusBarChangeInHeight;

@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *emojiButton;

@property (assign, nonatomic) BOOL showCameraButton;

@end

@implementation QMChatVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureChatVC];
    [self registerForNotifications:YES];
    self.keyboardController = [[QMKeyboardController alloc] initWithTextView:self.inputToolBar.contentView.textView
                                                                 contextView:self.navigationController.view
                                                        panGestureRecognizer:self.tableView.panGestureRecognizer
                                                                    delegate:self];
    _showCameraButton = YES;
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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self updateKeyboardTriggerPoint];
}

- (void)updateKeyboardTriggerPoint {
    
    self.keyboardController.keyboardTriggerPoint = CGPointMake(0.0f, CGRectGetHeight(self.inputToolBar.bounds));
}

#pragma mark - Configure ChatVC

- (void)configureInputView {
    
    self.cameraButton = [QMChatButtonsFactory cameraButton];
    self.sendButton = [QMChatButtonsFactory sendButton];
    self.emojiButton = [QMChatButtonsFactory emojiButton];
    
    self.inputToolBar.contentView.leftBarButtonItem = self.emojiButton;
    self.inputToolBar.contentView.rightBarButtonItem = self.cameraButton;
    
    self.inputToolBar.contentView.rightBarButtonItemWidth = 26;
    self.inputToolBar.contentView.leftBarButtonItemWidth = 26;
}

- (void)configureChatVC {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.inputToolBar = [[QMChatInputToolbar alloc] init];
    [self configureInputView];
    
    self.inputToolBar.delegate = self;
    self.inputToolBar.contentView.textView.delegate =self;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.inputToolBar];
    
    [self configureChatContstraints];
}

- (void)configureChatContstraints {
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.toolbarHeightConstraint = PVHeightOf(self.inputToolBar).equalTo.constant(kQMChatInputToolbarHeightDefault).asConstraint;
    self.toolbarBottomLayoutGuide = PVBottomOf(self.inputToolBar).equalTo.bottomOf(self.view).asConstraint;
    
    [self.view addConstraints:PVGroup(@[
                                        PVTopOf(self.view).equalTo.topOf(self.tableView),
                                        PVLeadingOf(self.view).equalTo.leadingOf(self.tableView),
                                        PVTrailingOf(self.view).equalTo.trailingOf(self.tableView),
                                        PVTrailingOf(self.view).equalTo.trailingOf(self.inputToolBar),
                                        PVLeadingOf(self.view).equalTo.leadingOf(self.inputToolBar),
                                        self.toolbarBottomLayoutGuide,
                                        self.toolbarHeightConstraint,
                                        PVTopOf(self.inputToolBar).equalTo.bottomOf(self.tableView),
                                        ]).asArray];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMMessage *message = self.dataSource.messages[indexPath.row];
    return message.messageSize.height;
}

#pragma mark - QMKeyboardControllerDelegate

- (void)keyboardDidChangeFrame:(CGRect)keyboardFrame {
    
    CGFloat heightFromBottom = keyboardFrame.origin.y - CGRectGetMaxY(self.view.frame);
    [self setToolbarBottomLayoutGuideConstant:heightFromBottom];
}

- (void)setToolbarBottomLayoutGuideConstant:(CGFloat)constant {
    
    self.toolbarBottomLayoutGuide.constant = constant;
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

- (void)removeObservers {
    
    @try {
        [self.inputToolBar.contentView.textView removeObserver:self
                                                    forKeyPath:NSStringFromSelector(@selector(contentSize))
                                                       context:kQMKeyValueObservingContext];
    }
    @catch (NSException * __unused exception) { }
}

- (void)addObservers {
    
    [self.inputToolBar.contentView.textView addObserver:self
                                             forKeyPath:NSStringFromSelector(@selector(contentSize))
                                                options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                                context:kQMKeyValueObservingContext];
}

- (void)registerForNotifications:(BOOL)registerForNotifications {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    if (registerForNotifications) {
        [notificationCenter addObserver:self
                               selector:@selector(handleDidChangeStatusBarFrameNotification:)
                                   name:UIApplicationDidChangeStatusBarFrameNotification
                                 object:nil];
    }
    else {
        [notificationCenter removeObserver:self
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
            [self.inputToolBar.contentView.textView resignFirstResponder];
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
    
    [self.dataSource scrollToBottomAnimated:NO];
}

- (void)setShowCameraButton:(BOOL)showCameraButton {
    
    if (_showCameraButton != showCameraButton) {
        _showCameraButton = showCameraButton;
        if (_showCameraButton) {
            self.inputToolBar.contentView.rightBarButtonItem = self.cameraButton;
            self.inputToolBar.contentView.rightBarButtonItemWidth = 26.0f;
        }else {
            self.inputToolBar.contentView.rightBarButtonItem = self.sendButton;
            self.inputToolBar.contentView.rightBarButtonItemWidth = 44.0f;
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    
    self.showCameraButton = textView.text.length == 0;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    [textView resignFirstResponder];
}

#pragma mark - Key-value observing for content size

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == kQMKeyValueObservingContext) {
        
        if (object == self.inputToolBar.contentView.textView && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            
            CGSize oldContentSize = [[change objectForKey:NSKeyValueChangeOldKey] CGSizeValue];
            CGSize newContentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
            
            CGFloat dy = newContentSize.height - oldContentSize.height;
            
            [self adjustInputToolbarForComposerTextViewContentSizeChange:dy];
            [self.dataSource scrollToBottomAnimated:NO];
        }
    }
}

- (void)adjustInputToolbarForComposerTextViewContentSizeChange:(CGFloat)dy {
    
    BOOL contentSizeIsIncreasing = (dy > 0);
    
    UITextView *textView = self.inputToolBar.contentView.textView;
    int numLines = textView.contentSize.height / textView.font.leading;
    
    if ([self inputToolbarHasReachedMaximumHeight] || numLines >= 4) {
        
        BOOL contentOffsetIsPositive = (self.inputToolBar.contentView.textView.contentOffset.y > 0);
        if (contentSizeIsIncreasing || contentOffsetIsPositive) {
            [self scrollComposerTextViewToBottomAnimated:YES];
            return;
        }
    }
    
    CGFloat toolbarOriginY = CGRectGetMinY(self.inputToolBar.frame);
    CGFloat newToolbarOriginY = toolbarOriginY - dy;
    
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
    
    float h = self.toolbarHeightConstraint.constant + dy;
    
    if (h < kQMChatInputToolbarHeightDefault) {
        self.toolbarHeightConstraint.constant = kQMChatInputToolbarHeightDefault;
    }else {
        self.toolbarHeightConstraint.constant = h;
    }
    
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

- (void)scrollComposerTextViewToBottomAnimated:(BOOL)animated {
    
    UITextView *textView = self.inputToolBar.contentView.textView;
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
    
    return (CGRectGetMinY(self.inputToolBar.frame) == self.topLayoutGuide.length);
}

#pragma mark - QMChatInputToolbarDelegate

- (void)chatInputToolbar:(QMChatInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender {
    
    if (sender == self.sendButton) {
        
        NSString *text = self.inputToolBar.contentView.textView.text;
        self.inputToolBar.contentView.textView.text = @"";
        [QMSoundManager playMessageSentSound];
        [self.dataSource sendMessage:text];
    }
    else {
        [self presentImagePicker];
    }
}

- (void)chatInputToolbar:(QMChatInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender {
    
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

- (void)showEmojiKeyboard {
    
    if ([self.inputToolBar.contentView.textView.inputView isKindOfClass:[AGEmojiKeyboardView class]]) {
      
        self.inputToolBar.contentView.textView.inputView = nil;
        [self.inputToolBar.contentView.textView reloadInputViews];
        
    } else {
        
        AGEmojiKeyboardView *emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216) dataSource:self];
        emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        emojiKeyboardView.delegate = self;
        emojiKeyboardView.tintColor = [UIColor colorWithRed:0.678 green:0.762 blue:0.752 alpha:1.000];
        
        self.inputToolBar.contentView.textView.inputView = emojiKeyboardView;
        [self.inputToolBar.contentView.textView reloadInputViews];
        [self.inputToolBar.contentView.textView becomeFirstResponder];
    }
}


- (NSArray *)sectionsImages {
    return @[@"😊", @"😊", @"🎍", @"🐶", @"🏠", @"🕘", @"Back"];
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
    
    [self textViewDidChange:self.inputToolBar.contentView.textView];
    NSString *textViewString = self.inputToolBar.contentView.textView.text;
    self.inputToolBar.contentView.textView.text = [textViewString stringByAppendingString:emoji];
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    
    self.inputToolBar.contentView.textView.inputView = nil;
    [self.inputToolBar.contentView.textView reloadInputViews];
}

@end
