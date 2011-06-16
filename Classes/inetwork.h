/*
 *  inetwork.h
 *  src
 *
 *  Created by maliy on 12/26/09.
 *
 */

#import <Foundation/Foundation.h>

@interface cTransportResponseInfo: NSObject

@property (nonatomic, assign) id error;
@property (nonatomic, assign) id info;
@property (nonatomic, assign) id data;

- (id) initWithError:(id) _error info:(id) _info;
- (id) initWithError:(id) _error info:(id) _info data:(id) _data;
@end


@interface restQuery: NSObject

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


@interface transportQuery: NSObject
@property (nonatomic, readonly) restQuery *query;
@property (nonatomic, readonly) id info;

- (id) initWithQuery:(restQuery *) _query responder:(id) target function:(SEL) sel info:(id) _info;
- (void) callResponder:(id) data;
- (void) callResponderWithData:(id) data error:(id) err; 
@end

