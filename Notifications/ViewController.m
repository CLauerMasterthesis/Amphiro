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
@import CoreLocation;

@interface ViewController () <WCSessionDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@end


/*!
 @ViewController
 
 @brief The View Controller class
 
 @discussion    This class was designed and implemented to simulate the iOS/amphiro App as the counterpart of the Watch-App
 */
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
    NSDictionary *userLoc=[[NSUserDefaults standardUserDefaults] objectForKey:@"userLocation"];
    NSString *lat= [userLoc objectForKey:@"lat"];
    NSString *lon =[userLoc objectForKey:@"long"];
    //Read UserDefault Data back
    NSString *someString = [[NSUserDefaults standardUserDefaults] stringForKey:@"goal"];
    [_goal setText:someString];
    [self.goal setText:someString];
}

/**
 * Updates the View if new data has been delivered.
 */
-(void)updateDisplay{
    NSString *someString = [[NSUserDefaults standardUserDefaults] stringForKey:@"goal"];
    [_goal setText:someString];
    [self.goal setText:someString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Receive Messages from Watch (in this case the data from Goal-Setting function and display new goal)
- (void)session:(nonnull WCSession *)session
didReceiveMessage:(nonnull NSDictionary *)message replyHandler:(nonnull void (^)(NSDictionary * __nonnull))replyHandler {

    //Wake Up
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
        [self updateDisplay];
    }
}

/**
 * Method to load the JSON data from the amphiro server and store it.
 */
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
                NSArray *jsonArray;
                @try {
                    NSData* array = [[NSUserDefaults standardUserDefaults] objectForKey:@"showerData"];
                    jsonArray = [NSKeyedUnarchiver unarchiveObjectWithData:array];
                }
                @catch (NSException *exception) {
                    jsonArray = responseObject;
                    NSData *serialized = [NSKeyedArchiver archivedDataWithRootObject:jsonArray];
                    [[NSUserDefaults standardUserDefaults] setObject:serialized forKey:@"showerData"];
                }
                @finally {
                    NSArray *save=responseObject;
                    //Compare old with loaded data
                    if(![responseObject isEqualToArray:jsonArray])
                    {
                        //If new data entries exists, save the data as new default data
                        if ([responseObject isKindOfClass:[NSArray class]]) {
                            //save data -> user default object
                            NSData *serialized = [NSKeyedArchiver archivedDataWithRootObject:save];
                            [[NSUserDefaults standardUserDefaults] setObject:serialized forKey:@"showerData"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            //Handle new data over
                            [self transferData:responseObject];
                            //Send Notification: New Data
                            [self sendNotifications:@"checkData"];
                        }
                        //Transfer Data normally would be called here
                    }
                    //if no new entries exsist
                    if([responseObject isEqualToArray:jsonArray])
                    {
                        //Send Notification: Pair your amphiro
                        [self sendNotifications:@"checkAmphiro"];
                    }
                }
            }
        }
        //if an error occurs
        failure:^(NSURLSessionTask *operation, NSError *error)
        {
            NSLog(@"Error: %@", error);
        }];
}

/**
 * Method to transfer the JSON data to the Watch-App.
 @param array Array with the JSON data.
 */
-(void)transferData:(NSMutableArray*)array{
    
    // Configure interface objects here.
    //Setup WCSession
    [[WCSession defaultSession]setDelegate:self];
    [[WCSession defaultSession] activateSession];
    NSData *serialized = [NSKeyedArchiver archivedDataWithRootObject:array];
    [[NSUserDefaults standardUserDefaults] setObject:serialized forKey:@"myKey"];
    NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[serialized] forKeys:@[@"JSONData"]];
    NSError *error = nil;
    //Send Message to the iPhone (handle over the goal value)
    if ([WCSession defaultSession]) {
        [[WCSession defaultSession] updateApplicationContext:applicationData error:&error];
        if (error) {
            NSLog(@"Problem: @%@", error);
        } else {
            NSLog(@"sent dictionary");
            // Create a dict of application data
            [[WCSession defaultSession] sendMessage:applicationData
                                       replyHandler:^(NSDictionary *replyHandler) {
                                           
                                       }
                                       errorHandler:^(NSError *error) {
                                       }
             ];
        }
    } else {
        NSLog(@"not paired");
    }
}


/**
 * If no new data was found it will send Notification -> "pair your amphiro" and an action to activate parent app; Later a function which checks how long since last the update took place could be added. So only when data hasn't been updated for longer than x days this notification should be triggered
 */
- (IBAction)try_Update:(id)sender {
    
    //Send Notification: Pair your amphiro
    [self sendNotifications:@"checkAmphiro"];
}

/**
 * Triggers the set Goal Notification. Later it would be triggered e.g. when the user has a high water/energy consumption or based on a timer
 */
- (IBAction)set_Goal:(id)sender {
    //Send Notification: Set Goal
    [self sendNotifications:@"set_goal"];
}

/**
 * Method to trigger (local) Notifications.
 @param Notifications (NSString) which decides which Notification will be triggered.
 */
- (void) sendNotifications:(NSString *) Notifications{
    
    //Action - amphiro pairing message
    UNNotificationAction *action = [UNNotificationAction actionWithIdentifier:@"action" title:@"amphiro verbinden" options:UNNotificationActionOptionForeground];
    
    //Action - motivating message
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"action2" title:@"Öffne App" options:UNNotificationActionOptionForeground];
    
    //Action - set goal message
    UNNotificationAction *action3 = [UNNotificationAction actionWithIdentifier:@"action3" title:@"Ziel setzen" options:UNNotificationActionOptionForeground];
    
    //Category1
    UNNotificationCategory * category1 = [UNNotificationCategory categoryWithIdentifier:@"myCategory" actions:@[action] intentIdentifiers:@[@"action"] options:UNNotificationCategoryOptionCustomDismissAction];
    
    //Category2
    UNNotificationCategory * category2 = [UNNotificationCategory categoryWithIdentifier:@"myCategory2" actions:@[action3] intentIdentifiers:@[@"action3"] options:UNNotificationCategoryOptionCustomDismissAction];
    
    //Category3
    UNNotificationCategory * category3 = [UNNotificationCategory categoryWithIdentifier:@"myCategory3" actions:@[action2] intentIdentifiers:@[@"action2"] options:UNNotificationCategoryOptionCustomDismissAction];

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
    }
    
    //New data Message
    if ([Notifications  isEqual:@"checkData"])
    {
        content.title = [NSString localizedUserNotificationStringForKey:@"amphiro!" arguments:nil];
        content.subtitle = [NSString localizedUserNotificationStringForKey:@"Neue Daten verfügbar" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:@"Neue Daten verfügbar =)" arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        content.categoryIdentifier=@"myCategory3";
    }
    
    //Set Goal Message
    if ([Notifications  isEqual:@"set_goal"])
    {
        content.title = [NSString localizedUserNotificationStringForKey:@"amphiro!" arguments:nil];
        content.subtitle = [NSString localizedUserNotificationStringForKey:@"Setze dir ein Ziel" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:@"Um noch mehr zu sparen =)" arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        content.categoryIdentifier=@"myCategory2";
    }
    
    //Send one of the above messages to iPhone, with time delay of 5 seconds
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
    UNNotificationRequest *notificationRequest = [UNNotificationRequest requestWithIdentifier:@"kNotificationIdentifier" content:content trigger:trigger];
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:notificationRequest
             withCompletionHandler:^(NSError * _Nullable error) {
                 NSLog(@"completed!");
             }];
}


/**
 * Method to get authorization from User for Location Updates.
 * Provides a request that asks the user if the certain location is their home.
 * If yes: Location will be saved
 */
- (IBAction)pairAmphiro:(id)sender {
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        [self.locationManager requestAlwaysAuthorization];
    }

    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"amphiro"
                                 message:@"Is this your home"
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    
                                    NSNumber *lat = [NSNumber numberWithDouble:_locationManager.location.coordinate.latitude];
                                    NSNumber *lon = [NSNumber numberWithDouble:_locationManager.location.coordinate.longitude];
                                    NSDictionary *userLocation=@{@"lat":lat,@"long":lon};
                                    
                                    [[NSUserDefaults standardUserDefaults] setObject:userLocation forKey:@"userLocation"];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                    float latitude = _locationManager.location.coordinate.latitude;
                                    float longitude = _locationManager.location.coordinate.longitude;
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"No"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
    NSLog(@"%@", [self deviceLocation]);
}

/**
 * Location data formated into a String.
 * Returns: deviceLocation(String)
 */
- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", _locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude];
}

@end
