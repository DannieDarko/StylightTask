//
//  SLSyncManager.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/05/16.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Image;

@interface SLSyncManager : NSObject
/**
 Returns a singleton instance of the class
 @return Singleton instance of the class.
*/
+(SLSyncManager *)defaultManager;
/**
 Syncs the API data of the given page with Core Data
 @param page Page in the API to sync with.
*/
-(void)syncDataOfPage:(NSUInteger)page;
/**
 Sync the image data of a Core Data Image entity
 @param image Core Data entity of type Image to sync image data for.
 @param completionBlock Block code to run when the image data is fetched.
*/
-(void)syncImage:(Image *)image completion:(void(^)(Image *image))completionBlock;
@end
