// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDMessages.h instead.

#import <CoreData/CoreData.h>


extern const struct CDMessagesAttributes {
	__unsafe_unretained NSString *attachFileId;
	__unsafe_unretained NSString *datetime;
	__unsafe_unretained NSString *recipientID;
	__unsafe_unretained NSString *roomId;
	__unsafe_unretained NSString *senderId;
	__unsafe_unretained NSString *senderNick;
	__unsafe_unretained NSString *state;
	__unsafe_unretained NSString *text;
	__unsafe_unretained NSString *uniqueId;
} CDMessagesAttributes;

extern const struct CDMessagesRelationships {
	__unsafe_unretained NSString *chatDialog;
} CDMessagesRelationships;

extern const struct CDMessagesFetchedProperties {
} CDMessagesFetchedProperties;

@class CDDialog;











@interface CDMessagesID : NSManagedObjectID {}
@end

@interface _CDMessages : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CDMessagesID*)objectID;





@property (nonatomic, strong) NSString* attachFileId;



//- (BOOL)validateAttachFileId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* datetime;



//- (BOOL)validateDatetime:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* recipientID;



@property int32_t recipientIDValue;
- (int32_t)recipientIDValue;
- (void)setRecipientIDValue:(int32_t)value_;

//- (BOOL)validateRecipientID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* roomId;



//- (BOOL)validateRoomId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* senderId;



@property int32_t senderIdValue;
- (int32_t)senderIdValue;
- (void)setSenderIdValue:(int32_t)value_;

//- (BOOL)validateSenderId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* senderNick;



//- (BOOL)validateSenderNick:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* state;



@property int16_t stateValue;
- (int16_t)stateValue;
- (void)setStateValue:(int16_t)value_;

//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* text;



//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* uniqueId;



//- (BOOL)validateUniqueId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CDDialog *chatDialog;

//- (BOOL)validateChatDialog:(id*)value_ error:(NSError**)error_;





@end

@interface _CDMessages (CoreDataGeneratedAccessors)

@end

@interface _CDMessages (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAttachFileId;
- (void)setPrimitiveAttachFileId:(NSString*)value;




- (NSDate*)primitiveDatetime;
- (void)setPrimitiveDatetime:(NSDate*)value;




- (NSNumber*)primitiveRecipientID;
- (void)setPrimitiveRecipientID:(NSNumber*)value;

- (int32_t)primitiveRecipientIDValue;
- (void)setPrimitiveRecipientIDValue:(int32_t)value_;




- (NSString*)primitiveRoomId;
- (void)setPrimitiveRoomId:(NSString*)value;




- (NSNumber*)primitiveSenderId;
- (void)setPrimitiveSenderId:(NSNumber*)value;

- (int32_t)primitiveSenderIdValue;
- (void)setPrimitiveSenderIdValue:(int32_t)value_;




- (NSString*)primitiveSenderNick;
- (void)setPrimitiveSenderNick:(NSString*)value;




- (NSNumber*)primitiveState;
- (void)setPrimitiveState:(NSNumber*)value;

- (int16_t)primitiveStateValue;
- (void)setPrimitiveStateValue:(int16_t)value_;




- (NSString*)primitiveText;
- (void)setPrimitiveText:(NSString*)value;




- (NSString*)primitiveUniqueId;
- (void)setPrimitiveUniqueId:(NSString*)value;





- (CDDialog*)primitiveChatDialog;
- (void)setPrimitiveChatDialog:(CDDialog*)value;


@end
