//
//  ViewController.m
//  Active8Plus
//
//  Created by forever on 7/8/17.
//  Copyright © 2017 forever. All rights reserved.
//

#import "LoginViewController.h"
#import "CameraViewController.h"
#import "APIManager.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtCampaign;
@property (weak, nonatomic) IBOutlet UIButton *btnGo;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initUI];
    
}

- (void) initUI {
    
    _txtCampaign.backgroundColor        = [UIColor whiteColor];
    _txtCampaign.layer.cornerRadius     = 10.f;
    _txtCampaign.layer.masksToBounds    = YES;
    
    _txtCampaign.delegate               = self;
    
    _btnGo.layer.masksToBounds          = YES;
    _btnGo.layer.cornerRadius           = 10.f;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"CCODE"]) {
        _txtCampaign.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"CCODE"];
        [self onGo:nil];
    }    
}

- (IBAction)onGo:(id)sender {
    
    if([_txtCampaign.text isEqualToString:@""]) {
        [[Utility sharedUtility] showAlertMessage:self title:@"" message:@"Please input your campaign."];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[APIManager sharedInstance] LoginWithCapaign:_txtCampaign.text successed:^(id _response) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(_response) {
            if([[_response objectForKey:@"status"] isEqualToString:@"success"]) {
                NSDictionary *dicData = [_response objectForKey:@"data"];
                
                [[NSUserDefaults standardUserDefaults] setObject:[dicData objectForKey:@"ccode"] forKey:@"CCODE"];
                [[NSUserDefaults standardUserDefaults] setObject:[dicData objectForKey:@"eid"] forKey:@"EID"];
                [[NSUserDefaults standardUserDefaults] setObject:[dicData objectForKey:@"campaign"] forKey:@"Campaign"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                CameraViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                [[Utility sharedUtility] showAlertMessage:self title:@"" message:@"Invalid Campaign."];
            }
        }
    } failure:^(id _failure) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[Utility sharedUtility] showAlertMessage:self title:@"" message:@"Please try again."];
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate Method
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(_txtCampaign == textField) {
        [_txtCampaign resignFirstResponder];
    }
    
    return YES;
}

@end
