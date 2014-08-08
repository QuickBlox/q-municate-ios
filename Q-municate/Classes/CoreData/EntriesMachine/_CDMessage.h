// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDMessage.h instead.

#import <CoreData/CoreData.h>


extern const struct CDMessageAttributes {
	__unsafe_unretained NSString *customParameters;
	__unsafe_unretained NSString *datetime;
	__unsafe_unretained NSString *dialogId;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *isRead;
	__unsafe_unretained NSString *recipientID;
	__unsafe_unretained NSString *roomId;
	__unsafe_unretained NSString *senderId;
	__unsafe_unretained NSString *senderNick;
	__unsafe_unretained NSString *state;
	__unsafe_unretained NSString *text;
} CDMessageAttributes;

extern const struct CDMessageRelationships {
	__unsafe_unretained NSString *attachments;
	__unsafe_unretained NSString *chatDialog;
} CDMessageRelationships;

extern const struct CDMessageFetchedProperties {
} CDMessageFetchedProperties;

@class CDAttachment;
@class CDDialog;













@interface CDMessageID : NSManagedObjectID {}
@end

@interface _CDMessage : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CDMessageID*)objectID;





@property (nonatomic, strong) NSData* customParameters;



//- (BOOL)validateCustomParameters:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* datetime;



//- (BOOL)validateDatetime:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* dialogId;



//- (BOOL)validateDialogId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* id;



//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isRead;



@property BOOL isReadValue;
- (BOOL)isReadValue;
- (void)setIsReadValue:(BOOL)value_;

//- (BOOL)validateIsRead:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSSet *attachments;

- (NSMutableSet*)attachmentsSet;




@property (nonatomic, strong) CDDialog *chatDialog;

//- (BOOL)validateChatDialog:(id*)value_ error:(NSError**)error_;





@end

@interface _CDMessage (CoreDataGeneratedAccessors)

- (void)addAttachments:(NSSet*)value_;
- (void)removeAttachments:(NSSet*)value_;
- (void)addAttachmentsObject:(CDAttachment*)value_;
- (void)removeAttachmentsObject:(CDAttachment*)value_;

@end

@interface _CDMessage (CoreDataGeneratedPrimitiveAccessors)


- (NSData*)primitiveCustomParameters;
- (void)setPrimitiveCustomParameters:(NSData*)value;




- (NSDate*)primitiveDatetime;
- (void)setPrimitiveDatetime:(NSDate*)value;




- (NSString*)primitiveDialogId;
- (void)setPrimitiveDialogId:(NSString*)value;




- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;




- (NSNumber*)primitiveIsRead;
- (void)setPrimitiveIsRead:(NSNumber*)value;

- (BOOL)primitiveIsReadValue;
- (void)setPrimitiveIsReadValue:(BOOL)value_;




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





- (NSMutableSet*)primitiveAttachments;
- (void)setPrimitiveAttachments:(NSMutableSet*)value;



- (CDDialog*)primitiveChatDialog;
- (void)setPrimitiveChatDialog:(CDDialog*)value;


@end
