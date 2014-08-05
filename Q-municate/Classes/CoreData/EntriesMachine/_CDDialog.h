// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDDialog.h instead.

#import <CoreData/CoreData.h>


extern const struct CDDialogAttributes {
	__unsafe_unretained NSString *countUnreadMessages;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *roomJID;
	__unsafe_unretained NSString *type;
} CDDialogAttributes;

extern const struct CDDialogRelationships {
	__unsafe_unretained NSString *messages;
	__unsafe_unretained NSString *occupants;
} CDDialogRelationships;

extern const struct CDDialogFetchedProperties {
} CDDialogFetchedProperties;

@class CDMessage;
@class CDUser;







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





@property (nonatomic, strong) NSString* id;



//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* roomJID;



//- (BOOL)validateRoomJID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* type;



@property int16_t typeValue;
- (int16_t)typeValue;
- (void)setTypeValue:(int16_t)value_;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *messages;

- (NSMutableSet*)messagesSet;




@property (nonatomic, strong) NSSet *occupants;

- (NSMutableSet*)occupantsSet;





@end

@interface _CDDialog (CoreDataGeneratedAccessors)

- (void)addMessages:(NSSet*)value_;
- (void)removeMessages:(NSSet*)value_;
- (void)addMessagesObject:(CDMessage*)value_;
- (void)removeMessagesObject:(CDMessage*)value_;

- (void)addOccupants:(NSSet*)value_;
- (void)removeOccupants:(NSSet*)value_;
- (void)addOccupantsObject:(CDUser*)value_;
- (void)removeOccupantsObject:(CDUser*)value_;

@end

@interface _CDDialog (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCountUnreadMessages;
- (void)setPrimitiveCountUnreadMessages:(NSNumber*)value;

- (int32_t)primitiveCountUnreadMessagesValue;
- (void)setPrimitiveCountUnreadMessagesValue:(int32_t)value_;




- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveRoomJID;
- (void)setPrimitiveRoomJID:(NSString*)value;




- (NSNumber*)primitiveType;
- (void)setPrimitiveType:(NSNumber*)value;

- (int16_t)primitiveTypeValue;
- (void)setPrimitiveTypeValue:(int16_t)value_;





- (NSMutableSet*)primitiveMessages;
- (void)setPrimitiveMessages:(NSMutableSet*)value;



- (NSMutableSet*)primitiveOccupants;
- (void)setPrimitiveOccupants:(NSMutableSet*)value;


@end
