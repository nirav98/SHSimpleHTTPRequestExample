//
//  SHSimpleHTTPRequest.m
//  SHSimpleHTTPRequestExample
//
//  Created by shabib hossain on 5/27/14.
//  Copyright (c) 2014 shabib hossain. All rights reserved.
//

#import "SHSimpleHTTPRequest.h"

#define urlCharactersToBeEncoded @"!*'();@$,%#[]"
#define urlDataCharactersToBeEncoded @"!*'();@$,%#[]+"

@interface SHSimpleHTTPRequest ()

- (BOOL)delegateIsConsistant;

- (void)initConnection;
- (void)startRequest;

- (NSString *)getURLEncodedStringForString:(NSString *)string WithCharacters:(NSString *)characters;

@end

@implementation SHSimpleHTTPRequest

@synthesize url;
@synthesize parameters;
@synthesize delegate;
@synthesize tag;
@synthesize timeout;
@synthesize statusCode;

- (id)initWithURL:(NSString *)_url formData:(NSDictionary *)_parameters delegate:(id)_delegate
{
    if (self = [super init])
    {
        // assigning parameters
        url = [_url getURLEncodedStringWithCharacters:urlCharactersToBeEncoded];
        if(_parameters != nil)
        {
            parameters = [[NSDictionary alloc] initWithDictionary:_parameters];
        }
        
        delegate = _delegate;
        
        // assigning default values
        cachePolicy = NSURLRequestUseProtocolCachePolicy;
        timeout = 20.0;
    }
    
    return self;
}

- (void)startGetRequestCall
{
    if ([self delegateIsConsistant])
    {
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        request.cachePolicy = cachePolicy;
        request.HTTPMethod = @"GET";
        request.timeoutInterval = timeout;
        
        [self initConnection];
        [self startRequest];
    }
}

- (void)startPostRequestCall
{
    if ([self delegateIsConsistant])
    {
        BOOL shouldAddHeaderForImage = NO;
        NSString *contentType;
        
        NSMutableData *postData = [[NSMutableData alloc] init];
        NSString *firstkey  = [[parameters allKeys] objectAtIndex:0];
        
        for(NSString *key in [parameters allKeys])
        {
            if(![key isEqualToString:firstkey] && ![key isEqualToString:kImageParameterKey])
            {
                [postData appendData:[@"&" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            id object = [parameters objectForKey:key];
            
            if([object isKindOfClass:[NSString class]])
            {
                NSString *postPart = [NSString stringWithFormat:@"%@=%@", key, (NSString *)object];
                
                [postData appendData:[[postPart getURLEncodedStringWithCharacters:urlDataCharactersToBeEncoded] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            else if([object isKindOfClass:[NSArray class]])
            {
                for(int i = 0; i < [(NSArray *)object count]; i++)
                {
                    if(i)
                    {
                        [postData appendData:[@"&" dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                    
                    NSString *postPart = [NSString stringWithFormat:@"%@=%@", key, [(NSArray *)object objectAtIndex:i]];
                    
                    [postData appendData:[[postPart getURLEncodedStringWithCharacters:urlDataCharactersToBeEncoded] dataUsingEncoding:NSUTF8StringEncoding]];
                }
            }
            else if([object isKindOfClass:[NSDictionary class]])
            {
                NSString *postPart = [NSString stringWithFormat:@"%@=%@", key, [(NSDictionary *)object returnJSONDictionary]];
                
                [postData appendData:[[postPart getURLEncodedStringWithCharacters:urlDataCharactersToBeEncoded] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            else if([object isKindOfClass:[NSNumber class]])
            {
                NSString *postPart = [NSString stringWithFormat:@"%@=%@", key, [(NSNumber *)object stringValue]];
                
                [postData appendData:[[postPart getURLEncodedStringWithCharacters:urlDataCharactersToBeEncoded] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            else if([object isKindOfClass:[UIImage class]])
            {
                shouldAddHeaderForImage = YES;
                
                // define boundary
                NSString *boundary = @"14737809831466499882746641449";
                
                contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
                
                // convert image to jpeg data
                // we are reducing the quality until its less than 600 kB
                
                NSData *imageData = UIImageJPEGRepresentation((UIImage *)object, 0.067);
                NSLog(@"%lu", (unsigned long)imageData.length);
                
                [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                
                [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpeg\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
                
                [postData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                
                [postData appendData:imageData];
                
                [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            else
            {
                NSLog(@"%@", key);
            }
        }
        
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        request.cachePolicy = cachePolicy;
        request.HTTPMethod = @"POST";
        request.timeoutInterval = timeout;
        request.HTTPBody = postData;
        
        if(shouldAddHeaderForImage)
        {
            [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        }
        
        [self initConnection];
        [self startRequest];
    }
}

- (void)startDeleteRequestCall
{
    if ([self delegateIsConsistant])
    {
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        request.HTTPMethod = @"DELETE";
        request.timeoutInterval = timeout;
        
        [self initConnection];
        [self startRequest];
    }
}

- (void)startPutRequestCall
{
    if ([self delegateIsConsistant])
    {
        BOOL shouldAddHeaderForImage = NO;
        NSString *contentType;
        
        NSMutableData *postData = [[NSMutableData alloc] init];
        
        NSString *firstkey  = [[parameters allKeys] objectAtIndex:0];
        
        for(NSString *key in [parameters allKeys])
        {
            if(![key isEqualToString:firstkey] && ![key isEqualToString:kImageParameterKey])
            {
                [postData appendData:[@"&" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            
            id object = [parameters objectForKey:key];
            
            if([object isKindOfClass:[NSString class]])
            {
                NSString *postPart = [NSString stringWithFormat:@"%@=%@", key, (NSString *)object];
                
                [postData appendData:[[postPart getURLEncodedStringWithCharacters:urlDataCharactersToBeEncoded] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            else if([object isKindOfClass:[NSArray class]])
            {
                for(int i = 0; i < [(NSArray *)object count]; i++)
                {
                    if(i)
                    {
                        [postData appendData:[@"&" dataUsingEncoding:NSUTF8StringEncoding]];
                    }
                    
                    NSString *postPart = [NSString stringWithFormat:@"%@=%@", key, [(NSArray *)object objectAtIndex:i]];
                    
                    [postData appendData:[[postPart getURLEncodedStringWithCharacters:urlDataCharactersToBeEncoded] dataUsingEncoding:NSUTF8StringEncoding]];
                }
            }
            else if([object isKindOfClass:[NSDictionary class]])
            {
                NSString *postPart = [NSString stringWithFormat:@"%@=%@", key, [(NSDictionary *)object returnJSONDictionary]];
                
                [postData appendData:[[postPart getURLEncodedStringWithCharacters:urlDataCharactersToBeEncoded] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            else if([object isKindOfClass:[NSNumber class]])
            {
                NSString *postPart = [NSString stringWithFormat:@"%@=%@", key, [(NSNumber *)object stringValue]];
                [postData appendData:[[postPart getURLEncodedStringWithCharacters:urlDataCharactersToBeEncoded] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            else if([object isKindOfClass:[UIImage class]])
            {
                shouldAddHeaderForImage = YES;
                // define boundary
                NSString *boundary = @"14737809831466499882746641449";
                
                contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
                
                // convert image to jpeg data
                // we are reducing the quality until its less than 600 kB
                
                NSData *imageData;
                double quality = 1.0;
                
                imageData = UIImageJPEGRepresentation((UIImage *)object, quality);
                
                while (imageData.length >= 614400)
                {
                    quality -= 0.1;
                    imageData = UIImageJPEGRepresentation((UIImage *)object, quality);
                }
                
                [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                
                [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpeg\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
                
                [postData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                
                [postData appendData:imageData];
                
                [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            }
            else
            {
                NSLog(@"%@", key);
            }
        }
        
        NSString *postString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", url, postString]]];
        request.cachePolicy = cachePolicy;
        request.HTTPMethod = @"PUT";
        request.timeoutInterval = timeout;
        
        if(shouldAddHeaderForImage)
        {
            [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        }
        
        [self initConnection];
        [self startRequest];
    }
}

- (void)startAsynchronousRequestCall
{
    if ([self delegateIsConsistant])
    {
        NSURLRequest *_request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        [NSURLConnection sendAsynchronousRequest:_request queue:queue completionHandler:^(NSURLResponse *_response, NSData *_data_, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                statusCode = [(NSHTTPURLResponse *)_response statusCode];
            });
            
            if (_data_.length > 0 && error == nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate simpleHTTPRequest:self didFinishLoadingData:_data_];
                });
            }
            else if (_data_.length == 0 && error == nil)
            {
                //Data is empty
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate simpleHTTPRequest:self didFinishLoadingData:_data_];
                });
                NSLog(@"Response is empty");
            }
            else if (error != nil && error.code == NSURLErrorTimedOut)
            {
                //Request timed out
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate simpleHTTPRequest:self didFailedWithError:error];
                });
                NSLog(@"%@", error.description);
            }
            else // if (error != nil)
            {
                //Failed to load data
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate simpleHTTPRequest:self didFailedWithError:error];
                });
                NSLog(@"%@", error.description);
            }
        }];
    }
}

- (void)stopRequest
{
    [connection cancel];
    data = nil;
}

- (void)disableCaching:(BOOL)yes
{
    if(yes) cachePolicy = NSURLRequestReloadIgnoringCacheData;
    else cachePolicy = NSURLRequestUseProtocolCachePolicy;
}

- (NSString *)getURL
{
    return url;
}

#pragma mark - Private methods

- (void)initConnection
{
    data = [[NSMutableData alloc] init];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
}

- (void)startRequest
{
    [connection start];
}

- (NSString *)getURLEncodedStringForString:(NSString *)string WithCharacters:(NSString *)characters
{
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, (CFStringRef)characters, kCFStringEncodingUTF8);
}

- (BOOL)delegateIsConsistant
{
    if ([delegate respondsToSelector:@selector(simpleHTTPRequest:didFinishLoadingData:)] && [delegate respondsToSelector:@selector(simpleHTTPRequest:didFailedWithError:)])
    {
        return YES;
    }
    
    @throw ([NSException exceptionWithName:@"DelegateIncompleteImplementationException" reason:@"You should implement #simpleHTTPRequest:didFinishLoadingData: and #simpleHTTPRequest:didFailedWithError:" userInfo:nil]);
}

#pragma mark - NSURLConnection Delegates

- (void)connection:(NSURLConnection *)_connection didReceiveResponse:(NSURLResponse *)_response
{
    statusCode = [(NSHTTPURLResponse *)_response statusCode];
}

- (void)connection:(NSURLConnection *)_connection didReceiveData:(NSData *)_data
{
	[data appendData:_data];
}

- (void)connection:(NSURLConnection *)_connection didFailWithError:(NSError *)error {
    
	NSLog(@"Connection Failed with error: %@ %@",[error localizedDescription],
		  [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	
	[delegate simpleHTTPRequest:self didFailedWithError:error];
	data = nil;
	connection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)_connection
{
    [delegate simpleHTTPRequest:self didFinishLoadingData:(NSData *)data];
	connection = nil;
	data = nil;
}

@end

@implementation NSString (Additions)

- (NSString *)getURLEncodedStringWithCharacters:(NSString *)characters
{
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, (CFStringRef)characters, kCFStringEncodingUTF8);
}

@end

@implementation NSDictionary (Additions)

- (NSString *)returnJSONDictionary
{
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

@end

@implementation NSData (Additions)

- (NSMutableDictionary *)getDeserializedDictionary
{
    NSError *error = nil;
    NSMutableDictionary *ret = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableContainers error:&error];
    
    return ret;
}

- (NSArray *)getDeserializedArray
{
    NSError *error = nil;
    NSArray *ret = (NSArray *)[NSJSONSerialization JSONObjectWithData:self options:0 error:&error];
    
    return ret;
}

- (id)deserialize
{
    NSError *error = nil;
    id object = (id)[NSJSONSerialization JSONObjectWithData:self options:0 error:&error];
    
    return object;
}

@end
