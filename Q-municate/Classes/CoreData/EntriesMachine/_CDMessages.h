// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDMessages.h instead.

#import <CoreData/CoreData.h>


extern const struct CDMessagesAttributes {
	__unsafe_unretained NSString *attachFileId;
	__unsafe_unretained NSString *body;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *roomId;
	__unsafe_unretained NSString *senderId;
	__unsafe_unretained NSString *state;
	__unsafe_unretained NSString *time;
} CDMessagesAttributes;

extern const struct CDMessagesRelationships {
} CDMessagesRelationships;

extern const struct CDMessagesFetchedProperties {
} CDMessagesFetchedProperties;










@interface CDMessagesID : NSManagedObjectID {}
@end

@interface _CDMessages : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CDMessagesID*)objectID;





@property (nonatomic, strong) NSString* attachFileId;



//- (BOOL)validateAttachFileId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* body;



//- (BOOL)validateBody:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* id;



@property int32_t idValue;
- (int32_t)idValue;
- (void)setIdValue:(int32_t)value_;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* roomId;



//- (BOOL)validateRoomId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* senderId;



@property int32_t senderIdValue;
- (int32_t)senderIdValue;
- (void)setSenderIdValue:(int32_t)value_;

//- (BOOL)validateSenderId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* state;



@property int16_t stateValue;
- (int16_t)stateValue;
- (void)setStateValue:(int16_t)value_;

//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* time;



//- (BOOL)validateTime:(id*)value_ error:(NSError**)error_;






@end

@interface _CDMessages (CoreDataGeneratedAccessors)

@end

@interface _CDMessages (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAttachFileId;
- (void)setPrimitiveAttachFileId:(NSString*)value;




- (NSString*)primitiveBody;
- (void)setPrimitiveBody:(NSString*)value;




- (NSNumber*)primitiveId;
- (void)setPrimitiveId:(NSNumber*)value;

- (int32_t)primitiveIdValue;
- (void)setPrimitiveIdValue:(int32_t)value_;




- (NSString*)primitiveRoomId;
- (void)setPrimitiveRoomId:(NSString*)value;




- (NSNumber*)primitiveSenderId;
- (void)setPrimitiveSenderId:(NSNumber*)value;

- (int32_t)primitiveSenderIdValue;
- (void)setPrimitiveSenderIdValue:(int32_t)value_;




- (NSNumber*)primitiveState;
- (void)setPrimitiveState:(NSNumber*)value;

- (int16_t)primitiveStateValue;
- (void)setPrimitiveStateValue:(int16_t)value_;




- (NSDate*)primitiveTime;
- (void)setPrimitiveTime:(NSDate*)value;




@end
