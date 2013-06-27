//
//  TUAlbumViewController.m
//  TuneUno
//
//  Created by mattneary on 6/12/13.
//  Copyright (c) 2013 mattneary. All rights reserved.
//

#import "TUAlbumViewController.h"

@interface TUAlbumViewController ()

@end

@implementation TUAlbumViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)scrollToBottom {
    if( ![self.chain count] ) return;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[self.chain count]-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"album" forIndexPath:indexPath];
    UIImageView *imageView = [[cell subviews][0] subviews][0];
    if( [self.chain count] > indexPath.item ) {
        NSDictionary *track = self.chain[indexPath.item];
        NSString *imageLink = track[@"image"][1][@"#text"];
        if( track[@"album_image"] != nil ) {
            imageView.image = track[@"album_image"];
        }
        //[imageView setImageWithURL:[NSURL URLWithString:imageLink]];
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    [self performSelector:@selector(scrollToBottom) withObject:Nil afterDelay:1];
    return [self.chain count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.chain = [[NSMutableArray alloc] initWithCapacity:255];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
