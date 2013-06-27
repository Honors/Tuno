//
//  TUViewController.h
//  TuneUno
//
//  Created by mattneary on 6/12/13.
//  Copyright (c) 2013 mattneary. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TUViewController : UIViewController
@property (nonatomic, strong) IBOutlet UITextField *trackURIField;
@property (nonatomic, strong) IBOutlet UILabel *trackTitle;
@property (nonatomic, strong) IBOutlet UILabel *trackArtist;
@property (nonatomic, strong) IBOutlet UILabel *trackAlbum;
@property (nonatomic, strong) IBOutlet UIImageView *coverView;
@property (nonatomic, strong) IBOutlet UISlider *positionSlider;

@property (nonatomic, strong) UIViewController *albumEmbed;
@property (nonatomic, strong) NSString *currentArtist;
@property (nonatomic, strong) NSString *currentSong;
@property (nonatomic, strong) NSString *previousArtist;
@property (nonatomic, strong) NSString *previousSong;

@property (nonatomic, strong) NSMutableArray *lastFMUrls;
@property NSString *lastFMHref;

- (IBAction)nextSong;
- (void)pickSongFromArtist: (NSString *)artist Song: (NSString *)song;
- (IBAction)seed;
- (void)setAlbumThumbnail: (UIImage *)image;
- (int)selectedIndex: (int)count;
- (IBAction)drop;
@end
