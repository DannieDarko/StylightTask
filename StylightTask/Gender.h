//
//  Gender.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/05/05.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Gender : NSManagedObject

@property (nonatomic, retain) NSNumber * genid;
@property (nonatomic, retain) NSString * genname;
@property (nonatomic, retain) NSSet *products;
@property (nonatomic, retain) NSManagedObject *creators;
@end

@interface Gender (CoreDataGeneratedAccessors)

- (void)addProductsObject:(Product *)value;
- (void)removeProductsObject:(Product *)value;
- (void)addProducts:(NSSet *)values;
- (void)removeProducts:(NSSet *)values;

@end
