//
//  AppDelegate.m
//  Notifications
//
//  Created by Christian Lauer on 14.12.16.
//  Copyright © 2016 Christian Lauer. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <WatchConnectivity/WatchConnectivity.h>
@import CoreLocation;

@interface AppDelegate ()
@property WCSession *session;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end
@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // Start a WatchKit connectivity session in AppDelegate for Background transfers
    if([WCSession isSupported]) {
        _session = [WCSession defaultSession];
        _session.delegate = self;
        [_session activateSession];
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
        _locationManager.activityType = CLActivityTypeFitness;
        _locationManager.pausesLocationUpdatesAutomatically=NO;
        _locationManager.allowsBackgroundLocationUpdates=true;
        [_locationManager setAllowsBackgroundLocationUpdates:YES];
        
        [_locationManager startUpdatingLocation];
    }
    
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

-(void)saveData:(NSArray*)array
{
    //Get the standard UserDefault object, store UITableView data array against a key, synchronize the defaults
    NSArray *save= [[NSArray alloc] initWithArray:array];
    [[NSUserDefaults standardUserDefaults] setObject:save forKey:@"showerData"];
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


////Activate Parent App when Watchkit try to pair was clicked
//- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void ( ^)( NSDictionary * ))reply
//{
//    // Start a WatchKit connectivity session
//    if([WCSession isSupported]) {
//        _session = [WCSession defaultSession];
//        _session.delegate = self;
//        [_session activateSession];
//    }
//    
//    //Begin Background Task
//    __block UIBackgroundTaskIdentifier watchKitHandler;
//    watchKitHandler = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"backgroundTask"expirationHandler:^{ watchKitHandler = UIBackgroundTaskInvalid;}];
//    
//    NSString * request = [userInfo objectForKey:@"Update"];
//    [[NSUserDefaults standardUserDefaults] setObject:request forKey:@"Switch"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    //Dispatch after 5 sec.
//    dispatch_after( dispatch_time( DISPATCH_TIME_NOW, (int64_t)NSEC_PER_SEC * 15), dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^{
//        [[UIApplication sharedApplication] endBackgroundTask:watchKitHandler];
//    } );
//}

//Receive Messages from Watch (Wake Up)
- (void)session:(nonnull WCSession *)session
didReceiveMessage:(nonnull NSDictionary *)message replyHandler:(nonnull void (^)(NSDictionary * __nonnull))replyHandler {
    if ([message objectForKey:@"Update"])
    {
    NSString * request = [message objectForKey:@"Update"];
    [[NSUserDefaults standardUserDefaults] setObject:request forKey:@"Switch"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    replyHandler(@{@"a":@"hello"});
    }
    //Goal Setting Value
    if ([message objectForKey:@"counterValue"])
    {
        NSArray*counterValue = [message objectForKey:@"counterValue"];
        NSString *text = counterValue[0];
        //Save value as NSUserDefault
        [[NSUserDefaults standardUserDefaults] setObject:text forKey:@"goal"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

/**
 * System will allow iOS-App to execute actions (even if in Background mode or when eliminated) when a location update takes place.
 */
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    NSDictionary *userLoc=[[NSUserDefaults standardUserDefaults] objectForKey:@"userLocation"];
    NSString *lat= [userLoc objectForKey:@"lat"];
    NSString *lon =[userLoc objectForKey:@"long"];
    CLLocation *oldLocation=[[CLLocation alloc] initWithLatitude:[[userLoc objectForKey:@"lat"] doubleValue] longitude:[[userLoc objectForKey:@"long"] doubleValue]];
    CLLocation *newLocation = locations.lastObject;
    CLLocationDistance threshold = 500.0;  // threshold distance in meters
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    [notification setAlertBody:@"Neue Location!"];
    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    // note: userLocation and otherLocation are CLLocation objects
    if ([newLocation distanceFromLocation:oldLocation] <= threshold) {
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        [notification setAlertBody:@"Zuhause!"];
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }

    if ([newLocation distanceFromLocation:oldLocation] >= threshold) {
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        [notification setAlertBody:@"Nicht zuhause!"];
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

@end
