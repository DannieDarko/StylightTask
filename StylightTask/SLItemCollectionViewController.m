//
//  ViewController.m
//  StylightTask
//
//  Created by Daniel Rexin on 14/04/25.
//  Copyright (c) 2014 STYLIGHT GMBH. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SLItemCollectionViewController.h"
#import "SLItemCollectionViewCell.h"
#import "SLSyncManager.h"
#import "SLDataStore.h"
#import "Item.h"
#import "Product.h"
#import "Image.h"
#import "Board.h"
#import "Creator.h"

@interface SLItemCollectionViewController () {
    NSCache *_imageCache;
    NSUInteger _page;
    CGRect _imageFrame;
}

@end

@implementation SLItemCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.topBarView.layer.shadowColor=[UIColor blackColor].CGColor;
    self.topBarView.layer.shadowOffset=CGSizeMake(0.0f, 0.0f);
    self.topBarView.layer.shadowRadius=5.0f;
    self.topBarView.layer.shadowOpacity=0.3f;
    _imageCache=[[NSCache alloc] init];
    _imageCache.countLimit=100;
    [SLDataStore defaultStore].delegate=self;
    _page=0;
}

-(void)hideImage:(UITapGestureRecognizer *)tapGestureRecognizer
{
    UIView *largeImageView=tapGestureRecognizer.view;
    UIView *backgroundView=[largeImageView viewWithTag:1];
    UIView *imageView=[largeImageView viewWithTag:2];
    [UIView animateWithDuration:0.3f animations:^{
        imageView.frame=_imageFrame;
        backgroundView.alpha=0.0f;
    } completion:^(BOOL finished) {
        [largeImageView removeFromSuperview];
        self.collectionView.userInteractionEnabled=YES;
    }];
}

#pragma mark UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Item *item=[[SLDataStore defaultStore] itemAtIndexPath:indexPath];
    SLItemCollectionViewCell *cell=(SLItemCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"primary=YES"];
    Image *itemImage=item.product?[item.product.images filteredSetUsingPredicate:predicate].anyObject:item.board.coverImage;
    UIImage *image=nil;
    if(itemImage) {
        image=[_imageCache objectForKey:itemImage.url];
        if(!image) {
            if(itemImage.image)
                image=[UIImage imageWithData:itemImage.image];
            if(!image) {
                image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:itemImage.url]]];
            }
        }
    }
    if(image) {
        self.collectionView.userInteractionEnabled=NO;
        UIView *largeImageView=[[UIView alloc] initWithFrame:self.collectionView.frame];
        largeImageView.backgroundColor=[UIColor clearColor];
        
        UIView *backgroundView=[[UIView alloc] initWithFrame:largeImageView.bounds];
        backgroundView.backgroundColor=[UIColor blackColor];
        backgroundView.alpha=0.0f;
        backgroundView.tag=1;
        [largeImageView addSubview:backgroundView];
        
        UIImageView *imageView=[[UIImageView alloc] initWithImage:image];
        imageView.contentMode=UIViewContentModeScaleAspectFit;
        imageView.frame=CGRectMake(cell.frame.origin.x+cell.imageView.frame.origin.x,
                                   cell.frame.origin.y+cell.imageView.frame.origin.y-self.collectionView.contentOffset.y,
                                   cell.imageView.frame.size.width,
                                   cell.imageView.frame.size.height);
        _imageFrame=imageView.frame;
        imageView.tag=2;
        [largeImageView addSubview:imageView];
        
        [self.view addSubview:largeImageView];
        [self.view bringSubviewToFront:self.topBarView];
        
        [UIView animateWithDuration:0.3f animations:^{
            backgroundView.alpha=0.3f;
            imageView.frame=largeImageView.bounds;
        } completion:^(BOOL finished) {
            UITapGestureRecognizer *gestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImage:)];
            [largeImageView addGestureRecognizer:gestureRecognizer];
            imageView.userInteractionEnabled=YES;
        }];
    }
}

#pragma mark UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger itemCount=[SLDataStore defaultStore].itemCount;
    return itemCount+20;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger itemCount=[SLDataStore defaultStore].itemCount;
    if(indexPath.row%20==0) {
        _page=indexPath.row/20+1;
        [[SLSyncManager defaultManager] syncDataOfPage:_page];
    }
    if(indexPath.row>=itemCount) {
        UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"loadingCell" forIndexPath:indexPath];
        return cell;
    }
    SLItemCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"itemCell" forIndexPath:indexPath];
    Item *item=[[SLDataStore defaultStore] itemAtIndexPath:indexPath];
    if(item.product||item.board) {
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"primary=YES"];
        Image *itemImage=nil;
        if(item.product) {
            cell.textLabel.text=item.product.name;
            itemImage=[[item.product.images filteredSetUsingPredicate:predicate] anyObject];
        }else if(item.board) {
            cell.textLabel.text=[NSString stringWithFormat:@"%@ by %@",item.board.title,item.board.creator.username];
            itemImage=item.board.coverImage;
        }
        if(itemImage) {
            //try to get the image from cache
            UIImage *image=[_imageCache objectForKey:itemImage.url];
            if(!image&&itemImage&&itemImage.image) {
                //get image from Core Data if it wasn't cached
                image=[UIImage imageWithData:itemImage.image];
            }
            if(image) {
                //display the image if there was any within cache or Core Data
                cell.imageView.image=image;
                if(cell.activityIndicator) {
                    [cell.activityIndicator stopAnimating];
                    cell.activityIndicator.hidden=YES;
                }
            }else {
                //otherwise load image from url
                [cell.activityIndicator startAnimating];
                cell.activityIndicator.hidden=NO;
                cell.imageView.image=nil;
                [[SLSyncManager defaultManager] syncImage:itemImage completion:^(Image *itemImage) {
                    UIImage *image=[UIImage imageWithData:itemImage.image];
                    [_imageCache setObject:image forKey:itemImage.url];
                    SLItemCollectionViewCell *cell=(SLItemCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
                    cell.imageView.image=image;
                    if(cell.activityIndicator) {
                        [cell.activityIndicator stopAnimating];
                        cell.activityIndicator.hidden=YES;
                    }
                }];
            }
        }
    }
    return cell;
}

#pragma mark SLDataStoreDelegate

-(void)didUpdateResults
{
    [self.collectionView reloadData];
}

-(void)didReceiveChangesAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [_imageCache removeAllObjects];
}

@end
