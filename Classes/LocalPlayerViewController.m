// Copyright 2014 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "AppDelegate.h"
#import "LocalPlayerViewController.h"
#import "FlintViewController.h"
#import "SimpleImageFetcher.h"
#import <Matchstick/Flint.h>

#define MOVIE_CONTAINER_TAG 1

@interface LocalPlayerViewController () {
    int lastKnownPlaybackTime;
    __weak IBOutlet UIImageView *_thumbnailView;
    __weak MatchstickDeviceController *_matchstickController;
}
@property(weak, nonatomic) IBOutlet UIButton *playPauseButton;

@property MPMoviePlayerController *moviePlayer;

@end

@implementation LocalPlayerViewController

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
    }

    return self;
}

- (void)dealloc {
}

#pragma mark State management
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"flintMedia"]) {
        [(FlintViewController *) [segue destinationViewController] setMediaToPlay:self.mediaToPlay
                                                                withStartingTime:lastKnownPlaybackTime];
    }
}

- (IBAction)playPauseButtonPressed:(id)sender {
    if (_matchstickController.isConnected) {
        if (self.playPauseButton.selected == NO) {
            [_matchstickController pauseFlintMedia:NO];
        }
        [self performSegueWithIdentifier:@"flintMedia" sender:self];
    } else {
        [self playMovieIfExists];
    }
}

#pragma mark - Managing the detail item

- (void)setMediaToPlay:(id)newMediaToPlay {
    if (_mediaToPlay != newMediaToPlay) {
        _mediaToPlay = newMediaToPlay;
    }
}

- (void)moviePlayBackDidChange:(NSNotification *)notification {
    NSLog(@"Movie playback state did change %d", _moviePlayer.playbackState);
}

- (void)moviePlayBackDidFinish:(NSNotification *)notification {
    NSLog(@"Looks like playback is over.");
    int reason = [[[notification userInfo]
            valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (reason == MPMovieFinishReasonPlaybackEnded) {
        NSLog(@"Playback has ended normally!");
    }
}

- (void)playMovieIfExists {
    if (self.mediaToPlay) {
        if (_matchstickController.isConnected) {
            // Asynchronously load the table view image
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

            dispatch_async(queue, ^{
                UIImage *image = [UIImage
                        imageWithData:[SimpleImageFetcher getDataFromImageURL:self.mediaToPlay.thumbnailURL]];

                dispatch_sync(dispatch_get_main_queue(), ^{
                    _thumbnailView.image = image;
                    [_thumbnailView setNeedsLayout];
                });
            });
        } else {
            NSURL *url = self.mediaToPlay.URL;
            NSLog(@"Playing movie %@", url);
            self.moviePlayer.contentURL = url;
            self.moviePlayer.allowsAirPlay = YES;
            self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
            self.moviePlayer.repeatMode = MPMovieRepeatModeNone;
            self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
            self.moviePlayer.shouldAutoplay = YES;

            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            if (UIInterfaceOrientationIsLandscape(orientation) &&
                    [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                self.moviePlayer.fullscreen = YES;
            } else {
                self.moviePlayer.fullscreen = NO;
            }

            [self.moviePlayer prepareToPlay];
            [self.moviePlayer play];
        }
        self.moviePlayer.view.hidden = _matchstickController.isConnected;

        self.mediaTitle.text = self.mediaToPlay.title;
        self.mediaSubtitle.text = self.mediaToPlay.subtitle;
        self.mediaDescription.text = self.mediaToPlay.descrip;
    }
}

// TODO: Perhaps just make this lazy instantiation
- (void)createMoviePlayer {
    //Create movie player controller and add it to the view
    if (!self.moviePlayer) {
        // Next create the movie player, on top of the thumbnail view.
        self.moviePlayer = [[MPMoviePlayerController alloc] init];
        self.moviePlayer.view.frame = _thumbnailView.frame;
        //self.moviePlayer.view.hidden = _matchstickController.isConnected;
        self.moviePlayer.view.hidden = YES;
        [self.view addSubview:self.moviePlayer.view];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:self.moviePlayer];

        [[NSNotificationCenter defaultCenter]
                addObserver:self
                   selector:@selector(moviePlayBackDidChange:)
                       name:MPMoviePlayerPlaybackStateDidChangeNotification
                     object:self.moviePlayer];
    }
    if (!_thumbnailView.image) {
        // Asynchronously load the table view image
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

        dispatch_async(queue, ^{
            UIImage *image = [UIImage
                    imageWithData:[SimpleImageFetcher getDataFromImageURL:self.mediaToPlay.thumbnailURL]];

            dispatch_sync(dispatch_get_main_queue(), ^{
                _thumbnailView.image = image;
                [_thumbnailView setNeedsLayout];
            });
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Store a reference to the matchstick controller.
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    _matchstickController = delegate.matchstickDeviceController;

    //Add flint button
    if (_matchstickController.deviceScanner.devices.count > 0) {
        self.navigationItem.rightBarButtonItem = _matchstickController.matchstickBarButton;
    }

    // Set an empty image for selected ("pause") state.
    [self.playPauseButton setImage:[UIImage new] forState:UIControlStateSelected];

    [self createMoviePlayer];

    // Listen to orientation changes.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Assign ourselves as delegate ONLY in viewWillAppear of a view controller.
    _matchstickController.delegate = self;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.moviePlayer) {
        self.moviePlayer.view.frame = _thumbnailView.frame;
        self.moviePlayer.view.hidden = YES;
    }
    [self updateControls];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // TODO Pause the player if navigating to a different view other than fullscreen movie view.
    if (self.moviePlayer && self.moviePlayer.fullscreen == NO) {
        [self.moviePlayer pause];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    // Respond to orientation only when not connected.
    if (_matchstickController.isConnected == YES) {
        return;
    }
    //Obtaining the current device orientation
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [self.moviePlayer setFullscreen:YES animated:YES];
    } else {
        [self.moviePlayer setFullscreen:NO animated:YES];
    }
    if (self.moviePlayer) {
        self.moviePlayer.view.frame = _thumbnailView.frame;
    }
}

#pragma mark - MatchstickControllerDelegate

- (void)didDiscoverDeviceOnNetwork {
    // Add the Matchstick icon if not present.
    self.navigationItem.rightBarButtonItem = _matchstickController.matchstickBarButton;
}

/**
 * Called when connection to the device was established.
 *
 * @param device The device to which the connection was established.
 */
- (void)didConnectToDevice:(MSFKDevice *)device {
    lastKnownPlaybackTime = [self.moviePlayer currentPlaybackTime];
    [self.moviePlayer stop];
    [self performSegueWithIdentifier:@"flintMedia" sender:self];
}

/**
 * Called when connection to the device was closed.
 */
- (void)didDisconnect {
    [self updateControls];
}

/**
 * Called when the playback state of media on the device changes.
 */
- (void)didReceiveMediaStateChange {
    [self updateControls];
}

/**
 * Called to display the modal device view controller from the flint icon.
 */
- (void)shouldDisplayModalDeviceController {
    [self performSegueWithIdentifier:@"listDevices" sender:self];
}

/**
 * Called to display the remote media playback view controller.
 */
- (void)shouldPresentPlaybackController {
    [self performSegueWithIdentifier:@"flintMedia" sender:self];
}

#pragma mark - Implementation

- (void)updateControls {
    // Check if the selected media is also playing on the screen. If so display the pause button.
    NSString *title =
            [_matchstickController.mediaInformation.metadata stringForKey:kMSFKMetadataKeyTitle];
    self.playPauseButton.selected = (_matchstickController.isConnected &&
            ([title isEqualToString:self.mediaToPlay.title] &&
                    (_matchstickController.playerState == MSFKMediaPlayerStatePlaying ||
                            _matchstickController.playerState == MSFKMediaPlayerStateBuffering)));
    self.playPauseButton.highlighted = NO;

    [_matchstickController updateToolbarForViewController:self];
}
@end