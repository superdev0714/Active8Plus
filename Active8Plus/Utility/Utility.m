//
//  Utility.m
//  Active8Plus
//
//  Created by forever on 5/13/17.
//  Copyright © 2017 forever. All rights reserved.
//

#import "Utility.h"
#import <UIImageView+AFNetworking.h>

@implementation Utility

+ (Utility *)sharedUtility
{
    __strong static Utility *sharedObject = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedObject = [[Utility alloc] init];
        
    });
    
    return sharedObject;
}

- (id)init
{
    if (self = [super init])
    {
    }
    return self;
}

- (BOOL)validateEmail:(NSString *)inputText {
    NSString *emailRegex = @"[A-Z0-9a-z][A-Z0-9a-z._%+-]*@[A-Za-z0-9][A-Za-z0-9.-]*\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    NSRange aRange;
    if([emailTest evaluateWithObject:inputText]) {
        aRange = [inputText rangeOfString:@"." options:NSBackwardsSearch range:NSMakeRange(0, [inputText length])];
        int indexOfDot = (int)aRange.location;
        
        if(aRange.location != NSNotFound) {
            NSString *topLevelDomain = [inputText substringFromIndex:indexOfDot];
            topLevelDomain = [topLevelDomain lowercaseString];
            
            NSSet *TLD;
            TLD = [NSSet setWithObjects:@".aero", @".asia", @".biz", @".cat", @".com", @".coop", @".edu", @".gov", @".info", @".int", @".jobs", @".mil", @".mobi", @".museum", @".name", @".net", @".org", @".pro", @".tel", @".travel", @".ac", @".ad", @".ae", @".af", @".ag", @".ai", @".al", @".am", @".an", @".ao", @".aq", @".ar", @".as", @".at", @".au", @".aw", @".ax", @".az", @".ba", @".bb", @".bd", @".be", @".bf", @".bg", @".bh", @".bi", @".bj", @".bm", @".bn", @".bo", @".br", @".bs", @".bt", @".bv", @".bw", @".by", @".bz", @".ca", @".cc", @".cd", @".cf", @".cg", @".ch", @".ci", @".ck", @".cl", @".cm", @".cn", @".co", @".cr", @".cu", @".cv", @".cx", @".cy", @".cz", @".de", @".dj", @".dk", @".dm", @".do", @".dz", @".ec", @".ee", @".eg", @".er", @".es", @".et", @".eu", @".fi", @".fj", @".fk", @".fm", @".fo", @".fr", @".ga", @".gb", @".gd", @".ge", @".gf", @".gg", @".gh", @".gi", @".gl", @".gm", @".gn", @".gp", @".gq", @".gr", @".gs", @".gt", @".gu", @".gw", @".gy", @".hk", @".hm", @".hn", @".hr", @".ht", @".hu", @".id", @".ie", @" No", @".il", @".im", @".in", @".io", @".iq", @".ir", @".is", @".it", @".je", @".jm", @".jo", @".jp", @".ke", @".kg", @".kh", @".ki", @".km", @".kn", @".kp", @".kr", @".kw", @".ky", @".kz", @".la", @".lb", @".lc", @".li", @".lk", @".lr", @".ls", @".lt", @".lu", @".lv", @".ly", @".ma", @".mc", @".md", @".me", @".mg", @".mh", @".mk", @".ml", @".mm", @".mn", @".mo", @".mp", @".mq", @".mr", @".ms", @".mt", @".mu", @".mv", @".mw", @".mx", @".my", @".mz", @".na", @".nc", @".ne", @".nf", @".ng", @".ni", @".nl", @".no", @".np", @".nr", @".nu", @".nz", @".om", @".pa", @".pe", @".pf", @".pg", @".ph", @".pk", @".pl", @".pm", @".pn", @".pr", @".ps", @".pt", @".pw", @".py", @".qa", @".re", @".ro", @".rs", @".ru", @".rw", @".sa", @".sb", @".sc", @".sd", @".se", @".sg", @".sh", @".si", @".sj", @".sk", @".sl", @".sm", @".sn", @".so", @".sr", @".st", @".su", @".sv", @".sy", @".sz", @".tc", @".td", @".tf", @".tg", @".th", @".tj", @".tk", @".tl", @".tm", @".tn", @".to", @".tp", @".tr", @".tt", @".tv", @".tw", @".tz", @".ua", @".ug", @".uk", @".us", @".uy", @".uz", @".va", @".vc", @".ve", @".vg", @".vi", @".vn", @".vu", @".wf", @".ws", @".ye", @".yt", @".za", @".zm", @".zw", nil];
            if(topLevelDomain != nil && ([TLD containsObject:topLevelDomain])) {
                return YES;
            }
            
        }
    }
    return NO;
}

- (BOOL)validatePhone:(NSString *)phoneNumber
{
    NSString *phoneRegex = @"[0-9]{10}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:phoneNumber];
}

- (UIImage *) getThumbnail:(NSString*) strPath {
    
    AVAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:strPath]];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime duration = asset.duration;
    CGFloat durationInSeconds = duration.value / duration.timescale;
    CMTime time = CMTimeMakeWithSeconds(durationInSeconds * 1, (int)duration.value);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    UIImage * portraitImage;
    if(thumbnail.size.width > thumbnail.size.height) {
       portraitImage = [[UIImage alloc] initWithCGImage: thumbnail.CGImage
                                                             scale: 1.0
                                                       orientation: UIImageOrientationRight];
        return portraitImage;
    }
    
    return thumbnail;
}

#pragma mark - Merge Images
- (UIImage *) mergeImages:(UIImage *)chromakeyImage overlayImage:(UIImage*) imgOverlay  {
    UIImage *bottomImage = [[UIImage alloc] initWithCGImage:imgOverlay.CGImage]; //background image
    UIImage *image       = [[UIImage alloc] initWithCGImage:chromakeyImage.CGImage]; //foreground image
    
    [UIImage imageWithCGImage:chromakeyImage.CGImage];
    
   
    CGSize newSize = CGSizeMake(imgOverlay.size.width, imgOverlay.size.height);
    
    UIGraphicsBeginImageContext(newSize);
    

    [image drawInRect:CGRectMake(0, 0 , newSize.width, newSize.height)];
    [bottomImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)resizeImage:(UIImage *)image {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGSize newSize = CGSizeMake(DEFAULT_MEDIA_WIDTH, DEFAULT_MEDIA_HEIGHT);
    
    if (screenSize.width < screenSize.height) {
        newSize = CGSizeMake(DEFAULT_MEDIA_HEIGHT, DEFAULT_MEDIA_WIDTH);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Download image to UIImageView
- (void)setImageURLWithAsync:(NSString *)_urlStr
              displayImgView:(UIImageView *)_displayImgView
                 placeholder:(NSString *)_placeholder
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_urlStr]];
//    UIActivityIndicatorView *activities = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    [activities setBackgroundColor:[UIColor clearColor]];
//    activities.center = _displayImgView.center;
//    [_displayImgView addSubview:activities];
//    [activities setHidesWhenStopped:YES];
//    [activities startAnimating];
    
    __block UIImageView *_feedImgView = _displayImgView;
    
    [_displayImgView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//        [activities stopAnimating];
        
        
        [_feedImgView setImage:image];
//        [activities removeFromSuperview];
        NSLog(@"_displayImgView  setImageWithURLRequest assadfsad");
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {

        NSLog(@"setImageWithURLRequest : Error :  %@", error.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^{
//            [activities stopAnimating];
//            [activities removeFromSuperview];
        });
    }];
    
}

- (void) showAlertMessage:(UIViewController*)viewController title:(NSString*)title message:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:okButton];
    [viewController presentViewController:alertController animated:YES completion:nil];
}

@end
