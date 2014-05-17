//
//  SLDataStore.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/04/26.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSFetchedResultsController.h>

@class Item, Product, Brand, Gender, Shop, Image, Currency, Board, Creator, NSManagedObject, NSManagedObjectID;
@protocol SLDataStoreDelegate;

@interface SLDataStore : NSObject<NSFetchedResultsControllerDelegate>
+(SLDataStore *)defaultStore;
-(NSManagedObject *)getManagedObjectOfEntity:(NSString *)entityName byField:(NSString *)field andValue:(NSObject *)value inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
-(NSManagedObject *)createEntityForName:(NSString *)entityName inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
-(NSUInteger)itemCount;
-(Item *)itemAtIndexPath:(NSIndexPath *)indexPath;
-(NSManagedObjectContext *)managedObjectContext;
-(NSManagedObjectContext *)newManagedObjectContext;
-(void)update;
@property (nonatomic, strong) id<SLDataStoreDelegate>delegate;
@end
