//
//  QMLinkPreview.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 4/3/17.
//
//

#import "QMLinkPreview.h"

@implementation QMLinkPreview

//MARK: - NSObject
- (NSString *)description{
    
    NSString *desc = [NSString stringWithFormat:
                      @"\r   url: %@"
                      "\r   title: %@"
                      "\r   description: %@"
                      "\r   imageURL: %@"
                      "\r   width: %tu"
                      "\r   height: %tu",
                      _siteUrl,
                      _siteTitle,
                      _siteDescription,
                      _imageURL,
                      _imageWidth,
                      _imageHeight
                      ];
    
    return desc;
}

//MARK: - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super init]) {
        
        _siteUrl = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(siteUrl))];
        _siteTitle = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(siteTitle))];
        _siteDescription = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(siteDescription))];
        _imageURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(imageURL))];
        _imageWidth =  [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(imageWidth))];
        _imageHeight =  [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(imageHeight))];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.siteUrl forKey:NSStringFromSelector(@selector(siteUrl))];
    [aCoder encodeObject:self.siteTitle forKey:NSStringFromSelector(@selector(siteTitle))];
    [aCoder encodeObject:self.siteDescription forKey:NSStringFromSelector(@selector(siteDescription))];
    [aCoder encodeObject:self.imageURL forKey:NSStringFromSelector(@selector(imageURL))];
    [aCoder encodeInteger:self.imageWidth forKey:NSStringFromSelector(@selector(imageWidth))];
    [aCoder encodeInteger:self.imageHeight forKey:NSStringFromSelector(@selector(imageHeight))];
}

//MARK: - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    
    QMLinkPreview *copy = [[QMLinkPreview alloc] init];
    
    copy.siteUrl = [self.siteUrl copyWithZone:zone];
    copy.siteTitle = [self.siteTitle copyWithZone:zone];
    copy.siteDescription = [self.siteDescription copyWithZone:zone];
    copy.imageURL = [self.imageURL copyWithZone:zone];
    
    return copy;
}

@end
