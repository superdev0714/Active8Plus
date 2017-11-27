//
//  UserListTableViewCell.h
//  Active8Plus
//
//  Created by forever on 8/11/17.
//  Copyright © 2017 forever. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserListTableViewCellDelegate <NSObject>

@optional

- (void)didDelete:(NSInteger) nIndex;

@end

@interface UserListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblUserEmail;
@property (atomic, assign) NSInteger nIndex;
@property (strong, nonatomic) id<UserListTableViewCellDelegate> delegate;

@end
