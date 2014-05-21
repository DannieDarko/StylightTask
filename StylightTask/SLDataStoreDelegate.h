//
//  SLDataStoreDelegate.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/05/14.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLDataStoreDelegate <NSObject>
/**
 Gets called when the fetched results from Core Data got updated
*/
@optional -(void)dataStoreDidUpdateResults;
/**
 Gets called when an object within Core Data did change
 @param indexPath Index path of the object within Core Data that changed.
*/
@optional -(void)dataStoreDidReceiveChangesAtIndexPath:(NSIndexPath *)indexPath;
@end
