//
//  ViewController.m
//  StylightTask
//
//  Created by Daniel Rexin on 14/04/25.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import "SLItemCollectionViewController.h"
#import "SLItemCollectionViewCell.h"
#import "SLDataGrabber.h"
#import "SLDataStore.h"
#import "Item.h"
#import "Product.h"
#import "Image.h"
#import "Board.h"
#import "Creator.h"

@interface SLItemCollectionViewController () {
    NSCache *_imageCache;
    NSUInteger _maxRow;
    NSUInteger _page;
}

@end

@implementation SLItemCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _imageCache=[[NSCache alloc] init];
    _maxRow=0;
    _page=0;
    [SLDataGrabber defaultDataGrabber].delegate=self;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _maxRow>0?_maxRow:[SLDataStore defaultStore].itemCount+20;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row>=[SLDataStore defaultStore].itemCount) {
        _page++;
        [[SLDataGrabber defaultDataGrabber] grabDataOfPage:_page];
        UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"loadingCell" forIndexPath:indexPath];
        return cell;
    }
    SLItemCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"itemCell" forIndexPath:indexPath];
    Item *item=[[SLDataStore defaultStore] itemAtIndexPath:indexPath];
    if(item.product||item.board) {
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"primary=YES"];
        NSString *imageUrl;
        Image *itemImage=nil;
        if(item.product) {
            cell.textLabel.text=item.product.name;
            itemImage=[[item.product.images filteredSetUsingPredicate:predicate] anyObject];
        }else if(item.board) {
            cell.textLabel.text=[NSString stringWithFormat:@"%@ by %@",item.board.title,item.board.creator.username];
            itemImage=item.board.coverImage;
        }
        if(itemImage)
            imageUrl=itemImage.url;
        UIImage *image=[_imageCache objectForKey:imageUrl];
        if(!image&&itemImage&&itemImage.image)
            image=itemImage.image;
        if(image) {
            cell.imageView.image=image;
            if(cell.activityIndicator) {
                [cell.activityIndicator stopAnimating];
                cell.activityIndicator.hidden=YES;
            }
        }else {
            [cell.activityIndicator startAnimating];
            cell.activityIndicator.hidden=NO;
            cell.imageView.image=nil;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                if(data) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SLItemCollectionViewCell *cell=(SLItemCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
                        UIImage *image=[UIImage imageWithData:data];
                        if(image) {
                            if(itemImage) {
                                itemImage.image=image;
                            }
                            cell.imageView.image=image;
                            [_imageCache setObject:image forKey:imageUrl];
                        }
                        if(cell.activityIndicator) {
                            [cell.activityIndicator stopAnimating];
                            cell.activityIndicator.hidden=YES;
                        }
                    });
                }
            });
        }
    }
    return cell;
}

#pragma mark SLDataGrabberDelegate

-(void)didFinishGrabbingData
{
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [_imageCache removeAllObjects];
}

@end
