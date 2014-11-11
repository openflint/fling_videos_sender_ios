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
#import "DeviceTableViewController.h"
#import "MatchstickDeviceController.h"
#import "SimpleImageFetcher.h"
#import <Matchstick/Fling.h>


NSString *const CellIdForDeviceName = @"deviceName";

@interface DeviceTableViewController ()

@end

@implementation DeviceTableViewController {
    BOOL _isManualVolumeChange;
    UISlider *_volumeSlider;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (MatchstickDeviceController *) matchstickDeviceController {
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    return delegate.matchstickDeviceController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.matchstickDeviceController.isConnected == NO) {
        self.title = @"Connect to";
        return self.matchstickDeviceController.deviceScanner.devices.count;
    } else {
        self.title =
                [NSString stringWithFormat:@"Connected to %@", self.matchstickDeviceController.deviceName];
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdForDeviceName = @"deviceName";
    static NSString *CellIdForReadyStatus = @"readyStatus";
    static NSString *CellIdForDisconnectButton = @"disconnectButton";
    static NSString *CellIdForPlayerController = @"playerController";
    static NSString *CellIdForVolumeControl = @"volumeController";
    static int TagForVolumeSlider = 201;
    
    UITableViewCell *cell;
//    if (self.matchstickDeviceController.isConnected == NO) {
//        cell = [tableView dequeueReusableCellWithIdentifier:CellIdForDeviceName forIndexPath:indexPath];
//
//        // Configure the cell...
//        MSFKDevice *device = [self.matchstickDeviceController.deviceScanner.devices objectAtIndex:indexPath.row];
//
//        cell.textLabel.text = device.friendlyName;
//        cell.detailTextLabel.text = device.modelName;
//
//    } else if (self.matchstickDeviceController.isPlayingMedia == NO) {
//        if (indexPath.row == 0) {
//            cell = [tableView dequeueReusableCellWithIdentifier:CellIdForReadyStatus
//                                                   forIndexPath:indexPath];
//        } else if(indexPath.row == 1){
//            // Display volume control as second cell.
//            cell = [tableView dequeueReusableCellWithIdentifier:CellIdForVolumeControl
//                                                   forIndexPath:indexPath];
//            
//            _volumeSlider = (UISlider *)[cell.contentView viewWithTag:TagForVolumeSlider];
//            _volumeSlider.minimumValue = 0;
//            _volumeSlider.maximumValue = 1.0;
//            _volumeSlider.value = [self matchstickDeviceController].deviceVolume;
//            _volumeSlider.continuous = NO;
//            [_volumeSlider addTarget:self
//                              action:@selector(sliderValueChanged:)
//                    forControlEvents:UIControlEventValueChanged];
//            [[NSNotificationCenter defaultCenter] addObserver:self
//                                                     selector:@selector(receivedVolumeChangedNotification:)
//                                                         name:@"Volume changed"
//                                                       object:[self matchstickDeviceController]];
//
//        } else {
//            cell = [tableView dequeueReusableCellWithIdentifier:CellIdForDisconnectButton
//                                                   forIndexPath:indexPath];
//        }
//
//    } else {
//        if (indexPath.row == 0) {
//            cell = [tableView dequeueReusableCellWithIdentifier:CellIdForPlayerController
//                                                   forIndexPath:indexPath];
//            cell.textLabel.text =
//                    [self.matchstickDeviceController.mediaInformation.metadata stringForKey:kMSFKMetadataKeyTitle];
//            cell.detailTextLabel.text = [self.matchstickDeviceController.mediaInformation.metadata
//                    stringForKey:kMSFKMetadataKeySubtitle];
//
//            // Accessory is the play/pause button.
//            BOOL playing = (self.matchstickDeviceController.playerState == MSFKMediaPlayerStatePlaying ||
//                    self.matchstickDeviceController.playerState == MSFKMediaPlayerStateBuffering);
//            UIImage *playImage = (playing ? [UIImage imageNamed:@"pause_black.png"]
//                    : [UIImage imageNamed:@"play_black.png"]);
//            CGRect frame = CGRectMake(0, 0, playImage.size.width, playImage.size.height);
//            UIButton *button = [[UIButton alloc] initWithFrame:frame];
//            [button setBackgroundImage:playImage forState:UIControlStateNormal];
//            [button addTarget:self
//                       action:@selector(playPausePressed:)
//             forControlEvents:UIControlEventTouchUpInside];
//            cell.accessoryView = button;
//
//            // Asynchronously load the table view image
//            if (self.matchstickDeviceController.mediaInformation.metadata.images.count > 0) {
//                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//
//                dispatch_async(queue, ^{
//                    MSFKImage *mediaImage =
//                            [self.matchstickDeviceController.mediaInformation.metadata.images objectAtIndex:0];
//                    UIImage *image =
//                            [UIImage imageWithData:[SimpleImageFetcher getDataFromImageURL:mediaImage.URL]];
//
//                    CGSize itemSize = CGSizeMake(40, 40);
//                    UIImage *thumbnailImage = [self scaleImage:image toSize:itemSize];
//
//                    dispatch_sync(dispatch_get_main_queue(), ^{
//                        UIImageView *mediaThumb = cell.imageView;
//                        [mediaThumb setImage:thumbnailImage];
//                        [cell setNeedsLayout];
//                    });
//                });
//            }
//        } else if(indexPath.row == 1){
//            // Display volume control as second cell.
//            cell = [tableView dequeueReusableCellWithIdentifier:CellIdForVolumeControl
//                                                   forIndexPath:indexPath];
//            
//            _volumeSlider = (UISlider *)[cell.contentView viewWithTag:TagForVolumeSlider];
//            _volumeSlider.minimumValue = 0;
//            _volumeSlider.maximumValue = 1.0;
//            _volumeSlider.value = [self matchstickDeviceController].deviceVolume;
//            _volumeSlider.continuous = NO;
//            [_volumeSlider addTarget:self
//                              action:@selector(sliderValueChanged:)
//                    forControlEvents:UIControlEventValueChanged];
//            [[NSNotificationCenter defaultCenter] addObserver:self
//                                                     selector:@selector(receivedVolumeChangedNotification:)
//                                                         name:@"Volume changed"
//                                                       object:[self matchstickDeviceController]];
//
//        } else {
//            cell = [tableView dequeueReusableCellWithIdentifier:CellIdForDisconnectButton
//                                                   forIndexPath:indexPath];
//        }
//    }
    
    
    
    if (self.matchstickDeviceController.isConnected == NO) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdForDeviceName forIndexPath:indexPath];
        
        // Configure the cell...
        MSFKDevice *device =
        [self.matchstickDeviceController.deviceScanner.devices objectAtIndex:indexPath.row];
        cell.textLabel.text = device.friendlyName;
//        cell.detailTextLabel.text = device.statusText ? device.statusText : device.modelName;
        cell.detailTextLabel.text = device.modelName;
    } else {
        if (indexPath.row == 0) {
            if (self.matchstickDeviceController.isPlayingMedia == NO) {
                cell =
                [tableView dequeueReusableCellWithIdentifier:CellIdForReadyStatus forIndexPath:indexPath];
            } else {
                // Display the view describing the playing media.
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdForPlayerController
                                                       forIndexPath:indexPath];
                cell.textLabel.text =
                [self.matchstickDeviceController.mediaInformation.metadata stringForKey:kMSFKMetadataKeyTitle];
                cell.detailTextLabel.text = [self.matchstickDeviceController.mediaInformation.metadata
                                             stringForKey:kMSFKMetadataKeySubtitle];
                
                // Accessory is the play/pause button.
                BOOL playing = (self.matchstickDeviceController.playerState == MSFKMediaPlayerStatePlaying ||
                                self.matchstickDeviceController.playerState == MSFKMediaPlayerStateBuffering);
                UIImage *playImage = (playing ? [UIImage imageNamed:@"pause_black.png"]
                                      : [UIImage imageNamed:@"play_black.png"]);
                CGRect frame = CGRectMake(0, 0, playImage.size.width, playImage.size.height);
                UIButton *button = [[UIButton alloc] initWithFrame:frame];
                [button setBackgroundImage:playImage forState:UIControlStateNormal];
                [button addTarget:self
                           action:@selector(playPausePressed:)
                 forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = button;
                
                // Asynchronously load the table view image
                if (self.matchstickDeviceController.mediaInformation.metadata.images.count > 0) {
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                    
                    dispatch_async(queue, ^{
                        MSFKImage *mediaImage =
                        [self.matchstickDeviceController.mediaInformation.metadata.images objectAtIndex:0];
                        UIImage *image =
                        [UIImage imageWithData:[SimpleImageFetcher getDataFromImageURL:mediaImage.URL]];
                        
                        CGSize itemSize = CGSizeMake(40, 40);
                        UIImage *thumbnailImage = [self scaleImage:image toSize:itemSize];
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            UIImageView *mediaThumb = cell.imageView;
                            [mediaThumb setImage:thumbnailImage];
                            [cell setNeedsLayout];
                        });
                    });
                }
            }
        } else if (indexPath.row == 1) {
            // Display volume control as second cell.
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdForVolumeControl
                                                   forIndexPath:indexPath];
            
            _volumeSlider = (UISlider *)[cell.contentView viewWithTag:TagForVolumeSlider];
            _volumeSlider.minimumValue = 0;
            _volumeSlider.maximumValue = 1.0;
            _volumeSlider.value = [self matchstickDeviceController].deviceVolume;
            _volumeSlider.continuous = NO;
            [_volumeSlider addTarget:self
                              action:@selector(sliderValueChanged:)
                    forControlEvents:UIControlEventValueChanged];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(receivedVolumeChangedNotification:)
                                                         name:@"Volume changed"
                                                       object:[self matchstickDeviceController]];
            
        } else {
            // Display disconnect control as last cell.
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdForDisconnectButton
                                                   forIndexPath:indexPath];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.matchstickDeviceController.isConnected == NO) {
    if (indexPath.row < self.matchstickDeviceController.deviceScanner.devices.count) {
      MSFKDevice *device =
          [self.matchstickDeviceController.deviceScanner.devices objectAtIndex:indexPath.row];
      NSLog(@"Selecting device:%@", device.friendlyName);
      [self.matchstickDeviceController connectToDevice:device];
    }
  } else if (self.matchstickDeviceController.isPlayingMedia == YES && indexPath.row == 0) {
    if ([self.matchstickDeviceController.delegate
            respondsToSelector:@selector(shouldPresentPlaybackController)]) {
      [self.matchstickDeviceController.delegate shouldPresentPlaybackController];
    }
    }
    // Dismiss the view.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)                       tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Accesory button tapped");
}

- (IBAction)disconnectDevice:(id)sender {
    [self.matchstickDeviceController disconnectFromDevice];

    // Dismiss the view.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)stopApplication:(id)sender {
    [self.matchstickDeviceController stopApplication];

    // Dismiss the view.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)playPausePressed:(id)sender {
    BOOL playing = (self.matchstickDeviceController.playerState == MSFKMediaPlayerStatePlaying ||
            self.matchstickDeviceController.playerState == MSFKMediaPlayerStateBuffering);
    [self.matchstickDeviceController pauseFlingMedia:playing];

    // change the icon.
    UIButton *button = sender;
    UIImage *playImage =
            (playing ? [UIImage imageNamed:@"play_black.png"] : [UIImage imageNamed:@"pause_black.png"]);
    [button setBackgroundImage:playImage forState:UIControlStateNormal];
}

#pragma mark - implementation
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize {
    CGSize scaledSize = newSize;
    float scaleFactor = 1.0;
    if (image.size.width > image.size.height) {
        scaleFactor = image.size.width / image.size.height;
        scaledSize.width = newSize.width;
        scaledSize.height = newSize.height / scaleFactor;
    } else {
        scaleFactor = image.size.height / image.size.width;
        scaledSize.height = newSize.height;
        scaledSize.width = newSize.width / scaleFactor;
    }

    UIGraphicsBeginImageContextWithOptions(scaledSize, NO, 0.0);
    CGRect scaledImageRect = CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height);
    [image drawInRect:scaledImageRect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return scaledImage;
}

# pragma mark - volume

- (void)receivedVolumeChangedNotification:(NSNotification *) notification {
    if(!_isManualVolumeChange) {
        MatchstickDeviceController *deviceController = (MatchstickDeviceController *) notification.object;
        _volumeSlider.value = deviceController.deviceVolume;
    }
}

- (IBAction)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *) sender;
    _isManualVolumeChange = YES;
    NSLog(@"Got new slider value: %.2f", slider.value);
    [self matchstickDeviceController].deviceVolume = slider.value;
    _isManualVolumeChange = NO;
}

@end