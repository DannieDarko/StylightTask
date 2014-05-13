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
+(SLDataGrabber *)defaultDataGrabber;
-(void)grabDataOfPage:(NSUInteger)page;
@property (nonatomic, strong) id<SLDataGrabberDelegate> delegate;
@end
