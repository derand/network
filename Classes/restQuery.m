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
	
	[engine sendRequestTo:address usingVerb:verb withParameters:params];
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
	address = [iaddress retain];;
	params = [iparams retain]; 
	
	[engine uploadData:idata named:filename toURL:iaddress withParameters:iparams];
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
	
	[engine uploadDataArray:idata
			   contentTypes:contentTypes 
				  fileNames:filenames
					  toURL:iaddress withParameters:iparams];
}


- (void) dealloc
{
	[error release];
	[address release];
	[params release];
	[mimeType release];
	[engine release];
	self.obj = nil;
	[super dealloc];
}

- (void)cancelConnection
{
	[engine cancelConnection];
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
