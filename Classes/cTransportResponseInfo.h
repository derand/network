//
//  cTransportResponseInfo.h
//  src
//
//  Created by maliy on 4/21/09.
//

#import <Foundation/Foundation.h>

@class cError;

@interface cTransportResponseInfo : NSObject
{
	cError *error;
	id info;
	
	id data; 
}

@property (nonatomic, assign) cError *error;
@property (nonatomic, assign) id info;
@property (nonatomic, assign) id data;

- (id) initWithError:(cError *) _error info:(id) _info;
- (id) initWithError:(cError *) _error info:(id) _info data:(id) _data;

@end
