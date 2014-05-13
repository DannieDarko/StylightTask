//
//  Creator.h
//  StylightTask
//
//  Created by Daniel Rexin on 14/05/05.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Board, Gender;

@interface Creator : NSManagedObject

@property (nonatomic, retain) NSNumber * aid;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSNumber * createdBoards;
@property (nonatomic, retain) NSDate * datecreated;
@property (nonatomic, retain) NSDate * datemodified;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSNumber * followees;
@property (nonatomic, retain) NSNumber * followers;
@property (nonatomic, retain) NSNumber * following;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSNumber * likedBoards;
@property (nonatomic, retain) NSNumber * likedProducts;
@property (nonatomic, retain) NSString * newsletter;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSString * refreshKey;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) Gender *gender;
@property (nonatomic, retain) NSSet *boards;
@end

@interface Creator (CoreDataGeneratedAccessors)

- (void)addBoardsObject:(Board *)value;
- (void)removeBoardsObject:(Board *)value;
- (void)addBoards:(NSSet *)values;
- (void)removeBoards:(NSSet *)values;

@end
