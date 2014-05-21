//
//  SLDataStore.m
//  StylightTask
//
//  Created by Daniel Rexin on 14/04/26.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import "SLDataStore.h"
#import <CoreData/CoreData.h>

#import "SLDataStoreDelegate.h"

@interface SLDataStore() {
    NSManagedObjectContext *_masterManagedObjectContext;
    NSManagedObjectContext *_managedObjectContext;
    NSFetchedResultsController *_resultsController;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSManagedObjectModel *_managedObjectModel;
    dispatch_queue_t _backgroundQueue;
}
@end

static SLDataStore *_instance;

@implementation SLDataStore
@synthesize delegate=_delegate;

+(SLDataStore *)defaultStore
{
    @synchronized(self) {
        if(_instance==nil)
            _instance=[[[self class] alloc] init];
        return _instance;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _backgroundQueue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);

        _managedObjectModel=[NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[NSBundle mainBundle]]];
        _persistentStoreCoordinator=[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
        NSString *storePath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"DataStore.sqlite"];
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:storePath] options:@{NSSQLitePragmasOption: @{@"journal_mode": @"wal", @"synchronous": @"normal"}} error:nil];
        
        dispatch_sync(_backgroundQueue, ^{
            _masterManagedObjectContext=[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            _masterManagedObjectContext.persistentStoreCoordinator=_persistentStoreCoordinator;
        });
        _managedObjectContext=[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.parentContext=_masterManagedObjectContext;
        
        NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"Item"];
        fetchRequest.fetchBatchSize=20;
        fetchRequest.sortDescriptors=@[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]];
        _resultsController=[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate=self;
        
        [self update];
    }
    return self;
}

-(NSManagedObject *)createEntityForName:(NSString *)entityName inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSManagedObject *managedObject=[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:managedObjectContext];
    return managedObject;
}

-(NSManagedObject *)getManagedObjectOfEntity:(NSString *)entityName byField:(NSString *)field andValue:(NSObject *)value inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSManagedObject *managedObject=nil;
    NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:entityName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",field,value];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:field ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error&&fetchedObjects&&fetchedObjects.count>0) {
        managedObject=fetchedObjects.firstObject;
    }else if(error) {
        NSLog(@"Error: %@",error);
    }
    return managedObject;
}

-(NSManagedObjectContext *)managedObjectContext
{
    return _managedObjectContext;
}

-(NSManagedObjectContext *)newManagedObjectContext
{
    NSManagedObjectContext *privateContext=[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    privateContext.parentContext=_managedObjectContext;
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:privateContext queue:nil usingBlock:^(NSNotification *note) {
        [_managedObjectContext performBlockAndWait:^{
            [_managedObjectContext save:nil];
            [_masterManagedObjectContext performBlockAndWait:^{
                [_masterManagedObjectContext save:nil];
            }];
        }];
    }];
    return privateContext;
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
    NSError *error;
    [_resultsController performFetch:&error];
}

#pragma mark NSResultsControllerDelegate

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if(self.delegate&&[self.delegate conformsToProtocol:@protocol(SLDataStoreDelegate)]&&[self.delegate respondsToSelector:@selector(dataStoreDidReceiveChangesAtIndexPath:)]) {
        [self.delegate dataStoreDidReceiveChangesAtIndexPath:newIndexPath];
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if(self.delegate&&[self.delegate conformsToProtocol:@protocol(SLDataStoreDelegate)]&&[self.delegate respondsToSelector:@selector(dataStoreDidUpdateResults)]) {
        [self.delegate dataStoreDidUpdateResults];
    }
}

@end
