//
//  QMSystemMessageCell.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 17.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSystemMessageCell.h"

@interface QMSystemMessageCell()

@end

@implementation QMSystemMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    QMSystemMessageCell *cell = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    cell.backgroundColor = [UIColor colorWithWhite:0.943 alpha:1.000];
    
    return cell;
}

@end
