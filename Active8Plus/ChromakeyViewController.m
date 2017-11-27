//
//  ChromakeyViewController.m
//  Active8Plus
//
//  Created by forever on 7/9/17.
//  Copyright © 2017 forever. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ChromakeyViewController.h"
#import "ShareViewController.h"
#import "ChromakeyCollectionViewCell.h"
#import "TouchImageView.h"
#import "APIManager.h"
#import <MBProgressHUD.h>
#import "Utility.h"
#import "HJImagesToVideo.h"
#import <MBProgressHUD.h>

@interface ChromakeyViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    TouchImageView  *img_Sticker;
//    NSMutableArray  *aryBackground;
    NSMutableArray  *aryMergedPhotos;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *imgBG;
@property (weak, nonatomic) IBOutlet UIView *viewMerge;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewOverlay;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mergeViewHeight;

@end

@implementation ChromakeyViewController
@synthesize arrBackground;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrBackground   = [[NSArray alloc] init];
    aryMergedPhotos = [[NSMutableArray alloc] init];
    
}

//- (void) viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    
//    [self initUI];
//}

-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self initUI];
}

- (void) initUI {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    float mergeViewWidth = screenSize.width * 600 / 1024.0f;
    if (screenSize.width > screenSize.height) {
        self.mergeViewHeight.constant = mergeViewWidth * 2 / 3.0f;
    } else {
        self.mergeViewHeight.constant = mergeViewWidth * 3 / 2.0f;
    }
    
    [self.view layoutIfNeeded];
    
    self.imageViewOverlay.image = self.imgOverlay;
    self.imageViewOverlay.userInteractionEnabled = NO;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE]) {
        NSString *strType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];
        if([strType isEqualToString:ANIMATEDGIF]) {
            self.imgChromakey = [self.aryCapturedPhoto objectAtIndex:0];
        }
    }
    
    if(img_Sticker != nil) {
        [img_Sticker removeFromSuperview];
        img_Sticker = nil;
    }
    
//    int leftTopX    = (self.viewMerge.frame.size.width  - self.imgChromakey.size.width  / 4) / 2;
//    int leftTopY    = (self.viewMerge.frame.size.height - self.imgChromakey.size.height / 4) / 2;
    
//    img_Sticker     = [[TouchImageView alloc]initWithFrame:CGRectMake(leftTopX, leftTopY, self.imgChromakey.size.width / 4, self.imgChromakey.size.height / 4)];

    img_Sticker     = [[TouchImageView alloc]initWithFrame:CGRectMake(0, 0, self.viewMerge.frame.size.width, self.viewMerge.frame.size.height)];
    
    [img_Sticker setUIImage:self.imgChromakey];
    img_Sticker.tag = 100;
    
    [self.viewMerge insertSubview:img_Sticker aboveSubview:self.imgBG];
 
    if(arrBackground.count> 0)
        return;
    
    [[APIManager sharedInstance] getBackgroundImage:^(id _response) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(_response) {
            if([[_response objectForKey:@"status"] isEqualToString:@"success"]) {
                
                arrBackground = [_response objectForKey:@"data"];
                
                if (arrBackground.count > 0) {
                    NSString *background = [[arrBackground objectAtIndex:0] valueForKey:@"h_background"];
                    NSString *overlayUrl = [[arrBackground objectAtIndex:0] valueForKey:@"h_overlay"];
                    
                    if (![self isLandscape]) {
                        background = [[arrBackground objectAtIndex:0] valueForKey:@"v_background"];
                        overlayUrl = [[arrBackground objectAtIndex:0] valueForKey:@"v_overlay"];
                    }
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:overlayUrl]];
                    self.imgOverlay = [UIImage imageWithData:imgData];
                    self.imageViewOverlay.image = self.imgOverlay;
                    
                    [[Utility sharedUtility] setImageURLWithAsync:background displayImgView:_imgBG placeholder:@""];
                    self.imageViewOverlay.image = self.imgOverlay;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_collectionView reloadData];
                });
                
            } else {
                [[Utility sharedUtility] showAlertMessage:self title:@"" message:@"Invalid Campaign."];
            }
        }
    } failure:^(id _failure) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[Utility sharedUtility] showAlertMessage:self title:@"" message:@"Please try again."];
    }];

}

-(BOOL) isLandscape {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (screenSize.height > screenSize.width) {
        return NO;
    }
    return YES;
}

- (IBAction)onNext:(id)sender {
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE]) {
        NSString *strPhotoType = [[NSUserDefaults standardUserDefaults] objectForKey:PHOTOTYPE];

        if([strPhotoType isEqualToString:GREENSCREENPHOTO]) {
            [img_Sticker removeFromSuperview];
            
            UIImage *imgMergedBGAndChromakey = [self mergeImages:self.imgChromakey];
            UIImage *imgfinal = [[Utility sharedUtility] mergeImages:imgMergedBGAndChromakey overlayImage:self.imgOverlay];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
            
            [APIManager sharedInstance].m_tmpMediaPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:
                                                          [NSString stringWithFormat:@"greenimage-%@.jpg", [formatter stringFromDate:[NSDate date]]]];
            
//            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"greenimage.jpg"];
            
//            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
            
            NSData *data = UIImageJPEGRepresentation(imgfinal, 1.0);
            [data writeToFile:[APIManager sharedInstance].m_tmpMediaPath atomically:YES];
            
            ShareViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
            vc.imgShare = imgfinal;
            vc.strFilePath = [APIManager sharedInstance].m_tmpMediaPath;
            
            [self.navigationController pushViewController:vc animated:YES];
        } else if([strPhotoType isEqualToString:ANIMATEDGIF]) {
            [self makeGifFile];
            [self gotoShareViewController];
        }
    }
}

- (IBAction)onRetake:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *) mergeImages:(UIImage *)chromakeyImage  {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGFloat radians = atan2f(img_Sticker.originalTransform.b, img_Sticker.originalTransform.a);
    CGFloat degrees = radians * (180 / M_PI);
    
    UIImage *bottomImage = [[UIImage alloc] initWithCGImage:_imgBG.image.CGImage]; //background image
    UIImage *image       = [self imageRotatedByDegrees:chromakeyImage deg:degrees]; //foreground image
    
    [UIImage imageWithCGImage:chromakeyImage.CGImage];
    
    CGSize newSize = CGSizeMake(DEFAULT_MEDIA_WIDTH, DEFAULT_MEDIA_HEIGHT);
    if (screenSize.height > screenSize.width) {
        newSize = CGSizeMake(DEFAULT_MEDIA_HEIGHT, DEFAULT_MEDIA_WIDTH);
    }
    UIGraphicsBeginImageContext(newSize);
    
    
    
    if (screenSize.width > screenSize.height) {
        // Use existing opacity as is
        [bottomImage drawInRect:CGRectMake(0,0,DEFAULT_MEDIA_WIDTH,DEFAULT_MEDIA_HEIGHT)];
        
        // Apply supplied opacity if applicable
        // Change xPos, yPos if applicable
        [image drawInRect:CGRectMake(img_Sticker.frame.origin.x * (DEFAULT_MEDIA_WIDTH / self.viewMerge.frame.size.width),
                                     img_Sticker.frame.origin.y * (DEFAULT_MEDIA_HEIGHT / self.viewMerge.frame.size.height),
                                     img_Sticker.frame.size.width * (DEFAULT_MEDIA_WIDTH / self.viewMerge.frame.size.width),
                                     img_Sticker.frame.size.height * (DEFAULT_MEDIA_HEIGHT / self.viewMerge.frame.size.height))
                blendMode:kCGBlendModeNormal alpha:1.0];
        
        
    } else {
        [bottomImage drawInRect:CGRectMake(0,0, DEFAULT_MEDIA_HEIGHT, DEFAULT_MEDIA_WIDTH)];
        [image drawInRect:CGRectMake(img_Sticker.frame.origin.x * (DEFAULT_MEDIA_HEIGHT / self.viewMerge.frame.size.width),
                                     img_Sticker.frame.origin.y * (DEFAULT_MEDIA_WIDTH / self.viewMerge.frame.size.height),
                                     img_Sticker.frame.size.width * (DEFAULT_MEDIA_HEIGHT / self.viewMerge.frame.size.width),
                                     img_Sticker.frame.size.height * (DEFAULT_MEDIA_WIDTH / self.viewMerge.frame.size.height))
                blendMode:kCGBlendModeNormal alpha:1.0];
    }
    
    
    
    
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees{
    //Calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    //Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    //Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//make gif file
- (void) makeGifFile {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Proccessing...";
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_hhmmss"];
    
    [APIManager sharedInstance].m_tmpMediaPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:
                                                  [NSString stringWithFormat:@"animated-%@.gif", [formatter stringFromDate:[NSDate date]]]];
    
//    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"animated.gif"];
    [aryMergedPhotos removeAllObjects];
//    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    
    for (int i = 0; i < self.aryCapturedPhoto.count; i ++) {
        UIImage *mergedImage = [self mergeImages:[self.aryCapturedPhoto objectAtIndex:i]];
        UIImage *imgFinal = [[Utility sharedUtility] mergeImages:mergedImage overlayImage:self.imgOverlay];
        [aryMergedPhotos addObject:imgFinal];
    }
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:[APIManager sharedInstance].m_tmpMediaPath],
                                                                        kUTTypeGIF,
                                                                        [aryMergedPhotos count],
                                                                        NULL);
    
    NSDictionary *frameProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.2] forKey:(NSString *)kCGImagePropertyGIFDelayTime]
                                                                forKey:(NSString *)kCGImagePropertyGIFDictionary];
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount]
                                                              forKey:(NSString *)kCGImagePropertyGIFDictionary];

    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)gifProperties);
    
    for (int i = 0; i < aryMergedPhotos.count; i ++) {
        UIImage *image = [aryMergedPhotos objectAtIndex:i];
        CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
    }

    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    NSLog(@"animated GIF file created at %@", [APIManager sharedInstance].m_tmpMediaPath);
    
    [hud hideAnimated:YES afterDelay:1.f];
}

- (void) gotoShareViewController {
    ShareViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
    vc.strFilePath = [APIManager sharedInstance].m_tmpMediaPath;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UICollectionViewDelegate Method
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChromakeyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ChromakeyCollectionViewCell" forIndexPath:indexPath];
    
    NSString *background = [[arrBackground objectAtIndex:indexPath.row] valueForKey:@"h_background"];
    
    if (![self isLandscape]) {
        background = [[arrBackground objectAtIndex:indexPath.row] valueForKey:@"v_background"];
    }
    
    [[Utility sharedUtility] setImageURLWithAsync:background displayImgView:cell.imgCell placeholder:@""];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *background = [[arrBackground objectAtIndex:indexPath.row] valueForKey:@"h_background"];
    NSString *overlay = [[arrBackground objectAtIndex:indexPath.row] valueForKey:@"h_overlay"];
    if (![self isLandscape]) {
        background = [[arrBackground objectAtIndex:indexPath.row] valueForKey:@"v_background"];
        overlay = [[arrBackground objectAtIndex:indexPath.row] valueForKey:@"v_overlay"];
    }
    
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:overlay]];
    self.imgOverlay = [UIImage imageWithData:imgData];
    self.imageViewOverlay.image = self.imgOverlay;
    
    [[Utility sharedUtility] setImageURLWithAsync:background displayImgView:_imgBG placeholder:@""];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return arrBackground.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
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
