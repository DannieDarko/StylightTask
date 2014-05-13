//
//  Currency.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/05/05.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Currency : NSManagedObject

@property (nonatomic, retain) NSNumber * curid;
@property (nonatomic, retain) NSString * curname;
@property (nonatomic, retain) Product *product;

@end
