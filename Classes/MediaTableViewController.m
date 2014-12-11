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
#import "MediaTableViewController.h"
#import "SimpleImageFetcher.h"
#import "Media.h"
#import "MediaListModel.h"
#import <Matchstick/Flint.h>

@interface MediaTableViewController () {
    __weak MatchstickDeviceController *_matchstickDeviceController;
}

@property(nonatomic, strong) MediaListModel *mediaList;
@end

@implementation MediaTableViewController

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
    }
    return self;
}

- (void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Store a reference to the Matchstick controller.
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    _matchstickDeviceController = delegate.matchstickDeviceController;

    // Show stylized application title in the titleview.
    self.navigationItem.titleView =
            [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_castvideos.png"]];

    // Display flint icon in the right nav bar button, if we have devices.
    if (_matchstickDeviceController.deviceScanner.devices.count > 0) {
        self.navigationItem.rightBarButtonItem = _matchstickDeviceController.matchstickBarButton;
    }

    // Asynchronously load the media json
    self.mediaList = [[MediaListModel alloc] init];

    [self.mediaList loadMedia:^(NSArray *array){
        self.title = self.mediaList.mediaTitle;
         [self.tableView reloadData];
    }
    ];
    
    NSLog(@"dsdsb");
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Assign ourselves as delegate ONLY in viewWillAppear of a view controller.
    _matchstickDeviceController.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [_matchstickDeviceController updateToolbarForViewController:self];
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.mediaList numberOfMediaLoaded];
//    return [ar count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Media *media = [self.mediaList mediaAtIndex:indexPath.row];

    UILabel *mediaTitle = (UILabel *) [cell viewWithTag:1];
    mediaTitle.text = media.title;

    UILabel *mediaOwner = (UILabel *) [cell viewWithTag:2];
    mediaOwner.text = media.subtitle;

    // Asynchronously load the table view image
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

    dispatch_async(queue, ^{
        UIImage *image =
                [UIImage imageWithData:[SimpleImageFetcher getDataFromImageURL:media.thumbnailURL]];

        dispatch_sync(dispatch_get_main_queue(), ^{
            UIImageView *mediaThumb = (UIImageView *) [cell viewWithTag:3];
            [mediaThumb setImage:image];
            [cell setNeedsLayout];
        });
    });

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Display the media details view.
    [self performSegueWithIdentifier:@"playMedia" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"flintMedia"] ||
            [[segue identifier] isEqualToString:@"playMedia"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Media *media = [self.mediaList mediaAtIndex:indexPath.row];
        [[segue destinationViewController] setMediaToPlay:media];
    }
}

#pragma mark - MatchstickControllerDelegate

/**
 * Called when Matchstick devices are discoverd on the network.
 */
- (void)didDiscoverDeviceOnNetwork {
    // Add the Matchstick icon if not present.
    self.navigationItem.rightBarButtonItem = _matchstickDeviceController.matchstickBarButton;
}

/**
 * Called when connection to the device was established.
 *
 * @param device The device to which the connection was established.
 */
- (void)didConnectToDevice:(MSFKDevice *)device {
    [_matchstickDeviceController updateToolbarForViewController:self];
}

/**
 * Called when connection to the device was closed.
 */
- (void)didDisconnect {
    [_matchstickDeviceController updateToolbarForViewController:self];
}

/**
 * Called when the playback state of media on the device changes.
 */
- (void)didReceiveMediaStateChange {
    [_matchstickDeviceController updateToolbarForViewController:self];
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
    // Select the item being played in the table, so prepareForSegue can find the
    // associated Media object.
    NSString *title =
            [_matchstickDeviceController.mediaInformation.metadata stringForKey:kMSFKMetadataKeyTitle];
    for (int i = 0; i < self.mediaList.numberOfMediaLoaded; i++) {
        Media *media = [self.mediaList mediaAtIndex:i];
        if ([media.title isEqualToString:title]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionNone];
            [self performSegueWithIdentifier:@"flintMedia" sender:self];
            break;
        }
    };
}

@end