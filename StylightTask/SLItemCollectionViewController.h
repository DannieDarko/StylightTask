//
//  ViewController.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/04/25.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLDataGrabberDelegate.h"

@interface SLItemCollectionViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,SLDataGrabberDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *topBarView;

@end
