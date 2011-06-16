//
//  restWrapperDelegate.h
//  tstStage-0.1
//
//  Created by maliy on 12/03/08.
//  Copyright 2009 off-club. All rights reserved.
//  $Id: restWrapperDelegate.h 168 2009-02-03 20:35:29Z maliy $
//

#import <Foundation/Foundation.h> 

@class restWrapper;

@protocol restWrapperDelegate

@required
- (void)restwr:(restWrapper *)restwrapper didRetrieveData:(NSData *)data;

@optional
- (void)restWrapperHasBadCredentials:(restWrapper *)wrapper;
- (void)restwr:(restWrapper *)restwrapper didCreateResourceAtURL:(NSString *)url;
- (void)restwr:(restWrapper *)restwrapper didFailWithError:(NSError *)error;
- (void)restwr:(restWrapper *)restwrapper didReceiveStatusCode:(int)statusCode;
- (void)restwr:(restWrapper *)restwrapper didReceivePacket:(int)length;

- (void)restwr:(restWrapper *)restwrapper willStartConnection:(NSURLRequest *)request;

@end
