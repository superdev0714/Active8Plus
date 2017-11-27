//
//  CameraViewController.h
//  Active8Plus
//
//  Created by forever on 7/8/17.
//  Copyright © 2017 forever. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLSimpleCamera.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) AVAsset *videoAsset;
@property(nonatomic, strong) NSMutableArray *arrLandscapeOverlays;
@property(nonatomic, strong) NSMutableArray *arrPortraitOverlays;
@property(nonatomic, strong) NSMutableArray *arrOverlays;

@property (weak, nonatomic) IBOutlet UIButton *btnSelectOverlay;

@property (weak, nonatomic) IBOutlet UITableView *overlayTable;

@end
