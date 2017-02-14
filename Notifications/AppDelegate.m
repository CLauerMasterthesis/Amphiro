//
//  AppDelegate.m
//  Notifications
//
//  Created by Christian Lauer on 14.12.16.
//  Copyright © 2016 Christian Lauer. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // Override point for customization after application launch.
    
    // None of the code should even be compiled unless the Base SDK is iOS 8.0 or later
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    // The following line must only run under iOS 8. This runtime check prevents
    // it from running if it doesn't exist (such as running under iOS 7 or earlier).
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
#endif
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

-(void)saveData:(NSMutableArray*)array
{
    //Get the standard UserDefault object, store UITableView data array against a key, synchronize the defaults
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"showerData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
 
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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

//Handle Notifications on the Phone
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler
{
    if([notification.category isEqualToString:@"myCategory"])
    {
        if([identifier isEqualToString:@"decline_action_id"])
        {
            NSLog(@"Decline was pressed");
        }
        else if([identifier isEqualToString:@"reply_action_id"])
        {
            NSLog(@"Reply was pressed");
        }
    }
    
    //Important to call this when finished
    completionHandler();
}

//Activate Parent App when Watchkit try to pair was clicked
- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply {
    NSString * request = [userInfo objectForKey:@"Update"];
    
    if ([request isEqualToString:@"Update"]) {
        
        __block UIBackgroundTaskIdentifier watchKitHandler;
        watchKitHandler = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"backgroundTask" expirationHandler:^{watchKitHandler = UIBackgroundTaskInvalid;}];
        
        if ([request isEqualToString:@"Update"])
        {
            // .....
            //
        }
        
        dispatch_after( dispatch_time( DISPATCH_TIME_NOW, (int64_t)NSEC_PER_SEC * 1 ), dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^{
            [[UIApplication sharedApplication] endBackgroundTask:watchKitHandler];
        } );
    }
    
    // This is just an example of what you could return. The one requirement is
    // you do have to execute the reply block, even if it is just to 'reply(nil)'.
    // All of the objects in the dictionary [must be serializable to a property list file][3].
    // If necessary, you can covert other objects to NSData blobs first.
    //NSArray * objects = [[NSArray alloc] initWithObjects:myObjectA, myObjectB, myObjectC, nil];
    //NSArray * keys = [[NSArray alloc] initWithObjects:@"objectAName", @"objectBName", @"objectCName", nil];
    //NSDictionary * replyContent = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    
    //reply(replyContent);
}


@end
