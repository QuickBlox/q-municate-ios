// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDUsers.h instead.

#import <CoreData/CoreData.h>


extern const struct CDUsersAttributes {
	__unsafe_unretained NSString *externalUserId;
	__unsafe_unretained NSString *fullName;
} CDUsersAttributes;

extern const struct CDUsersRelationships {
} CDUsersRelationships;

extern const struct CDUsersFetchedProperties {
} CDUsersFetchedProperties;





@interface CDUsersID : NSManagedObjectID {}
@end

@interface _CDUsers : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CDUsersID*)objectID;





@property (nonatomic, strong) NSNumber* externalUserId;



@property int32_t externalUserIdValue;
- (int32_t)externalUserIdValue;
- (void)setExternalUserIdValue:(int32_t)value_;

//- (BOOL)validateExternalUserId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* fullName;



//- (BOOL)validateFullName:(id*)value_ error:(NSError**)error_;






@end

@interface _CDUsers (CoreDataGeneratedAccessors)

@end

@interface _CDUsers (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveExternalUserId;
- (void)setPrimitiveExternalUserId:(NSNumber*)value;

- (int32_t)primitiveExternalUserIdValue;
- (void)setPrimitiveExternalUserIdValue:(int32_t)value_;




- (NSString*)primitiveFullName;
- (void)setPrimitiveFullName:(NSString*)value;




@end
