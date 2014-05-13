//
//  SLDataGrabber.m
//  StylightTask
//
//  Created by Daniel Rexin on 14/04/25.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import "SLDataGrabber.h"
#import "Item.h"
#import "Product.h"
#import "Image.h"
#import "Gender.h"
#import "Brand.h"
#import "Currency.h"
#import "Shop.h"
#import "Board.h"
#import "Creator.h"
#import "SLDataStore.h"
#import "SLDataGrabberDelegate.h"

static NSString * const kSLAPIURL=@"http://api.stylight.com/api/new";
static NSString * const kSLAPIKEYHEADERFIELD=@"X-apiKey";
static NSString * const kSLAPIKEY=@"D13A5A5A0A3602477A513E02691A8458";
static float const kSLTIMEOUT=30.0f;
static NSString * const kSUCCESS=@"SUCCESS";
static NSString * const kDateFormat=@"yyyy'-'MM'-'dd' 'HH':'mm':'ss'.'S";

@interface SLDataGrabber () {
    NSURLSession *_session;
}
@end

static SLDataGrabber *_instance;

@implementation SLDataGrabber

@synthesize delegate=_delegate;

+(SLDataGrabber *)defaultDataGrabber
{
    @synchronized(self) {
        if(_instance==nil)
            _instance=[[SLDataGrabber alloc] init];
        return _instance;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)grabDataOfPage:(NSUInteger)page
{
    if(!_session) {
        NSURLSessionConfiguration *config=[NSURLSessionConfiguration ephemeralSessionConfiguration];
        _session=[NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    }
    NSString *endpointURL=[kSLAPIURL stringByAppendingFormat:@"?gender=women&page=%li&pageItems=20&initializeRows=100",(long)page];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpointURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kSLTIMEOUT];
    [request setValue:kSLAPIKEY forHTTPHeaderField:kSLAPIKEYHEADERFIELD];
    NSURLSessionDataTask *dataTask=[_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error) {
            NSLog(@"Error: %@",error.description);
            [self cancelSession];
            return;
        }
        @autoreleasepool {
            NSError *jsonError=nil;
            NSDictionary *jsonObj=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
            dateFormatter.timeZone=[NSTimeZone timeZoneForSecondsFromGMT:0];
            dateFormatter.dateFormat=kDateFormat;
            
            if(!jsonObj||![jsonObj isKindOfClass:[NSDictionary class]]||[[jsonObj objectForKey:@"build"] integerValue]!=1||![[jsonObj objectForKey:@"status"] isEqualToString:kSUCCESS])
                return;
            
            for(NSDictionary *itemDict in [jsonObj objectForKey:@"items"]) {
                NSNumber *itemId=[itemDict objectForKey:@"id"];
                if(itemId&&[itemId isKindOfClass:[NSNumber class]]) {
                    Item *item=[[SLDataStore defaultStore] getItemById:itemId];
                    if(!item) {
                        item=[[SLDataStore defaultStore] createItem];
                        item.id=itemId;
                    }
                    item.datecreated=[dateFormatter dateFromString:[itemDict objectForKey:@"datecreated"]];
                    item.order=[itemDict objectForKey:@"order"];
                    
                    NSDictionary *boardDict=[itemDict objectForKey:@"board"];
                    if(boardDict&&[boardDict isKindOfClass:[NSDictionary class]]) {
                        NSNumber *boardId=[boardDict objectForKey:@"id"];
                        if(boardId&&[boardId isKindOfClass:[NSNumber class]]) {
                            Board *board=[[SLDataStore defaultStore] getBoardById:boardId];
                            if(!board) {
                                board=[[SLDataStore defaultStore] createBoard];
                                board.id=boardId;
                            }
                            board.comments=[boardDict objectForKey:@"comments"];
                            NSString *coverImageURL=[boardDict objectForKey:@"coverImage"];
                            if(coverImageURL&&[coverImageURL isKindOfClass:[NSString class]]&&coverImageURL.length>0) {
                                coverImageURL=[@"http:" stringByAppendingString:coverImageURL];
                                Image *coverImage=[[SLDataStore defaultStore] getImageByURL:coverImageURL];
                                if(!coverImage) {
                                    coverImage=[[SLDataStore defaultStore] createImage];
                                    coverImage.url=coverImageURL;
                                    coverImage.primary=[NSNumber numberWithBool:YES];
                                }
                                board.coverImage=coverImage;
                            }
                            board.datecreated=[dateFormatter dateFromString:[boardDict objectForKey:@"datecreated"]];
                            board.datemodified=[dateFormatter dateFromString:[boardDict objectForKey:@"datemodified"]];
                            NSString *desc=[boardDict objectForKey:@"description"];
                            if(desc&&[desc isKindOfClass:[NSString class]])
                                board.desc=desc;
                            board.id=[boardDict objectForKey:@"id"];
                            board.liked=[boardDict objectForKey:@"liked"];
                            board.likes=[boardDict objectForKey:@"likes"];
                            board.refreshKey=[boardDict objectForKey:@"refreshKey"];
                            board.title=[boardDict objectForKey:@"title"];
                            board.url=[boardDict objectForKey:@"url"];
                            board.urlKey=[boardDict objectForKey:@"urlKey"];
                            
                            NSDictionary *creatorDict=[boardDict objectForKey:@"creator"];
                            if(creatorDict&&[creatorDict isKindOfClass:[NSDictionary class]]) {
                                NSNumber *creatorAid=[creatorDict objectForKey:@"aid"];
                                if(!creatorAid||![creatorAid isKindOfClass:[NSNumber class]])
                                    break;
                                Creator *creator=[[SLDataStore defaultStore] getCreatorByAid:creatorAid];
                                if(!creator) {
                                    creator=[[SLDataStore defaultStore] createCreator];
                                    creator.aid=creatorAid;
                                }
                                creator.username=[creatorDict objectForKey:@"username"];
                                board.creator=creator;
                            }
                            item.board=board;
                        }
                    }
                    
                    NSDictionary *productDict=[itemDict objectForKey:@"product"];
                    if(productDict&&[productDict isKindOfClass:[NSDictionary class]]) {
                        NSNumber *productId=[productDict objectForKey:@"id"];
                        if(productId&&[productId isKindOfClass:[NSNumber class]]) {
                            Product *product=[[SLDataStore defaultStore] getProductById:productId];
                            if(!product) {
                                product=[[SLDataStore defaultStore] createProduct];
                                product.id=productId;
                            }
                            product.available=[productDict objectForKey:@"available"];
                            product.date=[dateFormatter dateFromString:[productDict objectForKey:@"date"]];
                            NSString *desc=[productDict objectForKey:@"desc"];
                            if(desc&&[desc isKindOfClass:[NSString class]])
                                product.desc=desc;
                            product.liked=[productDict objectForKey:@"liked"];
                            product.likes=[productDict objectForKey:@"likes"];
                            product.masterProductId=[productDict objectForKey:@"masterProductId"];
                            product.name=[productDict objectForKey:@"name"];
                            product.price=[productDict objectForKey:@"price"];
                            product.sale=[productDict objectForKey:@"sale"];
                            product.savings=[productDict objectForKey:@"savings"];
                            NSNumber *number=[productDict objectForKey:@"shippingCost"];
                            if(number&&[number isKindOfClass:[NSNumber class]])
                                product.shippingCost=[productDict objectForKey:@"shippingCost"];
                            product.shopLink=[productDict objectForKey:@"shopLink"];
                            product.url=[productDict objectForKey:@"url"];
                            
                            NSDictionary *brandDict=[productDict objectForKey:@"brand"];
                            if(brandDict&&[brandDict isKindOfClass:[NSDictionary class]]) {
                                NSNumber *brandBid=[brandDict objectForKey:@"bid"];
                                if(brandBid&&[brandBid isKindOfClass:[NSNumber class]]) {
                                    Brand *brand=[[SLDataStore defaultStore] getBrandByBid:brandBid];
                                    if(!brand) {
                                        brand=[[SLDataStore defaultStore] createBrand];
                                        brand.bid=brandBid;
                                    }
                                    brand.bname=[brandDict objectForKey:@"bname"];
                                    product.brand=brand;
                                }
                            }
                            
                            NSDictionary *currencyDict=[productDict objectForKey:@"currency"];
                            if(currencyDict&&[currencyDict isKindOfClass:[NSDictionary class]]) {
                                NSNumber *currencyCurid=[currencyDict objectForKey:@"curid"];
                                if(currencyCurid&&[currencyCurid isKindOfClass:[NSNumber class]]) {
                                    Currency *currency=[[SLDataStore defaultStore] getCurrencyByCurid:currencyCurid];
                                    if(!currency) {
                                        currency=[[SLDataStore defaultStore] createCurrency];
                                        currency.curid=currencyCurid;
                                    }
                                    currency.curname=[currencyDict objectForKey:@"curname"];
                                    product.currency=currency;
                                }
                            }
                            
                            NSDictionary *genderDict=[productDict objectForKey:@"gender"];
                            if(genderDict&&[genderDict isKindOfClass:[NSDictionary class]]) {
                                NSNumber *genderGenid=[genderDict objectForKey:@"genid"];
                                if(genderGenid&&[genderGenid isKindOfClass:[NSNumber class]]) {
                                    Gender *gender=[[SLDataStore defaultStore] getGenderByGenid:genderGenid];
                                    if(!gender) {
                                        gender=[[SLDataStore defaultStore] createGender];
                                        gender.genid=genderGenid;
                                    }
                                    gender.genname=[genderDict objectForKey:@"genname"];
                                    product.gender=gender;
                                }
                            }
                            
                            NSArray *images=[productDict objectForKey:@"images"];
                            if(images&&[images isKindOfClass:[NSArray class]]) {
                                for(NSDictionary *imageDict in images) {
                                    NSString *imageURL=[imageDict objectForKey:@"url"];
                                    if(imageURL&&[imageURL isKindOfClass:[NSString class]]&&imageURL.length>0) {
                                        Image *image=[[SLDataStore defaultStore] getImageByURL:imageURL];
                                        if(!image) {
                                            image=[[SLDataStore defaultStore] createImage];
                                            image.url=imageURL;
                                        }
                                        image.primary=[imageDict objectForKey:@"primary"];
                                        image.product=product;
                                    }
                                }
                            }
                            item.product=product;
                        }
                    }
                }
            }
        }
        [[SLDataStore defaultStore] update];
        [[SLDataStore defaultStore] save];
        if(self.delegate&&[self.delegate conformsToProtocol:@protocol(SLDataGrabberDelegate)]&&[self.delegate respondsToSelector:@selector(didFinishGrabbingData)]) {
            [self.delegate didFinishGrabbingData];
        }
    }];
    [dataTask resume];
}

-(BOOL)objectHasValue:(NSObject *)object isKindOfClass:(Class)class
{
    return object&&[object isKindOfClass:class];
}

-(void)cancelSession
{
    [_session invalidateAndCancel];
    _session=nil;
}




@end
