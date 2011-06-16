//
//  restWrapper.h
//  tstStage-0.1
//
//  Created by maliy on 12/03/08.
//

#import <Foundation/Foundation.h> 
#import "restWrapperDelegate.h"

@interface restWrapper : NSObject 
{
@private
    NSMutableData *receivedData;
    NSString *mimeType;
    NSURLConnection *conn;
    BOOL asynchronous;
    NSObject<restWrapperDelegate> *delegate;
    NSString *username;
    NSString *password;
	NSURL *finalURL;
	BOOL useCookies;
	
	NSDictionary *allHeadersFields;
	
	NSString *fileName;
	BOOL saveResponce2File;
	FILE *fo;
}

@property (nonatomic, readonly) NSData *receivedData;
@property (nonatomic) BOOL asynchronous;
@property (nonatomic, retain) NSString *mimeType;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, assign) NSObject<restWrapperDelegate> *delegate; // Do not retain delegates!
@property (nonatomic, readonly) NSDictionary *allHeadersFields;
@property (nonatomic, retain) NSURL *finalURL;
@property (nonatomic, assign) BOOL useCookies;
@property (nonatomic, retain) NSString *fileName;

- (void)sendRequestTo:(NSURL *)url usingVerb:(NSString *)verb withParameters:(NSDictionary *)parameters;
- (void)uploadData:(NSData *)data toURL:(NSURL *)url withParameters:(NSDictionary *)parameters;
- (void)uploadData:(NSData *)data named:(NSString *) filename toURL:(NSURL *)url withParameters:(NSDictionary *)parameters;
- (void)cancelConnection;
- (NSDictionary *)responseAsPropertyList;
- (NSString *)responseAsText;

- (void) uploadDataArray:(NSArray *) data contentTypes:(NSArray *) contentTypes fileNames:(NSArray *) names
				   toURL:(NSURL *)url withParameters:(NSDictionary *)parameters;


@end

