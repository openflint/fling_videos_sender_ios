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

#import "FlintViewController.h"
#import "LocalPlayerViewController.h"
#import "AppDelegate.h"
#import "SimpleImageFetcher.h"
#import <Matchstick/Flint.h>

@interface FlintViewController () <VolumeChangeControllerDelegate> {
    NSTimeInterval _mediaStartTime;
    BOOL _currentlyDraggingSlider;
    BOOL _readyToShowInterface;
    BOOL _joinExistingSession;
    __weak MatchstickDeviceController *_matchstickController;
}
@property(strong, nonatomic) UIPopoverController *masterPopoverController;
@property IBOutlet UIImageView *thumbnailImage;
@property IBOutlet UILabel *flintingToLabel;
@property(weak, nonatomic) IBOutlet UILabel *mediaTitleLabel;
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *flintActivityIndicator;
@property(weak, nonatomic) NSTimer *updateStreamTimer;

@property(nonatomic) UIBarButtonItem *currTime;
@property(nonatomic) UIBarButtonItem *totalTime;
@property(nonatomic) UISlider *slider;
@property(nonatomic) NSArray *playToolbar;
@property(nonatomic) NSArray *pauseToolbar;
@property(nonatomic) NSArray *notHaveButtonBar;
@property BOOL isManualVolumeChange;
@property(nonatomic) UIBarButtonItem* cc;
@property(weak, nonatomic) NSTimer* fadeVolumeControlTimer;


@end

@implementation FlintViewController

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
//        [self initControls];
    }

    return self;
}

- (void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Store a reference to the controller.
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    _matchstickController = delegate.matchstickDeviceController;

    self.navigationItem.rightBarButtonItem = _matchstickController.matchstickBarButton;

    self.flintingToLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Flinting to %@", nil),
                                                          _matchstickController.deviceName];
    self.mediaTitleLabel.text = self.mediaToPlay.title;
    
    self.volumeControlLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Volume", nil),
                                    _matchstickController.deviceName];
    self.volumeSlider.minimumValue = 0;
    self.volumeSlider.maximumValue = 1.0;
    
    self.volumeSlider.value = _matchstickController.getStreamVolume ?
    _matchstickController.getStreamVolume : 0.5;
    self.volumeSlider.continuous = NO;
    [self.volumeSlider addTarget:self
                          action:@selector(sliderValueChanged:)
                forControlEvents:UIControlEventValueChanged];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(receivedVolumeChangedNotification:)
//                                                 name:@"Volume changed"
//                                               object:_matchstickController];
    UIButton *transparencyButton = [[UIButton alloc] initWithFrame:self.view.bounds];
    transparencyButton.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    transparencyButton.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:transparencyButton aboveSubview:self.thumbnailImage];
    [transparencyButton addTarget:self action:@selector(showVolumeSlider:) forControlEvents:UIControlEventTouchUpInside];
    [self initControls];
}

# pragma mark - volume

//- (void)receivedVolumeChangedNotification:(NSNotification *) notification {
//    if(!_isManualVolumeChange) {
//        MatchstickDeviceController *deviceController = (MatchstickDeviceController *) notification.object;
//        _volumeSlider.value = deviceController.deviceVolume;
//    }
//}

- (IBAction)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *) sender;
    // Essentially a fake lock to prevent us from being stuck in an endless loop (volume change
    // triggers notification, triggers UI change, triggers volume change ...
    // This method is not foolproof (not thread safe), but for most use cases *should* be safe
    // enough.
    _isManualVolumeChange = YES;
    NSLog(@"Got new slider value: %.2f", slider.value);
//    _matchstickController.deviceVolume = slider.value;
    [_matchstickController setStreamVolume:slider.value];
    _isManualVolumeChange = NO;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showVolumeSlider:(id)sender {
    if(self.volumeControls.hidden) {
        self.volumeControls.hidden = NO;
        [self.volumeControls setAlpha:0];
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.volumeControls.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                             NSLog(@"Done!");
                         }];
        
    }
    // Do this so if a user taps the screen or plays with the volume slider, it resets the timer
    // for fading the volume controls
    if(self.fadeVolumeControlTimer != nil) {
        [self.fadeVolumeControlTimer invalidate];
    }
    self.fadeVolumeControlTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                                   target:self
                                                                 selector:@selector(fadeVolumeSlider:)
                                                                 userInfo:nil repeats:NO];
    
    
}

- (void)fadeVolumeSlider:(NSTimer *)timer {
    [self.volumeControls setAlpha:1.0];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.volumeControls.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         self.volumeControls.hidden = YES;
                     }];
}


#pragma mark - Managing the detail item

- (void)setMediaToPlay:(Media *)newDetailItem {
    [self setMediaToPlay:newDetailItem withStartingTime:0];
}

- (void)setMediaToPlay:(Media *)newMedia withStartingTime:(NSTimeInterval)startTime {
    _mediaStartTime = startTime;
    if (_mediaToPlay != newMedia) {
        _mediaToPlay = newMedia;

        // Update the view.
        [self configureView];
    }
}

- (void)resetInterfaceElements {
    self.totalTime.title = @"";
    self.currTime.title = @"";
    [self.slider setValue:0];
    [self.flintActivityIndicator startAnimating];
    _currentlyDraggingSlider = NO;
    self.navigationController.toolbarHidden = YES;
    _readyToShowInterface = NO;
}

- (void)mediaNowPlaying {
    _readyToShowInterface = YES;
    [self updateInterfaceFromFlint:nil];
    self.navigationController.toolbarHidden = NO;
}

- (void)updateInterfaceFromFlint:(NSTimer *)timer {
    [_matchstickController updateStatsFromDevice];

    
    if (!_readyToShowInterface)
        return;

    if (_matchstickController.playerState != MSFKMediaPlayerStateBuffering) {
        [self.flintActivityIndicator stopAnimating];
    } else {
        [self.flintActivityIndicator startAnimating];
    }

    if (_matchstickController.streamDuration > 0 && !_currentlyDraggingSlider) {
        self.currTime.title = [self getFormattedTime:_matchstickController.streamPosition];
        self.totalTime.title = [self getFormattedTime:_matchstickController.streamDuration];
        [self.slider
                setValue:(_matchstickController.streamPosition / _matchstickController.streamDuration)
                animated:YES];
    }
//    if (_matchstickController.playerState == MSFKMediaPlayerStatePaused) {
//        self.toolbarItems = self.playToolbar;
//    } else if (_matchstickController.playerState == MSFKMediaPlayerStatePlaying ||
//            _matchstickController.playerState == MSFKMediaPlayerStateBuffering) {
//        self.toolbarItems = self.pauseToolbar;
//    } else if(_matchstickController.playerState == MSFKMediaPlayerStateUnknown || _matchstickController.playerState == MSFKMediaPlayerStateIdle){
//        self.toolbarItems = self.notHaveButtonBar;
//    }
    
    
    
    if (_matchstickController.playerState == MSFKMediaPlayerStatePaused ||
        _matchstickController.playerState == MSFKMediaPlayerStateIdle) {
        self.toolbarItems = self.playToolbar;
    } else if (_matchstickController.playerState == MSFKMediaPlayerStatePlaying ||
               _matchstickController.playerState == MSFKMediaPlayerStateBuffering) {
        self.toolbarItems = self.pauseToolbar;
    }
}

// Little formatting option here

- (NSString *)getFormattedTime:(NSTimeInterval)timeInSeconds {
    NSInteger seconds = (NSInteger) round(timeInSeconds);
    NSInteger hours = seconds / (60 * 60);
    seconds %= (60 * 60);

    NSInteger minutes = seconds / 60;
    seconds %= 60;

    if (hours > 0) {
        return [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
    } else {
        return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    }
}

- (void)configureView {
    if (self.mediaToPlay && _matchstickController.isConnected) {
        NSURL *url = self.mediaToPlay.URL;
        self.flintingToLabel.text =
                [NSString stringWithFormat:@"Flinting to %@", _matchstickController.deviceName];
        self.mediaTitleLabel.text = self.mediaToPlay.title;
        NSLog(@"Flinting movie %@ at starting time %f", url, _mediaStartTime);

        //Loading thumbnail async
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage
                    imageWithData:[SimpleImageFetcher getDataFromImageURL:self.mediaToPlay.posterURL]];

            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Loaded thumbnail image");
                self.thumbnailImage.image = image;
                [self.view setNeedsLayout];
            });
        });

        // If the newMedia is already playing, join the existing session.
        if (![self.mediaToPlay.title isEqualToString:[_matchstickController.mediaInformation.metadata
                stringForKey:kMSFKMetadataKeyTitle]]) {
            //Flint the movie!!
            [_matchstickController loadMedia:url
                                thumbnailURL:self.mediaToPlay.thumbnailURL
                                       title:self.mediaToPlay.title
                                    subtitle:self.mediaToPlay.subtitle
                                    mimeType:self.mediaToPlay.mimeType
                                   startTime:_mediaStartTime
                                    autoPlay:YES];
            _joinExistingSession = NO;
        } else {
            if(_matchstickController.isPlayingMedia){
                _joinExistingSession = YES;
                [self mediaNowPlaying];
            } else {
                //Flint the movie!!
                [_matchstickController loadMedia:url
                                    thumbnailURL:self.mediaToPlay.thumbnailURL
                                           title:self.mediaToPlay.title
                                        subtitle:self.mediaToPlay.subtitle
                                        mimeType:self.mediaToPlay.mimeType
                                       startTime:_mediaStartTime
                                        autoPlay:YES];
                _joinExistingSession = NO;
                
            }
        }

        // Start the timer
        if (self.updateStreamTimer) {
            [self.updateStreamTimer invalidate];
            self.updateStreamTimer = nil;
        }

        self.updateStreamTimer =
                [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(updateInterfaceFromFlint:)
                                               userInfo:nil
                                                repeats:YES];

    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!_matchstickController.isConnected) {
        return;
    }

    // Assign ourselves as delegate ONLY in viewWillAppear of a view controller.
    _matchstickController.delegate = self;

    // Make the navigation bar transparent.
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];

    // We want a transparent toolbar.
    [self.navigationController.toolbar setBackgroundImage:[UIImage new]
                                       forToolbarPosition:UIBarPositionBottom
                                               barMetrics:UIBarMetricsDefault];
    [self.navigationController.toolbar setShadowImage:[UIImage new]
                                   forToolbarPosition:UIBarPositionBottom];
    self.navigationController.toolbarHidden = YES;
    self.toolbarItems = self.playToolbar;

    [self resetInterfaceElements];

    if (_joinExistingSession == YES) {
        [self mediaNowPlaying];
    }

    [self configureView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    // I think we can safely stop the timer here
    [self.updateStreamTimer invalidate];
    self.updateStreamTimer = nil;

    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.toolbar setBackgroundImage:nil
                                       forToolbarPosition:UIBarPositionBottom
                                               barMetrics:UIBarMetricsDefault];
}

#pragma mark - On - screen UI elements
- (IBAction)pauseButtonClicked:(id)sender {
    [_matchstickController pauseFlintMedia:YES];
}

- (IBAction)playButtonClicked:(id)sender {
    [_matchstickController pauseFlintMedia:NO];
}

// Unsed, but if you wanted a stop, as opposed to a pause button, this is probably
// what you would call
- (IBAction)stopButtonClicked:(id)sender {
    [_matchstickController stopFlintMedia];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onTouchDown:(id)sender {
    _currentlyDraggingSlider = YES;
}

// This is continuous, so we can update the current/end time labels
- (IBAction)onSliderValueChanged:(id)sender {
    float pctThrough = [self.slider value];
    if (_matchstickController.streamDuration > 0) {
        self.currTime.title =
                [self getFormattedTime:(pctThrough * _matchstickController.streamDuration)];
    }
}

// This is called only on one of the two touch up events
- (void)touchIsFinished {
    [_matchstickController setPlaybackPercent:[self.slider value]];
    _currentlyDraggingSlider = NO;
}

- (IBAction)onTouchUpInside:(id)sender {
    NSLog(@"Touch up inside");
    [self touchIsFinished];

}

- (IBAction)onTouchUpOutside:(id)sender {
    NSLog(@"Touch up outside");
    [self touchIsFinished];
}

#pragma mark - MatchstickControllerDelegate

/**
 * Called when connection to the device was closed.
 */
- (void)didDisconnect {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * Called when the playback state of media on the device changes.
 */
- (void)didReceiveMediaStateChange {
    _readyToShowInterface = YES;
    self.navigationController.toolbarHidden = NO;

    if (_matchstickController.playerState == MSFKMediaPlayerStateIdle) {
//        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if(_matchstickController.isPlayMediaFinish){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/**
 * Called to display the modal device view controller from the flint icon.
 */
- (void)shouldDisplayModalDeviceController {
    [self performSegueWithIdentifier:@"listDevices" sender:self];
}


#pragma mark - implementation.
- (void)initControls {
    UIBarButtonItem* playButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                  target:self
                                                  action:@selector(playButtonClicked:)];
    playButton.tintColor = [UIColor whiteColor];
    UIBarButtonItem* pauseButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                                                  target:self
                                                  action:@selector(pauseButtonClicked:)];
    pauseButton.tintColor = [UIColor whiteColor];
    UIBarButtonItem *volumeButton =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_volume3.png"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(showVolumeSlider:)];
    volumeButton.tintColor = [UIColor whiteColor];
//    self.cc =
//    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"closed_caption_white.png"]
//                                     style:UIBarButtonItemStylePlain
//                                    target:self
//                                    action:@selector(subtitleButtonClicked:)];
//    self.cc.tintColor = [UIColor whiteColor];
    self.currTime = [[UIBarButtonItem alloc] initWithTitle:@"00:00"
                                                     style:UIBarButtonItemStylePlain
                                                    target:nil
                                                    action:nil];
    self.currTime.tintColor = [UIColor whiteColor];
    self.totalTime = [[UIBarButtonItem alloc] initWithTitle:@"100:00"
                                                      style:UIBarButtonItemStylePlain
                                                     target:nil
                                                     action:nil];
    self.totalTime.tintColor = [UIColor whiteColor];
    UIBarButtonItem* flexibleSpace =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];
    UIBarButtonItem* flexibleSpace2 =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];
    UIBarButtonItem* flexibleSpace3 =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];
    UIBarButtonItem* flexibleSpace4 =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];
    
    self.slider = [[UISlider alloc] init];
    [self.slider addTarget:self
                    action:@selector(onSliderValueChanged:)
          forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self
                    action:@selector(onTouchDown:)
          forControlEvents:UIControlEventTouchDown];
    [self.slider addTarget:self
                    action:@selector(onTouchUpInside:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.slider addTarget:self
                    action:@selector(onTouchUpOutside:)
          forControlEvents:UIControlEventTouchUpOutside];
    self.slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIBarButtonItem* sliderItem = [[UIBarButtonItem alloc] initWithCustomView:self.slider];
    sliderItem.tintColor = [UIColor yellowColor];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        sliderItem.width = 500;
    }
    
    // Round the corners on the volume pop up.
    self.volumeControls.layer.cornerRadius = 5;
    self.volumeControls.layer.masksToBounds = YES;
    
    self.playToolbar = [NSArray arrayWithObjects:flexibleSpace,
                        playButton, flexibleSpace2, volumeButton, flexibleSpace3,
                        self.currTime, sliderItem, self.totalTime, flexibleSpace4,
                         nil];
    self.pauseToolbar = [NSArray arrayWithObjects:flexibleSpace,
                         pauseButton, flexibleSpace2, volumeButton, flexibleSpace3,
                         self.currTime, sliderItem, self.totalTime, flexibleSpace4,
                          nil];
}



@end