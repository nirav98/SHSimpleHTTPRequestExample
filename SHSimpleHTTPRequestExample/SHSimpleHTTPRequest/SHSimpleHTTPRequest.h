//
//  SHSimpleHTTPRequest.h
//  SHSimpleHTTPRequestExample
//
//  Created by shabib hossain on 5/27/14.
//  Copyright (c) 2014 shabib hossain. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SHSimpleHTTPRequest;

@protocol SHSimpleHTTPRequestDelegate <NSObject>

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

@property (nonatomic, strong, readonly) NSString *url;
@property (nonatomic, strong, readonly) NSDictionary *parameters;
@property (nonatomic, readwrite) NSInteger tag;
@property (nonatomic, readwrite) NSTimeInterval timeout;
@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, weak) id <SHSimpleHTTPRequestDelegate> delegate;

- (id)initWithURL:(NSString *)url data:(NSDictionary *)parameters delegate:(id)delegate;
- (void)initGetRequest;
- (void)initPostRequest;
- (void)initDeleteRequest;
- (void)initPutRequest;
- (void)initAsyncGetRequest;
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
