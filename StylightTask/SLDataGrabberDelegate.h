//
//  SLDataGrabberDelegate.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/04/28.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SLDataGrabberDelegate <NSObject>
@optional -(void)didFinishGrabbingData;
@optional -(void)didFailGrabbingData;
@end
