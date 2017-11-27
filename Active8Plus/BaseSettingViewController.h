//
//  BaseSettingViewController.h
//  Active8Plus
//
//  Created by forever on 9/11/17.
//  Copyright © 2017 CTM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseSettingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(strong, nonatomic) NSMutableArray                     *m_dataSource;

- (IBAction)onCancel:(id)sender;

@end
