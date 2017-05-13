//
//  ExtensionDelegate.m
//  Notifications WatchKit Extension
//
//  Created by Christian Lauer on 14.12.16.
//  Copyright © 2016 Christian Lauer. All rights reserved.
//

#import "ExtensionDelegate.h"
#import "InterfaceController.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "setGoal.h"

@import WatchConnectivity;

@interface ExtensionDelegate()
@property WCSession *session;
@end

@implementation ExtensionDelegate


//Init WCSession in Extension Delegate
- (instancetype)init
{
    self = [super init];
    if(self) {
        // Start a WatchKit connectivity session
        if([WCSession isSupported]) {
            _session = [WCSession defaultSession];
            _session.delegate = self;
            [_session activateSession];
        }
    }
    return self;
}

- (void)applicationDidFinishLaunching {
    // Perform any final initialization of your application.
    
}

- (void)applicationDidBecomeActive {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillResignActive {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
}

- (void)handleBackgroundTasks:(NSSet<WKRefreshBackgroundTask *> *)backgroundTasks {
    // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
    for (WKRefreshBackgroundTask * task in backgroundTasks) {
        // Check the Class of each task to decide how to process it
        if ([task isKindOfClass:[WKApplicationRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKApplicationRefreshBackgroundTask *backgroundTask = (WKApplicationRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompleted];
        } else if ([task isKindOfClass:[WKSnapshotRefreshBackgroundTask class]]) {
            // Snapshot tasks have a unique completion call, make sure to set your expiration date
            WKSnapshotRefreshBackgroundTask *snapshotTask = (WKSnapshotRefreshBackgroundTask*)task;
            [snapshotTask setTaskCompletedWithDefaultStateRestored:YES estimatedSnapshotExpiration:[NSDate distantFuture] userInfo:nil];
        } else if ([task isKindOfClass:[WKWatchConnectivityRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKWatchConnectivityRefreshBackgroundTask *backgroundTask = (WKWatchConnectivityRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompleted];
        } else if ([task isKindOfClass:[WKURLSessionRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKURLSessionRefreshBackgroundTask *backgroundTask = (WKURLSessionRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompleted];
        } else {
            // make sure to complete unhandled task types
            [task setTaskCompleted];
        }
    }
}

//Get Background Transfer Data
- (void)session:(WCSession *)session
didReceiveApplicationContext:(nonnull NSDictionary<NSString *,id> *)applicationContext
{
    NSData*jsonData = [applicationContext objectForKey:@"JSONData"];
    NSArray *jsonArray = [NSKeyedUnarchiver unarchiveObjectWithData:jsonData];
    //Get latest shower records
    NSString *volume = [[jsonArray objectAtIndex: 0] objectForKey:@"volume"];
    NSString *temp = [[jsonArray  objectAtIndex: 0] objectForKey:@"temperature"];
    NSString *efficiency = [[jsonArray  objectAtIndex: 0] objectForKey:@"heatingEfficiency"];
    //Store data into UserDefaults
    //Save value as NSUserDefault
    [[NSUserDefaults standardUserDefaults] setObject:temp forKey:@"temperature"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:volume forKey:@"volume"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:efficiency forKey:@"heatingEfficiency"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
