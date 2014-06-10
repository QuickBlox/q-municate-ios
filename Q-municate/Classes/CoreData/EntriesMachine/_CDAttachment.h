// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDAttachment.h instead.

#import <CoreData/CoreData.h>


extern const struct CDAttachmentAttributes {
	__unsafe_unretained NSString *type;
	__unsafe_unretained NSString *uniqueId;
	__unsafe_unretained NSString *url;
} CDAttachmentAttributes;

extern const struct CDAttachmentRelationships {
	__unsafe_unretained NSString *message;
} CDAttachmentRelationships;

extern const struct CDAttachmentFetchedProperties {
} CDAttachmentFetchedProperties;

@class CDMessages;





@interface CDAttachmentID : NSManagedObjectID {}
@end

@interface _CDAttachment : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CDAttachmentID*)objectID;





@property (nonatomic, strong) NSString* type;



//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* uniqueId;



//- (BOOL)validateUniqueId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* url;



//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CDMessages *message;

//- (BOOL)validateMessage:(id*)value_ error:(NSError**)error_;





@end

@interface _CDAttachment (CoreDataGeneratedAccessors)

@end

@interface _CDAttachment (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;




- (NSString*)primitiveUniqueId;
- (void)setPrimitiveUniqueId:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;





- (CDMessages*)primitiveMessage;
- (void)setPrimitiveMessage:(CDMessages*)value;


@end
