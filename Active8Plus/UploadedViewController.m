//
//  UploadedViewController.m
//  Active8Plus
//
//  Created by forever on 9/11/17.
//  Copyright © 2017 CTM. All rights reserved.
//

#import "UploadedViewController.h"
#import "APIManager.h"
#import "SettingTableViewCell.h"

@interface UploadedViewController ()


@end

@implementation UploadedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploaded:) name:UPLOADING_START_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploaded:) name:UPLOADING_SUCCESS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploaded:) name:UPLOADING_FAIL_NOTIFICATION object:nil];
    
    [self initUI];
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

- (IBAction)onCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}


#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UploadedCell" forIndexPath:indexPath];
    NSMutableDictionary *one = [self.m_dataSource objectAtIndex:indexPath.row];
    cell.filename.text = [one objectForKey:@"file_name"];
    cell.imgView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[one objectForKey:@"file_path"]]];
    cell.date.text = @"";
    
    NSInteger status = [[one objectForKey:@"status"] integerValue]; // 0: start, 1: success, 2: failure
    
    if (status == 0) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, cell.frame.size.height)];
        [btn setImage:[UIImage imageNamed:@"upload_icon"] forState:UIControlStateNormal];
        cell.accessoryView = btn;
        
    }
    else if (status == 1) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, cell.frame.size.height)];
        [btn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
        cell.accessoryView = btn;
    }
    else {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, cell.frame.size.height)];
        btn.tag = indexPath.row;
        [btn setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onReupload:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = btn;
    }
    return cell;
}
- (IBAction)onAll:(UIButton *)sender {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (NSMutableDictionary *one in self.m_dataSource) {
            NSInteger status = [[one objectForKey:@"status"] integerValue];
            if (status == 2) {
                [one setObject:[NSNumber numberWithInt:0] forKey:@"status"];
                [[NSNotificationCenter defaultCenter] postNotificationName:UPLOADING_START_NOTIFICATION object:one];
            }
            
            [self initUI];
        }
        
    });
}

- (void) onReupload:(UIButton *)sender {
    NSMutableArray *upload_files = [[APIManager sharedInstance].m_fileQueue objectForKey:KEY_UPLOAD];
    NSMutableDictionary *one  = [upload_files objectAtIndex:sender.tag];
    [one setObject:[NSNumber numberWithInteger:0] forKey:@"status"]; // start
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UPLOADING_START_NOTIFICATION object:one];
    
    [self.ttblView reloadData];
}

- (void) fileUploaded:(NSNotification *)sender {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *one = sender.object;
        NSInteger status = [[one objectForKey:@"status"] integerValue];
        
        if (status == 1) {
            [[NSFileManager defaultManager] removeItemAtPath:[one objectForKey:@"file_path"] error:NULL];
            NSMutableArray *tmpArray = [[APIManager sharedInstance].m_fileQueue objectForKey:KEY_UPLOAD];
            [tmpArray removeObject:one];
        }
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initUI];
        });
    });
}

- (void) initUI {
    [self.m_allBtn setHidden:true];
    
    self.m_dataSource = [[APIManager sharedInstance].m_fileQueue objectForKey:KEY_UPLOAD];
    if (self.m_dataSource == nil) {
        self.m_dataSource = [NSMutableArray new];
    }
    
    for (NSMutableDictionary *one in self.m_dataSource) {
        NSInteger status = [[one objectForKey:@"status"] integerValue];
        if (status == 2) {
            [self.m_allBtn setHidden:false];
        }
    }
    
    [self.ttblView reloadData];
}
@end
