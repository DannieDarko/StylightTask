//
//  SLItemCollectionViewCell.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/05/03.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLItemCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;

@end
