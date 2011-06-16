//
//  restWrapper.m
//  tstStage-0.1
//
//  Created by maliy on 12/03/08.
//

#import "restWrapper.h"

@interface restWrapper (Private)
- (void)startConnection:(NSURLRequest *)request;
@end

@implementation restWrapper

@synthesize receivedData;
@synthesize asynchronous;
@synthesize mimeType;
@synthesize username;
@synthesize password;
@synthesize delegate;
@synthesize allHeadersFields;
@synthesize finalURL;
@synthesize useCookies;
@synthesize fileName;

#pragma mark lifeCycle

- (id)init
{
    self = [super init];
    if(self)
    {
        receivedData = [[NSMutableData alloc] init];
        conn = nil;

        asynchronous = YES;
        mimeType = @"text/html";
        delegate = nil;
        username = @"";
        password = @"";
		allHeadersFields = nil;
		useCookies = NO;
		fileName = nil;
    }

    return self;
}

- (void)dealloc
{
	self.fileName = nil;
	self.finalURL = nil;
	[allHeadersFields release];
	[receivedData release];
	receivedData = nil;
	self.mimeType = nil;
	self.username = nil;
	self.password = nil;

    [super dealloc];
}

#pragma mark -
#pragma mark Public methods

- (void)sendRequestTo:(NSURL *)url usingVerb:(NSString *)verb withParameters:(NSDictionary *)parameters
{
    NSData *body = nil;
    NSMutableString *params = nil;
    NSString *contentType = @"text/html; charset=utf-8";
    self.finalURL = url;
    if (parameters != nil)
    {
        params = [[NSMutableString alloc] init];
		BOOL needDeletelastCharset = NO;
        for (id key in parameters)
        {
            [params appendFormat:@"%@=%@&", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
             [[parameters objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			needDeletelastCharset = YES;
        }
		if (needDeletelastCharset)
			[params deleteCharactersInRange:NSMakeRange([params length] - 1, 1)];
    }
    
    if ([verb isEqualToString:@"POST"] || [verb isEqualToString:@"PUT"])
    {
        contentType = @"application/x-www-form-urlencoded; charset=utf-8";
        body = [params dataUsingEncoding:NSUTF8StringEncoding];
    }
    else
    {
        if (parameters != nil)
        {
            NSString *urlWithParams = [[url absoluteString] stringByAppendingFormat:@"?%@", params];
            self.finalURL = [NSURL URLWithString:urlWithParams];
        }
    }

	NSMutableDictionary *headers;
	if (useCookies)
	{
		NSArray *availableCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage]
									 cookiesForURL:[NSURL URLWithString:[finalURL host]]]; 
	
		headers = [[NSMutableDictionary alloc] 
				   initWithDictionary:[NSHTTPCookie requestHeaderFieldsWithCookies:availableCookies]];
	}
	else
	{
		headers = [[NSMutableDictionary alloc] init];
	}
    [headers setValue:contentType forKey:@"Content-Type"];
    [headers setValue:mimeType forKey:@"Accept"];
//    [headers setValue:@"no-cache" forKey:@"Cache-Control"];
//    [headers setValue:@"no-cache" forKey:@"Pragma"];
    [headers setValue:@"close" forKey:@"Connection"]; // Avoid HTTP 1.1 "keep alive" for the connection

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:finalURL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:verb];
    [request setAllHTTPHeaderFields:headers];
    if (parameters != nil)
    {
        [request setHTTPBody:body];
    }
    [params release];
    [self startConnection:request];
	[headers release];
	
}

- (void)uploadData:(NSData *)data named:(NSString *) filename toURL:(NSURL *)url withParameters:(NSDictionary *)parameters
{
	[self uploadDataArray:[NSArray arrayWithObject:data]
			 contentTypes:[NSArray arrayWithObject:@"image/jpeg"]
				fileNames:[NSArray arrayWithObject:filename]
					toURL:url
		   withParameters:parameters];
	return ;
}

- (void)uploadData:(NSData *)data toURL:(NSURL *)url withParameters:(NSDictionary *)parameters
{
	[self uploadData:data named:@"avatar" toURL:url withParameters:parameters];
}

- (void) uploadDataArray:(NSArray *) data contentTypes:(NSArray *) contentTypes fileNames:(NSArray *) names
				   toURL:(NSURL *)url withParameters:(NSDictionary *)parameters
{
	// File upload code adapted from http://www.cocoadev.com/index.pl?HTTPFileUpload
    // and http://www.cocoadev.com/index.pl?HTTPFileUploadSample
	
    NSString* stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
    
    NSMutableDictionary* headers = [[[NSMutableDictionary alloc] init] autorelease];
    [headers setValue:@"no-cache" forKey:@"Cache-Control"];
    [headers setValue:@"no-cache" forKey:@"Pragma"];
    [headers setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary] forKey:@"Content-Type"];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
	NSInteger sz = 0;
	for (NSData *dt in data)
		sz += [dt length];
	
    NSMutableData* postData = [NSMutableData dataWithCapacity:sz+512*[parameters count]+512];
	//Content-Disposition: form-data; name="name"
	[postData appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	for (id key in parameters)
	{
		//[params appendFormat:@"%@=%@&", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
		// [[parameters objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		
		[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] 
							  dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[[parameters objectForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	int i;
	for (i=0; i<([data count]); i++)
	{
		[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [names objectAtIndex:i], [names objectAtIndex:i]] 
							  dataUsingEncoding:NSUTF8StringEncoding]];
//		[postData appendData:[@"Content-Type: image/jpeg\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", [contentTypes objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[data objectAtIndex:i]];
		[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	/*
	[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [names objectAtIndex:i], [names objectAtIndex:i]] 
						  dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n", [contentTypes objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[data objectAtIndex:i]];
	[postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	 */
	NSRange range;
	range.location = [postData length]-2;
	range.length = 2;
	[postData replaceBytesInRange:range withBytes:"--"];
	[postData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postData];
    
    [self startConnection:request];
}


- (void)cancelConnection
{
    [conn cancel];
    [conn release];
    conn = nil;
}

- (NSDictionary *)responseAsPropertyList
{
    NSString *errorStr = nil;
    NSPropertyListFormat format;
    NSDictionary *propertyList = [NSPropertyListSerialization propertyListFromData:receivedData
                                                                  mutabilityOption:NSPropertyListImmutable
                                                                            format:&format
                                                                  errorDescription:&errorStr];
    [errorStr release];
    return propertyList;
}

- (NSString *)responseAsText
{
    return [[[NSString alloc] initWithData:receivedData 
                                 encoding:NSUTF8StringEncoding] autorelease];
}


#pragma mark -
#pragma mark Private methods

- (void)startConnection:(NSURLRequest *)request
{
	if ([delegate respondsToSelector:@selector(restwr:willStartConnection:)])
	{
		[delegate restwr:self willStartConnection:request];
	}
	
	saveResponce2File = NO;
	if (fileName!=nil)
	{
		fo = fopen([fileName cStringUsingEncoding:NSUTF8StringEncoding], "w+");
        if (fo)
        {
//            NSLog(@"Open file \"%@\"", [fileName lastPathComponent]);
        }
        else
        {
            NSLog(@"Can't open file \"%@\" error: \"%s\"", fileName, strerror(errno));
        }
            
		saveResponce2File = YES;
	}
	
    if (asynchronous)
    {
        [self cancelConnection];
        conn = [[NSURLConnection alloc] initWithRequest:request
                                               delegate:self
                                       startImmediately:YES];
        
        if (!conn)
        {
            if ([delegate respondsToSelector:@selector(restwr:didFailWithError:)])
            {
                NSMutableDictionary* info = [NSMutableDictionary dictionaryWithObject:[request URL] forKey:NSErrorFailingURLStringKey];
                [info setObject:@"Could not open connection" forKey:NSLocalizedDescriptionKey];
                NSError* error = [NSError errorWithDomain:@"restWrapper" code:1 userInfo:info];
                [delegate restwr:self didFailWithError:error];
            }
        }
    }
    else
    {
        NSURLResponse* response = [[NSURLResponse alloc] init];
        NSError* error = [[NSError alloc] init];
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        [receivedData setData:data];
        [response release];
        response = nil;
        [error release];
        error = nil;
    }
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSInteger count = [challenge previousFailureCount];
    if (count == 0)
    {
        NSURLCredential* credential = [[NSURLCredential credentialWithUser:username
                                                                  password:password
                                                               persistence:NSURLCredentialPersistenceNone] autorelease];
        [[challenge sender] useCredential:credential 
               forAuthenticationChallenge:challenge];
    }
    else
    {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        if ([delegate respondsToSelector:@selector(restWrapperHasBadCredentials:)])
        {
            [delegate restWrapperHasBadCredentials:self];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int statusCode = [httpResponse statusCode];
	allHeadersFields = [[httpResponse allHeaderFields] retain];
    switch (statusCode)
    {
        case 200:
            break;

        case 201:
        {
            NSString* url = [[httpResponse allHeaderFields] objectForKey:@"Location"];
            if ([delegate respondsToSelector:@selector(restwr:didCreateResourceAtURL:)])
            {
                [delegate restwr:self didCreateResourceAtURL:url];
            }
            break;
        }
            
        // Here you could add more status code handling... for example 404 (not found),
        // 204 (after a PUT or a DELETE), 500 (server error), etc... with the
        // corresponding delegate methods called as required.
        
        default:
        {
            if ([delegate respondsToSelector:@selector(restwr:didReceiveStatusCode:)])
            {
                [delegate restwr:self didReceiveStatusCode:statusCode];
            }
            break;
        }
    }
    [receivedData setLength:0];
	
	if (useCookies)
	{
		NSArray *allCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields]
																 forURL:[NSURL URLWithString:[finalURL host]] ];
		NSLog(@"How many Cookies: %d", allCookies.count);
		for (NSHTTPCookie *cookie in allCookies)
		{
			NSLog(@"Name: %@ : Value: %@, Expires: %@", cookie.name, cookie.value, cookie.expiresDate);
		}
		[[NSHTTPCookieStorage sharedHTTPCookieStorage]
			setCookies:allCookies forURL:[NSURL URLWithString:[finalURL host]] mainDocumentURL:nil]; 
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (saveResponce2File)
	{
		fwrite([data bytes], 1, [data length], fo);
	}
	else
	{
		[receivedData appendData:data];
	}
    if ([delegate respondsToSelector:@selector(restwr:didReceivePacket:)])
    {
        [delegate restwr:self didReceivePacket:[data length]];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (saveResponce2File)
	{
		fclose(fo);
	}
    [self cancelConnection];
    if ([delegate respondsToSelector:@selector(restwr:didFailWithError:)])
    {
        [delegate restwr:self didFailWithError:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (saveResponce2File)
	{
		fclose(fo);
	}
    [self cancelConnection];
    if ([delegate respondsToSelector:@selector(restwr:didRetrieveData:)])
    {
        [delegate restwr:self didRetrieveData:receivedData];
    }
}

@end
