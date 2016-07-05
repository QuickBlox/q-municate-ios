//
//  QMLocationViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/4/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMLocationViewController.h"

#import "QMMapView.h"
#import "QMLocationButton.h"
#import "QMLocationPinView.h"

static const CGFloat kQMLocationButtonSize = 44.0f;
static const CGFloat kQMLocationButtonSpacing = 16.0f;

static const CGFloat kQMLocationPinXShift = 3.0f;

@interface QMLocationViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate>
{
    QMMapView *_mapView;
    QMLocationButton *_locationButton;
    QMLocationPinView *_pinView;
    
    CLLocationManager *_locationManager;
    
    BOOL _initialPin;
    BOOL _userLocationChanged;
    BOOL _regionChanged;
}

@end

@implementation QMLocationViewController

#pragma mark - Construction

- (instancetype)init {
    
    self = [super init];
    if (self != nil) {
        
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithState:(QMLocationVCState)state {
    
    self = [super init];
    if (self != nil) {
        
        [self commonInit];
        
        _state = state;
        
        switch (state) {
                
            case QMLocationVCStateView:
                break;
                
            case QMLocationVCStateSend:
                [self configureSendState];
                break;
        }
    }
    
    return self;
}

- (instancetype)initWithState:(QMLocationVCState)state locationCoordinate:(CLLocationCoordinate2D)locationCoordinate {
    
    self = [self initWithState:state];
    if (self != nil) {
        
        [self setLocationCoordinate:locationCoordinate];
    }
    
    return self;
}

- (void)commonInit {
    
    self.title = NSLocalizedString(@"QM_STR_LOCATION", nil);
    
    _mapView = [[QMMapView alloc] initWithFrame:self.view.bounds];
    [_mapView setManipulationsEnabled:YES];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapView.delegate = self;
    
    [self.view addSubview:_mapView];
}

- (void)configureSendState {
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager requestWhenInUseAuthorization];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"QM_STR_SEND", nil) style:UIBarButtonItemStylePlain target:self action:@selector(_sendAction)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) style:UIBarButtonItemStylePlain target:self action:@selector(_cancelAction)];
    
    CGFloat shift = kQMLocationButtonSize + kQMLocationButtonSpacing;
    _locationButton = [[QMLocationButton alloc]
                       initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - shift,
                                                CGRectGetHeight(self.view.bounds) - shift,
                                                kQMLocationButtonSize,
                                                kQMLocationButtonSize)];
    _locationButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [_locationButton addTarget:self action:@selector(_updateUserLocation) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_locationButton];
    
    _pinView = [[QMLocationPinView alloc] init];
    _pinView.frame = CGRectMake(CGRectGetWidth(_mapView.frame) / 2.0f - QMLocationPinViewOriginPinCenter,
                                CGRectGetHeight(_mapView.frame) / 2.0f - kQMLocationPinXShift,
                                CGRectGetWidth(_pinView.frame),
                                CGRectGetHeight(_pinView.frame));
    
    [_mapView addSubview:_pinView];
}

#pragma mark - Setters

- (void)setLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate {
    
    [_mapView markCoordinate:locationCoordinate animated:NO];
}

#pragma mark - Private

- (void)_sendAction {
    
    self.sendButtonPressed(_mapView.centerCoordinate);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_cancelAction {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_showLocationRestrictedAlert {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"QM_STR_LOCATION_ERROR", nil)
                                          message:NSLocalizedString(@"QM_STR_NO_PERMISSIONS_TO_LOCATION", nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_SETTINGS", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)_updateUserLocation {
    
    if (_userLocationChanged || _regionChanged) {
        
        [_locationButton setLoadingState:YES];
        [self _setRegionForCoordinate:_mapView.userLocation.coordinate];
        
        _userLocationChanged = NO;
        _regionChanged = NO;
    }
}

- (void)_setRegionForCoordinate:(CLLocationCoordinate2D)coordinate {
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, MKCoordinateSpanDefaultValue, MKCoordinateSpanDefaultValue);
    [_mapView setRegion:region animated:YES];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)__unused manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    switch (status) {
            
        case kCLAuthorizationStatusNotDetermined:
            break;
            
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            
            _locationButton.hidden = YES;
            [self _showLocationRestrictedAlert];
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            
            _locationButton.hidden = NO;
            _mapView.showsUserLocation = YES;
            break;
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)__unused mapView didUpdateUserLocation:(MKUserLocation *)__unused userLocation {
    
    _userLocationChanged = YES;
    
    if (!_initialPin) {
        
        [self _updateUserLocation];
        _initialPin = YES;
    }
}

- (void)mapView:(MKMapView *)__unused mapView regionWillChangeAnimated:(BOOL)__unused animated {
    
    [_pinView setPinRaised:YES animated:YES];
}

- (void)mapView:(MKMapView *)__unused mapView regionDidChangeAnimated:(BOOL)__unused animated {
    
    if (_locationButton.loadingState) {
        
        [_locationButton setLoadingState:NO];
    }
    else {
        
        _regionChanged = YES;
    }
    
    [_pinView setPinRaised:NO animated:YES];
}

@end
