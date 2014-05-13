//
//  Product.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/05/05.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Brand, Currency, Gender, Image, Item, Shop;

@interface Product : NSManagedObject

@property (nonatomic, retain) NSNumber * available;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * liked;
@property (nonatomic, retain) NSNumber * likes;
@property (nonatomic, retain) NSNumber * masterProductId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * sale;
@property (nonatomic, retain) NSNumber * savings;
@property (nonatomic, retain) NSNumber * shippingCost;
@property (nonatomic, retain) NSString * shopLink;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Currency *currency;
@property (nonatomic, retain) Brand *brand;
@property (nonatomic, retain) Gender *gender;
@property (nonatomic, retain) Shop *shop;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) Item *item;
@end

@interface Product (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
