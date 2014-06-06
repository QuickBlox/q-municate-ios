// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDMessages.m instead.

#import "_CDMessages.h"

const struct CDMessagesAttributes CDMessagesAttributes = {
	.attachFileId = @"attachFileId",
	.body = @"body",
	.id = @"id",
	.roomId = @"roomId",
	.senderId = @"senderId",
	.state = @"state",
	.time = @"time",
};

const struct CDMessagesRelationships CDMessagesRelationships = {
};

const struct CDMessagesFetchedProperties CDMessagesFetchedProperties = {
};

@implementation CDMessagesID
@end

@implementation _CDMessages

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CDMessages" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CDMessages";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CDMessages" inManagedObjectContext:moc_];
}

- (CDMessagesID*)objectID {
	return (CDMessagesID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"senderIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"senderId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"stateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"state"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic attachFileId;






@dynamic body;






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





@dynamic roomId;






@dynamic senderId;



- (int32_t)senderIdValue {
	NSNumber *result = [self senderId];
	return [result intValue];
}

- (void)setSenderIdValue:(int32_t)value_ {
	[self setSenderId:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveSenderIdValue {
	NSNumber *result = [self primitiveSenderId];
	return [result intValue];
}

- (void)setPrimitiveSenderIdValue:(int32_t)value_ {
	[self setPrimitiveSenderId:[NSNumber numberWithInt:value_]];
}





@dynamic state;



- (int16_t)stateValue {
	NSNumber *result = [self state];
	return [result shortValue];
}

- (void)setStateValue:(int16_t)value_ {
	[self setState:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveStateValue {
	NSNumber *result = [self primitiveState];
	return [result shortValue];
}

- (void)setPrimitiveStateValue:(int16_t)value_ {
	[self setPrimitiveState:[NSNumber numberWithShort:value_]];
}





@dynamic time;











@end
