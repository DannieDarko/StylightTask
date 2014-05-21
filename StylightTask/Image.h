//
//  Image.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/05/21.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Board, Product;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * primary;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Board *board;
@property (nonatomic, retain) Product *product;

@end
