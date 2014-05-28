//
//  SHSimpleHTTPRequest.h
//  SHSimpleHTTPRequestExample
//
//  Created by shabib hossain on 5/27/14.
//  Copyright (c) 2014 shabib hossain. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kImageParameterKey @"image"

@class SHSimpleHTTPRequest;

@protocol SHSimpleHTTPRequestDelegate <NSObject>

@required
- (void)simpleHTTPRequest:(SHSimpleHTTPRequest *)request didFinishLoadingData:(NSData *)data;
- (void)simpleHTTPRequest:(SHSimpleHTTPRequest *)request didFailedWithError:(NSError *)error;

@end

@interface SHSimpleHTTPRequest : NSObject
{
    NSMutableData *data;
    NSURLConnection *connection;
    NSMutableURLRequest *request;
    NSURLRequestCachePolicy cachePolicy;
}

@property (nonatomic, weak) id <SHSimpleHTTPRequestDelegate> delegate;

@property (nonatomic, strong, readonly) NSString *url;

@property (nonatomic, strong, readonly) NSDictionary *parameters;

@property (nonatomic, readwrite) NSTimeInterval timeout;

@property (nonatomic, readwrite) NSInteger tag;
@property (nonatomic, readonly) NSInteger statusCode;

- (id)initWithURL:(NSString *)url formData:(NSDictionary *)parameters delegate:(id)delegate;

- (void)startGetRequestCall;
- (void)startPostRequestCall;
- (void)startDeleteRequestCall;
- (void)startPutRequestCall;
- (void)startAsynchronousRequestCall;

- (void)stopRequest;

- (void)disableCaching:(BOOL)yes;

- (NSString *)getURL;

@end

@interface NSString (Additions)

- (NSString *)getURLEncodedStringWithCharacters:(NSString *)characters;

@end

@interface NSDictionary (Additions)

- (NSString *)returnJSONDictionary;

@end

@interface NSData (Additions)

- (NSMutableDictionary *)getDeserializedDictionary;
- (NSArray *)getDeserializedArray;

@end
