//
//  QMHelpers.m
//  Q-municate
//
//  Created by Andrey Ivanov on 05.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMHelpers.h"

BOOL FloatAlmostEqual(double x, double y, double delta) {
    return fabs(x - y) <= delta;
}

