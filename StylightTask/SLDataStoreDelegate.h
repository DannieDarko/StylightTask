//
//  SLDataStoreDelegate.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/05/14.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLDataStoreDelegate <NSObject>
@optional -(void)didUpdateResults;
@optional -(void)didReceiveChanges;
@end
