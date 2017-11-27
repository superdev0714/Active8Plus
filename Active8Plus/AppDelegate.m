//
//  AppDelegate.m
//  Active8Plus
//
//  Created by forever on 7/8/17.
//  Copyright © 2017 forever. All rights reserved.
//

#import "AppDelegate.h"
#import <IQKeyboardManager.h>

#import "APIManager.h"
#import "Reachability.h"

#import <MobilePrintSDK/MP.h>
#import <MobilePrintSDK/MPPrintItemFactory.h>
#import <MobilePrintSDK/MPPrintManager.h>
#import <MobilePrintSDK/MPLayoutFactory.h>

@interface AppDelegate () <MPPrintManagerDelegate>

@property (strong, nonatomic) MPPrintManager                *printManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [IQKeyboardManager sharedManager].enable = YES;
    
    [[APIManager sharedInstance] loadSettings];
    
    application.statusBarHidden = YES;
    
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [APIManager sharedInstance].group = dispatch_group_create();
    [APIManager sharedInstance].group1 = dispatch_group_create();
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadMedia:) name:UPLOADING_START_NOTIFICATION object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(printMedia:) name:NOTIFICATION_ADD_PRINT_FILE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgoundQueue:) name:kReachabilityChangedNotification object:nil];
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[APIManager sharedInstance] saveSettings];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void) backgoundQueue:(NSNotification *)notification {
    Reachability *networkReachability = (Reachability *)notification.object;
    NetworkStatus status = [networkReachability currentReachabilityStatus];
    
    switch (status) {
        case NotReachable: {
            NSLog(@"no internet connection-1do ");
            break;
        }
        case ReachableViaWiFi: {
            /*
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if ([APIManager sharedInstance].m_fileQueue.count > 0) {
                    
                    NSMutableArray *file_queue = [[APIManager sharedInstance].m_fileQueue objectForKey:KEY_UPLOAD];
                    for (NSMutableDictionary *one in file_queue) {
                        
                        dispatch_group_enter([APIManager sharedInstance].group);
                        
                        NSLog(@"uploading via wifi");
                        
                        NSURL *file_path = [one objectForKey:@"file_path"];
                        NSString *file_name = [one objectForKey:@"file_name"];
                        FILE_TYPE file_type = [[one objectForKey:@"file_type"] intValue];
                        NSString *mime_type = [one objectForKey:@"mime_type"];
                        NSArray *ary_emails = [one objectForKey:@"ary_emails"];
                        NSArray *ary_numbers = [one objectForKey:@"ary_numbers"];
                        
                        [[APIManager sharedInstance] uploadMediaToAmazonAndBackend:file_path contentType:mime_type fileType:file_type filename:file_name userEmails:ary_emails userPhones:ary_numbers successed:^(id _success) {
                            
                            NSMutableArray *file_upload = [[APIManager sharedInstance].m_fileHistory objectForKey:KEY_UPLOAD];
                            if (file_upload == nil) {
                                file_upload = [NSMutableArray new];
                                
                                if ([APIManager sharedInstance].m_fileHistory == nil) {
                                    [APIManager sharedInstance].m_fileHistory = [NSMutableDictionary new];
                                }
                                [[APIManager sharedInstance].m_fileHistory setObject:file_upload forKey:KEY_UPLOAD];
                            }
                            
                            if ([file_upload indexOfObject:one] == NSNotFound) {
                                NSLog(@"One file add to queue");
                                [file_upload addObject:one];
                            }
                            
                            if ([file_queue indexOfObject:one] != NSNotFound) {
                                [file_queue removeObject:one];
                            }
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [[NSFileManager defaultManager] removeItemAtPath:file_path.absoluteString error:NULL];
                            });
                            
                            NSLog(@"File Uploading Success!!! ");
                            dispatch_group_leave([APIManager sharedInstance].group);
                        } failure:^(NSError *_failure) {
                            NSLog(@"File Uploading Failure!!!");
                            dispatch_group_leave([APIManager sharedInstance].group);
                        }];
                    }
                    
                    NSMutableArray *file_print_queue = [[APIManager sharedInstance].m_fileQueue objectForKey:KEY_PRINT];
                    for (NSMutableDictionary *one in file_print_queue) {
                        
                        
                        dispatch_group_enter([APIManager sharedInstance].group);
                        
                        
                        NSString *image_path = [one objectForKey:@"url_str"];
                        NSLog(@"One is %@", one);
                        
                        NSURL *file_path = [[NSURL alloc] initFileURLWithPath:image_path];
                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:file_path]];
                        MPPrintItem *item = [MPPrintItemFactory printItemWithAsset:image];
                        NSError *error;
                        
                        
                        [self.printManager print:item pageRange:nil numCopies:1 error:&error];
                        
                        if (error) {
                            NSLog(@"Error --- %@", [error localizedDescription]);
                            
                            dispatch_group_leave([APIManager sharedInstance].group);
                        }
                        else {
                            
                            NSMutableArray *file_print = [[APIManager sharedInstance].m_fileHistory objectForKey:KEY_PRINT];
                            if (file_print == nil) {
                                file_print = [NSMutableArray new];
                                
                                if ([APIManager sharedInstance].m_fileHistory == nil) {
                                    [APIManager sharedInstance].m_fileHistory = [NSMutableDictionary new];
                                }
                                [[APIManager sharedInstance].m_fileHistory setObject:file_print forKey:KEY_PRINT];
                            }
                            
                            [file_print addObject:[one objectForKey:@"title"]];
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [[NSFileManager defaultManager] removeItemAtPath:file_path.absoluteString error:NULL];
                            });
                            
                            NSMutableArray *file_queue = [[APIManager sharedInstance].m_fileQueue objectForKey:KEY_PRINT];
                            [file_queue removeObject:one];
                            
                            dispatch_group_leave([APIManager sharedInstance].group);
                        }
                        
                    }

                    dispatch_notify([APIManager sharedInstance].group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSLog(@"work is done. %ld", (unsigned long)file_queue.count);
                    });
                }
            });
            */
            break;
        }
        case ReachableViaWWAN: {
            NSLog(@"cellurar");
            break;
        }
    }
}
/*
- (void) uploadMedia: (NSNotification *)notification {
    NSLog(@"uploadMedia");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([APIManager sharedInstance].m_fileQueue.count > 0) {
            
            
            dispatch_group_enter([APIManager sharedInstance].group);
            
            
            NSMutableArray *file_queue = [[APIManager sharedInstance].m_fileQueue objectForKey:KEY_UPLOAD];

            NSMutableDictionary *one = notification.object;
            NSURL *file_path = [one objectForKey:@"file_path"];
            NSString *file_name = [one objectForKey:@"file_name"];
            FILE_TYPE file_type = [[one objectForKey:@"file_type"] intValue];
            NSString *mime_type = [one objectForKey:@"mime_type"];
            NSArray *ary_emails = [one objectForKey:@"ary_emails"];
            NSArray *ary_numbers = [one objectForKey:@"ary_numbers"];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UPLOADING_STATUS_NOTIFICATION object:nil];
            [[APIManager sharedInstance] uploadMediaToAmazonAndBackend:file_path contentType:mime_type fileType:file_type filename:file_name userEmails:ary_emails userPhones:ary_numbers successed:^(id _success) {
                
                NSMutableArray *file_upload = [[APIManager sharedInstance].m_fileHistory objectForKey:KEY_UPLOAD];
                if (file_upload == nil) {
                    file_upload = [NSMutableArray new];
                    
                    if ([APIManager sharedInstance].m_fileHistory == nil) {
                        [APIManager sharedInstance].m_fileHistory = [NSMutableDictionary new];
                    }
                    
                    [[APIManager sharedInstance].m_fileHistory setObject:file_upload forKey:KEY_UPLOAD];
                }
                
                [one setObject:[NSNumber numberWithBool:true] forKey:@"is_success"];
                
                if ([file_upload indexOfObject:one] == NSNotFound) {
                    if (one) {
                        [file_upload addObject:one];
                    }
                }
                
                if ([file_queue indexOfObject:one] != NSNotFound) {
                    if (one) {
                        [file_queue removeObject:one];
                    }
                }
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[NSFileManager defaultManager] removeItemAtPath:file_path.absoluteString error:NULL];
                });
                
                NSLog(@"File Uploading Success!!!");
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RESPONSED_UPLOAD_FILE object:nil];
                
                dispatch_group_leave([APIManager sharedInstance].group);

            } failure:^(NSError *_failure) {
                
                NSMutableArray *file_upload = [[APIManager sharedInstance].m_fileHistory objectForKey:KEY_UPLOAD];
                
                if ([file_upload indexOfObject:one] == NSNotFound) {
                    
                    if (one) {
                        [file_upload addObject:one];
                    }
                }
                
                if ([file_queue indexOfObject:one] != NSNotFound) {
                    if (one) {
                        [file_queue removeObject:one];
                    }
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RESPONSED_UPLOAD_FILE object:nil];
                
                dispatch_group_leave([APIManager sharedInstance].group);
            }];
            
            dispatch_group_wait([APIManager sharedInstance].group, DISPATCH_TIME_FOREVER);
        }
    });
}
*/
/*
- (void) printMedia:(NSNotification *)notification {
}
*/

#pragma mark MPPrintManagerDelegate
- (void)didFinishPrintJob:(UIPrintInteractionController *)printController
                completed:(BOOL)completed error:(NSError *)error {
    
}

@end
