//
//  SLSyncManager.m
//  StylightTask
//
//  Created by Daniel Rexin on 14/05/16.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import "SLSyncManager.h"
#import "SLDataGrabber.h"
#import "SLDataStore.h"
#import "Item.h"
#import "Product.h"
#import "Image.h"
#import "Gender.h"
#import "Brand.h"
#import "Currency.h"
#import "Shop.h"
#import "Board.h"
#import "Creator.h"

static SLSyncManager *_instance;
static NSDateFormatter *_dateFormatter;

static NSString * const kSUCCESS=@"SUCCESS";
static NSString * const kDateFormat=@"yyyy'-'MM'-'dd' 'HH':'mm':'ss'.'S";
static NSUInteger const kTimeBetweenSyncs=15*60;

@interface SLSyncManager () {
    NSMutableDictionary *_syncDateDictionary;
}
-(NSObject *)objectForKey:(NSString *)key fromDictionary:(NSDictionary *)dictionary;
-(NSDate *)dateFromString:(NSString *)dateString;
-(BOOL)objectHasValue:(NSObject *)object isKindOfClass:(Class)class;
@end

@implementation SLSyncManager

+(SLSyncManager *)defaultManager
{
    @synchronized(self) {
        if(_instance==nil) {
            _instance=[[[self class] alloc] init];
            _dateFormatter=[[NSDateFormatter alloc] init];
            _dateFormatter.timeZone=[NSTimeZone timeZoneForSecondsFromGMT:0];
            _dateFormatter.dateFormat=kDateFormat;
        }
        return _instance;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _syncDateDictionary=[[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)syncDataOfPage:(NSUInteger)page
{
    NSDate *lastSyncDate=[_syncDateDictionary objectForKey:[NSString stringWithFormat:@"%li",(long)page]];
    if(lastSyncDate&&[lastSyncDate timeIntervalSinceNow]+kTimeBetweenSyncs>0) {
        NSLog(@"Last sync too recent");
        return;
    }else {
    
    }
    [[SLDataGrabber defaultDataGrabber] grabDataOfPage:page completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if(error) {
                NSLog(@"Error: %@",error.description);
                [[SLDataGrabber defaultDataGrabber] cancelSession];
                return;
            }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                NSError *jsonError=nil;
                NSDictionary *jsonObj=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
                if(!jsonObj||![jsonObj isKindOfClass:[NSDictionary class]]||[[jsonObj objectForKey:@"build"] integerValue]!=1||![[jsonObj objectForKey:@"status"] isEqualToString:kSUCCESS])
                    return;
                
                NSManagedObjectContext *managedObjectContext=[[SLDataStore defaultStore] newManagedObjectContext];
                
                [managedObjectContext performBlock:^{
                    for(NSDictionary *itemDict in (NSDictionary *)[self objectForKey:@"items" fromDictionary:jsonObj]) {
                        NSNumber *itemId=(NSNumber *)[self objectForKey:@"id" fromDictionary:itemDict];
                        if(itemId&&[itemId isKindOfClass:[NSNumber class]]) {
                            Item *item=(Item *)[[SLDataStore defaultStore] getManagedObjectOfEntity:@"Item" byField:@"id" andValue:itemId inManagedObjectContext:managedObjectContext];
                            if(!item) {
                                item=(Item *)[[SLDataStore defaultStore] createEntityForName:@"Item" inManagedObjectContext:managedObjectContext];
                                item.id=itemId;
                            }
                            item.datecreated=[self dateFromString:(NSString *)[self objectForKey:@"datecreated" fromDictionary:itemDict]];
                            item.order=(NSNumber *)[self objectForKey:@"order" fromDictionary:itemDict];
                            
                            NSDictionary *boardDict=(NSDictionary *)[self objectForKey:@"board" fromDictionary:itemDict];
                            if(boardDict&&[boardDict isKindOfClass:[NSDictionary class]]) {
                                NSNumber *boardId=(NSNumber *)[self objectForKey:@"id" fromDictionary:boardDict];
                                if(boardId&&[boardId isKindOfClass:[NSNumber class]]) {
                                    Board *board=(Board *)[[SLDataStore defaultStore] getManagedObjectOfEntity:@"Board" byField:@"id" andValue:boardId inManagedObjectContext:managedObjectContext];
                                    if(!board) {
                                        board=(Board *)[[SLDataStore defaultStore] createEntityForName:@"Board" inManagedObjectContext:managedObjectContext];
                                        board.id=boardId;
                                    }
                                    board.comments=(NSNumber *)[self objectForKey:@"comments" fromDictionary:boardDict];
                                    NSString *coverImageURL=(NSString *)[self objectForKey:@"coverImage" fromDictionary:boardDict];
                                    if(coverImageURL&&[coverImageURL isKindOfClass:[NSString class]]&&coverImageURL.length>0) {
                                        //prepend http: because the API data lacks this and starts with //
                                        coverImageURL=[@"http:" stringByAppendingString:coverImageURL];
                                        
                                        Image *coverImage=(Image *)[[SLDataStore defaultStore] getManagedObjectOfEntity:@"Image" byField:@"url" andValue:coverImageURL inManagedObjectContext:managedObjectContext];
                                        if(!coverImage) {
                                            coverImage=(Image *)[[SLDataStore defaultStore] createEntityForName:@"Image" inManagedObjectContext:managedObjectContext];
                                            coverImage.url=coverImageURL;
                                            coverImage.primary=[NSNumber numberWithBool:YES];
                                        }
                                        board.coverImage=coverImage;
                                    }
                                    board.datecreated=[self dateFromString:(NSString *)[self objectForKey:@"datecreated" fromDictionary:boardDict]];
                                    board.datemodified=[self dateFromString:(NSString *)[self objectForKey:@"datemodified" fromDictionary:boardDict]];
                                    board.desc=(NSString *)[self objectForKey:@"description" fromDictionary:boardDict];
                                    board.id=(NSNumber *)[self objectForKey:@"id" fromDictionary:boardDict];
                                    board.liked=(NSNumber *)[self objectForKey:@"liked" fromDictionary:boardDict];
                                    board.likes=(NSNumber *)[self objectForKey:@"likes" fromDictionary:boardDict];
                                    board.refreshKey=(NSString *)[self objectForKey:@"refreshKey" fromDictionary:boardDict];
                                    board.title=(NSString *)[self objectForKey:@"title" fromDictionary:boardDict];
                                    board.url=(NSString *)[self objectForKey:@"url" fromDictionary:boardDict];
                                    board.urlKey=(NSString *)[self objectForKey:@"urlKey" fromDictionary:boardDict];
                                    
                                    NSDictionary *creatorDict=(NSDictionary *)[self objectForKey:@"creator" fromDictionary:boardDict];
                                    if(creatorDict&&[creatorDict isKindOfClass:[NSDictionary class]]) {
                                        NSNumber *creatorAid=(NSNumber *)[self objectForKey:@"aid" fromDictionary:creatorDict];
                                        if(creatorAid&&[creatorAid isKindOfClass:[NSNumber class]]) {
                                            Creator *creator=(Creator *)[[SLDataStore defaultStore] getManagedObjectOfEntity:@"Creator" byField:@"aid" andValue:creatorAid inManagedObjectContext:managedObjectContext];
                                            if(!creator) {
                                                creator=(Creator *)[[SLDataStore defaultStore] createEntityForName:@"Creator" inManagedObjectContext:managedObjectContext];
                                                creator.aid=creatorAid;
                                            }
                                            creator.username=(NSString *)[self objectForKey:@"username" fromDictionary:creatorDict];
                                            board.creator=creator;
                                        }
                                    }
                                    item.board=board;
                                }
                            }
                            
                            NSDictionary *productDict=(NSDictionary *)[self objectForKey:@"product" fromDictionary:itemDict];
                            if(productDict&&[productDict isKindOfClass:[NSDictionary class]]) {
                                NSNumber *productId=(NSNumber *)[self objectForKey:@"id" fromDictionary:productDict];
                                if(productId&&[productId isKindOfClass:[NSNumber class]]) {
                                    Product *product=(Product *)[[SLDataStore defaultStore] getManagedObjectOfEntity:@"Product" byField:@"id" andValue:productId inManagedObjectContext:managedObjectContext];
                                    if(!product) {
                                        product=(Product *)[[SLDataStore defaultStore] createEntityForName:@"Product" inManagedObjectContext:managedObjectContext];
                                        product.id=productId;
                                    }
                                    product.available=(NSNumber *)[self objectForKey:@"available" fromDictionary:productDict];
                                    product.date=[self dateFromString:(NSString *)[self objectForKey:@"date" fromDictionary:productDict]];
                                    product.desc=(NSString *)[self objectForKey:@"desc" fromDictionary:productDict];
                                    product.liked=(NSNumber *)[self objectForKey:@"liked" fromDictionary:productDict];
                                    product.likes=(NSNumber *)[self objectForKey:@"likes" fromDictionary:productDict];
                                    product.masterProductId=(NSNumber *)[self objectForKey:@"masterProductId" fromDictionary:productDict];
                                    product.name=(NSString *)[self objectForKey:@"name" fromDictionary:productDict];
                                    product.price=(NSNumber *)[self objectForKey:@"price" fromDictionary:productDict];
                                    product.sale=(NSNumber *)[self objectForKey:@"sale" fromDictionary:productDict];
                                    product.savings=(NSNumber *)[self objectForKey:@"savings" fromDictionary:productDict];
                                    product.shippingCost=(NSNumber *)[self objectForKey:@"shippingCost" fromDictionary:productDict];
                                    product.shopLink=(NSString *)[self objectForKey:@"shopLink" fromDictionary:productDict];
                                    product.url=(NSString *)[self objectForKey:@"url" fromDictionary:productDict];
                                    
                                    NSDictionary *brandDict=(NSDictionary *)[self objectForKey:@"brand" fromDictionary:productDict];
                                    if(brandDict&&[brandDict isKindOfClass:[NSDictionary class]]) {
                                        NSNumber *brandBid=(NSNumber *)[self objectForKey:@"bid" fromDictionary:brandDict];
                                        if(brandBid&&[brandBid isKindOfClass:[NSNumber class]]) {
                                            Brand *brand=(Brand *)[[SLDataStore defaultStore] getManagedObjectOfEntity:@"Brand" byField:@"bid" andValue:brandBid inManagedObjectContext:managedObjectContext];
                                            if(!brand) {
                                                brand=(Brand *)[[SLDataStore defaultStore] createEntityForName:@"Brand" inManagedObjectContext:managedObjectContext];
                                                brand.bid=brandBid;
                                            }
                                            brand.bname=(NSString *)[self objectForKey:@"bname" fromDictionary:brandDict];
                                            product.brand=brand;
                                        }
                                    }
                                    
                                    NSDictionary *currencyDict=(NSDictionary *)[self objectForKey:@"currency" fromDictionary:productDict];
                                    if(currencyDict&&[currencyDict isKindOfClass:[NSDictionary class]]) {
                                        NSNumber *currencyCurid=(NSNumber *)[self objectForKey:@"curid" fromDictionary:currencyDict];
                                        if(currencyCurid&&[currencyCurid isKindOfClass:[NSNumber class]]) {
                                            Currency *currency=(Currency *)[[SLDataStore defaultStore] getManagedObjectOfEntity:@"Currency" byField:@"curid" andValue:currencyCurid inManagedObjectContext:managedObjectContext];
                                            if(!currency) {
                                                currency=(Currency *)[[SLDataStore defaultStore] createEntityForName:@"Currency" inManagedObjectContext:managedObjectContext];
                                                currency.curid=currencyCurid;
                                            }
                                            currency.curname=(NSString *)[self objectForKey:@"curname" fromDictionary:currencyDict];
                                            product.currency=currency;
                                        }
                                    }
                                    
                                    NSDictionary *genderDict=(NSDictionary *)[self objectForKey:@"gender" fromDictionary:productDict];
                                    if(genderDict&&[genderDict isKindOfClass:[NSDictionary class]]) {
                                        NSNumber *genderGenid=(NSNumber *)[self objectForKey:@"genid" fromDictionary:genderDict];
                                        if(genderGenid&&[genderGenid isKindOfClass:[NSNumber class]]) {
                                            Gender *gender=(Gender *)[[SLDataStore defaultStore] getManagedObjectOfEntity:@"Gender" byField:@"genid" andValue:genderGenid inManagedObjectContext:managedObjectContext];
                                            if(!gender) {
                                                gender=(Gender *)[[SLDataStore defaultStore] createEntityForName:@"Gender" inManagedObjectContext:managedObjectContext];
                                                gender.genid=genderGenid;
                                            }
                                            gender.genname=(NSString *)[self objectForKey:@"genname" fromDictionary:genderDict];
                                            product.gender=gender;
                                        }
                                    }
                                    
                                    NSArray *images=(NSArray *)[self objectForKey:@"images" fromDictionary:productDict];
                                    if(images&&[images isKindOfClass:[NSArray class]]) {
                                        for(NSDictionary *imageDict in images) {
                                            NSString *imageURL=(NSString *)[self objectForKey:@"url" fromDictionary:imageDict];
                                            if(imageURL&&[imageURL isKindOfClass:[NSString class]]&&imageURL.length>0) {
                                                Image *image=(Image *)[[SLDataStore defaultStore] getManagedObjectOfEntity:@"Image" byField:@"url" andValue:imageURL inManagedObjectContext:managedObjectContext];
                                                if(!image) {
                                                    image=(Image *)[[SLDataStore defaultStore] createEntityForName:@"Image" inManagedObjectContext:managedObjectContext];
                                                    image.url=imageURL;
                                                }
                                                image.primary=(NSNumber *)[self objectForKey:@"primary" fromDictionary:imageDict];
                                                image.product=product;
                                            }
                                        }
                                    }
                                    item.product=product;
                                }
                            }
                        }
                    }
                    NSError *error;
                    [managedObjectContext save:&error];
                    if(!error) {
                        [_syncDateDictionary setObject:[NSDate date] forKey:[NSString stringWithFormat:@"%li",(long)page]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[SLDataStore defaultStore] update];
                        });
                    }
                }];
            }
            });
            }];
}

-(void)syncImage:(Image *)image completion:(void(^)(Image *image))completionBlock
{
    //dispatch loading the image from url into background queue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @autoreleasepool {
            NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:image.url]];
            if(data) {
                image.image=[UIImage imageWithData:data];
                if(image.image) {
                    //dispatch UI updates to main queue
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(image);
                    });
                    
                    NSManagedObjectContext *managedObjectContext=[[SLDataStore defaultStore] newManagedObjectContext];
                    [managedObjectContext performBlock:^{
                        NSError *error;
                        Image *backgroundItemImage=(Image *)[managedObjectContext existingObjectWithID:image.objectID error:&error];
                        if(!error&&backgroundItemImage) {
                            backgroundItemImage.image=image.image;
                            [managedObjectContext save:&error];
                            if(error) {
                                NSLog(@"Error: %@",error);
                            }
                        }
                    }];
                }
            }
        }
    });
}

#pragma mark private
-(NSObject *)objectForKey:(NSString *)key fromDictionary:(NSDictionary *)dictionary
{
    NSObject *object=[dictionary objectForKey:key];
    if(object==[NSNull null])
        object=nil;
    return object;
}

-(NSDate *)dateFromString:(NSString *)dateString
{
    NSDate *date=nil;
    if(dateString&&[dateString isKindOfClass:[NSString class]]&&dateString.length>0) {
        date=[_dateFormatter dateFromString:dateString];
    }
    return date;
}

-(BOOL)objectHasValue:(NSObject *)object isKindOfClass:(Class)class
{
    return object&&[object isKindOfClass:class];
}


@end
