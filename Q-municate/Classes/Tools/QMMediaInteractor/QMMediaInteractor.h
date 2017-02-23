//
//  QMMediaInteractor.h
//  QMPLayer
//
//  Created by Vitaliy Gurkovsky on 1/30/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMInteractorDelegate.h"

@protocol QMPlayerService;

@interface QMMediaInteractor : NSObject <QMMediaInteractorInput>

@property (weak, nonatomic) id <QMMediaInteractorOutput> output;

@property (weak, nonatomic) id <QMPlayerService> playerService;


@end

@protocol QMPlayerService <NSObject>

- (void)activateMedia:(QMMediaItem *)item sender:(QMMediaInteractor *)sender;

@end

@protocol QMMediaAssistant <NSObject>

- (void)requestForMedia:(QMMediaItem *)item sender:(QMMediaInteractor *)sender;

@end
