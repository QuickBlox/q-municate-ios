# Parus

Parus is a small objective-c DSL for AutoLayout in code.

## Features
* It is easy to create constraints - just like writing a sentence;
* More compact and semantical than usual NSAutoLayout;
* Flexibility in creating constraints - you specify only parameters that you need;
* Autocomplete rocks!

## Usage
### Single constraint

NSLayoutConstraint:
```obj-c
[NSLayoutConstraint constraintWithItem:view
                             attribute:NSLayoutAttributeLeft
                             relatedBy:NSLayoutRelationEqual
                                toItem:superview
                             attribute:NSLayoutAttributeLeft
                            multiplier:2.0
                              constant:10];
```

Using Parus:
```obj-c
PVLeftOf(view).equalTo.leftOf(superview).multipliedTo(2).plus(10).asConstraint;
```

Using default values make it even shorter:
```obj-c
[NSLayoutConstraint constraintWithItem:view
                             attribute:NSLayoutAttributeLeft
                             relatedBy:NSLayoutRelationEqual
                                toItem:nil
                             attribute:NSLayoutAttributeNotAnAttribute
                            multiplier:1.0
                              constant:10];
```
```obj-c
PVLeftOf(view).equalTo.constant(10).asConstraint;
```

### Visual Formatting Language (VFL)

Simple VFL constraints:
```obj-c
[NSLayoutConstraint constraintsWithVisualFormat:@"|-padding-[view]-padding-|"
                                        options:(NSLayoutFormatAlignAllTop | 
                                                 NSLayoutFormatDirectionLeadingToTrailing)
                                        metrics:@{@"padding" : @20}
                                          views:NSDictionaryOfVariableBindings(view)];
```
```obj-c
PVVFL(@"|-padding-[view]-padding-|").alignAllTop.fromLeadingToTrailing.withViews(NSDictionaryOfVariableBindings(view)).metrics(@{@"padding": @20}).asArray;
```

With special masks and defaults:
```obj-c
[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view1][view2][view3]|"
                                        options:(NSLayoutFormatAlignAllLeft | 
                                                 NSLayoutFormatAlignAllRight)
                                        metrics:nil
                                          views:NSDictionaryOfVariableBindings(view1, view2, view3)];
```
```obj-c
PVVFL(@"V:|[view1][view2][view3]|").alignAllLeftAndRight.withViews(NSDictionaryOfVariableBindings(view1, view2, view3)).asArray;
```

### Groups

There is available feature that helps you group constraints and produce even less code.
Enjoy!
```obj-c
[someView addConstraint:[NSLayoutConstraint constraintWithItem:view
                           						     attribute:NSLayoutAttributeLeft
                             						 relatedBy:NSLayoutRelationEqual
                                						toItem:nil
                             						 attribute:NSLayoutAttributeNotAnAttribute
                            						multiplier:1.0
                              						  constant:10]];
[someView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view1][view2][view3]|"
                                        						 options:(NSLayoutFormatAlignAllLeft | 
                                                 						  NSLayoutFormatAlignAllRight)
                                        						 metrics:nil
                                          						   views:NSDictionaryOfVariableBindings(view1, view2, view3)]];
[someView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view1]|"
                                        						 options:NSLayoutFormatDirectionLeadingToTrailing
                                        						 metrics:nil
                                          						   views:NSDictionaryOfVariableBindings(view1)]];
```
```obj-c
[someView addConstraints:PVGroup(@[PVLeftOf(view).equalTo.constant(10),
								   PVVFL(@"V:|[view1][view2][view3]|").alignAllLeftAndRight,
								   PVVFL(@"H:|[view1]|")
								   ]).withViews(NSDictionaryOfVariableBindings(view1, view2, view3)).asArray];
```

You can also use usual ```NSLayoutConstraint``` or ```NSArray``` of ```NSLayoutConstraint``` as an item for ```PVGroup()```. Following code is totally acceptable:

```obj-c
NSLayoutConstraint* usualConstraint = [NSLayoutConstraint constraintWithItem:... blablabla very long constraint definition ...];
NSArray* usualConstraints = [NSLayoutConstraint constraintsWithVisualFormat:... blabla ...];

[someView addConstraints:PVGroup(@[usualConstraint, usualConstraints]).asArray];
```

## Alternatives

* [Masonry](https://github.com/cloudkite/Masonry)
* [NSLayoutEquations](https://github.com/gormster/NSLayoutEquations)

## Installation

Use [cocoapods](http://cocoapods.org/)!
```ruby
pod 'Parus'
```
```obj-c
#import <Parus/Parus.h>
```

## TODO

* Mac OS X support;
* Extend debug description;
* Category for NSString as a start point for creating VFL.

## More information

Visit our [wiki](https://github.com/DAlOG/Parus/wiki)

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/DAlOG/parus/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
