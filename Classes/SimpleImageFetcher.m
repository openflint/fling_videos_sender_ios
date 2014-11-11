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

#import "SimpleImageFetcher.h"

@implementation SimpleImageFetcher

+ (NSData *)getDataFromImageURL:(NSURL *)urlToFetch {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // We should really use a better hashing mechanism than this.
    NSString *cacheFileName = [NSString stringWithFormat:@"%ul", [[urlToFetch absoluteString] hash]];
    NSURL *cacheDirectory =
            [[[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject]
                    URLByAppendingPathComponent:@"thumbnails"];
    NSURL *cacheFileURL = [cacheDirectory URLByAppendingPathComponent:cacheFileName];

    if ([fileManager fileExistsAtPath:[cacheFileURL path]]) {
        // Cache hit!
        return [[NSData alloc] initWithContentsOfURL:cacheFileURL];
    } else {
        // Retrieve the data from the internet
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:urlToFetch];

        // Create the cache directory, if needed
        NSError *error;
        if (![fileManager fileExistsAtPath:[cacheDirectory path]]) {
            [fileManager createDirectoryAtURL:cacheDirectory
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:&error];
            if (error) {
                NSLog(@"Received an error trying to create a directory %@", [error localizedDescription]);
            }
        }
        error = nil;

        // Write the image to our cache
        [imageData writeToURL:cacheFileURL options:NSDataWritingAtomic error:&error];
        if (error) {
            NSLog(@"Received an error trying to save a cached file %@", [error localizedDescription]);
        }
        return imageData;
    }

}

@end