//
//  Image.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/05/05.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSNumber * primary;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) UIImage * image;
@property (nonatomic, retain) Product *product;

@end
