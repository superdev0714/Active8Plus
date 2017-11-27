//
//  Utility.h
//  Active8Plus
//
//  Created by forever on 5/13/17.
//  Copyright © 2017 forever. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define DEFAULT_MEDIA_WIDTH 1080
#define DEFAULT_MEDIA_HEIGHT 720

@interface Utility : NSObject

+ (Utility *)sharedUtility;

- (BOOL)validateEmail:(NSString *)inputText;
- (BOOL)validatePhone:(NSString *)phoneNumber;

- (UIImage *)resizeImage:(UIImage *)image;
- (UIImage *)mergeImages:(UIImage *)chromakeyImage overlayImage:(UIImage*) imgOverlay;
- (UIImage *)getThumbnail:(NSString*) strPath;

- (void)setImageURLWithAsync:(NSString *)_urlStr
              displayImgView:(UIImageView *)_displayImgView
                 placeholder:(NSString *)_placeholder;
- (void) showAlertMessage:(UIViewController*)viewController title:(NSString*)title message:(NSString*)message;

@end
