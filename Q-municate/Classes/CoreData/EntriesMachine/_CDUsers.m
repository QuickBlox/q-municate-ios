// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDUsers.m instead.

#import "_CDUsers.h"

const struct CDUsersAttributes CDUsersAttributes = {
	.externalUserId = @"externalUserId",
	.fullName = @"fullName",
};

const struct CDUsersRelationships CDUsersRelationships = {
};

const struct CDUsersFetchedProperties CDUsersFetchedProperties = {
};

@implementation CDUsersID
@end

@implementation _CDUsers

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDUsers" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDUsers";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDUsers" inManagedObjectContext:moc_];
}

- (CDUsersID*)objectID {
	return (CDUsersID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"externalUserIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"externalUserId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic externalUserId;



- (int32_t)externalUserIdValue {
	NSNumber *result = [self externalUserId];
	return [result intValue];
}

- (void)setExternalUserIdValue:(int32_t)value_ {
	[self setExternalUserId:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveExternalUserIdValue {
	NSNumber *result = [self primitiveExternalUserId];
	return [result intValue];
}

- (void)setPrimitiveExternalUserIdValue:(int32_t)value_ {
	[self setPrimitiveExternalUserId:[NSNumber numberWithInt:value_]];
}





@dynamic fullName;











@end
