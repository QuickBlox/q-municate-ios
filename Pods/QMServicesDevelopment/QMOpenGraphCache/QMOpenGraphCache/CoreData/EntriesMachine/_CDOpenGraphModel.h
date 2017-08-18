// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CDOpenGraphModel.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CDOpenGraphModelID : NSManagedObjectID {}
@end

@interface _CDOpenGraphModel : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) CDOpenGraphModelID *objectID;

@property (nonatomic, strong, nullable) NSString* faviconURL;

@property (nonatomic, strong, nullable) NSNumber* height;

@property (atomic) int16_t heightValue;
- (int16_t)heightValue;
- (void)setHeightValue:(int16_t)value_;

@property (nonatomic, strong) NSString* id;

@property (nonatomic, strong, nullable) NSString* imageURL;

@property (nonatomic, strong, nullable) NSString* siteDescription;

@property (nonatomic, strong, nullable) NSString* title;

@property (nonatomic, strong, nullable) NSString* url;

@property (nonatomic, strong, nullable) NSNumber* width;

@property (atomic) int16_t widthValue;
- (int16_t)widthValue;
- (void)setWidthValue:(int16_t)value_;

@end

@interface _CDOpenGraphModel (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveFaviconURL;
- (void)setPrimitiveFaviconURL:(NSString*)value;

- (NSNumber*)primitiveHeight;
- (void)setPrimitiveHeight:(NSNumber*)value;

- (int16_t)primitiveHeightValue;
- (void)setPrimitiveHeightValue:(int16_t)value_;

- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;

- (NSString*)primitiveImageURL;
- (void)setPrimitiveImageURL:(NSString*)value;

- (NSString*)primitiveSiteDescription;
- (void)setPrimitiveSiteDescription:(NSString*)value;

- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;

- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;

- (NSNumber*)primitiveWidth;
- (void)setPrimitiveWidth:(NSNumber*)value;

- (int16_t)primitiveWidthValue;
- (void)setPrimitiveWidthValue:(int16_t)value_;

@end

@interface CDOpenGraphModelAttributes: NSObject 
+ (NSString *)faviconURL;
+ (NSString *)height;
+ (NSString *)id;
+ (NSString *)imageURL;
+ (NSString *)siteDescription;
+ (NSString *)title;
+ (NSString *)url;
+ (NSString *)width;
@end

NS_ASSUME_NONNULL_END
