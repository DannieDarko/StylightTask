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
/**
 Returns a singleton instance of the class
 @return Singleton instance of the class.
*/
+(SLDataStore *)defaultStore;
/**
 Retrieves a managed object from Core Data matching the given restrictions
 @param entityName Name which identitfies the entity type.
 @param field Field to apply filter to.
 @param value Value for field to filter by.
 @param managedObjectContext The context to get the entity from.
 @return Managed object of entity type requested matching the restrictions. Returns nil if none is found.
*/
-(NSManagedObject *)getManagedObjectOfEntity:(NSString *)entityName byField:(NSString *)field andValue:(NSObject *)value inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
/**
 Creates a new entity of named type
 @param entityName Name which identitfies the entity type.
 @param managedObjectContext The context to create the entity in.
 @return Managed object of new created entity.
*/
-(NSManagedObject *)createEntityForName:(NSString *)entityName inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
/**
 Returns the count of items within Core Data
 @return Count of items within Core Data.
*/
-(NSUInteger)itemCount;
/**
 Returns a managed object at a given index path within Core Data
 @param indexPath Index path of the entity to retrieve.
 @return Managed object of entity type Item. Returns nil if none was found.
*/
-(Item *)itemAtIndexPath:(NSIndexPath *)indexPath;
/**
 Returns the default context
 @return Default context.
*/
-(NSManagedObjectContext *)managedObjectContext;
/**
 Creates a new child context for asynchronous tasks
 @return New child context.
*/
-(NSManagedObjectContext *)newManagedObjectContext;
/**
 Updates the results from Core Data
*/
-(void)update;
@property (nonatomic, strong) id<SLDataStoreDelegate>delegate;
@end
