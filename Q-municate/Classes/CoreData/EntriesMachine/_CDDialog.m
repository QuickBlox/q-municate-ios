// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDDialog.m instead.

#import "_CDDialog.h"

const struct CDDialogAttributes CDDialogAttributes = {
	.countUnreadMessages = @"countUnreadMessages",
	.dialogId = @"dialogId",
	.id = @"id",
	.lastMessage = @"lastMessage",
	.name = @"name",
	.roomId = @"roomId",
	.type = @"type",
};

const struct CDDialogRelationships CDDialogRelationships = {
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
	if ([key isEqualToString:@"idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"id"];
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





@dynamic dialogId;






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





@dynamic lastMessage;






@dynamic name;






@dynamic roomId;






@dynamic type;











@end
