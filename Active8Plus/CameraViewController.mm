//
//  CameraViewController.m
//  Active8Plus
//
//  Created by forever on 7/8/17.
//  Copyright © 2017 forever. All rights reserved.
//

#import "CameraViewController.h"
#import "ChromakeyViewController.h"
#import "ShareViewController.h"
#import "SettingViewController.h"
#import "SelectOverlayTableViewCell.h"
#import "Chromagic.h"
#import "APIManager.h"
#import <MBProgressHUD.h>

/**
 * Default Chromakey values
 **/

#define DEFAULT_HUE 120.0f
#define DEFAULT_TOLERANCE 30.0f
#define DEFAULT_SATURATION 0.2f
#define DEFAULT_MIN_VALUE  0.35f
#define DEFAULT_MAX_VALUE 0.95f

/*Default Video Length Value, Number of Photos*/
#define DEFAULT_VIDEOLENGTH @"videoLength"
#define DEFAULT_ANIMATEDPHOTOCOUNT @"animatedPhotoCount"

#define TIMEMR_INTERVAL 0.05f

@interface CameraViewController ()<UITextFieldDelegate>
{
    NSMutableArray *aryCapturedPhoto;
    NSTimer *recordingTimer;
}
@property (weak, nonatomic) IBOutlet UIView *viewCurrentTimeProgress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTimeProgressRight;

@property (weak, nonatomic) IBOutlet UIView     *cameraView;
@property (weak, nonatomic) IBOutlet UIButton   *btnCapture;
@property (weak, nonatomic) IBOutlet UIButton   *btnCheck;
@property (weak, nonatomic) IBOutlet UIButton   *btnSetting;

//ChromakeySettingView
@property (weak, nonatomic) IBOutlet UIView *viewChromakeySetting;
@property (weak, nonatomic) IBOutlet UITextField *txtSaturation;
@property (weak, nonatomic) IBOutlet UITextField *txtMax;
@property (weak, nonatomic) IBOutlet UITextField *txtTolerance;
@property (weak, nonatomic) IBOutlet UITextField *txtHue;
@property (weak, nonatomic) IBOutlet UITextField *txtMin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintChromakeySettingViewBottom;

//MediaTypeSettingView
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMediaTypeSettingViewBottom;
@property (weak, nonatomic) IBOutlet UIView *viewMediaTypeSetting;
@property (weak, nonatomic) IBOutlet UIImageView *imgStandardPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *imgGreenScreenPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *imgVideo;
@property (weak, nonatomic) IBOutlet UIImageView *imgAnimatedGif;

//VideoSettingView
@property (weak, nonatomic) IBOutlet UIView *viewVideoSetting;
@property (weak, nonatomic) IBOutlet UILabel *lblRecordTime;
@property (weak, nonatomic) IBOutlet UISlider *sldVideoRecordTime;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintVideoSettingViewBottom;

//AnimatedGifSettingView
@property (weak, nonatomic) IBOutlet UISlider *sldAnimatedGifCount;
@property (weak, nonatomic) IBOutlet UILabel *lblNumberofPhotos;
@property (weak, nonatomic) IBOutlet UIView *viewAnimatedGifSetting;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAnimatedGifSettingViewBottom;

@property (strong, nonatomic) LLSimpleCamera    *camera;
@property (weak, nonatomic) IBOutlet UIImageView *imgOverlay;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSelectOverlayViewRight;

@end

@implementation CameraViewController
@synthesize arrLandscapeOverlays;
@synthesize arrPortraitOverlays;
@synthesize arrOverlays;

@synthesize overlayTable;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    arrOverlays = [[NSMutableArray alloc] init];
    arrLandscapeOverlays = [[NSMutableArray alloc] init];
    arrPortraitOverlays = [[NSMutableArray alloc] init];
    
    [self initControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _constraintSelectOverlayViewRight.constant = -200;
    
    [self.camera start];
    [aryCapturedPhoto removeAllObjects];
    
    
}


-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self checkSelectOverlayButton];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.camera.view.frame = CGRectMake(0.0f, 0.0f, screenSize.width, screenSize.height);
    
    if ([self isLandscape]) {
        arrOverlays = arrLandscapeOverlays;
    } else {
        arrOverlays = arrPortraitOverlays;
    }
    _imgOverlay.image = nil;
    if (arrOverlays.count > 0) {
        NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
        if ([strType isEqualToString:GREENSCREENPHOTO]) {
            _imgOverlay.image = nil;
        } else {
            [[Utility sharedUtility] setImageURLWithAsync:[arrOverlays[0] objectForKey:@"filename"] displayImgView:_imgOverlay placeholder:@""];
        }
    }
    [self.overlayTable reloadData];
}

-(void) checkSelectOverlayButton{
    NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
    if ([strType isEqualToString:GREENSCREENPHOTO]) {
        [self.btnSelectOverlay setHidden:YES];
    } else {
        [self.btnSelectOverlay setHidden:NO];
    }
}

- (void) initControl {
    
    aryCapturedPhoto = [[NSMutableArray alloc] init];
    
    _txtHue.delegate        = self;
    _txtSaturation.delegate = self;
    _txtTolerance.delegate  = self;
    _txtMax.delegate        = self;
    _txtMin.delegate        = self;
    
    _txtHue.layer.cornerRadius          = 10.f;
    _txtHue.layer.masksToBounds         = YES;
    _txtHue.backgroundColor             = [UIColor whiteColor];
    
    _txtSaturation.layer.cornerRadius   = 10.f;
    _txtSaturation.layer.masksToBounds  = YES;
    _txtSaturation.backgroundColor      = [UIColor whiteColor];
    
    _txtTolerance.layer.cornerRadius    = 10.f;
    _txtTolerance.layer.masksToBounds   = YES;
    _txtTolerance.backgroundColor       = [UIColor whiteColor];
    
    _txtMin.layer.cornerRadius          = 10.f;
    _txtMin.layer.masksToBounds         = YES;
    _txtMin.backgroundColor             = [UIColor whiteColor];
    
    _txtMax.layer.cornerRadius          = 10.f;
    _txtMax.layer.masksToBounds         = YES;
    _txtMax.backgroundColor             = [UIColor whiteColor];
    
    _txtHue.text            = [NSString stringWithFormat:@"%.02f", DEFAULT_HUE];
    _txtSaturation.text     = [NSString stringWithFormat:@"%.02f", DEFAULT_SATURATION];
    _txtTolerance.text      = [NSString stringWithFormat:@"%.02f", DEFAULT_TOLERANCE];
    _txtMin.text            = [NSString stringWithFormat:@"%.02f", DEFAULT_MIN_VALUE];
    _txtMax.text            = [NSString stringWithFormat:@"%.02f", DEFAULT_MAX_VALUE];
    
    _constraintChromakeySettingViewBottom.constant = -240;
    _constraintMediaTypeSettingViewBottom.constant = - 200;
    _constraintVideoSettingViewBottom.constant = -200;
    _constraintAnimatedGifSettingViewBottom.constant = -200;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    _constraintTimeProgressRight.constant = screenSize.width;
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE]) {
        [[NSUserDefaults standardUserDefaults] setObject:STANDARDPHOTO forKey:PHOTOTYPE];
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_VIDEOLENGTH]) {
        self.sldVideoRecordTime.value = [[[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_VIDEOLENGTH] integerValue];
        self.lblRecordTime.text = [NSString stringWithFormat:@"Record Time : %2.f s", self.sldVideoRecordTime.value];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@(30) forKey:DEFAULT_VIDEOLENGTH];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.sldVideoRecordTime.value = 30;
        self.lblRecordTime.text = [NSString stringWithFormat:@"Record Time : %2.f s", self.sldVideoRecordTime.value];
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_ANIMATEDPHOTOCOUNT]) {
        self.sldAnimatedGifCount.value = [[[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_ANIMATEDPHOTOCOUNT] integerValue];
        self.lblNumberofPhotos.text = [NSString stringWithFormat:@"Number of Photos : %2.f", self.sldAnimatedGifCount.value];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@(15) forKey:DEFAULT_ANIMATEDPHOTOCOUNT];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.sldAnimatedGifCount.value = 15;
        self.lblNumberofPhotos.text = [NSString stringWithFormat:@"Number of Photos : %2.f", self.sldAnimatedGifCount.value];
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh
                                                 position:LLCameraPositionRear
                                             videoEnabled:YES];
    [self addChildViewController:self.camera];
    self.camera.view.frame = self.cameraView.frame;
    [self.cameraView addSubview:self.camera.view];
    [self.camera didMoveToParentViewController:self];
    
    self.camera.fixOrientationAfterCapture  = NO;
    __weak typeof(self) weakSelf            = self;
    
    [self.camera setOnDeviceChange:^(LLSimpleCamera *camera, AVCaptureDevice * device) {
        NSLog(@"Device changed.");
    }];
    
    [self getImageOverlay];
    
    [self.camera setOnError:^(LLSimpleCamera *camera, NSError *error) {
        NSLog(@"Camera error: %@", error);
        
        if([error.domain isEqualToString:LLSimpleCameraErrorDomain]) {
            if(error.code == LLSimpleCameraErrorCodeCameraPermission ||
               error.code == LLSimpleCameraErrorCodeMicrophonePermission) {
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.text = @"We need permission for the camera.\nPlease go to your settings.";
                label.numberOfLines = 2;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:24.0f];
                label.textColor = [UIColor whiteColor];
                label.textAlignment = NSTextAlignmentCenter;
                [label sizeToFit];
                label.center = CGPointMake(screenRect.size.width / 2.0f, screenRect.size.height / 2.0f);
                [weakSelf.cameraView addSubview:label];
            }
        }
    }];
}

- (void) getImageOverlay {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Loading";
    
    NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
    
    [[APIManager sharedInstance] getOverlay:^(id _response) {
        
        [hud hideAnimated:YES];
        
        if(_response) {
            if([[_response objectForKey:@"status"] isEqualToString:@"success"]) {
                
                NSArray *arrData = [_response objectForKey:@"data"];
                arrPortraitOverlays = [[NSMutableArray alloc] init];
                arrLandscapeOverlays = [[NSMutableArray alloc] init];
                arrOverlays = [[NSMutableArray alloc] init];
                
                for (NSDictionary *dic in arrData) {
                    NSString *m_mode = [dic valueForKey:@"m_mode"];
                    if ([m_mode isEqualToString:@"h"]) {
                        [arrLandscapeOverlays addObject:dic];
                    } else if ([m_mode isEqualToString:@"v"]) {
                        [arrPortraitOverlays addObject:dic];
                    }
                }
                
                if ([self isLandscape]) {
                    arrOverlays = arrLandscapeOverlays;
                } else {
                    arrOverlays = arrPortraitOverlays;
                }
                if (arrOverlays.count > 0) {
                    if (![strType isEqualToString:GREENSCREENPHOTO]) {
                        [[Utility sharedUtility] setImageURLWithAsync:[arrOverlays[0] objectForKey:@"filename"] displayImgView:_imgOverlay placeholder:@""];
                    } else {
                        _imgOverlay.image = nil;
                    }
                }
                [overlayTable reloadData];
                
            } else {
                [[Utility sharedUtility] showAlertMessage:self title:@"" message:@"Error! Can't get Overlay Image Please try again."];
            }
        }
    } failure:^(id _failure) {
        [hud hideAnimated:YES];
        [[Utility sharedUtility] showAlertMessage:self title:@"" message:@"Error! Can't get Overlay Image Please try again."];
    }];
}

- (void) applyUserChromaKeyValues: (Chromagic::IChromaKey*) ck
{
    ck->setHue([_txtHue.text floatValue]);
    ck->setSaturation([_txtSaturation.text floatValue]);
    ck->setTolerance([_txtTolerance.text floatValue]);
    ck->setValue([_txtMin.text floatValue], [_txtMax.text floatValue]);
}

- (UIImage *)chromaTheImage:(UIImage*)image
{
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char *)malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    Chromagic::IChromaKey *ck = Chromagic::createChromaKey();
    // Set user-chosen chromakey values
    [self applyUserChromaKeyValues: ck];
    
    ck->chroma((int)width, (int)height, rawData);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    
    // Send the rawData to the chroma algorithm
    
    for (int ii = 0 ; ii < width * height; ++ii)
    {
        float alpha = rawData[ii * 4 + 3] / 255.0;
        rawData[ii * 4 + 0] *= alpha;
        rawData[ii * 4 + 1] *= alpha;
        rawData[ii * 4 + 2] *= alpha;
    }
    
    CGImageRef img = CGBitmapContextCreateImage(context);
    UIImage *ui_img = [UIImage imageWithCGImage: img];
    
    CGImageRelease(img);
    CGContextRelease(context);
    free(rawData);
    
    return ui_img;
}

- (IBAction)onCheck:(id)sender {
    
    if(self.camera.recording) {
        return;
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE]) {
        NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
        if([strType isEqualToString:STANDARDPHOTO]) {
            _imgStandardPhoto.image     = [UIImage imageNamed:@"btn_check"];
            _imgGreenScreenPhoto.image  = [UIImage imageNamed:@"btn_uncheck"];
            _imgVideo.image             = [UIImage imageNamed:@"btn_uncheck"];
            _imgAnimatedGif.image       = [UIImage imageNamed:@"btn_uncheck"];
        } else if([strType isEqualToString:GREENSCREENPHOTO]) {
            _imgStandardPhoto.image     = [UIImage imageNamed:@"btn_uncheck"];
            _imgGreenScreenPhoto.image  = [UIImage imageNamed:@"btn_check"];
            _imgVideo.image             = [UIImage imageNamed:@"btn_uncheck"];
            _imgAnimatedGif.image       = [UIImage imageNamed:@"btn_uncheck"];
        } else if([strType isEqualToString:VIDEO]) {
            _imgStandardPhoto.image     = [UIImage imageNamed:@"btn_uncheck"];
            _imgGreenScreenPhoto.image  = [UIImage imageNamed:@"btn_uncheck"];
            _imgVideo.image             = [UIImage imageNamed:@"btn_check"];
            _imgAnimatedGif.image       = [UIImage imageNamed:@"btn_uncheck"];
        } else if([strType isEqualToString:ANIMATEDGIF]) {
            _imgStandardPhoto.image     = [UIImage imageNamed:@"btn_uncheck"];
            _imgGreenScreenPhoto.image  = [UIImage imageNamed:@"btn_uncheck"];
            _imgVideo.image             = [UIImage imageNamed:@"btn_uncheck"];
            _imgAnimatedGif.image       = [UIImage imageNamed:@"btn_check"];
        }
    } else {
        _imgStandardPhoto.image     = [UIImage imageNamed:@"btn_check"];
        _imgGreenScreenPhoto.image  = [UIImage imageNamed:@"btn_uncheck"];
        _imgVideo.image             = [UIImage imageNamed:@"btn_uncheck"];
        _imgAnimatedGif.image       = [UIImage imageNamed:@"btn_uncheck"];
        [[NSUserDefaults standardUserDefaults] setObject:STANDARDPHOTO forKey:PHOTOTYPE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _constraintMediaTypeSettingViewBottom.constant = 0;
        [self.viewMediaTypeSetting layoutIfNeeded];
    }];
}

- (IBAction)onCapture:(id)sender {
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
    if([strType isEqualToString:VIDEO]) {
        if(!self.camera.isRecording) {
            // start recording
            
            recordingTimer = [NSTimer scheduledTimerWithTimeInterval:TIMEMR_INTERVAL target:self selector:@selector(checkTimer) userInfo:nil repeats:YES];
            
            [self.btnCapture setImage:[UIImage imageNamed:@"btn_video_end"] forState:UIControlStateNormal];
            NSURL *outputURL = [[[self applicationDocumentsDirectory]
                                 URLByAppendingPathComponent:@"test"] URLByAppendingPathExtension:@"mov"];
            [[NSFileManager defaultManager] removeItemAtURL:outputURL error:NULL];
            
            self.camera.useDeviceOrientation = YES;
            
            [self.camera startRecordingWithOutputUrl:outputURL didRecord:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
                [self addOverlayImageToVideo];
            }];
            
        } else {
            fCurrentTime = 0;
            
            [recordingTimer invalidate];
            recordingTimer = nil;
            
            _constraintTimeProgressRight.constant = screenSize.width;
            
            [self.btnCapture setImage:[UIImage imageNamed:@"btn_camera"] forState:UIControlStateNormal];
            [self.camera stopRecording];
        }
    } else {
        [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
            if(!error) {
                
                UIImage *imgchromaImage = [self chromaTheImage:[[Utility sharedUtility] resizeImage:image]];
                
                if([strType isEqualToString:ANIMATEDGIF]) {
                    
                    [aryCapturedPhoto addObject:imgchromaImage];
                    
                    NSInteger nPhotoCount = [[[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_ANIMATEDPHOTOCOUNT] integerValue];
                    if (aryCapturedPhoto.count >= nPhotoCount) {
                        ChromakeyViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChromakeyViewController"];
                        vc.aryCapturedPhoto         = aryCapturedPhoto;
                        vc.imgOverlay               = self.imgOverlay.image;//[self chromaTheImage:self.imgOverlay.image];
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                    
                } else if([strType isEqualToString:GREENSCREENPHOTO]){
                    
                    ChromakeyViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChromakeyViewController"];
                    vc.imgChromakey             = imgchromaImage;
                    vc.imgOverlay               = self.imgOverlay.image;
                    
                    [self.navigationController pushViewController:vc animated:YES];
                    
                } else {
                    UIImage *originImage = [[Utility sharedUtility] resizeImage:image];
                    UIImage *newImage = [[Utility sharedUtility] mergeImages:originImage overlayImage:self.imgOverlay.image];
                    
                    [self saveStandardImage:newImage];
                    ShareViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
                    vc.imgShare             = newImage;
                    vc.strFilePath          = [APIManager sharedInstance].m_tmpMediaPath;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                
            }
            else {
                NSLog(@"An error has occured: %@", error);
            }
        } exactSeenImage:YES];
    }
}

- (void) saveStandardImage:(UIImage*) image {

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
    
    [APIManager sharedInstance].m_tmpMediaPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:
                                                  [NSString stringWithFormat:@"standardimage-%@.jpg", [formatter stringFromDate:[NSDate date]]]];
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    [data writeToFile:[APIManager sharedInstance].m_tmpMediaPath atomically:YES];
}

static float fCurrentTime = 0;
- (void) checkTimer {
    fCurrentTime += TIMEMR_INTERVAL;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    NSInteger nMaxVideoLength = 30;
    if([[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_VIDEOLENGTH]) {
        nMaxVideoLength = [[[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_VIDEOLENGTH] integerValue];
    }
    
    if(fCurrentTime >= nMaxVideoLength) {
        if(self.camera.recording) {
            [self onCapture:nil];
        }
        
        fCurrentTime = 0;
        
        [recordingTimer invalidate];
        recordingTimer = nil;
        
        _constraintTimeProgressRight.constant = screenSize.width;
        return;
    }
    
    _constraintTimeProgressRight.constant = screenSize.width - (screenSize.width / nMaxVideoLength) * fCurrentTime;
}

- (IBAction)onSetting:(id)sender {
    
    if(self.camera.recording)
        return;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE]) {
        NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
        if([strType isEqualToString:STANDARDPHOTO]) {
           
        } else if([strType isEqualToString:GREENSCREENPHOTO]) {
            [UIView animateWithDuration:0.3f animations:^{
                _constraintChromakeySettingViewBottom.constant = 0;
                [self.viewChromakeySetting layoutIfNeeded];
            }];
        } else if([strType isEqualToString:VIDEO]) {
            [UIView animateWithDuration:0.3f animations:^{
                _constraintVideoSettingViewBottom.constant = 0;
                [self.viewVideoSetting layoutIfNeeded];
            }];
        } else if([strType isEqualToString:ANIMATEDGIF]) {
            [UIView animateWithDuration:0.3f animations:^{
                _constraintAnimatedGifSettingViewBottom.constant = 0;
                [self.viewAnimatedGifSetting layoutIfNeeded];
            }];
        }
    } else {
        
        [[NSUserDefaults standardUserDefaults] setObject:STANDARDPHOTO forKey:PHOTOTYPE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (IBAction)onSetStandardPhoto:(id)sender {
    _imgStandardPhoto.image     = [UIImage imageNamed:@"btn_check"];
    _imgGreenScreenPhoto.image  = [UIImage imageNamed:@"btn_uncheck"];
    _imgVideo.image             = [UIImage imageNamed:@"btn_uncheck"];
    _imgAnimatedGif.image       = [UIImage imageNamed:@"btn_uncheck"];
    
    [[NSUserDefaults standardUserDefaults] setObject:STANDARDPHOTO forKey:PHOTOTYPE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[Utility sharedUtility] setImageURLWithAsync:[arrOverlays[0] objectForKey:@"filename"] displayImgView:_imgOverlay placeholder:@""];
    [self checkSelectOverlayButton];
    
    [self onImageTypeCancel:nil];
}

- (IBAction)onSetGreenScreenPhoto:(id)sender {
    _imgStandardPhoto.image     = [UIImage imageNamed:@"btn_uncheck"];
    _imgGreenScreenPhoto.image  = [UIImage imageNamed:@"btn_check"];
    _imgVideo.image             = [UIImage imageNamed:@"btn_uncheck"];
    _imgAnimatedGif.image       = [UIImage imageNamed:@"btn_uncheck"];
    
    [[NSUserDefaults standardUserDefaults] setObject:GREENSCREENPHOTO forKey:PHOTOTYPE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _imgOverlay.image = nil;
    [self checkSelectOverlayButton];
    
    [self onImageTypeCancel:nil];
}

- (IBAction)onSetVideo:(id)sender {
    _imgStandardPhoto.image     = [UIImage imageNamed:@"btn_uncheck"];
    _imgGreenScreenPhoto.image  = [UIImage imageNamed:@"btn_uncheck"];
    _imgVideo.image             = [UIImage imageNamed:@"btn_check"];
    _imgAnimatedGif.image       = [UIImage imageNamed:@"btn_uncheck"];
    
    [[NSUserDefaults standardUserDefaults] setObject:VIDEO forKey:PHOTOTYPE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[Utility sharedUtility] setImageURLWithAsync:[arrOverlays[0] objectForKey:@"filename"] displayImgView:_imgOverlay placeholder:@""];
    [self checkSelectOverlayButton];
    
    [self onImageTypeCancel:nil];
}

- (IBAction)onAnimatedGif:(id)sender {
    _imgStandardPhoto.image     = [UIImage imageNamed:@"btn_uncheck"];
    _imgGreenScreenPhoto.image  = [UIImage imageNamed:@"btn_uncheck"];
    _imgVideo.image             = [UIImage imageNamed:@"btn_uncheck"];
    _imgAnimatedGif.image       = [UIImage imageNamed:@"btn_check"];
    
    [[NSUserDefaults standardUserDefaults] setObject:ANIMATEDGIF forKey:PHOTOTYPE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[Utility sharedUtility] setImageURLWithAsync:[arrOverlays[0] objectForKey:@"filename"] displayImgView:_imgOverlay placeholder:@""];
    [self checkSelectOverlayButton];
    
    [self onImageTypeCancel:nil];
}

- (IBAction)onCancel:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        _constraintChromakeySettingViewBottom.constant = -240;
        [self.viewChromakeySetting layoutIfNeeded];
    }];
}

- (IBAction)onImageTypeCancel:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^{
        _constraintMediaTypeSettingViewBottom.constant = -200;
        [self.viewMediaTypeSetting layoutIfNeeded];
    }];
}

- (IBAction)onChangeVideoLength:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(self.sldVideoRecordTime.value) forKey:DEFAULT_VIDEOLENGTH];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.lblRecordTime.text = [NSString stringWithFormat:@"Record Time : %2.f s", self.sldVideoRecordTime.value];
}

- (IBAction)onChangeAnimatedGifPhotoCount:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(self.sldAnimatedGifCount.value) forKey:DEFAULT_ANIMATEDPHOTOCOUNT];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.lblNumberofPhotos.text = [NSString stringWithFormat:@"Number of Photos : %2.f", self.sldAnimatedGifCount.value];
}

- (IBAction)onVideoSettingCancel:(id)sender {
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        _constraintVideoSettingViewBottom.constant = -200;
        [self.viewVideoSetting layoutIfNeeded];
    }];
}

- (IBAction)onAnimatedGifSettingCancel:(id)sender {
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        _constraintAnimatedGifSettingViewBottom.constant = -200;
        [self.viewAnimatedGifSetting layoutIfNeeded];
    }];
}
- (IBAction)gotoLogoutScreen:(id)sender {
    SettingViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onSelectOverlay:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        _constraintSelectOverlayViewRight.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)onCloseSelectOverlayView:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        _constraintSelectOverlayViewRight.constant = -200;
        [self.view layoutIfNeeded];
    }];
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}
/*
- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return (UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight);
}
*/

- (void) gotoShareVC:(MBProgressHUD *)hud {
    [hud hideAnimated:YES];
    
    ShareViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITextFieldDelegate Method
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma  mark - Add Overlay to video
- (void) addOverlayImageToVideo {
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Processing Video...";
    
    NSURL *originVideoURL = [[[self applicationDocumentsDirectory]
                         URLByAppendingPathComponent:@"test"] URLByAppendingPathExtension:@"mov"];
    self.videoAsset = [AVAsset assetWithURL:originVideoURL];
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    // 3 - Video track
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.videoAsset.duration)
                        ofTrack:[[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                         atTime:kCMTimeZero error:nil];
    
    // 3.1 - Create AVMutableVideoCompositionInstruction
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.videoAsset.duration);
    
    // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    AVAssetTrack *videoAssetTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    BOOL isVideoAssetPortrait_  = NO;
    
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ =  UIImageOrientationLeft;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ =  UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
    }
    
    float fVideoScaleX = DEFAULT_MEDIA_WIDTH / videoAssetTrack.naturalSize.width;
    float fVideoScaleY = DEFAULT_MEDIA_HEIGHT / videoAssetTrack.naturalSize.height;
    
    if (screenSize.height > screenSize.width) {
        fVideoScaleX = DEFAULT_MEDIA_HEIGHT / videoAssetTrack.naturalSize.width;
        fVideoScaleY = DEFAULT_MEDIA_WIDTH / videoAssetTrack.naturalSize.height;
    }
    
    CGAffineTransform videoScale = CGAffineTransformMakeScale(fVideoScaleX, fVideoScaleY);
    [videolayerInstruction setTransform:videoScale atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:self.videoAsset.duration];
    
    // 3.3 - Add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction, nil];
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    CGSize naturalSize;
    if(isVideoAssetPortrait_){
        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    } else {
        naturalSize = videoAssetTrack.naturalSize;
    }
    
    float renderWidth, renderHeight;
    renderWidth = DEFAULT_MEDIA_WIDTH;
    renderHeight = DEFAULT_MEDIA_HEIGHT;
    
    if (screenSize.height > screenSize.width) {
        renderWidth = DEFAULT_MEDIA_HEIGHT;
        renderHeight = DEFAULT_MEDIA_WIDTH;
    }
    
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    
    if (screenSize.width > screenSize.height) {
        [self applyVideoEffectsToComposition:mainCompositionInst size:CGSizeMake(DEFAULT_MEDIA_WIDTH, DEFAULT_MEDIA_HEIGHT)];
    } else {
        [self applyVideoEffectsToComposition:mainCompositionInst size:CGSizeMake(DEFAULT_MEDIA_HEIGHT, DEFAULT_MEDIA_WIDTH)];
    }
    
    
    // 4 - Get path
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
    
    [APIManager sharedInstance].m_tmpMediaPath = [NSString stringWithFormat:@"final-%@", [formatter stringFromDate:[NSDate date]]];
    NSURL *outputURL = [[[self applicationDocumentsDirectory]
                         URLByAppendingPathComponent:[APIManager sharedInstance].m_tmpMediaPath] URLByAppendingPathExtension:@"mp4"];
//    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:NULL];
    
    // 5 - Create exporter
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = outputURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIImage *image = [[UIImage imageNamed:@"btn_done"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            hud.customView = imageView;
            hud.mode = MBProgressHUDModeCustomView;
            hud.label.text = @"Completed";
            
            [self performSelector:@selector(gotoShareVC:) withObject:hud afterDelay:2];
        });
    }];
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    CALayer *overlayLayer = [CALayer layer];
    UIImage *overlayImage = self.imgOverlay.image; //[self chromaTheImage:self.imgOverlay.image];
    
    [overlayLayer setContents:(id)[overlayImage CGImage]];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    
    // 2 - set up the parent layer
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            [videoLayer setTransform:CATransform3DMakeRotation(-M_PI/2, 0, 0, 1)];
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            [videoLayer setTransform:CATransform3DMakeRotation(M_PI/2, 0, 0, 1)];
            break;
        case UIDeviceOrientationLandscapeLeft:
            break;
        case UIDeviceOrientationLandscapeRight:
            [videoLayer setTransform:CATransform3DMakeRotation(M_PI, 0, 0, 1)];
            break;
        default:
            break;
    }
    
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    // 3 - apply magic
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

-(BOOL) isLandscape {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (screenSize.height > screenSize.width) {
        return NO;
    }
    return YES;
}

#pragma mark - tableview datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return arrOverlays.count;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectOverlayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectOverlayTableViewCell" forIndexPath:indexPath];
    
    NSInteger row = [indexPath row];
    NSURL *url = [NSURL URLWithString:[arrOverlays[row] objectForKey:@"filename"]];
    NSData *imgData = [NSData dataWithContentsOfURL:url];
    
    UIImage *img = [UIImage imageWithData:imgData];
    cell.imgOverlay.image = img;
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    
    NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
    if ([strType isEqualToString:GREENSCREENPHOTO]) {
        _imgOverlay.image = nil;
    } else {
        [[Utility sharedUtility] setImageURLWithAsync:[arrOverlays[row] objectForKey:@"filename"] displayImgView:_imgOverlay placeholder:@""];
    }
    
}

@end
