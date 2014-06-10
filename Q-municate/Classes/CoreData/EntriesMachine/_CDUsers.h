// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDUsers.h instead.

#import <CoreData/CoreData.h>


extern const struct CDUsersAttributes {
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *fullName;
	__unsafe_unretained NSString *phone;
	__unsafe_unretained NSString *status;
	__unsafe_unretained NSString *type;
	__unsafe_unretained NSString *uniqueId;
} CDUsersAttributes;

extern const struct CDUsersRelationships {
	__unsafe_unretained NSString *dialogs;
} CDUsersRelationships;

extern const struct CDUsersFetchedProperties {
} CDUsersFetchedProperties;

@class CDDialog;








@interface CDUsersID : NSManagedObjectID {}
@end

@interface _CDUsers : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CDUsersID*)objectID;





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* fullName;



//- (BOOL)validateFullName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* phone;



//- (BOOL)validatePhone:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* status;



//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* type;



//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* uniqueId;



@property int32_t uniqueIdValue;
- (int32_t)uniqueIdValue;
- (void)setUniqueIdValue:(int32_t)value_;

//- (BOOL)validateUniqueId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CDDialog *dialogs;

//- (BOOL)validateDialogs:(id*)value_ error:(NSError**)error_;





@end

@interface _CDUsers (CoreDataGeneratedAccessors)

@end

@interface _CDUsers (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveFullName;
- (void)setPrimitiveFullName:(NSString*)value;




- (NSString*)primitivePhone;
- (void)setPrimitivePhone:(NSString*)value;




- (NSString*)primitiveStatus;
- (void)setPrimitiveStatus:(NSString*)value;




- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;




- (NSNumber*)primitiveUniqueId;
- (void)setPrimitiveUniqueId:(NSNumber*)value;

- (int32_t)primitiveUniqueIdValue;
- (void)setPrimitiveUniqueIdValue:(int32_t)value_;





- (CDDialog*)primitiveDialogs;
- (void)setPrimitiveDialogs:(CDDialog*)value;


@end
