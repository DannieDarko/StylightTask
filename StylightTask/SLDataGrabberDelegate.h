//
//  SLDataGrabberDelegate.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/04/28.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLDataGrabberDelegate <NSObject>
/**
 Gets called when the SLDataGrabber succesfully retrieved data
*/
@optional -(void)dataGrabberDidFinishGrabbingData;
/**
 Gets called when the SLDataGrabber failed to retrieve data
*/
@optional -(void)dataGrabberDidFailGrabbingData;
@end
