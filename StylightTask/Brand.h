//
//  Brand.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/05/05.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Brand : NSManagedObject

@property (nonatomic, retain) NSNumber * bid;
@property (nonatomic, retain) NSString * bname;
@property (nonatomic, retain) NSSet *products;
@end

@interface Brand (CoreDataGeneratedAccessors)

- (void)addProductsObject:(Product *)value;
- (void)removeProductsObject:(Product *)value;
- (void)addProducts:(NSSet *)values;
- (void)removeProducts:(NSSet *)values;

@end
