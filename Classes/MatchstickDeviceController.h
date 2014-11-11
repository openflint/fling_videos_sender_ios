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

#import <Foundation/Foundation.h>
#import "Media.h"
#import "VolumeChangeController.h"
#import <Matchstick/Fling.h>

typedef NS_ENUM(NSInteger, MatchstickControllerFeatures) {
    // Constant for no features.
            MatchstickControllerFeaturesNone = 0x0,
    // Constant for controller device volume from hardware volume buttons.
            MatchstickControllerFeatureHWVolumeControl = 0x1,
    // Constant for adding notification support.
            MatchstickControllerFeatureNotifications = 0x2,
    // Constant for adding lock screen controls.
            MatchstickControllerFeatureLockscreenControl = 0x4
};

/**
 * The delegate to MatchstickDeviceController. Allows responsding to device and
 * media states and reflecting that in the UI.
 */
@protocol MatchstickControllerDelegate <NSObject>

@optional

/**
 * Called when Matchstick devices are discoverd on the network.
 */
- (void)didDiscoverDeviceOnNetwork;

/**
 * Called when connection to the device was established.
 *
 * @param device The device to which the connection was established.
 */
- (void)didConnectToDevice:(MSFKDevice *)device;

/**
 * Called when connection to the device was closed.
 */
- (void)didDisconnect;

/**
 * Called when the playback state of media on the device changes.
 */
- (void)didReceiveMediaStateChange;

/**
 * Called to display the modal device view controller from the fling icon.
 */
- (void)shouldDisplayModalDeviceController;

/**
 * Called to display the remote media playback view controller.
 */
- (void)shouldPresentPlaybackController;

@end

/**
 * Controller for managing the Matchstick device. Provides methods to connect to
 * the device, launch an application, load media and control its playback.
 */
@interface MatchstickDeviceController : NSObject <MSFKDeviceScannerListener,
        MSFKDeviceManagerDelegate,
        MSFKMediaControlChannelDelegate,
        VolumeChangeControllerDelegate>

/** The device scanner used to detect devices on the network. */
@property(nonatomic, strong) MSFKDeviceScanner *deviceScanner;

/** The device manager used to manage conencted Matchstick device. */
@property(nonatomic, strong) MSFKDeviceManager *deviceManager;

/** Get the friendly name of the device. */
@property(readonly, getter=getDeviceName) NSString *deviceName;

/** Length of the media loaded on the device. */
@property(nonatomic, readonly) NSTimeInterval streamDuration;

/** Current playback position of the media loaded on the device. */
@property(nonatomic, readonly) NSTimeInterval streamPosition;

/** The media player state of the media on the device. */
@property(nonatomic, readonly) MSFKMediaPlayerState playerState;

/** The media information of the loaded media on the device. */
@property(nonatomic, readonly) MSFKMediaInformation *mediaInformation;

/** The UIBarButtonItem denoting the Matchstick device. */
@property(nonatomic, readonly) UIBarButtonItem *matchstickBarButton;

/** The delegate attached to this controller. */
@property(nonatomic, assign) id <MatchstickControllerDelegate> delegate;

/** The volume the device is currently at **/
@property(nonatomic) float deviceVolume;

/** Initialize the controller with features for various experiences. */
- (id)initWithFeatures:(MatchstickControllerFeatures)features;

/** Update the toolbar representing the playback state of media on the device. */
- (void)updateToolbarForViewController:(UIViewController *)viewController;

/** Perform a device scan to discover devices on the network. */
- (void)performScan:(BOOL)start;

/** Connect to a specific Matchstick device. */
- (void)connectToDevice:(MSFKDevice *)device;

/** Disconnect from a Matchstick device. */
- (void)disconnectFromDevice;

- (void)stopApplication;

/** Load a media on the device with supplied media metadata. */
- (BOOL)loadMedia:(NSURL *)url
     thumbnailURL:(NSURL *)thumbnailURL
            title:(NSString *)title
         subtitle:(NSString *)subtitle
         mimeType:(NSString *)mimeType
        startTime:(NSTimeInterval)startTime
         autoPlay:(BOOL)autoPlay;

/** Returns true if connected to a Matchstick device. */
- (BOOL)isConnected;

/** Returns true if media is loaded on the device. */
- (BOOL)isPlayingMedia;

/** Pause or play the currently loaded media on the Matchstick device. */
- (void)pauseFlingMedia:(BOOL)shouldPause;

/** Request an update of media playback stats from the Matchstick device. */
- (void)updateStatsFromDevice;

/** Sets the position of the playback on the Matchstick device. */
- (void)setPlaybackPercent:(float)newPercent;

/** Stops the media playing on the Matchstick device. */
- (void)stopFlingMedia;

/** Increase or decrease the volume on the Matchstick device. */
- (void)changeVolumeIncrease:(BOOL)goingUp;

- (BOOL) isPlayMediaFinish;

- (float) getStreamVolume;

- (void) setStreamVolume : (float) streamVolume;

@end