// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDLinkPreview.m instead.

#import "_CDLinkPreview.h"

@implementation CDLinkPreviewID
@end

@implementation _CDLinkPreview

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDLinkPreview" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDLinkPreview";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDLinkPreview" inManagedObjectContext:moc_];
}

- (CDLinkPreviewID*)objectID {
	return (CDLinkPreviewID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"heightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"height"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"widthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"width"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic height;

- (int16_t)heightValue {
	NSNumber *result = [self height];
	return [result shortValue];
}

- (void)setHeightValue:(int16_t)value_ {
	[self setHeight:@(value_)];
}

- (int16_t)primitiveHeightValue {
	NSNumber *result = [self primitiveHeight];
	return [result shortValue];
}

- (void)setPrimitiveHeightValue:(int16_t)value_ {
	[self setPrimitiveHeight:@(value_)];
}

@dynamic imageURL;

@dynamic siteDescription;

@dynamic title;

@dynamic url;

@dynamic width;

- (int16_t)widthValue {
	NSNumber *result = [self width];
	return [result shortValue];
}

- (void)setWidthValue:(int16_t)value_ {
	[self setWidth:@(value_)];
}

- (int16_t)primitiveWidthValue {
	NSNumber *result = [self primitiveWidth];
	return [result shortValue];
}

- (void)setPrimitiveWidthValue:(int16_t)value_ {
	[self setPrimitiveWidth:@(value_)];
}

@end

@implementation CDLinkPreviewAttributes 
+ (NSString *)height {
	return @"height";
}
+ (NSString *)imageURL {
	return @"imageURL";
}
+ (NSString *)siteDescription {
	return @"siteDescription";
}
+ (NSString *)title {
	return @"title";
}
+ (NSString *)url {
	return @"url";
}
+ (NSString *)width {
	return @"width";
}
@end

