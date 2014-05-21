//
//  SLDataGrabber.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/04/25.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLDataGrabberDelegate;

@interface SLDataGrabber : NSObject
/**
 Returns a singleton instance of the class
 @return Singleton instance of the class.
*/
+(SLDataGrabber *)defaultDataGrabber;
/**
 Loads the data of a given page from the API
 @param page Page in the API to load data from.
 @param completionHandler Code block to run once the data is retrieved from the API.
*/
-(void)grabDataOfPage:(NSUInteger)page completionHandler:(void(^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
/**
 Cancels all running tasks and invalidates the current session
*/
-(void)cancelSession;
@property (nonatomic, strong) id<SLDataGrabberDelegate> delegate;
@end
