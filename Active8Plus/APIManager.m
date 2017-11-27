//
//  APIManager.m
//  Active8Plus
//
//  Created by forever on 7/8/17.
//  Copyright © 2017 forever. All rights reserved.
//

#import "APIManager.h"
#import <MBProgressHUD.h>
#import "AFNetworking.h"
#import <AWSS3/AWSS3.h>

static const NSString *baseURLString = @"https://api.goactiv8plus.com/";

#define API_LOGIN           @"doCampaign"
#define API_GETBACKGROUND   @"getGSGraphics"
#define API_UPLOADMEDIA     @"uploadMedia"
#define API_GETOVERLAY      @"getOverlay"

@interface APIManager ()

- (void)sendToService:(NSDictionary *)_params
               suffix:(NSString*)_suffix
              success:(void (^)(id))_success
              failure:(void (^)(id))_failure;

- (void)sendToService:(NSDictionary *)_params
             fileType:(FILE_TYPE) _type
               suffix:(NSString*)_suffix
              success:(void (^)(id))_success
              failure:(void (^)(id))_failure;

@end

@implementation APIManager

static APIManager *sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t DDASLLoggerOnceToken;
    dispatch_once(&DDASLLoggerOnceToken, ^{
        sharedInstance = [[[self class] alloc] init];
        sharedInstance.m_fileQueue = [NSMutableDictionary new];
//        sharedInstance.m_fileHistory = [NSMutableDictionary new];
    });
    return sharedInstance;
}

- (void)sendToService:(NSDictionary *)_params
               suffix:(NSString*)_suffix
              success:(void (^)(id))_success
              failure:(void (^)(id))_failure{
    
    NSURL     *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseURLString, _suffix]];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_params
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString;
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url.absoluteString parameters:nil error:nil];
    
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
            if (!error) {
            NSLog(@"Reply JSON: %@", responseObject);
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                
                _success(responseObject);
            }
        } else {
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            _failure(responseObject);
        }
    }] resume];
}

- (void)sendToService:(NSDictionary *)_params
             fileType:(FILE_TYPE) _type
               suffix:(NSString*)_suffix
              success:(void (^)(id))_success
              failure:(void (^)(id))_failure{
    
    NSURL     *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseURLString, _suffix]];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_params
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString;
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url.absoluteString parameters:_params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        /*
        NSString *strMimeType = @"image/jpeg";
        
        if(_type == FVIDEO) {
            //Video file
            NSString *fileExtention = [[_params objectForKey:@"filename"] pathExtension];
            
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
        } else if(_type == FORIGINPHOTO) {
            strMimeType = @"image/jpeg";
        } else if(_type == FGREENPHOTO) {
            strMimeType = @"image/jpeg";
        } else if(_type == FANIMATEDGIF) {
            strMimeType = @"image/gif";
        }
        
        [formData appendPartWithFileData:_attachedFile name:@"file" fileName:[_params objectForKey:@"filename"] mimeType:strMimeType];*/
        
    } error:nil];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            NSLog(@"Reply JSON: %@", responseObject);
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                
                _success(responseObject);
            }
        } else {
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            _failure(responseObject);
        }
    }] resume];
}

- (void) LoginWithCapaign:(NSString*)strCampaign
                successed:(void (^)(id))_success
                  failure:(void (^)(id))_failure
{
    NSDictionary *param = @{@"ccode": strCampaign};
    [self sendToService:param suffix:API_LOGIN success:_success failure:_failure];
}

- (void) getBackgroundImage:(void (^)(id))_success
                    failure:(void (^)(id))_failure
{
    NSDictionary *param = @{@"eid": [[NSUserDefaults standardUserDefaults] objectForKey:@"EID"]};
    
    [self sendToService:param suffix:API_GETBACKGROUND success:_success failure:_failure];
}

- (void) getOverlay:(void (^)(id))_success
            failure:(void (^)(id))_failure {
    NSDictionary *param = @{@"eid": [[NSUserDefaults standardUserDefaults] objectForKey:@"EID"]};
    
    [self sendToService:param suffix:API_GETOVERLAY success:_success failure:_failure];
}

- (void) uploadMedia:(NSString*)_fileName
            fileType:(FILE_TYPE)_fileType
          userEmails:(NSArray*)aryEmails
          userPhones:(NSArray*)aryPhoneNumbers
           successed:(void (^)(id))_success
             failure:(void (^)(id))_failure {
    NSString *fType = @"photo";
    
    if(_fileType == FVIDEO) {
        fType = @"video";
    }
    NSDictionary *param = @{@"eid":[[NSUserDefaults standardUserDefaults] objectForKey:@"EID"],
                            @"filename": _fileName,
                            @"filetype": fType,
                            @"email": aryEmails,
                            @"sms": aryPhoneNumbers};
    [self sendToService:param fileType:_fileType suffix:API_UPLOADMEDIA success:_success failure:_failure];
}

- (void) uploadFileToAmazon:(NSURL*)filePath
                contentType:(NSString*)contentType
                   fileName:(NSString *)strFileName
                  successed:(void (^)(id))_success
                    failure:(void (^)(id))_failure {
    
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc]initWithAccessKey:@"AKIAIXWGQHC6WUJ7IXAQ" secretKey:@"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"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc]initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    [AWSS3TransferManager registerS3TransferManagerWithConfiguration:configuration forKey:@"USWest2S3TransferManager"];
    AWSS3TransferManager * transferManager = [AWSS3TransferManager S3TransferManagerForKey:@"USWest2S3TransferManager"];
    
//    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    
    uploadRequest.bucket = @"ssdatahd";
    uploadRequest.key = [NSString stringWithFormat:@"customer_uploads/%@/%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"EID"], strFileName];
    uploadRequest.body = filePath;
    uploadRequest.contentType = contentType;
    uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
    
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                       withBlock:^id(AWSTask *task) {
                                                           if (task.error) {
                                                               if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                   switch (task.error.code) {
                                                                       case AWSS3TransferManagerErrorCancelled:
                                                                       case AWSS3TransferManagerErrorPaused:
                                                                           break;
                                                                           
                                                                       default:
                                                                           NSLog(@"Error: %@", task.error);
                                                                           break;
                                                                   }
                                                                   _failure(task.error);
                                                               } else {
                                                                   // Unknown error.
                                                                   NSLog(@"Error: %@", task.error);
                                                                   _failure(task.error);
                                                               }
                                                           }
                                                           
                                                           if (task.result) {
                                                               AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                                                               // The file uploaded successfully.
                                                               NSLog(@"File uploaded successfully.");
                                                               
                                                               NSString *strPublicUrl = [NSString stringWithFormat:@"https://ssdatahd.s3.amazonaws.com/customer_uploads/%@/%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"EID"], strFileName];
                                                               _success(strPublicUrl);
                                                           }
                                                           return nil;
                                                       }];
}


- (void)loadSettings {
    NSUserDefaults *dflt_user = [NSUserDefaults standardUserDefaults];
    NSData *data = [dflt_user objectForKey:KEY_SETTINGS];
    
    NSMutableDictionary *setting_data = [[NSMutableDictionary alloc] init];
    setting_data = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    self.m_fileQueue = [setting_data objectForKey:@"file_queue"];
//    self.m_fileHistory = [setting_data objectForKey:@"file_history"];
    
//    if (self.m_fileHistory == nil) {
//        self.m_fileHistory = [NSMutableDictionary new];
//    }
    
    if (self.m_fileQueue == nil) {
        self.m_fileQueue = [NSMutableDictionary new];
    }
    
}

- (void)saveSettings {
//    if (self.m_fileHistory == nil) {
//        self.m_fileHistory = [NSMutableDictionary new];
//    }

    if (self.m_fileQueue == nil) {
        self.m_fileQueue = [NSMutableDictionary new];
    }
    
    
    NSMutableDictionary *setting_data = [[NSMutableDictionary alloc] init];
//    [setting_data setObject:self.m_fileHistory forKey:@"file_history"];
    [setting_data setObject:self.m_fileQueue forKey:@"file_queue"];
    
    NSUserDefaults *dflt_user = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:setting_data];
    [dflt_user setObject:data forKey:KEY_SETTINGS];
}

- (void)uploadMediaToAmazonAndBackend:(NSURL *)filePath contentType:(NSString *)contentType fileType:(FILE_TYPE)_fileType filename:(NSString *)strFileName userEmails:(NSArray *)aryEmails userPhones:(NSArray *)aryNumbers successed:(void (^)(id))_success failure:(void (^)(id))_failure {

    [self uploadFileToAmazon:filePath contentType:contentType fileName:strFileName successed:^(id _success1) {
        [self uploadMedia:_success1 fileType:_fileType userEmails:aryEmails userPhones:aryNumbers successed:_success failure:nil];
    } failure:_failure];
}
@end
