//
//  QMInviteFriendsDataSource.h
//  Q-municate
//
//  Created by Ivanov Andrey on 07.04.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

@interface QMInviteFriendsDataSource : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView;
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSArray *)facebookIDsToInvite;
- (NSArray *)emailsToInvite;

@end
