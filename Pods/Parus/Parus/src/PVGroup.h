//
//  PVGroup.h
//  Parus
//
//  Created by Алексей Демедецкий on 10.08.13.
//
//

#import <Foundation/Foundation.h>
#import "PVRoot.h"

@protocol _PVGroupProtocol;

typedef _PVRoot<_PVGroupProtocol> _PVGroup;

/// This call allow to perform next syntax:
/// PVGroup()
///     (.fromLeftToRight OR .fromRightToLeft OR .fromLeadingToTrailing)
///     (.withViews)
///     (.withMetrics)
///     .asArray
/// NSArray*;
///
/// Whrere, (...) is an optionall part.
/// All calls should be finished via .asArray; call. Or behavior is undefined.
/// Please, do not store any intermediate results.
/// Constraint inequality are guaranteed.

_PVGroup* PVGroup(NSArray* array);


@protocol _PVGroupArrayConversionProtocol

/// -asArray is finaliser for group syntax chain.
/// Each access to this property will cause items processing from very beginning.
/// For preoperty merging and supported class description - please refer to wiki
/// https://github.com/DAlOG/Parus/wiki/PVGroup()-description

@property (readonly) NSArray* asArray;

@end

typedef _PVRoot<_PVGroupArrayConversionProtocol> _PVGroupArrayConversion;
typedef _PVGroupArrayConversion* _PVGroupWithMetricsResult;
typedef _PVGroupWithMetricsResult(^_PVGroupWithMetricsBlock)(NSDictionary*);

@protocol _PVGroupWithMetricsProtocol

/// Set reecieved metrics into all VFL-based items.
///
/// Merge policy:
/// All metrics already existed in VFL context will not be replaced.
/// All other metrics will be added to VFL context only during finalization step.
///
@property (readonly) _PVGroupWithMetricsBlock withMetrics;

@end

typedef _PVRoot
        <
            _PVGroupArrayConversionProtocol,
            _PVGroupWithMetricsProtocol
        >
        _PVGroupWithViewsResult;
typedef _PVGroupWithViewsResult*(^_PVGroupWithViewsBlock)(NSDictionary*);

@protocol _PVGroupWithViewsProtocol

/// Set recieved views into all VFL based items
///
/// Merge policy:
/// All views already specified will not be replaced.
/// All new views will be added to context only dring a finalization step.
///
@property (readonly) _PVGroupWithViewsBlock withViews;

@end


typedef _PVRoot
        <
            _PVGroupArrayConversionProtocol,
            _PVGroupWithViewsProtocol,
            _PVGroupWithMetricsProtocol
        >
        _PVGroupDiretionChooseResult;
@protocol _PVGroupDirectionChooseProtocol

/// Next properties will set up direction into appropriate VFL contexts.
/// Merge policy:
/// Already specified direction will not be replaced.
///
/// Definition of direction option detected by equality check:
/// opt == NSLayoutFormatDirectionMask.
///
/// New value will be transported to VFL context only at finalising steps.

@property (readonly) _PVGroupDiretionChooseResult* fromLeftToRight;
@property (readonly) _PVGroupDiretionChooseResult* fromRightToLeft;
@property (readonly) _PVGroupDiretionChooseResult* fromLeadingToTrailing;

@end


/// Resulting protocol for PVGroup() call.
@protocol _PVGroupProtocol
<
    _PVGroupDirectionChooseProtocol,
    _PVGroupArrayConversionProtocol,
    _PVGroupWithViewsProtocol,
    _PVGroupWithMetricsProtocol
>

@end
