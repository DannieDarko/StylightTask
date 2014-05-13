//
//  SLDataStore.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/04/26.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSFetchedResultsController.h>

@class Item, Product, Brand, Gender, Shop, Image, Currency, Board, Creator;

@interface SLDataStore : NSObject<NSFetchedResultsControllerDelegate>
+(SLDataStore *)defaultStore;
-(Item *)createItem;
-(Product *)createProduct;
-(Board *)createBoard;
-(Brand *)createBrand;
-(Image *)createImage;
-(Gender *)createGender;
-(Shop *)createShop;
-(Currency *)createCurrency;
-(Creator *)createCreator;
-(Item *)getItemById:(NSNumber *)itemId;
-(Board *)getBoardById:(NSNumber *)boardId;
-(Creator *)getCreatorByAid:(NSNumber *)creatorAid;
-(Product *)getProductById:(NSNumber *)productId;
-(Brand *)getBrandByBid:(NSNumber *)brandBid;
-(Currency *)getCurrencyByCurid:(NSNumber *)curid;
-(Gender *)getGenderByGenid:(NSNumber *)genderId;
-(Image *)getImageByURL:(NSString *)imageURL;
-(NSUInteger)productCount;
-(NSUInteger)itemCount;
-(Item *)itemAtIndexPath:(NSIndexPath *)indexPath;
-(void)update;
-(void)save;
@end
