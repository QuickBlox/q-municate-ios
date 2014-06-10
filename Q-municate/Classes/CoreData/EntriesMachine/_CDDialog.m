// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDDialog.m instead.

#import "_CDDialog.h"

const struct CDDialogAttributes CDDialogAttributes = {
	.countUnreadMessages = @"countUnreadMessages",
	.name = @"name",
	.roomJID = @"roomJID",
	.type = @"type",
	.uniqueId = @"uniqueId",
};

const struct CDDialogRelationships CDDialogRelationships = {
	.messages = @"messages",
	.occupants = @"occupants",
};

const struct CDDialogFetchedProperties CDDialogFetchedProperties = {
};

@implementation CDDialogID
@end

@implementation _CDDialog

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDDialogs" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDDialogs";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDDialogs" inManagedObjectContext:moc_];
}

- (CDDialogID*)objectID {
	return (CDDialogID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"countUnreadMessagesValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"countUnreadMessages"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"typeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"type"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic countUnreadMessages;



- (int32_t)countUnreadMessagesValue {
	NSNumber *result = [self countUnreadMessages];
	return [result intValue];
}

- (void)setCountUnreadMessagesValue:(int32_t)value_ {
	[self setCountUnreadMessages:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveCountUnreadMessagesValue {
	NSNumber *result = [self primitiveCountUnreadMessages];
	return [result intValue];
}

- (void)setPrimitiveCountUnreadMessagesValue:(int32_t)value_ {
	[self setPrimitiveCountUnreadMessages:[NSNumber numberWithInt:value_]];
}





@dynamic name;






@dynamic roomJID;






@dynamic type;



- (int16_t)typeValue {
	NSNumber *result = [self type];
	return [result shortValue];
}

- (void)setTypeValue:(int16_t)value_ {
	[self setType:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveTypeValue {
	NSNumber *result = [self primitiveType];
	return [result shortValue];
}

- (void)setPrimitiveTypeValue:(int16_t)value_ {
	[self setPrimitiveType:[NSNumber numberWithShort:value_]];
}





@dynamic uniqueId;






@dynamic messages;

	
- (NSMutableSet*)messagesSet {
	[self willAccessValueForKey:@"messages"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"messages"];
  
	[self didAccessValueForKey:@"messages"];
	return result;
}
	

@dynamic occupants;

	
- (NSMutableSet*)occupantsSet {
	[self willAccessValueForKey:@"occupants"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"occupants"];
  
	[self didAccessValueForKey:@"occupants"];
	return result;
}
	






@end
