// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDUser.m instead.

#import "_CDUser.h"

const struct CDUserAttributes CDUserAttributes = {
	.email = @"email",
	.fullName = @"fullName",
	.id = @"id",
	.phone = @"phone",
	.profileType = @"profileType",
	.status = @"status",
};

const struct CDUserRelationships CDUserRelationships = {
	.dialogs = @"dialogs",
};

const struct CDUserFetchedProperties CDUserFetchedProperties = {
};

@implementation CDUserID
@end

@implementation _CDUser

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDUser" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDUser";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDUser" inManagedObjectContext:moc_];
}

- (CDUserID*)objectID {
	return (CDUserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic email;






@dynamic fullName;






@dynamic id;



- (int32_t)idValue {
	NSNumber *result = [self id];
	return [result intValue];
}

- (void)setIdValue:(int32_t)value_ {
	[self setId:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveIdValue {
	NSNumber *result = [self primitiveId];
	return [result intValue];
}

- (void)setPrimitiveIdValue:(int32_t)value_ {
	[self setPrimitiveId:[NSNumber numberWithInt:value_]];
}





@dynamic phone;






@dynamic profileType;






@dynamic status;






@dynamic dialogs;

	






@end
