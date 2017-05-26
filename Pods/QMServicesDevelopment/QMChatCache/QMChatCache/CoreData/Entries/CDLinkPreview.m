#import "CDLinkPreview.h"
#import "QMLinkPreview.h"

@interface CDLinkPreview ()

// Private interface goes here.

@end

@implementation CDLinkPreview

- (QMLinkPreview *)toQMLinkPreview {
    
    QMLinkPreview *linkPreview = [QMLinkPreview new];
    
    linkPreview.siteUrl = self.url;
    linkPreview.siteTitle = self.title;
    linkPreview.siteDescription = self.siteDescription;
    linkPreview.imageURL = self.imageURL;
    linkPreview.imageWidth = self.widthValue;
    linkPreview.imageHeight = self.heightValue;
    
    return linkPreview;
}

- (void)updateWithQMLinkPreview:(QMLinkPreview *)linkPreview {
    
    self.url = linkPreview.siteUrl;
    self.title = linkPreview.siteTitle;
    self.siteDescription = linkPreview.siteDescription;
    self.imageURL = linkPreview.imageURL;
    self.height = @(linkPreview.imageHeight);
    self.width = @(linkPreview.imageWidth);
}

@end
