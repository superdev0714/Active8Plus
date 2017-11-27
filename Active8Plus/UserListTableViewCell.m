//
//  UserListTableViewCell.m
//  Active8Plus
//
//  Created by forever on 8/11/17.
//  Copyright © 2017 forever. All rights reserved.
//

#import "UserListTableViewCell.h"

@implementation UserListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onDelete:(id)sender {
    [self.delegate didDelete:self.nIndex];
}

@end
