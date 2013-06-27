//
//  TUViewController.m
//  TuneUno
//
//  Created by mattneary on 6/12/13.
//  Copyright (c) 2013 mattneary. All rights reserved.
//

#import "TUViewController.h"
#import "CocoaLibSpotify.h"
#import "TUAlbumViewController.h"
#import "Simple_PlayerAppDelegate.h"

@interface TUViewController ()

@end

@implementation TUViewController

- (int)selectedIndex: (int)count {
    int sampleSize = 20;
    float p = .2;
    
    int sum = 0;
    for( int j = 0; j < sampleSize; j++ ) {
        if( (float)(arc4random()%100)/100 < p ) sum += 1;
    }
    int options[5];
    options[0] = sum;
    options[1] = sum;
    options[2] = sum;
    options[3] = 0;
    options[4] = 1;
    
    return floor(options[arc4random()%5] * count / sampleSize);
}
- (NSString *)pickTrackUrl: (NSString *)artist Song: (NSString *)song {
    NSError *error;
    NSString *similar = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=track.getsimilar&artist=%@&track=%@&api_key=61345c60522b64a99645147a47227c20&format=json&limit=33", artist, song]] encoding:NSStringEncodingConversionAllowLossy error:&error];
    NSDictionary *similarTracks = [NSJSONSerialization JSONObjectWithData:[similar dataUsingEncoding:NSStringEncodingConversionAllowLossy] options:nil error:&error];
    NSDictionary *similars = [similarTracks objectForKey:@"similartracks"];
    NSArray *tracks = similars[@"track"];
    if( [[tracks class] isSubclassOfClass:[NSString class]] ) {
        NSLog(@"String resp.");
        return [self pickTrackUrl:self.previousArtist Song:self.previousSong];
    }
    int selectedIndex = [self selectedIndex:[tracks count]];
    NSMutableDictionary *choice = [NSMutableDictionary dictionaryWithDictionary:tracks[selectedIndex]];
    if(choice == nil) {
        NSLog(@"Song selection failed.");
        return @"";
    }
    NSLog(@"lasts: %@ %@", self.lastFMUrls, choice[@"url"]);
    while( [self.lastFMUrls containsObject:choice[@"url"]] ) {
        if( selectedIndex < [tracks count]-1 ) {
            selectedIndex += 1;
            choice = [NSMutableDictionary dictionaryWithDictionary:tracks[selectedIndex]];
        } else {
            break;
            NSLog(@"failed to find new match!!");
        }
    }
    if( choice[@"url"] == nil ) {
        NSLog(@"Choice invalid.");
        return @"";
    }
    [self.lastFMUrls addObject:choice[@"url"]];
    self.lastFMHref = choice[@"url"];
    [((TUAlbumViewController *)self.albumEmbed).chain addObject:choice];
    [((TUAlbumViewController *)self.albumEmbed).collectionView reloadData];
    self.previousArtist = artist;
    self.previousSong = song;
    self.currentArtist = [choice[@"artist"][@"name"] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    self.currentSong = [choice[@"name"] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSLog(@"current song: %@", self.currentSong);
    NSString *query = [NSString stringWithFormat:@"http://ws.spotify.com/search/1/track.json?q=%@", [[[NSString stringWithFormat:@"%@ %@", choice[@"name"], choice[@"artist"][@"name"]] stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByReplacingOccurrencesOfString:@"&" withString:@"_"]];
    NSString *spotifyInfo = [NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSStringEncodingConversionAllowLossy error:&error];
    if( error ) {
        // recurse, current song will have been excluded by array push
        return [self pickTrackUrl:artist Song:song];
    }
    NSDictionary *spotifyTrack = [NSJSONSerialization JSONObjectWithData:[spotifyInfo dataUsingEncoding:NSStringEncodingConversionAllowLossy] options:Nil error:&error];
    if( error ) {
        // recurse, current song will have been excluded by array push
        return [self pickTrackUrl:artist Song:song];
    }
    NSString *spotifyHref = spotifyTrack[@"tracks"][0][@"href"];
    return spotifyHref;
}
- (void)setAlbumThumbnail: (UIImage *)image {
    NSArray *tracks = ((TUAlbumViewController *)self.albumEmbed).chain;
    [tracks lastObject][@"album_image"] = image;
    [((TUAlbumViewController *)self.albumEmbed).collectionView reloadData];
}
- (void)pickSongFromArtist: (NSString *)artist Song: (NSString *)song {
    NSString *spotifyHref = [self pickTrackUrl:artist Song:song];
    Simple_PlayerAppDelegate *appDelegate = (Simple_PlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate playTrack:spotifyHref];
}
- (IBAction)nextSong {
    [self pickSongFromArtist:self.currentArtist Song:self.currentSong];
}
- (IBAction)drop {
    [((TUAlbumViewController *)self.albumEmbed).chain removeLastObject];
    [((TUAlbumViewController *)self.albumEmbed).collectionView reloadData];
    [self pickSongFromArtist:self.previousArtist Song:self.previousSong];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *artist = [[[alertView textFieldAtIndex:0] text] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *song = [[[alertView textFieldAtIndex:1] text] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *spotifyHref = [self pickTrackUrl:artist Song:song];
    Simple_PlayerAppDelegate *appDelegate = (Simple_PlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    ((TUAlbumViewController *)self.albumEmbed).chain = [[NSMutableArray alloc] initWithCapacity:255];
    [((TUAlbumViewController *)self.albumEmbed).collectionView reloadData];
    [appDelegate seedSong:spotifyHref];
}
- (IBAction)seed {    
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert textFieldAtIndex:1].secureTextEntry = NO;
    [alert textFieldAtIndex:0].placeholder = @"Song Artist";
    [alert textFieldAtIndex:1].placeholder = @"Song Title";
    alert.delegate = self;
    [alert addButtonWithTitle:@"OK"];
    alert.title = @"Seed Song:";
    [alert show];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.currentArtist = @"Kid+Cudi";
    self.currentSong = @"Mojo+So+Dope";
    self.previousArtist = @"Kid+Cudi";
    self.previousSong = @"Mojo+So+Dope";
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    self.lastFMUrls = [[NSMutableArray alloc] initWithCapacity:255];        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"embedChain"] ) {
        self.albumEmbed = segue.destinationViewController;
    }
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    NSLog(@"remote control");
    Simple_PlayerAppDelegate *appDelegate = (Simple_PlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {                
            case UIEventSubtypeRemoteControlPause:
                // play/pause
                appDelegate.playbackManager.playbackSession.playing = NO;
                break;
            case UIEventSubtypeRemoteControlPlay:
                appDelegate.playbackManager.playbackSession.playing = YES;
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                // previous
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                // next (drop)
                [self drop];
                break;
            default:
                break;
        }
    }
}

@end
