//
//  PrintedViewController.m
//  Active8Plus
//
//  Created by forever on 9/11/17.
//  Copyright © 2017 CTM. All rights reserved.
//

#import "PrintedViewController.h"
#import "APIManager.h"
#import "SettingTableViewCell.h"
#import <MP.h>

@interface PrintedViewController ()

@end

@implementation PrintedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.m_dataSource = [[APIManager sharedInstance].m_fileQueue objectForKey:KEY_PRINT];
    if (self.m_dataSource == nil) {
        self.m_dataSource = [NSMutableArray new];
    }
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(printMedia:) name:PRINTING_START_NOTIFICATION object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(printMedia:) name:PRINTING_START_NOTIFICATION object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(printMedia:) name:PRINTING_START_NOTIFICATION object:nil];
//    
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kMPWiFiConnectionEstablished object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kMPWiFiConnectionLost object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrintQueueNotification:) name:kMPPrintQueueNotification object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void) printMedia: (NSNotification *)notification {
    
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PrintedCell" forIndexPath:indexPath];
    NSMutableDictionary *one = [self.m_dataSource objectAtIndex:indexPath.row];
    cell.filename.text = [one objectForKey:@"file_name"];
    cell.date.text = @"";
    
    
    return cell;
}


@end
