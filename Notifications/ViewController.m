//
//  ViewController.m
//  Notifications
//
//  Created by Christian Lauer on 14.12.16.
//  Copyright © 2016 Christian Lauer. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotifications/UserNotifications.h>
#import "NotificationController.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface ViewController () <WCSessionDelegate>

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    if([WCSession isSupported])
    {
        //Setup WCSession
        [[WCSession defaultSession]setDelegate:self];
        [[WCSession defaultSession] activateSession];
    }
    
    //Read UserDefault Data back
    NSString *someString = [[NSUserDefaults standardUserDefaults] stringForKey:@"goal"];
    [_goal setText:someString];
    [self.goal setText:someString];

}

//Update Display (goal value)
-(void)updateDisplay{
    
    // Read UserDefault data back
    NSString *someString = [[NSUserDefaults standardUserDefaults] stringForKey:@"goal"];
    [_goal setText:someString];
    [self.goal setText:someString];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Receive Messages from Watch (in this case the data from Goal-Setting function and display new goal)
- (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary *)message replyHandler:(nonnull void (^)(NSDictionary * __nonnull))replyHandler {
    NSArray*counterValue = [message objectForKey:@"counterValue"];
    NSString *text = counterValue[0];
    //Save value as NSUserDefault
    [[NSUserDefaults standardUserDefaults] setObject:text forKey:@"goal"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //Update View Controller
    [self updateDisplay];
}

//Let iOS check for new Data
- (IBAction)checkforData:(id)sender {

    //With the help of AF Manager, get JSON Data
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //[manager.requestSerializer setAuthorizationHeaderFieldWithToken:token];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"DAwCbbOWsFjJK2dORoMngr6aHn22jsyJue5Cx1dyZbF0dhx1" forHTTPHeaderField:@"Authorization"];
    //User -> me
    [manager GET:@"https://amphirob1.com/api/users/2319/devices/2891/extractions" parameters:nil progress:nil
        //if successfull -> data to array
        success:^(NSURLSessionTask *task, id responseObject)
        {
            NSLog(@"JSON: %@", responseObject);
            if ([responseObject isKindOfClass:[NSArray class]]) {
                //if no Data is stored before
                if([[NSUserDefaults standardUserDefaults] objectForKey:@"showerData"] == nil) {
                    //save data -> user default object
                    AppDelegate *myClass = [[AppDelegate alloc]init];
                    [myClass saveData:responseObject];
                }
                else
                {
                    // Read NSDefaultData back
                    NSMutableArray* array = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"showerData"]];
                    
                    //Compare old with loaded data
                    if(sizeof(responseObject)>sizeof(array))
                    {
                        //If new data entries exists, save the data as new default data
                        AppDelegate *myClass = [[AppDelegate alloc]init];
                        [myClass saveData:responseObject];
                    }
                    
                    //if no new entries exsist
                    if(sizeof(responseObject)==sizeof(array))
                    {
                        //Send Notification: Pair your amphiro
                        [self sendNotifications:@"checkAmphiro"];
                    }
                    
                    //Transfer Data to Watch (normally this would only take place if new data exists, but for testing, this should be called with every button click event)
                    [self transferData:responseObject];
                }
            }
        }
        //if an error occurs
        failure:^(NSURLSessionTask *operation, NSError *error)
        {
            NSLog(@"Error: %@", error);
        }];
}

//Get JSON Data and transfer it to the watch
-(void)transferData:(NSMutableArray*)array{
    
    // Configure interface objects here.
    WCSession* session = [WCSession defaultSession];
    session.delegate = self;
    [session activateSession];
    NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[array] forKeys:@[@"JSONData"]];
    //Send Message to the iPhone (handle over the goal value)
    [[WCSession defaultSession] sendMessage:applicationData
                               replyHandler:^(NSDictionary *reply) {
                                   //handle reply from iPhone app here
                               }
                               errorHandler:^(NSError *error) {
                                   //catch any errors here
                               }
     ];
}

- (IBAction)motivate:(id)sender {
    //Send Notification: Pair your amphiro
    //[self sendNotifications:@"motivate"];
}

//If no new data was found send Notification -> pair your amphiro and action to activate parent app; Later a function which checks how long since last update took place could be added. So only when data hasn't been updated for longer than x days this notification should be triggered
- (IBAction)try_Update:(id)sender {
    
    //Send Notification: Pair your amphiro
    [self sendNotifications:@"checkAmphiro"];
}

//Set Goal Notification
- (IBAction)set_Goal:(id)sender {
    //Send Notification: Set Goal
    [self sendNotifications:@"set_goal"];
}

//Create and send Notifications
- (void) sendNotifications:(NSString *) Notifications{
    
    //Action - amphiro pairing message
    UNNotificationAction *action = [UNNotificationAction actionWithIdentifier:@"action" title:@"Versuche Update" options:UNNotificationActionOptionForeground];
    
    //Action - motivating message
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"action2" title:@"Öffne App" options:UNNotificationActionOptionForeground];
    
    //Action - set goal
    UNNotificationAction *action3 = [UNNotificationAction actionWithIdentifier:@"action3" title:@"Set Goal" options:UNNotificationActionOptionForeground];
    
    //Category1
    UNNotificationCategory * category1 = [UNNotificationCategory categoryWithIdentifier:@"myCategory" actions:@[action] intentIdentifiers:@[@"action"] options:UNNotificationCategoryOptionCustomDismissAction];
    
    //Category2
    UNNotificationCategory * category2 = [UNNotificationCategory categoryWithIdentifier:@"myCategory2" actions:@[action2] intentIdentifiers:@[@"action2"] options:UNNotificationCategoryOptionCustomDismissAction];
    
    //Category3
    UNNotificationCategory * category3 = [UNNotificationCategory categoryWithIdentifier:@"myCategory3" actions:@[action3] intentIdentifiers:@[@"action3"] options:UNNotificationCategoryOptionCustomDismissAction];

    //NSSET
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObjects:category1,category2, category3, nil]];
    
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
        NSLog(@"completionHandler");
    }];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    
    //Decision which Notification will be send
    //Pair Message
    if ([Notifications  isEqual:@"checkAmphiro"])
    {
        content.title = [NSString localizedUserNotificationStringForKey:@"amphiro!"
                                                              arguments:nil];
        content.subtitle = [NSString localizedUserNotificationStringForKey:@"Paire dein amphiro"
                                                             arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:@"amhpiro lange nicht gesehen"
                                                             arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        content.categoryIdentifier=@"myCategory";

        //Do it via local Notification -> replaced in iOS 10.0 and higher
        //localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:15];
        //localNotification.alertTitle = @"Paire dein amphiro";
        //localNotification.alertBody = @"Habe dein amphiro länger nicht gesehen";
        //localNotification.timeZone = [NSTimeZone defaultTimeZone];
        //localNotification.category =@"myCategory";
        //localNotification.hasAction = true;
        //localNotification.alertAction = @"Öffnen";
        //[[UNMutableNotificationContent sharedApplication] scheduleLocalNotification:localNotification];
    }
    
    //Motivating Message
    if ([Notifications  isEqual:@"motivate"])
    {
        // Read it back
        NSString *someString = [[NSUserDefaults standardUserDefaults]
                                stringForKey:@"goalLabel"];
        [_goal setText:someString];
    }
    
    //Set Goal Message
    if ([Notifications  isEqual:@"set_goal"])
    {
        content.title = [NSString localizedUserNotificationStringForKey:@"amphiro!" arguments:nil];
        content.subtitle = [NSString localizedUserNotificationStringForKey:@"Setze dir ein Ziel" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:@"Um noch mehr zu sparen =)" arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        content.categoryIdentifier=@"myCategory3";
    }
    
    //Send one of the above messages to iPhone, with time delay of 15 seconds
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
    UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:@"kNotificationIdentifier" content:content trigger:trigger];
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:notificationRequest
             withCompletionHandler:^(NSError * _Nullable error) {
                 NSLog(@"completed!");
             }];
}


@end
