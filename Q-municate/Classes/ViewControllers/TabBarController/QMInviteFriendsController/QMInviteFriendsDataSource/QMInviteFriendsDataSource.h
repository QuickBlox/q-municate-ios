//
//  QMInviteFriendsDataSource.h
//  Q-municate
//
//  Created by Andrey Ivanov on 07.04.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//


@protocol QMCheckBoxStateDelegate <NSObject>
@optional
- (void)checkListDidchangeCount:(NSInteger)checkedCount;
@end



@interface QMInviteFriendsDataSource : NSObject

@property (weak, nonatomic) id <QMCheckBoxStateDelegate> checkBoxDelegate;

- (instancetype)initWithTableView:(UITableView *)tableView;
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)facebookIDsToInvite;
- (NSArray *)emailsToInvite;
- (void)clearABFriendsToInvite;
- (void)clearFBFriendsToInvite;

@end
