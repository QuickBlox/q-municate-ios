// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDDialog.h instead.

#import <CoreData/CoreData.h>


extern const struct CDDialogAttributes {
	__unsafe_unretained NSString *countUnreadMessages;
	__unsafe_unretained NSString *dialogId;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *lastMessage;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *roomId;
	__unsafe_unretained NSString *type;
} CDDialogAttributes;

extern const struct CDDialogRelationships {
} CDDialogRelationships;

extern const struct CDDialogFetchedProperties {
} CDDialogFetchedProperties;










@interface CDDialogID : NSManagedObjectID {}
@end

@interface _CDDialog : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CDDialogID*)objectID;





@property (nonatomic, strong) NSNumber* countUnreadMessages;



@property int32_t countUnreadMessagesValue;
- (int32_t)countUnreadMessagesValue;
- (void)setCountUnreadMessagesValue:(int32_t)value_;

//- (BOOL)validateCountUnreadMessages:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* dialogId;



//- (BOOL)validateDialogId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* id;



@property int32_t idValue;
- (int32_t)idValue;
- (void)setIdValue:(int32_t)value_;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* lastMessage;



//- (BOOL)validateLastMessage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* roomId;



//- (BOOL)validateRoomId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* type;



//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;






@end

@interface _CDDialog (CoreDataGeneratedAccessors)

@end

@interface _CDDialog (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCountUnreadMessages;
- (void)setPrimitiveCountUnreadMessages:(NSNumber*)value;

- (int32_t)primitiveCountUnreadMessagesValue;
- (void)setPrimitiveCountUnreadMessagesValue:(int32_t)value_;




- (NSString*)primitiveDialogId;
- (void)setPrimitiveDialogId:(NSString*)value;




- (NSNumber*)primitiveId;
- (void)setPrimitiveId:(NSNumber*)value;

- (int32_t)primitiveIdValue;
- (void)setPrimitiveIdValue:(int32_t)value_;




- (NSString*)primitiveLastMessage;
- (void)setPrimitiveLastMessage:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveRoomId;
- (void)setPrimitiveRoomId:(NSString*)value;




- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;




@end
