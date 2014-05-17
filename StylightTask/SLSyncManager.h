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
+(SLSyncManager *)defaultManager;
-(void)syncDataOfPage:(NSUInteger)page;
-(void)syncImage:(Image *)image completion:(void(^)(Image *image))completionBlock;
@end
