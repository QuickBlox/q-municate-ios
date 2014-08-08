// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDUser.h instead.

#import <CoreData/CoreData.h>


extern const struct CDUserAttributes {
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *fullName;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *phone;
	__unsafe_unretained NSString *status;
	__unsafe_unretained NSString *type;
} CDUserAttributes;

extern const struct CDUserRelationships {
	__unsafe_unretained NSString *dialogs;
} CDUserRelationships;

extern const struct CDUserFetchedProperties {
} CDUserFetchedProperties;

@class CDDialog;








@interface CDUserID : NSManagedObjectID {}
@end

@interface _CDUser : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CDUserID*)objectID;





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) CDDialog *dialogs;

//- (BOOL)validateDialogs:(id*)value_ error:(NSError**)error_;





@end

@interface _CDUser (CoreDataGeneratedAccessors)

@end

@interface _CDUser (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




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





- (CDDialog*)primitiveDialogs;
- (void)setPrimitiveDialogs:(CDDialog*)value;


@end
