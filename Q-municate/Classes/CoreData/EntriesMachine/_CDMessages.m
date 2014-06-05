// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDMessages.m instead.

#import "_CDMessages.h"

const struct CDMessagesAttributes CDMessagesAttributes = {
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
	

	return keyPaths;
}









@end
