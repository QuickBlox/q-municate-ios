// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDUsers.m instead.

#import "_CDUsers.h"

const struct CDUsersAttributes CDUsersAttributes = {
	.email = @"email",
	.externalUserId = @"externalUserId",
	.fullName = @"fullName",
	.id = @"id",
	.phone = @"phone",
	.status = @"status",
	.type = @"type",
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
	if ([key isEqualToString:@"idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic email;






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






@dynamic status;






@dynamic type;











@end
