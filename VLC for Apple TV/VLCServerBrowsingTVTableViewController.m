//
//  VLCServerBrowsingTVTableViewController.m
//  VLC for iOS
//
//  Created by Tobias Conradi on 27.10.15.
//  Copyright © 2015 VideoLAN. All rights reserved.
//

#import "VLCServerBrowsingTVTableViewController.h"

@interface VLCServerBrowsingTVTableViewController ()
@property (nonatomic, readonly) id<VLCNetworkServerBrowser>serverBrowser;
@property (nonatomic) NSByteCountFormatter *byteCounterFormatter;

@end
static NSString *const cellIdentifier = @"cell";

@implementation VLCServerBrowsingTVTableViewController

- (instancetype)initWithServerBrowser:(id<VLCNetworkServerBrowser>)serverBrowser
{
    self = [super init];
    if (self) {
        _serverBrowser = serverBrowser;
        serverBrowser.delegate = self;
        self.title = serverBrowser.title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.serverBrowser update];
}

#pragma mark -

- (void)networkServerBrowserDidUpdate:(id<VLCNetworkServerBrowser>)networkBrowser {
    self.title = networkBrowser.title;
    [self.tableView reloadData];
}

- (void)networkServerBrowser:(id<VLCNetworkServerBrowser>)networkBrowser requestDidFailWithError:(NSError *)error {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LOCAL_SERVER_CONNECTION_FAILED_TITLE", nil)
                                                                             message:NSLocalizedString(@"LOCAL_SERVER_CONNECTION_FAILED_MESSAGE", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];


    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"BUTTON_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -
- (NSByteCountFormatter *)byteCounterFormatter {
    if (!_byteCounterFormatter) {
        _byteCounterFormatter = [[NSByteCountFormatter alloc] init];
    }
    return _byteCounterFormatter;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.serverBrowser items].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    if (cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    id<VLCNetworkServerBrowserItem> item = self.serverBrowser.items[indexPath.row];

    cell.textLabel.text = item.name;

    if (item.isContainer) {
//        cell.isDirectory = YES;
        cell.imageView.image = [UIImage imageNamed:@"folder"];
    } else {
//        cell.isDirectory = NO;
        cell.imageView.image = [UIImage imageNamed:@"blank"];

        NSString *sizeString = item.fileSizeBytes ? [self.byteCounterFormatter stringFromByteCount:item.fileSizeBytes.longLongValue] : nil;

        NSString *duration = nil;
        if ([item respondsToSelector:@selector(duration)]) {
            duration = item.duration;
        }

        NSString *subtitle = nil;
        if (sizeString && duration) {
            subtitle = [NSString stringWithFormat:@"%@ (%@)",sizeString, duration];
        } else if (sizeString) {
            subtitle = sizeString;
        } else if (duration) {
            subtitle = duration;
        }
        cell.detailTextLabel.text = sizeString;
//        cell.isDownloadable = YES;
//        cell.delegate = self;

        NSURL *thumbnailURL = nil;
        if ([item respondsToSelector:@selector(thumbnailURL)]) {
            thumbnailURL = item.thumbnailURL;
        }

//        if (thumbnailURL) {
//            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
//            dispatch_async(queue, ^{
//                UIImage *img = [self getCachedImage:thumbnailURL];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (img) {
//                        [cell setIcon:img];
//                    }
//                });
//            });
//        }

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id<VLCNetworkServerBrowserItem> item = self.serverBrowser.items[indexPath.row];

    if (item.isContainer) {
        VLCServerBrowsingTVTableViewController *browsingViewController = [[VLCServerBrowsingTVTableViewController alloc] initWithServerBrowser:[item containerBrowser]];
        [self showViewController:browsingViewController sender:nil];
    }
}

@end