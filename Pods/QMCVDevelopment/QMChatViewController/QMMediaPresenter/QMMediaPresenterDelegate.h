//
//  QMMediaPresenterDelegate.h
//  QMPLayer
//
//  Created by Vitaliy Gurkovsky on 1/30/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMMediaPresenterInputOutput.h"



@protocol QMMediaViewDelegate;
@protocol QMPlayerService;
@protocol QMMediaAssistant;
@protocol QMEventHandler;

@protocol QMMediaPresenterDelegate <QMMediaPresenterInput, QMMediaPresenterOutput>

@property (weak, nonatomic) id <QMMediaViewDelegate> view;

- (instancetype)initWithView:(id <QMMediaViewDelegate>)view;

@property (weak, nonatomic) id <QMPlayerService> playerService;
@property (weak, nonatomic) id <QMMediaAssistant> mediaAssistant;
@property (weak, nonatomic) id <QMEventHandler> eventHandler;

@end


@protocol QMPlayerService <NSObject>

- (void)activateMediaWithSender:(id <QMMediaPresenterDelegate>)sender;
- (void)requestPlayingStatus:(id <QMMediaPresenterDelegate>)sender;

@end

@protocol QMMediaAssistant <NSObject>

- (void)requestForMediaWithSender:(id <QMMediaPresenterDelegate>)sender;

@end

@protocol QMEventHandler <NSObject>

- (void)didTapContainer:(id <QMMediaPresenterDelegate>)sender;


@end
