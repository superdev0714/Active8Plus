//
//  ChromakeyViewController.h
//  Active8Plus
//
//  Created by forever on 7/9/17.
//  Copyright © 2017 forever. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChromakeyViewController : UIViewController

@property (strong, nonatomic) UIImage           *imgChromakey;
@property (strong, nonatomic) NSMutableArray    *aryCapturedPhoto;
@property (strong, nonatomic) UIImage           *imgOverlay;

@property (strong, nonatomic) NSArray           *arrBackground;

@end
