//
//  QMInviteFriendsDataSource.h
//  Q-municate
//
//  Created by lysenko.mykhayl on 4/4/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

@class QMPerson;



@interface QMInviteFriendsDataSource : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView;
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;


@end
