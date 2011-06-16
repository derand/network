//
//  transportQuery.h
//  src
//
//  Created by maliy on 2/9/09.
//

#import <UIKit/UIKit.h>

@class restQuery;
@class cError;

@interface transportQuery : NSObject
{
	restQuery *query;
	id responder;
	SEL selFunction;
	id info;
}

@property (nonatomic, readonly) restQuery *query;
@property (nonatomic, readonly) id info;

- (id) initWithQuery:(restQuery *) _query responder:(id) target function:(SEL) sel info:(id) _info;
- (void) callResponder:(id) data;
- (void) callResponderWithData:(id) data error:(cError *) err; 

@end
