//
//  SettingTableViewCell.h
//  Active8Plus
//
//  Created by forever on 9/11/17.
//  Copyright © 2017 CTM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *filename;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end
