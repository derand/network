//
//  cTransportResponseInfo.m
//  src
//
//  Created by maliy on 4/21/09.
//  Copyright 2009 off-club. All rights reserved.
//  $Id: cTransportResponseInfo.m 494 2009-04-23 15:57:50Z maliy $
//

#import "cTransportResponseInfo.h"


@implementation cTransportResponseInfo
@synthesize error;
@synthesize info;
@synthesize data;

- (id) initWithError:(cError *) _error info:(id) _info
{
	return [self initWithError:_error info:_info data:nil];
}

- (id) initWithError:(cError *) _error info:(id) _info data:(id) _data
{
	if(self = [super init])
	{
		error = _error;
		info = _info;
		data = _data;
	}
	return self;
}


- (void) dealloc
{
	[super dealloc];
}

@end
