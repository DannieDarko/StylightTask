//
//  SLDataStore.m
//  StylightTask
//
//  Created by Daniel Rexin on 14/04/26.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import "SLDataStore.h"
#import <CoreData/CoreData.h>

@interface SLDataStore() {
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSFetchedResultsController *_resultsController;
}

@end

static SLDataStore *_instance;

@implementation SLDataStore

+(SLDataStore *)defaultStore
{
    @synchronized(self) {
        if(_instance==nil)
            _instance=[[SLDataStore alloc] init];
        return _instance;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _managedObjectModel=[NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[NSBundle mainBundle]]];
        _managedObjectContext=[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _persistentStoreCoordinator=[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
        NSString *storePath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"DataStore.sqlite"];
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:storePath] options:@{NSSQLitePragmasOption: @{@"journal_mode": @"wal", @"synchronous": @"normal"}} error:nil];
        
        _managedObjectContext.persistentStoreCoordinator=_persistentStoreCoordinator;
        
        NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"Item"];
        fetchRequest.fetchBatchSize=20;
        fetchRequest.sortDescriptors=@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]];
        _resultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
        _resultsController.delegate=self;
        
        [self update];
    }
    return self;
}

-(Item *)createItem
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:_managedObjectContext];
}

-(Product *)createProduct
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:_managedObjectContext];
}

-(Image *)createImage
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:_managedObjectContext];
}

-(Brand *)createBrand
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Brand" inManagedObjectContext:_managedObjectContext];
}

-(Gender *)createGender
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Gender" inManagedObjectContext:_managedObjectContext];
}

-(Currency *)createCurrency
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Currency" inManagedObjectContext:_managedObjectContext];
}

-(Shop *)createShop
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Shop" inManagedObjectContext:_managedObjectContext];
}

-(Board *)createBoard
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Board" inManagedObjectContext:_managedObjectContext];
}

-(Creator *)createCreator
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Creator" inManagedObjectContext:_managedObjectContext];
}

-(NSManagedObject *)getManagedObjectOfEntity:(NSString *)entityName byField:(NSString *)field andValue:(NSObject *)value
{
    NSManagedObject *managedObject=nil;
    NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:entityName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",field,value];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:field ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error&&fetchedObjects&&fetchedObjects.count>0) {
        managedObject=fetchedObjects.firstObject;
    }
    return managedObject;
}

-(Item *)getItemById:(NSNumber *)itemId
{
    return (Item *)[self getManagedObjectOfEntity:@"Item" byField:@"id" andValue:itemId];
}

-(Board *)getBoardById:(NSNumber *)boardId
{
    return (Board *)[self getManagedObjectOfEntity:@"Board" byField:@"id" andValue:boardId];
}

-(Creator *)getCreatorByAid:(NSNumber *)creatorAid
{
    return (Creator *)[self getManagedObjectOfEntity:@"Creator" byField:@"aid" andValue:creatorAid];
}

-(Product *)getProductById:(NSNumber *)productId
{
    return (Product *)[self getManagedObjectOfEntity:@"Product" byField:@"id" andValue:productId];
}

-(Brand *)getBrandByBid:(NSNumber *)brandBid
{
    return (Brand *)[self getManagedObjectOfEntity:@"Brand" byField:@"bid" andValue:brandBid];
}

-(Currency *)getCurrencyByCurid:(NSNumber *)currencyId
{
    return (Currency *)[self getManagedObjectOfEntity:@"Currency" byField:@"curid" andValue:currencyId];
}

-(Gender *)getGenderByGenid:(NSNumber *)genderId
{
    return (Gender *)[self getManagedObjectOfEntity:@"Gender" byField:@"genid" andValue:genderId];
}

-(Image *)getImageByURL:(NSString *)imageURL
{
    return (Image *)[self getManagedObjectOfEntity:@"Image" byField:@"url" andValue:imageURL];
}

-(NSUInteger)productCount
{
    NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"Product"];
    return [_managedObjectContext countForFetchRequest:fetchRequest error:nil];
}

-(NSUInteger)itemCount
{
    return [[[_resultsController sections] firstObject] numberOfObjects];
}

-(Item *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_resultsController objectAtIndexPath:indexPath];
}

-(void)update
{
    [NSFetchedResultsController deleteCacheWithName:@"Master"];
    NSError *error;
    [_resultsController performFetch:&error];
}

-(void)save
{
    NSError *error;
    [_managedObjectContext save:&error];
}

#pragma mark NSResultsControllerDelegate

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSLog(@"Did change section");
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSLog(@"Did change object");
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"Did change content");
}

@end
