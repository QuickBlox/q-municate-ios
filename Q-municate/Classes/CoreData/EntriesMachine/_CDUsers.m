// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDUsers.m instead.

#import "_CDUsers.h"

const struct CDUsersAttributes CDUsersAttributes = {
	.email = @"email",
	.fullName = @"fullName",
	.phone = @"phone",
	.status = @"status",
	.type = @"type",
	.uniqueId = @"uniqueId",
};

const struct CDUsersRelationships CDUsersRelationships = {
	.dialogs = @"dialogs",
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
	
	if ([key isEqualToString:@"uniqueIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"uniqueId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic email;






@dynamic fullName;






@dynamic phone;






@dynamic status;






@dynamic type;






@dynamic uniqueId;



- (int32_t)uniqueIdValue {
	NSNumber *result = [self uniqueId];
	return [result intValue];
}

- (void)setUniqueIdValue:(int32_t)value_ {
	[self setUniqueId:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveUniqueIdValue {
	NSNumber *result = [self primitiveUniqueId];
	return [result intValue];
}

- (void)setPrimitiveUniqueIdValue:(int32_t)value_ {
	[self setPrimitiveUniqueId:[NSNumber numberWithInt:value_]];
}





@dynamic dialogs;

	






@end
