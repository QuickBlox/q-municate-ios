// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDDialog.m instead.

#import "_CDDialog.h"

const struct CDDialogAttributes CDDialogAttributes = {
	.countUnreadMessages = @"countUnreadMessages",
	.dialogType = @"dialogType",
	.id = @"id",
	.name = @"name",
	.roomJID = @"roomJID",
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
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDDialog" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDDialog";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDDialog" inManagedObjectContext:moc_];
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
	if ([key isEqualToString:@"dialogTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"dialogType"];
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





@dynamic dialogType;



- (int16_t)dialogTypeValue {
	NSNumber *result = [self dialogType];
	return [result shortValue];
}

- (void)setDialogTypeValue:(int16_t)value_ {
	[self setDialogType:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveDialogTypeValue {
	NSNumber *result = [self primitiveDialogType];
	return [result shortValue];
}

- (void)setPrimitiveDialogTypeValue:(int16_t)value_ {
	[self setPrimitiveDialogType:[NSNumber numberWithShort:value_]];
}





@dynamic id;






@dynamic name;






@dynamic roomJID;






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
