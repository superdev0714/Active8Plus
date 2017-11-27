//
//  SettingViewController.m
//  Active8Plus
//
//  Created by forever on 7/9/17.
//  Copyright © 2017 forever. All rights reserved.
//

#import "SettingViewController.h"
#import "CameraViewController.h"

@interface SettingViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnSwitchCampaign;
@property (weak, nonatomic) IBOutlet UIButton *btnLogout;
@property (weak, nonatomic) IBOutlet UILabel *lblCampaign;
@property (weak, nonatomic) IBOutlet UIButton *btnUploaded;
@property (weak, nonatomic) IBOutlet UIButton *btnPrinted;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
}

- (void) initUI {
    _btnSwitchCampaign.layer.cornerRadius   = 10.f;
    _btnSwitchCampaign.layer.masksToBounds  = YES;
    _btnSwitchCampaign.backgroundColor      = [UIColor colorWithRed:0.039 green:0.57 blue:0.81 alpha:1.0];
    
    _btnUploaded.layer.cornerRadius   = 10.f;
    _btnUploaded.layer.masksToBounds  = YES;
    _btnUploaded.backgroundColor      = [UIColor colorWithRed:0.039 green:0.57 blue:0.81 alpha:1.0];
    
    _btnPrinted.layer.cornerRadius   = 10.f;
    _btnPrinted.layer.masksToBounds  = YES;
    _btnPrinted.backgroundColor      = [UIColor colorWithRed:0.039 green:0.57 blue:0.81 alpha:1.0];
    
    _btnLogout.layer.cornerRadius           = 10.f;
    _btnLogout.layer.masksToBounds          = YES;
    _btnLogout.layer.borderColor            = [UIColor grayColor].CGColor;
    _btnLogout.layer.borderWidth            = 1;
    
    _lblCampaign.text = [NSString stringWithFormat:@"Current Campaign\n%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"Campaign"]];
}

- (IBAction)onCancel:(id)sender {
    
    for (UIViewController* viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[CameraViewController class]] ) {
            CameraViewController *cameraVC = (CameraViewController*)viewController;
            [self.navigationController popToViewController:cameraVC animated:YES];
        }
    }
}

- (IBAction)onSwitchCampagin:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Campaign"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CCODE"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"EID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onLogout:(id)sender {    
    [self.navigationController popToRootViewControllerAnimated:YES];
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

@end
