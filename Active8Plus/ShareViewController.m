//
//  ShareViewController.m
//  Active8Plus
//
//  Created by forever on 7/9/17.
//  Copyright © 2017 forever. All rights reserved.
//

#import "ShareViewController.h"
#import "UserListTableViewCell.h"
#import "CameraViewController.h"
#import <MessageUI/MessageUI.h>
#import "NSData+Base64.h"
#import "APIManager.h"
#import "Utility.h"
#import "UIImage+animatedGIF.h"
#import <MBProgressHUD.h>

#import <MobilePrintSDK/MP.h>
#import <MobilePrintSDK/MPPrintItemFactory.h>
#import <MobilePrintSDK/MPPrintManager.h>
#import <MobilePrintSDK/MPLayoutFactory.h>
#import <MobilePrintSDK/MPPrintLaterJob.h>

//#define ARY_EMAIL_USERS         @"ary_email_users"
//#define ARY_PHONENUMBER_USERS   @"ary_phonenumber_users"

@interface ShareViewController ()<MFMailComposeViewControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UserListTableViewCellDelegate, MPPrintDelegate, MPPrintDataSource, MPPrintPaperDelegate>
{
    NSMutableArray *aryUserEmails;
    NSMutableArray *aryUserPhoneNumbers;
    
    NSInteger nUserCount;
    MBProgressHUD *hud;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *btnPrint;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UITextField *txtEmailAddress;
@property (weak, nonatomic) IBOutlet UIView *viewEmailAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnAddEmail;
@property (weak, nonatomic) IBOutlet UIView *viewSMS;
@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *btnAddPhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblEmailUsersCount;
@property (weak, nonatomic) IBOutlet UIView *viewUserList;
@property (weak, nonatomic) IBOutlet UITableView *tblUserList;
@property (weak, nonatomic) IBOutlet UIButton *btnUserListDone;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintUserlistRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewHeight;

@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerLayer *avPlayerLayer;
@property (strong, nonatomic) UIButton *btnVideoPlay;


@property (strong, nonatomic) MPPrintItem   *printItem;


@end

@implementation ShareViewController

NSString * const kMetricsOfframpKey = @"off_ramp";
NSString * const kMetricsAppTypeKey = @"app_type";
NSString * const kMetricsAppTypeHP = @"HP";


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
    
    aryUserEmails = [[NSMutableArray alloc] init];
    aryUserPhoneNumbers = [[NSMutableArray alloc] init];
    
    nUserCount = 0;
    
    
//    if([[NSUserDefaults standardUserDefaults] objectForKey:ARY_EMAIL_USERS]) {
//        aryUserEmails = [[NSUserDefaults standardUserDefaults] objectForKey:ARY_EMAIL_USERS];
//        nUserCount = nUserCount + aryUserEmails.count;
//    }
//    
//    if([[NSUserDefaults standardUserDefaults] objectForKey:ARY_PHONENUMBER_USERS]) {
//        aryUserPhoneNumbers = [[NSUserDefaults standardUserDefaults] objectForKey:ARY_PHONENUMBER_USERS];
//        nUserCount = nUserCount + aryUserPhoneNumbers.count;
//    }
    
    self.tblUserList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.lblEmailUsersCount.text = [NSString stringWithFormat:@"Users : %ld", (long)nUserCount];
    [self.tblUserList reloadData];
    
    self.constraintUserlistRight.constant = -500;
    
    self.txtEmailAddress.delegate = self;
    self.txtPhoneNumber.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadMedia:) name:UPLOADING_START_NOTIFICATION object:nil];
    
    [MP sharedInstance].printPaperDelegate = self;
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    float mainViewWidth = screenSize.width - 260;
    
    if (screenSize.width > screenSize.height) {
        self.mainViewHeight.constant = mainViewWidth * 2 / 3.0f;
    } else {
        self.mainViewHeight.constant = mainViewWidth * 3 / 2.0f;
    }
    [self.view layoutIfNeeded];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE]) {
        NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
        if([strType isEqualToString:VIDEO]) {
            
            self.avPlayerLayer.frame = CGRectMake(_imgView.frame.origin.x, _imgView.frame.origin.y, _imgView.frame.size.width, _imgView.frame.size.height);
            [self.avPlayer play];
            
            [self.btnVideoPlay setFrame:CGRectMake(self.mainView.frame.size.width/2-125, self.mainView.frame.size.height/2-125, 250, 250)];
            
            [_imgView setHidden:YES];
        }
    }
    
}

- (void) initUI {
    
    self.viewEmailAddress.layer.cornerRadius = 3.f;
    self.viewEmailAddress.clipsToBounds = YES;
    self.viewEmailAddress.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.viewEmailAddress.layer.borderWidth = 1.f;
    
    self.viewSMS.layer.cornerRadius = 3.f;
    self.viewSMS.clipsToBounds = YES;
    self.viewSMS.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.viewSMS.layer.borderWidth = 1.f;
    
    self.btnAddEmail.layer.cornerRadius = 3.f;
    self.btnAddEmail.clipsToBounds = YES;
    
    self.btnAddPhoneNumber.layer.cornerRadius = 3.f;
    self.btnAddPhoneNumber.clipsToBounds = YES;
    
    self.btnUserListDone.layer.cornerRadius = 3.f;
    self.btnUserListDone.clipsToBounds = YES;
    
    self.viewUserList.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.viewUserList.layer.borderWidth = 1.f;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE]) {
        NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
        if([strType isEqualToString:VIDEO])
            [self.btnPrint setHidden:YES];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE]) {
        NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
        if([strType isEqualToString:STANDARDPHOTO] || [strType isEqualToString:GREENSCREENPHOTO]) {
            _imgView.image = self.imgShare;
        } else if([strType isEqualToString:ANIMATEDGIF]) {
//            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"animated.gif"];
            NSString *path = self.strFilePath;
            NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
            _imgView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
        } else if([strType isEqualToString:VIDEO]) {
            
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [APIManager sharedInstance].m_tmpMediaPath]];
            self.avPlayer = [AVPlayer playerWithURL:[[NSURL alloc] initFileURLWithPath:path]];
            self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            
            self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[self.avPlayer currentItem]];
            
            self.avPlayerLayer.frame = CGRectMake(_imgView.frame.origin.x, _imgView.frame.origin.y, _imgView.frame.size.width, _imgView.frame.size.height);
            [self.mainView.layer addSublayer:self.avPlayerLayer];
            [self.avPlayer play];
            
            self.btnVideoPlay = [[UIButton alloc] initWithFrame:CGRectMake(self.mainView.frame.size.width/2-125, self.mainView.frame.size.height/2-125, 250, 250)];
            [self.btnVideoPlay setImage:[UIImage imageNamed:@"btn_video_play"] forState:UIControlStateNormal];
            [self.btnVideoPlay addTarget:self action:@selector(onPlayButton) forControlEvents:UIControlEventTouchUpInside];
            [self.mainView addSubview:self.btnVideoPlay];
            
            [self.btnVideoPlay setHidden:YES];
            [_imgView setHidden:YES];
        }
    } else {
        _imgView.image = self.imgShare;
    }
}

- (void) onPlayButton {
    if(self.avPlayer != nil) {
        [self.avPlayer seekToTime:kCMTimeZero];
        [self.avPlayer play];
        [self.btnVideoPlay setHidden:YES];
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
//    AVPlayerItem *p = [notification object];
//    [p seekToTime:kCMTimeZero];
    
    [self.btnVideoPlay setHidden:NO];
}

- (IBAction)onDone:(id)sender {
    [self.view endEditing:YES];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
    NSString *fileName = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
    
    int nFileType = FORIGINPHOTO;

    if([[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE]) {
        NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
        if([strType isEqualToString:STANDARDPHOTO]) {
            nFileType = FORIGINPHOTO;
            fileName = [NSString stringWithFormat:@"%@.jpg", fileName];
        } else if([strType isEqualToString:GREENSCREENPHOTO]) {
            nFileType = FGREENPHOTO;
            fileName = [NSString stringWithFormat:@"%@.jpg", fileName];
        } else if([strType isEqualToString:ANIMATEDGIF]) {
            nFileType = FANIMATEDGIF;
            fileName = [NSString stringWithFormat:@"%@.gif", fileName];
        } else if([strType isEqualToString:VIDEO]) {
            nFileType = FVIDEO;
            fileName = [NSString stringWithFormat:@"%@.mp4", fileName];
        }
    } else {
        nFileType = FORIGINPHOTO;
        [fileName stringByAppendingString:@".jpg"];
    }
    
    NSString *strMimeType = @"image/jpeg";
    
    if(nFileType == FVIDEO) {
        //Video file
        NSString *fileExtention = [fileName pathExtension];
        
        if([[fileExtention uppercaseString] isEqualToString:@"MOV"]) {
            strMimeType = @"video/quicktime";
        } else if ([[fileExtention uppercaseString] isEqualToString:@"MP4"]) {
            strMimeType = @"video/mp4";
        } else if ([[fileExtention uppercaseString] isEqualToString:@"M4V"]) {
            strMimeType = @"video/x-m4v";
        } else if ([[fileExtention uppercaseString] isEqualToString:@"3GP"]) {
            strMimeType = @"video/3gpp";
        } else if ([[fileExtention uppercaseString] isEqualToString:@"AVI"]) {
            strMimeType = @"video/avi";
        } else {
            strMimeType = @"video/mp4";
        }
    } else if(nFileType == FORIGINPHOTO) {
        strMimeType = @"image/jpeg";
    } else if(nFileType == FGREENPHOTO) {
        strMimeType = @"image/jpeg";	
    } else if(nFileType == FANIMATEDGIF) {
        strMimeType = @"image/gif";
    }
    
    NSMutableDictionary *one = [NSMutableDictionary new];
    [one setObject:[self getFilePath] forKey:@"file_path"];
    [one setObject:strMimeType forKey:@"mime_type"];
    [one setObject:fileName forKey:@"file_name"];
    [one setObject:[NSNumber numberWithInt:nFileType] forKey:@"file_type"];
    [one setObject:aryUserEmails forKey:@"ary_emails"];
    [one setObject:aryUserPhoneNumbers forKey:@"ary_numbers"];
    [one setObject:[NSNumber numberWithInteger:0] forKey:@"status"]; // start
    
    NSMutableArray *upload_files = [[APIManager sharedInstance].m_fileQueue objectForKey:KEY_UPLOAD];
    if (upload_files == nil) {
        upload_files = [NSMutableArray new];
        if ([APIManager sharedInstance].m_fileQueue == nil) {
            [APIManager sharedInstance].m_fileQueue = [NSMutableDictionary new];
        }
        [[APIManager sharedInstance].m_fileQueue setObject:upload_files forKey:KEY_UPLOAD];
    }
    [upload_files addObject:one];
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"It will be uploaded automatically" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
        
        [self performSelector:@selector(gotoCameraVC) withObject:nil];
        [self uploadMedia:[NSNotification notificationWithName:UPLOADING_START_NOTIFICATION object:one]];
        
        
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:true completion:nil];
}


- (void) uploadMediaInfo:(NSString *) strUrl fileType:(FILE_TYPE)nFileType {
    [[APIManager sharedInstance] uploadMedia:strUrl fileType:nFileType userEmails:aryUserEmails userPhones:aryUserPhoneNumbers successed:^(id _success) {
        
        NSLog(@"%@", _success);
        if([[_success objectForKey:@"status"] isEqualToString:@"success"]) {
            
            UIImage *image = [[UIImage imageNamed:@"btn_done"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            hud.customView = imageView;
            hud.mode = MBProgressHUDModeCustomView;
            hud.label.text = @"Completed";
            
            [self performSelector:@selector(gotoCameraVC) withObject:nil afterDelay:3];
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
            });
            
            [[Utility sharedUtility] showAlertMessage:self title:@"" message:@"Please try again!"];
        }
    } failure:^(id _failure) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        [[Utility sharedUtility] showAlertMessage:self title:@"" message:@"Please try again!"];
    }];
}

- (void) gotoCameraVC {
    [hud hideAnimated:YES];
    
    for (UIViewController* viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[CameraViewController class]] ) {
            CameraViewController *cameraVC = (CameraViewController*)viewController;
            [self.navigationController popToViewController:cameraVC animated:YES];
        }
    }
}

- (IBAction)OnRetake:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSURL*) getFilePath {
    NSURL *urlPath = nil;
    NSString *szDocumentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE]) {
        NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
        if([strType isEqualToString:STANDARDPHOTO]) {
//            urlPath = [[NSURL alloc] initFileURLWithPath:[szDocumentPath stringByAppendingPathComponent:self.strFilePath]];
            urlPath = [[NSURL alloc] initFileURLWithPath:self.strFilePath];
        } else if([strType isEqualToString:GREENSCREENPHOTO]) {
//            urlPath = [[NSURL alloc] initFileURLWithPath:[szDocumentPath stringByAppendingPathComponent:self.strFilePath]];
            urlPath = [[NSURL alloc] initFileURLWithPath:self.strFilePath];
        } else if([strType isEqualToString:ANIMATEDGIF]) {
//            urlPath = [[NSURL alloc] initFileURLWithPath:[szDocumentPath stringByAppendingPathComponent:[APIManager sharedInstance].m_tmpMediaPath]];
            urlPath = [[NSURL alloc] initFileURLWithPath:[APIManager sharedInstance].m_tmpMediaPath];
        } else if([strType isEqualToString:VIDEO]) {
            urlPath = [[NSURL alloc] initFileURLWithPath:[szDocumentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [APIManager sharedInstance].m_tmpMediaPath]]];
        }
    } else {
        urlPath = [[NSURL alloc] initFileURLWithPath:[szDocumentPath stringByAppendingPathComponent:self.strFilePath]];
    }
    
    return urlPath;
}

- (NSData*) getAttachedFile {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    });
    NSData *attachedFile;
    if([[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE]) {
        NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
        if([strType isEqualToString:STANDARDPHOTO]) {
            attachedFile = UIImageJPEGRepresentation(self.imgView.image, 1.0f);
        } else if([strType isEqualToString:GREENSCREENPHOTO]) {
            attachedFile = UIImageJPEGRepresentation(self.imgView.image, 1.0f);
        } else if([strType isEqualToString:ANIMATEDGIF]) {
//            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"animated.gif"];
            NSString *path = self.strFilePath;
            attachedFile = [NSData dataWithContentsOfFile: path];
        } else if([strType isEqualToString:VIDEO]) {
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [APIManager sharedInstance].m_tmpMediaPath]];
            attachedFile = [NSData dataWithContentsOfFile: path];
        }
    } else {
        attachedFile = UIImageJPEGRepresentation(self.imgView.image, 1.0f);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
    return attachedFile;
}

- (IBAction)onMMS:(id)sender {
    [self.view endEditing:YES];
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setSubject:@"Please check out this image!"];
        
        NSData *myData = [self getAttachedFile];
        
        NSString *strMimeType = @"image/jpeg";
        NSString *strType;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
        NSString *fileName = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE]) {
            strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
        } else {
            strType = STANDARDPHOTO;
        }
        
        int nFileType = FORIGINPHOTO;
        //    NSData *_attachedData;
        if([[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE]) {
            NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
            if([strType isEqualToString:STANDARDPHOTO]) {
                strMimeType = @"image/jpeg";
                fileName = [NSString stringWithFormat:@"%@.jpg", fileName];
            } else if([strType isEqualToString:GREENSCREENPHOTO]) {
                strMimeType = @"image/jpeg";
                fileName = [NSString stringWithFormat:@"%@.jpg", fileName];
            } else if([strType isEqualToString:ANIMATEDGIF]) {
                strMimeType = @"image/gif";
                fileName = [NSString stringWithFormat:@"%@.gif", fileName];
            } else if([strType isEqualToString:VIDEO]) {
                strMimeType = @"video/mp4";
                fileName = [NSString stringWithFormat:@"%@.mp4", fileName];
            }
        } else {
            nFileType = FORIGINPHOTO;
        }
        
        [picker addAttachmentData:myData mimeType:strMimeType fileName:fileName];
        
        // Fill out the email body text
        NSString *emailBody = @"My cool image is attached.";
        [picker setMessageBody:emailBody isHTML:NO];
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)onEmail:(id)sender {
    [self.view endEditing:YES];
    
    if([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setSubject:@"Please check out this image!"];
        
        NSData *myData = [self getAttachedFile];
        
        NSString *strMimeType = @"image/jpeg";
        NSString *strType;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
        NSString *fileName = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE]) {
            strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
        } else {
            strType = STANDARDPHOTO;
        }
        
        int nFileType = FORIGINPHOTO;
        //    NSData *_attachedData;
        if([[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE]) {
            NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
            if([strType isEqualToString:STANDARDPHOTO]) {
                strMimeType = @"image/jpeg";
                fileName = [NSString stringWithFormat:@"%@.jpg", fileName];
            } else if([strType isEqualToString:GREENSCREENPHOTO]) {
                strMimeType = @"image/jpeg";
                fileName = [NSString stringWithFormat:@"%@.jpg", fileName];
            } else if([strType isEqualToString:ANIMATEDGIF]) {
                strMimeType = @"image/gif";
                fileName = [NSString stringWithFormat:@"%@.gif", fileName];
            } else if([strType isEqualToString:VIDEO]) {
                strMimeType = @"video/mp4";
                fileName = [NSString stringWithFormat:@"%@.mp4", fileName];
            }
        } else {
            nFileType = FORIGINPHOTO;
        }
        
        [picker addAttachmentData:myData mimeType:strMimeType fileName:fileName];
        
        // Fill out the email body text
        NSString *emailBody = @"My cool image is attached.";
        [picker setMessageBody:emailBody isHTML:NO];
        [self presentViewController:picker animated:YES completion:nil];
    }
}

// Then implement the delegate method
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)onPrint:(id)sender {
    [self.view endEditing:YES];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE]) {
        NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
        if([strType isEqualToString:VIDEO]) {
            [[Utility sharedUtility] showAlertMessage:self title:@"" message:@"Can't print Video file."];
            return;
        }
    }
    
    self.printItem = [MPPrintItemFactory printItemWithAsset:[UIImage imageWithData:[NSData dataWithContentsOfURL:[self getFilePath]] scale:1.0]];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
    NSString *fileName = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
    
    int nFileType = FORIGINPHOTO;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE]) {
        NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
        if([strType isEqualToString:STANDARDPHOTO]) {
            nFileType = FORIGINPHOTO;
            fileName = [NSString stringWithFormat:@"%@.jpg", fileName];
        } else if([strType isEqualToString:GREENSCREENPHOTO]) {
            nFileType = FGREENPHOTO;
            fileName = [NSString stringWithFormat:@"%@.jpg", fileName];
        } else if([strType isEqualToString:ANIMATEDGIF]) {
            nFileType = FANIMATEDGIF;
            fileName = [NSString stringWithFormat:@"%@.gif", fileName];
        } else if([strType isEqualToString:VIDEO]) {
            nFileType = FVIDEO;
            fileName = [NSString stringWithFormat:@"%@.mp4", fileName];
        }
    } else {
        nFileType = FORIGINPHOTO;
        [fileName stringByAppendingString:@".jpg"];
    }
    
    NSString *strMimeType = @"image/jpeg";
    
    if(nFileType == FVIDEO) {
        //Video file
        NSString *fileExtention = [fileName pathExtension];
        
        if([[fileExtention uppercaseString] isEqualToString:@"MOV"]) {
            strMimeType = @"video/quicktime";
        } else if ([[fileExtention uppercaseString] isEqualToString:@"MP4"]) {
            strMimeType = @"video/mp4";
        } else if ([[fileExtention uppercaseString] isEqualToString:@"M4V"]) {
            strMimeType = @"video/x-m4v";
        } else if ([[fileExtention uppercaseString] isEqualToString:@"3GP"]) {
            strMimeType = @"video/3gpp";
        } else if ([[fileExtention uppercaseString] isEqualToString:@"AVI"]) {
            strMimeType = @"video/avi";
        } else {
            strMimeType = @"video/mp4";
        }
    } else if(nFileType == FORIGINPHOTO) {
        strMimeType = @"image/jpeg";
    } else if(nFileType == FGREENPHOTO) {
        strMimeType = @"image/jpeg";
    } else if(nFileType == FANIMATEDGIF) {
        strMimeType = @"image/gif";
    }

    
    NSMutableDictionary *one = [NSMutableDictionary new];
    [one setObject:self.printItem forKey:@"print_item"];
    [one setObject:[self getFilePath] forKey:@"file_path"];
    [one setObject:strMimeType forKey:@"mime_type"];
    [one setObject:fileName forKey:@"file_name"];
    [one setObject:[NSNumber numberWithInt:nFileType] forKey:@"file_type"];
    [one setObject:[NSNumber numberWithInteger:0] forKey:@"status"]; // start
    NSMutableArray *print_files = [[APIManager sharedInstance].m_fileQueue objectForKey:KEY_PRINT];
    if (print_files == nil) {
        print_files = [NSMutableArray new];
        if ([APIManager sharedInstance].m_fileQueue == nil) {
            [APIManager sharedInstance].m_fileQueue = [NSMutableDictionary new];
        }
        [[APIManager sharedInstance].m_fileQueue setObject:print_files forKey:KEY_PRINT];
    }
    [print_files addObject:one];
    
    UIViewController *vc = [[MP sharedInstance] printViewControllerWithDelegate:self dataSource:self printItem:self.printItem fromQueue:false settingsOnly:false];
    [self presentViewController:vc animated:true completion:^{
        
    }];

}
NSString * const kAddJobClientNamePrefix = @"From Client";

- (IBAction)onAddEmail:(id)sender {
    [self.view endEditing:YES];
    
    if([[Utility sharedUtility] validateEmail:self.txtEmailAddress.text] == NO) {
        [[Utility sharedUtility] showAlertMessage:self title:@"" message:@"Invalid Email Address."];
        return;
    }
    
    for(int i = 0; i < aryUserEmails.count; i ++) {
        NSString *strEmail = [aryUserEmails objectAtIndex:i];
        if([self.txtEmailAddress.text isEqualToString:strEmail]) {
            [[Utility sharedUtility] showAlertMessage:self title:@"" message:@"This Email Address was already added."];
            return;
        }
    }
    
    if([self.txtEmailAddress.text isEqualToString:@""])
        return;
    
    [aryUserEmails addObject:self.txtEmailAddress.text];
    
    [[Utility sharedUtility] showAlertMessage:self title:@"" message:@"You can add additonal emails."];
    self.txtEmailAddress.text = @"";
    
    [self updateInviteUserCount];
    
//    [[NSUserDefaults standardUserDefaults] setObject:aryUserEmails forKey:ARY_EMAIL_USERS];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tblUserList reloadData];
}

- (IBAction)onAddSMS:(id)sender {
    [self.view endEditing:YES];
    
    if([[Utility sharedUtility] validatePhone:self.txtPhoneNumber.text] == NO) {
        [[Utility sharedUtility] showAlertMessage:self title:@"" message:@"Invalid Phone Number."];
        return;
    }
    
    for(int i = 0; i < aryUserPhoneNumbers.count; i ++) {
        NSString *strEmail = [aryUserPhoneNumbers objectAtIndex:i];
        if([self.txtPhoneNumber.text isEqualToString:strEmail]) {
            [[Utility sharedUtility] showAlertMessage:self title:@"" message:@"This Phone number was already added."];
            return;
        }
    }
    
    if([self.txtPhoneNumber.text isEqualToString:@""])
        return;
    
    [aryUserPhoneNumbers addObject:self.txtPhoneNumber.text];
    
    [[Utility sharedUtility] showAlertMessage:self title:@"" message:@"You can add additonal phone numbers."];
    self.txtPhoneNumber.text = @"";
    
    [self updateInviteUserCount];
    
//    [[NSUserDefaults standardUserDefaults] setObject:aryUserPhoneNumbers forKey:ARY_PHONENUMBER_USERS];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tblUserList reloadData];
}

- (void) updateInviteUserCount {
    nUserCount = aryUserEmails.count + aryUserPhoneNumbers.count;
    self.lblEmailUsersCount.text = [NSString stringWithFormat:@"Users : %ld", (long)nUserCount];
}

- (IBAction)onHideUserList:(id)sender {
    [UIView animateWithDuration:0.3f animations:^{
        self.constraintUserlistRight.constant = -500;
        [self.viewUserList layoutIfNeeded];
    }];
}

- (IBAction)onShowUserList:(id)sender {
    [UIView animateWithDuration:0.3f animations:^{
        self.constraintUserlistRight.constant = 0;
        [self.viewUserList layoutIfNeeded];
    }];
}


- (void) uploadMedia: (NSNotification *)notification {
    NSLog(@"uploadMedia %@", notification.name);
    
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_enter([APIManager sharedInstance].group);
        
        NSMutableDictionary *one = notification.object;
        NSURL *file_path = [one objectForKey:@"file_path"];
        NSString *file_name = [one objectForKey:@"file_name"];
        FILE_TYPE file_type = [[one objectForKey:@"file_type"] intValue];
        NSString *mime_type = [one objectForKey:@"mime_type"];
        NSArray *ary_emails = [one objectForKey:@"ary_emails"];
        NSArray *ary_numbers = [one objectForKey:@"ary_numbers"];
        
        
        [[APIManager sharedInstance] uploadMediaToAmazonAndBackend:file_path contentType:mime_type fileType:file_type filename:file_name userEmails:ary_emails userPhones:ary_numbers successed:^(id _success) {
            
            [one setObject:[NSNumber numberWithInteger:1] forKey:@"status"]; // success
            
            NSLog(@"File Uploading Success!!!");
            
            NSMutableArray *tmpArray = [[APIManager sharedInstance].m_fileQueue objectForKey:KEY_UPLOAD];
            [tmpArray removeObject:one];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UPLOADING_SUCCESS_NOTIFICATION object:one];
            
            dispatch_group_leave([APIManager sharedInstance].group);
            
        } failure:^(NSError *_failure) {
            
            NSLog(@"File Uploading Failure!!!");
            [one setObject:[NSNumber numberWithInteger:2] forKey:@"status"]; // failure
            [[NSNotificationCenter defaultCenter] postNotificationName:UPLOADING_FAIL_NOTIFICATION object:one];
            
            dispatch_group_leave([APIManager sharedInstance].group);
        }];
        
        dispatch_group_wait([APIManager sharedInstance].group, DISPATCH_TIME_FOREVER);
    });
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return aryUserPhoneNumbers.count + aryUserEmails.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserListTableViewCell *cell = [self.tblUserList dequeueReusableCellWithIdentifier:@"UserListTableViewCell"];
    
    if(aryUserEmails.count > indexPath.row) {
        cell.lblUserEmail.text = [aryUserEmails objectAtIndex:indexPath.row];
    } else {
        cell.lblUserEmail.text = [aryUserPhoneNumbers objectAtIndex:(indexPath.row - aryUserEmails.count)];
    }
    cell.nIndex = indexPath.row;
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - UserListTableViewCellDelegate
- (void)didDelete:(NSInteger)nIndex {
    
    if(aryUserEmails.count > nIndex) {
        [aryUserEmails removeObjectAtIndex:nIndex];
        
//        if(aryUserEmails.count == 0)
//           [[NSUserDefaults standardUserDefaults] removeObjectForKey:ARY_EMAIL_USERS];
//        else
//            [[NSUserDefaults standardUserDefaults] setObject:aryUserEmails forKey:ARY_EMAIL_USERS];
//        
//        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [aryUserPhoneNumbers removeObjectAtIndex:(nIndex - aryUserEmails.count)];
        
//        if(aryUserPhoneNumbers.count == 0)
//            [[NSUserDefaults standardUserDefaults] removeObjectForKey:ARY_PHONENUMBER_USERS];
//        else
//            [[NSUserDefaults standardUserDefaults] setObject:aryUserPhoneNumbers forKey:ARY_PHONENUMBER_USERS];
//        
//        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self updateInviteUserCount];
    [self.tblUserList reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark MPPrintDelegate
- (void)didFinishPrintFlow:(UIViewController *)printViewController {
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:PRINTING_END_NOTIFICATION object:nil];
    
    [printViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)didCancelPrintFlow:(UIViewController *)printViewController {
    [printViewController dismissViewControllerAnimated:true completion:nil];
}


#pragma mark - MPPrintPaperDelegate

- (BOOL)hidePaperSizeForPrintSettings:(MPPrintSettings *)printSettings
{
    return [printSettings.printerModel containsString:@"Label"];
}

- (BOOL)hidePaperTypeForPrintSettings:(MPPrintSettings *)printSettings
{
    return [printSettings.printerModel containsString:@"Label"];
}

- (MPPaper *)defaultPaperForPrintSettings:(MPPrintSettings *)printSettings
{
    MPPaper *defaultPaper = [[self paperList] firstObject];
    if ([printSettings.printerModel containsString:@"Label"]) {
        NSUInteger paperSize = [self aspectRatio4up] ? k4UpPaperSizeId : k3UpPaperSizeId;
        defaultPaper = [[MPPaper alloc] initWithPaperSize:paperSize paperType:kLabelPaperTypeId];
    }
    
    return defaultPaper;
    
}

- (NSArray *)supportedPapersForPrintSettings:(MPPrintSettings *)printSettings
{
    NSArray *papers = [self paperList];
    
    if ([printSettings.printerModel containsString:@"Label"]) {
        NSUInteger paperSize = [self aspectRatio4up] ? k4UpPaperSizeId : k3UpPaperSizeId;
        papers = @[ [[MPPaper alloc] initWithPaperSize:paperSize paperType:kLabelPaperTypeId] ];
    }
    
    if (!IS_OS_8_OR_LATER) {
        papers = [MPPaper availablePapers];
    }
    
    return papers;
}

- (UIPrintPaper *)printInteractionController:(UIPrintInteractionController *)printInteractionController choosePaper:(NSArray *)paperList forPrintSettings:(MPPrintSettings *)printSettings
{
    // Implement custom paper selection logic here...
    NSLog(@"Cstom Paper");
    MPLogInfo(@"CUT LENGTH");
    return nil; //[NSNumber numberWithFloat:printSettings.paper.height * 72.0];
}

- (NSNumber *)printInteractionController:(UIPrintInteractionController *)printInteractionController cutLengthForPaper:(UIPrintPaper *)paper forPrintSettings:(MPPrintSettings *)printSettings
{
//    return 5.0 * 72.0;
    MPLogInfo(@"CHOOSE PAPER");
    return nil;
}


- (NSArray *)paperList
{
    NSArray *papers = [MPPaper availablePapers];
    [MP sharedInstance].defaultPaper = [[MPPaper alloc] initWithPaperSize:MPPaperSize4x6 paperType:MPPaperTypePhoto];
//    if (kPaperSegmentUSAIndex == self.paperSegmentControl.selectedSegmentIndex) {
//        [MP sharedInstance].defaultPaper = [MPPaper standardUSADefaultPaper];
//        NSMutableArray *standardPapers = [NSMutableArray arrayWithArray:[MPPaper standardUSAPapers]];
//        MPPaper *paper3Up = [[MPPaper alloc] initWithPaperSize:MPPaperSize5x7 paperType:k3UpPaperTypeId];
//        papers = [standardPapers arrayByAddingObject:paper3Up];
//    } else if (kPaperSegmentInternationalIndex == self.paperSegmentControl.selectedSegmentIndex) {
//        [MP sharedInstance].defaultPaper = [MPPaper standardInternationalDefaultPaper];
//        papers = [MPPaper standardInternationalPapers];
//    }
    return papers;
}

- (BOOL)aspectRatio3up
{
    BOOL is3up = NO;
    if (self.printItem) {
        CGSize printItemSize = [self.printItem sizeInUnits:Inches];
        is3up = fabs((printItemSize.width / printItemSize.height) - (k3UpPaperSizeWidth / k3UpPaperSizeHeight)) < 0.001;
    }
    return is3up;
}

- (BOOL)aspectRatio4up
{
    BOOL is4up = NO;
    if (self.printItem) {
        CGSize printItemSize = [self.printItem sizeInUnits:Inches];
        is4up = fabs((printItemSize.width / printItemSize.height) - (k4UpPaperSizeWidth / k4UpPaperSizeHeight)) < 0.001;
    }
    return is4up;
}


#pragma mark - Photo strip paper

NSUInteger const k3UpPaperSizeId = 100;
NSString * const k3UpPaperSizeTitle = @"2 x 6";
CGFloat const k3UpPaperSizeWidth = 2.0; // inches
CGFloat const k3UpPaperSizeHeight = 6.0; // inches

NSUInteger const k4UpPaperSizeId = 101;
NSString * const k4UpPaperSizeTitle = @"1.5 x 8";
CGFloat const k4UpPaperSizeWidth = 1.5; // inches
CGFloat const k4UpPaperSizeHeight = 8.0; // inches

NSUInteger const k3UpPaperTypeId = 100;
NSString * const k3UpPaperTypeTitle = @"3-Up Perforated";
BOOL const k3UpPaperTypePhoto = YES;

NSUInteger const kLabelPaperTypeId = 101;
NSString * const kLabelPaperTypeTitle = @"Label";
BOOL const kLabelPaperTypePhoto = NO;

@end
