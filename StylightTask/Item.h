//
//  Item.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/05/05.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Board, Product;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSDate * datecreated;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) Product *product;
@property (nonatomic, retain) Board *board;

@end
