//
//  restQuery.h
//  tstStage-0.1
//
//  Created by maliy on 1/26/09.
//

#import <UIKit/UIKit.h>
#import "restWrapperDelegate.h"

@class restWrapper;

@interface restQuery : NSObject <restWrapperDelegate, NSCopying>
{
	NSURL *address;
	NSString *verb;
	NSDictionary *params;
	NSString *mimeType;
	//NSString *output;
	id obj;
	SEL onComplite;
	
	restWrapper *engine;

	NSDictionary *allHeadersFields;
	NSError *error;
	
	id rdTarget;
	SEL rdSelector;
	NSUInteger recivedBytes;
}

@property (nonatomic, readonly) NSDictionary *allHeadersFields;
@property (nonatomic, readonly) NSURL *address;
@property (nonatomic, readonly) NSDictionary *params;
@property (nonatomic, readonly) NSError *error;
@property (nonatomic, assign) NSString *outputFile;

- (id) init;
- (id) initWithQuery:(NSURL *)address usingVerb:(NSString *)verb parametrs:(NSDictionary *)params mimneType:(NSString *)mimeType object:(id)obj responseSel:(SEL) response;
- (void) queryToAddress:(NSURL *)iaddress usingVerb:(NSString *)iverb parametrs:(NSDictionary *)iparams mimneType:(NSString *)imimeType object:(id)iobj responseSel:(SEL) response;
- (void) uploadData:(NSURL *)iaddress data:(NSData *)idata named:(NSString *) filename parametrs:(NSDictionary *)iparams object:(id)iobj responseSel:(SEL) response;
- (void)cancelConnection;
- (void) uploadData:(NSURL *)iaddress data:(NSArray *)idata contentTypes:(NSArray *) contentTypes
			  named:(NSArray *) filenames parametrs:(NSDictionary *)iparams
			 object:(id)iobj responseSel:(SEL) response;

- (void) useCookies:(BOOL) _sc;
- (void) reciveDataTarget:(id) target selector:(SEL) aSelector;

@end
