//
//  transportQuery.m
//  src
//
//  Created by maliy on 2/9/09.
//

#import "transportQuery.h"
#import "restQuery.h"
#import "cTransportResponseInfo.h"

@implementation transportQuery
@synthesize query;
@synthesize info;

#pragma mark lifeCycle

- (id) initWithQuery:(restQuery *) _query responder:(id) target function:(SEL) sel info:(id) _info
{
    self = [super init];
	if (self)
	{
		query = _query;
		if (query == nil)
			query = [[restQuery alloc] init];
		responder = target;
		selFunction = sel;
		info = [_info retain];;		
	}
	return self;
}

-(void) dealloc
{
	[info release];
	[query release];
	[super dealloc];
}


#pragma mark -

- (void) callResponder:(id) data
{
	if (responder != nil)
	{
		[responder performSelector:selFunction withObject:data withObject:info];
	}
}

- (void) callResponderWithData:(id) data error:(NSError *) err
{
	if (responder != nil)
	{
		cTransportResponseInfo *tri = [[cTransportResponseInfo alloc] initWithError:err info:info data:data];
		[responder performSelector:selFunction withObject:tri];
		[tri release];
	}
}



@end
