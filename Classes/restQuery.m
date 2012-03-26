//
//  restQuery.m
//  tstStage-0.1
//
//  Created by maliy on 1/26/09.
//

#import "restQuery.h"
#import "restWrapper.h"

@interface restQuery ()
@property (nonatomic, retain) id obj;
@end



@implementation restQuery
@synthesize allHeadersFields;
@synthesize address;
@synthesize params;
@synthesize obj;
@synthesize error;
@synthesize startImmediately;
@synthesize queryStatus;

#pragma mark LifeCycle

- (id) initWithQuery:(NSURL *) iaddress usingVerb:(NSString *)iverb parametrs:(NSDictionary *) iparams mimneType:(NSString *) imimeType object:(id)iobj responseSel:(SEL) response
{
	if ( self = [super init])
	{
		address = [iaddress retain];
		verb = [iverb retain];
		params  = [iparams retain];
		mimeType = [imimeType retain];
		self.obj = iobj;
		allHeadersFields = nil;
		
		if (address != nil)
		{
			[self queryToAddress:address usingVerb:verb parametrs:params mimneType:mimeType object:obj responseSel:response];
		}
		error = nil;
		rdTarget = nil;
		
		engine = [[restWrapper alloc] init];
        engine.delegate = self;

        startImmediately = YES;
        queryStatus = QueryStatusNone;
	}
	return self;
}

- (id) init
{
	return [self initWithQuery:nil usingVerb:nil parametrs:nil mimneType:nil object:nil responseSel:nil];
}

- (void) queryToAddress:(NSURL *)iaddress usingVerb:(NSString *)iverb parametrs:(NSDictionary *)iparams mimneType:(NSString *)imimeType object:(id)iobj responseSel:(SEL) response
{
	UIApplication *application = [UIApplication sharedApplication];
	application.networkActivityIndicatorVisible = YES;

	self.obj = iobj;
	onComplite = response;
    if (engine == nil)
    {
        engine = [[restWrapper alloc] init];
        engine.delegate = self;
    }
	engine.mimeType = imimeType;
	if (engine.mimeType == nil)
	{
		engine.mimeType = @"text/html";
	}
	address = [iaddress retain];;
	verb = [iverb retain];
	params = [iparams retain]; 
	
    if (startImmediately)
    {
		queryStatus = QueryStatusStarted;
		[engine sendRequestTo:address usingVerb:verb withParameters:params];
    }
	else
	{
		qtype = 1;
	}
}


- (void) uploadData:(NSURL *)iaddress data:(NSData *)idata
			  named:(NSString *) filename parametrs:(NSDictionary *)iparams
			 object:(id)iobj responseSel:(SEL) response
{
	UIApplication *application = [UIApplication sharedApplication];
	application.networkActivityIndicatorVisible = YES;

	self.obj = iobj;
	onComplite = response;
    if (engine == nil)
    {
        engine = [[restWrapper alloc] init];
        engine.delegate = self;
    }
	address = [iaddress retain];
	params = [iparams retain]; 
	
    if (startImmediately)
    {
		queryStatus = QueryStatusStarted;
		[engine uploadData:idata named:filename toURL:address withParameters:params];
	}
	else
	{
		qtype = 2;
		[storedData release];
		storedData = [idata retain];
		[storefFileName release];
		storefFileName = [filename retain]; 
	}
}

- (void) uploadData:(NSURL *)iaddress data:(NSArray *)idata contentTypes:(NSArray *) contentTypes
			  named:(NSArray *) filenames parametrs:(NSDictionary *)iparams
			 object:(id)iobj responseSel:(SEL) response
{
	UIApplication *application = [UIApplication sharedApplication];
	application.networkActivityIndicatorVisible = YES;
	
	self.obj = iobj;
	onComplite = response;
    if (engine == nil)
    {
        engine = [[restWrapper alloc] init];
        engine.delegate = self;
    }
	address = [iaddress retain];;
	params = [iparams retain]; 
	
    if (startImmediately)
    {
		queryStatus = QueryStatusStarted;
		[engine uploadDataArray:idata
				   contentTypes:contentTypes 
					  fileNames:filenames
						  toURL:address
				 withParameters:params];
	}
	else
	{
		qtype = 3;
		[storedDataArray release];
		storedDataArray = [idata retain];
		[storedContentTypes release];
		storedContentTypes = [contentTypes retain]; 
		[storedFileNames release];
		storedFileNames = [storedFileNames retain]; 
	}
}

- (void) startConnection
{
	if (!startImmediately)
	{
		switch (qtype)
		{
			case 1:
				queryStatus = QueryStatusStarted;
				[engine sendRequestTo:address usingVerb:verb withParameters:params];
				break;
			case 2:
				queryStatus = QueryStatusStarted;
				[engine uploadData:storedData named:storefFileName toURL:address withParameters:params];
				break;
			case 3:
				queryStatus = QueryStatusStarted;
				[engine uploadDataArray:storedDataArray
						   contentTypes:storedContentTypes 
							  fileNames:storedFileNames
								  toURL:address
						 withParameters:params];
				break;
				
			default:
				break;
		}
	}
}

- (void)cancelConnection
{
	[engine cancelConnection];
}

- (void) dealloc
{
	[storedDataArray release];
	[storedContentTypes release];
	[storedFileNames release];
	[storedData release];
	[storefFileName release];

	[error release];
	[address release];
	[params release];
	[mimeType release];
	[engine release];
	self.obj = nil;
	[super dealloc];
}

- (void) useCookies:(BOOL) _sc
{
	engine.useCookies = _sc;
}

- (void) reciveDataTarget:(id) target selector:(SEL) aSelector
{
	rdTarget = target;
	rdSelector = aSelector;
}

- (void) setOutputFile:(NSString *) fileName
{
	engine.fileName = fileName;
}

- (NSString *) outputFile
{
    return engine.fileName;
}


#pragma mark -
#pragma mark restWrapperDelegate

- (void)restwr:(restWrapper *)restwrapper didRetrieveData:(NSData *)data
{
	allHeadersFields = [restwrapper allHeadersFields];
//	NSLog(@"%@", [engine responseAsText]);
	[obj performSelector:onComplite withObject:self withObject:[engine receivedData]];
}

- (void)restWrapperHasBadCredentials:(restWrapper *)wrapper
{
	allHeadersFields = [wrapper allHeadersFields];
}
- (void)restwr:(restWrapper *)restwrapper didCreateResourceAtURL:(NSString *)url
{
	allHeadersFields = [restwrapper allHeadersFields];
}
- (void) restwr:(restWrapper *) restwrapper didFailWithError:(NSError *) _error
{
	allHeadersFields = [restwrapper allHeadersFields];
	[error release];
	error = [_error retain];
	[obj performSelector:onComplite withObject:self withObject:nil];
}
- (void) restwr:(restWrapper *) restwrapper didReceiveStatusCode:(int) statusCode
{
	allHeadersFields = [restwrapper allHeadersFields];
	[error release];
	error = [[NSError alloc] initWithDomain:@"Server error"
									   code:statusCode
								   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
											 NSLocalizedString(@"Server error.\n Please try again later", @""),
											 @"NSLocalizedDescription", nil]];
}

- (void)restwr:(restWrapper *)restwrapper didReceivePacket:(int)length
{
	if (rdTarget)
	{
		recivedBytes += length;
		[rdTarget performSelector:rdSelector withObject:self withObject:[NSNumber numberWithInteger:recivedBytes]];
	}
}

- (void)restwr:(restWrapper *)restwrapper willStartConnection:(NSURLRequest *)request
{
	recivedBytes = 0;
}



#pragma mark -
#pragma mark NSCopying protocol

- (id)copyWithZone:(NSZone *)zone
{
	return [self retain];
}


@end
