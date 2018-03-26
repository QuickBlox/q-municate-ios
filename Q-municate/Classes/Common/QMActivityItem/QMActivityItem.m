//
//  QMActivityItem.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 10/18/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMActivityItem.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <QMServices/QMSLog.h>

@interface QMActivityItem()

@property (nonatomic) id placeholderItem;
@property (nonatomic, copy) NSString *typeIdentifier;
@property (nonatomic, strong) NSMutableDictionary <NSString* , QMActivityItemResultBlock> *additionalTypeIdentifiers;
@property (nonatomic, copy) QMActivityItemResultBlock loadHandlerBlock;
@end

@implementation QMActivityItem

//MARK - NSObject

- (instancetype)initWithPlaceholderItem:(id)placeholderItem
                         typeIdentifier:(NSString *)typeIdentifier
                       loadHandlerBlock:(QMActivityItemResultBlock)loadHandlerBlock {
    
    self = [super init];
    
    if (self) {
        _placeholderItem = placeholderItem;
        _typeIdentifier = typeIdentifier ? [typeIdentifier copy] : typeIdentifierForActivityItem(placeholderItem);
        _loadHandlerBlock = [loadHandlerBlock copy];
        _additionalTypeIdentifiers = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (instancetype)initWithImageTypeIdentifier:(NSString *)typeIdentifier
                           loadHandlerBlock:(QMActivityItemResultBlock)loadHandlerBlock {
    return [self initWithPlaceholderItem:[UIImage new]
                          typeIdentifier:typeIdentifier
                        loadHandlerBlock:loadHandlerBlock];
}

- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithPlaceholderItem:URL
                          typeIdentifier:URL.isFileURL ? (NSString *)kUTTypeFileURL : (NSString *)kUTTypeURL
                        loadHandlerBlock:nil];
}

- (instancetype)initWithString:(NSString *)string {
    return [self initWithPlaceholderItem:string
                          typeIdentifier:(NSString *)kUTTypePlainText
                        loadHandlerBlock:nil];
}

- (instancetype)initWithImage:(UIImage *)image {
    
    return [self initWithPlaceholderItem:image
                          typeIdentifier:(NSString *)kUTTypeImage
                        loadHandlerBlock:nil];
}

- (instancetype)initWithData:(NSData *)data
              typeIdentifier:(NSString *)typeIdentifier {
    
    return [self initWithPlaceholderItem:data
                          typeIdentifier:typeIdentifier
                        loadHandlerBlock:nil];
}

- (void)addItemWithTypeIdentifier:(NSString *)typeIdentifier
                 loadHandlerBlock:(QMActivityItemResultBlock)loadHandlerBlock {
    
    NSParameterAssert(typeIdentifier.length > 0);
    NSParameterAssert(loadHandlerBlock != nil);
    
    self.additionalTypeIdentifiers[typeIdentifier] = [loadHandlerBlock copy];
}

//MARK: - UIActivityItemSource

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)__unused activityViewController {
    return self.placeholderItem;
}

- (nullable id)activityViewController:(UIActivityViewController *)__unused activityViewController
                  itemForActivityType:(nullable UIActivityType)__unused activityType {
    
    NSExtensionItem *item = [[NSExtensionItem alloc] init];
    
    NSString *typeIdentifier =
    [self.placeholderItem isKindOfClass:NSURL.class] ?
    typeIdentifierForActivityItem(self.placeholderItem) :
    self.typeIdentifier;
    
    NSItemProvider *itemProvider = [[NSItemProvider alloc] init];
    
    [itemProvider registerItemForTypeIdentifier:typeIdentifier
                                    loadHandler:^(NSItemProviderCompletionHandler  _Null_unspecified completionHandler,
                                                  Class __unused  _Null_unspecified __unsafe_unretained expectedValueClass,
                                                  NSDictionary * __unused _Null_unspecified options) {
                                        if (self.loadHandlerBlock) {
                                            self.loadHandlerBlock(completionHandler, activityType);
                                        }
                                        else {
                                            completionHandler(self.placeholderItem, nil);
                                        }
                                    }];
    
    [self.additionalTypeIdentifiers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key,
                                                                        QMActivityItemResultBlock  _Nonnull obj,
                                                                        BOOL * __unused _Nonnull stop) {
        
        [itemProvider registerItemForTypeIdentifier:key
                                        loadHandler:^(NSItemProviderCompletionHandler  _Null_unspecified completionHandler,
                                                      Class __unused  _Null_unspecified __unsafe_unretained expectedValueClass,
                                                      NSDictionary * __unused _Null_unspecified options) {
                                            obj(completionHandler,activityType);
                                        }];
    }];
    
    item.attachments = @[itemProvider];
    
    return item;
}

- (NSString *)activityViewController:(UIActivityViewController *)__unused activityViewController
   dataTypeIdentifierForActivityType:(NSString *)__unused activityType {
    return self.typeIdentifier;
}

static NSString *typeIdentifierForActivityItem(id item) {
    
    if ([item isKindOfClass:[NSURL class]]) {
        NSURL *URL = (NSURL *)item;
        
        if (URL.isFileURL) {
            return (NSString *)kUTTypeFileURL;
        }
    }
    
    return QMTypeIdentifiersDictionary()[[item class]];
}

NSDictionary *QMTypeIdentifiersDictionary() {
    
    static NSDictionary *typeIdentifiers = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        typeIdentifiers = @{(id)[NSURL class] : (NSString *)kUTTypeURL,
                            (id)[NSData class] : (NSString *)kUTTypeData,
                            (id)[NSString class] : (NSString *)kUTTypePlainText,
                            (id)[UIImage class] : (NSString *)kUTTypeImage
                            };
    });
    
    return typeIdentifiers;
}

- (void)dealloc {
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

@end
