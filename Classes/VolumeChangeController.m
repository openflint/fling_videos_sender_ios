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

#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VolumeChangeController.h"

static NSString *const kVolumeChangeNotification =
        @"AVSystemController_SystemVolumeDidChangeNotification";
static NSString *const kVolumeChangeNotificationParameter =
        @"AVSystemController_AudioVolumeNotificationParameter";
static const NSTimeInterval kResumeNotificationsInterval = 0.1;

@interface VolumeChangeController () {
    float _initialVolume;
    BOOL _capturedVolumeButtons;
    BOOL _isAppActive;
    __strong UIView *_volumeView;
}
@end

@implementation VolumeChangeController

- (id)init {
    self = [super init];
    if (self) {
        _isAppActive = YES;
    }
    return self;
}

- (void)dealloc {
    [self releaseVolumeButtons];
}

- (void)setDelegate:(id <VolumeChangeControllerDelegate>)delegate {
    _delegate = delegate;
}

- (void)captureVolumeButtons {
    if (_capturedVolumeButtons) {
        return;
    }

    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    AudioSessionSetActive(YES);
    CGRect frame = CGRectMake(0, -100, 10, 0);
    _volumeView = [[MPVolumeView alloc] initWithFrame:frame];
    [_volumeView sizeToFit];
    [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:_volumeView];

    _initialVolume = [[MPMusicPlayerController iPodMusicPlayer] volume];
    // If initial volume is 0 or 1, adjust it so that volume buttons fire.
    if (_initialVolume == 1.0) {
        _initialVolume = 0.95;
    } else if (_initialVolume == 0) {
        _initialVolume = 0.05;
    }

    [self enableVolumeChangeNotifications];

    _capturedVolumeButtons = YES;

    if (_isAppActive) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pauseCapturingVolumeButtons:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resumeCapturingVolumeButtons:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
}

- (void)releaseVolumeButtons {
    if (!_capturedVolumeButtons) {
        return;
    }
    [self disableVolumeChangeNotifications];

    // Stop observing all notifications
    if (_isAppActive) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }

    AudioSessionSetActive(NO);

    [_volumeView removeFromSuperview];
    _volumeView = nil;

    _capturedVolumeButtons = NO;
}

#pragma mark Private Implementation

- (void)volumeChanged:(NSNotification *)notification {
    float newVolume =
            [[[notification userInfo] objectForKey:kVolumeChangeNotificationParameter] floatValue];

    [self disableVolumeChangeNotifications];

    [[MPMusicPlayerController applicationMusicPlayer] setVolume:_initialVolume];

    [self performSelector:@selector(enableVolumeChangeNotifications)
               withObject:self
               afterDelay:kResumeNotificationsInterval];

    if (newVolume > _initialVolume) {
        if ([_delegate respondsToSelector:@selector(didChangeVolumeUp)]) {
            [_delegate didChangeVolumeUp];
        }
    } else if (newVolume < _initialVolume) {
        if ([_delegate respondsToSelector:@selector(didChangeVolumeDown)]) {
            [_delegate didChangeVolumeDown];
        }
    }
}

- (void)enableVolumeChangeNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChanged:)
                                                 name:kVolumeChangeNotification
                                               object:nil];
}

- (void)disableVolumeChangeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kVolumeChangeNotification
                                                  object:nil];
}

- (void)pauseCapturingVolumeButtons:(NSNotification *)notification {
    if (_capturedVolumeButtons) {
        _isAppActive = NO;
        [self releaseVolumeButtons];
    }
}

- (void)resumeCapturingVolumeButtons:(NSNotification *)notification {
    if (!_capturedVolumeButtons) {
        [self captureVolumeButtons];
        _isAppActive = YES;
    }
}

@end