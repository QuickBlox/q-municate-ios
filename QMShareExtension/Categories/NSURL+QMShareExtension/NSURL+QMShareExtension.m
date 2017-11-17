//
//  NSURL+QMShareExtension.m
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/20/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "NSURL+QMShareExtension.h"
#import <Bolts/Bolts.h>
#import "QMLog.h"

NSString *const QMAppleMapsHost = @"maps.apple.com";
NSString *const QMAppleMapsPath = @"/maps";
NSString *const QMAppleMapsLatLonKey = @"ll";

NSString *const QMGoogleMapsAPIKey = @"AIzaSyAgJbVJswdgnpplYjAEip9BoBLTl05820o";
NSString *const QMGoogleMapsShortenerEndpointUrl = @"https://www.googleapis.com/urlshortener/v1/url";

NSString *const QMGoogleMapsShortHost = @"goo.gl";
NSString *const QMGoogleMapsShortPath = @"/maps";
NSString *const QMGoogleMapsHost = @"google.com";
NSString *const QMGoogleMapsSearchPath = @"maps/search";
NSString *const QMGoogleMapsPlacePath = @"maps/place";
NSString *const QMGoogleMapsProvider = @"google";


@implementation NSURL (QMShareExtension)

- (BOOL)isLocationURL {
    return [self isAppleMapURL] ||[self isGoogleMapURL];
}

- (BFTask <CLLocation *>*)location {
    BFTaskCompletionSource *source = [[BFTaskCompletionSource alloc] init];
    
    if ([self isAppleMapURL]) {
        
        CLLocationCoordinate2D coordinates = [self locationCoordinate];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinates.latitude
                                                          longitude:coordinates.longitude];
        [source setResult:location];
    }
    
    else if ([self isGoogleMapURL]) {
        
        [[self locationFromGoogleURL:self] continueWithBlock:^id _Nullable(BFTask<CLLocation *> * _Nonnull t) {
            
            t.error ? [source setError:t.error] : [source setResult:t.result];
            
            return nil;
        }];
    }
    
    return source.task;
}

+ (NSURL *)appleMapsURLForLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate {
    
    NSString *coordinates = [NSString stringWithFormat:@"%lf,%lf", locationCoordinate.latitude, locationCoordinate.longitude];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.apple.com/maps?ll=%@&q=%@&t=m", coordinates, coordinates]];
    return url;
}

- (CLLocationCoordinate2D)locationCoordinate {
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:false];
    NSArray *queryItems = urlComponents.queryItems;
    
    NSString *latLon = nil;
    
    for (NSURLQueryItem *queryItem in queryItems)
    {
        if ([queryItem.name isEqualToString:QMAppleMapsLatLonKey])
        {
            latLon = queryItem.value;
        }
    }
    
    if (latLon == nil) {
        return kCLLocationCoordinate2DInvalid;
    }
    
    
    NSArray *coordComponents = [latLon componentsSeparatedByString:@","];
    if (coordComponents.count != 2) {
        return kCLLocationCoordinate2DInvalid;
    }
    
    double latitude = [coordComponents.firstObject floatValue];
    double longitude = [coordComponents.lastObject floatValue];
    
    return  CLLocationCoordinate2DMake(latitude, longitude);
}

- (BOOL)isAppleMapURL {
    
    return ([self.host isEqualToString:QMAppleMapsHost]
            && [self.path isEqualToString:QMAppleMapsPath]);
}

- (BOOL)isGoogleMapURL {
    return [self isShortGoogleMapURL] || [self isLongGoogleMapURL];
}


- (BOOL)isShortGoogleMapURL {
    return
    [self.host isEqualToString:QMGoogleMapsShortHost] &&
    [self.path hasPrefix:QMGoogleMapsShortPath];
}

- (BOOL)isLongGoogleMapURL {
    return
    [self.host isEqualToString:QMGoogleMapsHost] &&
    ([self.path hasPrefix:QMGoogleMapsSearchPath] ||
     [self.path hasPrefix:QMGoogleMapsPlacePath]);
    
}


- (BFTask <CLLocation *> *)locationFromGoogleURL:(NSURL *)url {
    
    BFTaskCompletionSource *source = [[BFTaskCompletionSource alloc] init];
    
    void(^completionBlock)(NSString *longURL) = ^(NSString *longURL) {
        
        NSString *pattern = @"([0-9.\\-]*),([0-9.\\-]*)";
        NSError *regexError = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&regexError];
        if (!regexError) {
            NSArray *matches = [regex matchesInString:longURL options:0 range:NSMakeRange(0, [longURL length])];
            NSString *latitude = [longURL substringWithRange:[[matches objectAtIndex:0] rangeAtIndex:1]];
            NSString *longitude = [longURL substringWithRange:[[matches objectAtIndex:0] rangeAtIndex:2]];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude.doubleValue longitude:longitude.doubleValue];
            [source setResult:location];
        } else {
            QMLog(@"REGEX error: %@", regexError);
            [source setError:regexError];
        }
    };
    
    
    if ([self isShortGoogleMapURL]) {
        
        [[self getLongURL] continueWithExecutor:BFExecutor.mainThreadExecutor
                                      withBlock:^id _Nullable(BFTask<NSURL *> * _Nonnull t) {
                                          
                                          t.error ?
                                          [source setError:t.error] :
                                          completionBlock(t.result.absoluteString);
                                          
                                          return nil;
                                      }];
    }
    else {
        completionBlock(url.absoluteString);
    }
    
    return source.task;
}

- (BFTask <NSURL*> *)getLongURL {
    
    BFTaskCompletionSource *source = [[BFTaskCompletionSource alloc] init];
    
    
    NSString *url =
    [NSString stringWithFormat:@"%@?fields=longUrl,status&shortUrl=%@&key=%@",
     QMGoogleMapsShortenerEndpointUrl,
     QMEncodedStringFromStringWithEncoding(self.absoluteString, NSUTF8StringEncoding),
     QMGoogleMapsAPIKey];
    
    
    
    [[NSURLSession.sharedSession dataTaskWithURL:[NSURL URLWithString:url]
                               completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error) {
          if (!error) {
              if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                  NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                  if (statusCode != 200) {
                      QMLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                      NSError *responseError =
                      [NSError errorWithDomain:@"QMShareExtension"
                                          code:0
                                      userInfo:nil];
                      
                      [source setError:responseError];
                  }
              }
              
              NSError *jsonParseError = nil;
              NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:0
                                                                     error:&jsonParseError];
              
              if (!jsonParseError) {
                  NSString *longUrl = [json objectForKey:@"longUrl"];
                  [source setResult:[NSURL URLWithString:longUrl]];
              }
              else {
                  QMLog(@"JSON parse error: %@", jsonParseError);
                  [source setError:error];
              }
          }
          else {
              QMLog(@"API request error: %@", error);
              [source setError:error];
          }
      }] resume];
    
    return source.task;
}

static inline NSString * QMEncodedStringFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kAFLegalCharactersToBeEscaped = @"?!@#$^&%*+=,:;'\"`<>()[]{}/\\|~ ";
    
    /*
     The documentation for `CFURLCreateStringByAddingPercentEscapes` suggests that one should "pre-process" URL strings with unpredictable sequences that may already contain percent escapes. However, if the string contains an unescaped sequence with '%' appearing without an escape code (such as when representing percentages like "42%"), `stringByReplacingPercentEscapesUsingEncoding` will return `nil`. Thus, the string is only unescaped if there are no invalid percent-escaped sequences.
     */
    NSString *unescapedString = [string stringByReplacingPercentEscapesUsingEncoding:encoding];
    if (unescapedString) {
        string = unescapedString;
    }
    
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)kAFLegalCharactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding));
}


@end
