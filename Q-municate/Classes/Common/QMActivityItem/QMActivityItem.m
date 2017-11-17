//
//  QMActivityItem.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 10/18/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMActivityItem.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface QMActivityItem()

@property (nonatomic) id placeholderItem;
@property (nonatomic, copy) NSString *typeIdentifier;

@end

@implementation QMActivityItem

//MARK - NSObject
- (instancetype)initWithPlaceholderItem:(id)placeholderItem
                         typeIdentifier:(NSString *)typeIdentifier {
    
    self = [super init];
    
    if (self) {
        _placeholderItem = placeholderItem;
        _typeIdentifier = typeIdentifier ? [typeIdentifier copy] : typeIdentifierForActivityItem(placeholderItem);
    }
    
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithPlaceholderItem:URL
                          typeIdentifier:URL.isFileURL ? (NSString *)kUTTypeFileURL : (NSString *)kUTTypeURL];
}

- (instancetype)initWithString:(NSString *)string {
    return [self initWithPlaceholderItem:string
                          typeIdentifier:(NSString *)kUTTypePlainText];
}

- (instancetype)initWithImage:(UIImage *)image {
    
    return [self initWithPlaceholderItem:image
                          typeIdentifier:(NSString *)kUTTypeImage];
}

- (instancetype)initWithData:(NSData *)data
              typeIdentifier:(NSString *)typeIdentifier {
    
    return [self initWithPlaceholderItem:data
                          typeIdentifier:typeIdentifier];
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
    
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithItem:self.placeholderItem
                                                         typeIdentifier:typeIdentifier];
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

@end
