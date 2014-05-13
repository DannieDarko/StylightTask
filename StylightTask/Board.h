//
//  Board.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/05/05.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, Creator, Image;

@interface Board : NSManagedObject

@property (nonatomic, retain) NSNumber * comments;
@property (nonatomic, retain) Image * coverImage;
@property (nonatomic, retain) NSDate * datecreated;
@property (nonatomic, retain) NSDate * datemodified;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * liked;
@property (nonatomic, retain) NSNumber * likes;
@property (nonatomic, retain) NSString * refreshKey;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * urlKey;
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) Creator *creator;

@end
