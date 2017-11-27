//
//  APIManager.h
//  Active8Plus
//
//  Created by forever on 7/8/17.
//  Copyright © 2017 forever. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utility.h"

#define PHOTOTYPE           @"PHOTO_TYPE"
#define STANDARDPHOTO       @"StandardPhoto"
#define GREENSCREENPHOTO    @"GreenScreenPhoto"
#define VIDEO               @"Video"
#define ANIMATEDGIF         @"AnimatedGif"

#define KEY_UPLOAD          @"uploaded_files"
#define KEY_PRINT           @"printed_files"
#define KEY_SETTINGS        @"app_settings"

#define UPLOADING_START_NOTIFICATION                        @"UPLOADING_START_NOTIFICATION"
#define UPLOADING_FAIL_NOTIFICATION                         @"UPLOADING_FAIL_NOTIFICATION"
#define UPLOADING_SUCCESS_NOTIFICATION                       @"UPLOADING_SUCCESS_NOTIFICATION"

#define PRINTING_START_NOTIFICATION             @"PRINTING_START_NOTIFICATION"
#define PRINTING_SUCCESS_NOTIFICATION               @"PRINTING_SUCCESS_NOTIFICATION"
#define PRINTING_FAIL_NOTIFICATION              @"PRINTING_FAIL_NOTIFICATION"


typedef enum {
    FORIGINPHOTO = 0,
    FGREENPHOTO,
    FANIMATEDGIF,
    FVIDEO
} FILE_TYPE;

@interface APIManager : NSObject

@property dispatch_group_t group;
@property dispatch_group_t group1;

//@property (strong, nonatomic) NSMutableDictionary                   *m_fileHistory;
@property (strong, nonatomic) NSMutableDictionary                   *m_fileQueue;
@property (strong, nonatomic) NSString                              *m_tmpMediaPath;

+ (instancetype) sharedInstance;

- (void) LoginWithCapaign:(NSString*)strCampaign
                successed:(void (^)(id))_success
                  failure:(void (^)(id))_failure;

- (void) getBackgroundImage:(void (^)(id))_success
                    failure:(void (^)(id))_failure;

- (void) getOverlay:(void (^)(id))_success
            failure:(void (^)(id))_failure;

- (void) uploadMedia:(NSString*)_fileName
            fileType:(FILE_TYPE)_fileType
          userEmails:(NSArray*)aryEmails
          userPhones:(NSArray*)aryPhoneNumbers
           successed:(void (^)(id))_success
             failure:(void (^)(id))_failure;

- (void) uploadFileToAmazon:(NSURL*)filePath
                contentType:(NSString*)contentType
                   fileName:(NSString *)strFileName
                  successed:(void (^)(id))_success
                    failure:(void (^)(id))_failure;


- (void) saveSettings;
- (void) loadSettings;

- (void) uploadMediaToAmazonAndBackend:(NSURL *)filePath
                           contentType:(NSString *)contentType
                              fileType:(FILE_TYPE)_fileType
                              filename:(NSString *)strFileName
                            userEmails:(NSArray *)aryEmails
                            userPhones:(NSArray *)aryNumbers
                             successed:(void (^)(id))_success
                               failure:(void (^)(id))_failure;
@end
