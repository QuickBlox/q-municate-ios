// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDUsers.h instead.

#import <CoreData/CoreData.h>


extern const struct CDUsersAttributes {
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *externalUserId;
	__unsafe_unretained NSString *fullName;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *phone;
	__unsafe_unretained NSString *status;
	__unsafe_unretained NSString *type;
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





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* externalUserId;



@property int32_t externalUserIdValue;
- (int32_t)externalUserIdValue;
- (void)setExternalUserIdValue:(int32_t)value_;

//- (BOOL)validateExternalUserId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* fullName;



//- (BOOL)validateFullName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* id;



@property int32_t idValue;
- (int32_t)idValue;
- (void)setIdValue:(int32_t)value_;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* phone;



//- (BOOL)validatePhone:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* status;



//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* type;



//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;






@end

@interface _CDUsers (CoreDataGeneratedAccessors)

@end

@interface _CDUsers (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSNumber*)primitiveExternalUserId;
- (void)setPrimitiveExternalUserId:(NSNumber*)value;

- (int32_t)primitiveExternalUserIdValue;
- (void)setPrimitiveExternalUserIdValue:(int32_t)value_;




- (NSString*)primitiveFullName;
- (void)setPrimitiveFullName:(NSString*)value;




- (NSNumber*)primitiveId;
- (void)setPrimitiveId:(NSNumber*)value;

- (int32_t)primitiveIdValue;
- (void)setPrimitiveIdValue:(int32_t)value_;




- (NSString*)primitivePhone;
- (void)setPrimitivePhone:(NSString*)value;




- (NSString*)primitiveStatus;
- (void)setPrimitiveStatus:(NSString*)value;




- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;




@end
