//
//  AppDelegate.h
//  Active8Plus
//
//  Created by forever on 7/8/17.
//  Copyright © 2017 forever. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AWSCore/AWSCore.h>
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Reachability                  *reachability;


//com.goactiv8plus.app  
@end

