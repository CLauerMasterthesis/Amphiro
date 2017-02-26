
//
//  InterfaceController.m
//  Notifications WatchKit Extension
//
//  Created by Christian Lauer on 14.12.16.
//  Copyright © 2016 Christian Lauer. All rights reserved.
//

#import "InterfaceController.h"
#import "OrdinaryEventRow.h"
#import <UIKit/UIKit.h> 
#import <WatchConnectivity/WatchConnectivity.h>

@interface InterfaceController()

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *grp;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *goalSettter;
@property (nonatomic, weak) IBOutlet InterfaceController *interfaceController;
@property (nonatomic, assign) BOOL switchStatus;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    //Configure interface objects here.
    
    //Load Shower Data
    //Get the value UserDefaults(Json)
    NSString *temp = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"temperature"];
    //add temp to table
    NSString *text = temp;
    NSMutableArray *rowTypesList = [NSMutableArray array];
    [rowTypesList addObject:@"OrdinaryEventRow"];
    [_tb setNumberOfRows:3 withRowType:@"OrdinaryEventRow"];
    NSObject *row = [_tb rowControllerAtIndex:0];
    OrdinaryEventRow *importantRow = (OrdinaryEventRow *) row;
    [importantRow.label setText:text];
    [importantRow.table_text setText:@"Volume"];
    [importantRow.label setTextColor:[UIColor whiteColor]];
    [importantRow.grp setBackgroundColor:[UIColor colorWithRed:0.05 green:0.20 blue:0.24 alpha:1.0]];
    
    //add volume to table
    NSString *volume= [[NSUserDefaults standardUserDefaults] stringForKey:@"volume"];
    text = volume;
    [rowTypesList addObject:@"OrdinaryEventRow"];
    row = [_tb rowControllerAtIndex:1];
    importantRow = (OrdinaryEventRow *) row;
    [importantRow.label setText:text];
    [importantRow.table_text setText:@"Temperature"];
    [importantRow.label setTextColor:[UIColor whiteColor]];
    [importantRow.grp setBackgroundColor:[UIColor colorWithRed:0.05 green:0.20 blue:0.24 alpha:1.0]];

    //add volume to table
    NSString *efficiency= [[NSUserDefaults standardUserDefaults] stringForKey:@"heatingEfficiency"];
    text = efficiency;
    [rowTypesList addObject:@"OrdinaryEventRow"];
    row = [_tb rowControllerAtIndex:2];
    importantRow = (OrdinaryEventRow *) row;
    [importantRow.label setText:text];
    [importantRow.table_text setText:@"Efficiency"];
    [importantRow.label setTextColor:[UIColor whiteColor]];
    [importantRow.grp setBackgroundColor:[UIColor colorWithRed:0.05 green:0.20 blue:0.24 alpha:1.0]];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    //Setup WCSession
    if ([WCSession isSupported]) {
        [[WCSession defaultSession] setDelegate:self];
        [[WCSession defaultSession] activateSession];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

//Receive Messages from iPhone (in this case the JSON data)
- (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary *)message replyHandler:(nonnull void (^)(NSDictionary * __nonnull))replyHandler {
    NSArray*jsonData = [message objectForKey:@"JSONData"];
    
    //Save array as NSUserDefault
    [[NSUserDefaults standardUserDefaults] setObject:jsonData forKey:@"jsonData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //Get Number of elements from Json Data
    NSInteger count = [jsonData count];
    
    //Get latest shower records
    NSString *volume = [[jsonData objectAtIndex: 0] objectForKey:@"volume"];
    NSString *temp = [[jsonData objectAtIndex: 0] objectForKey:@"temperature"];
    NSString *efficiency = [[jsonData objectAtIndex: 0] objectForKey:@"heatingEfficiency"];
    
    //Store data into UserDefaults
    //Save value as NSUserDefault
    [[NSUserDefaults standardUserDefaults] setObject:temp forKey:@"temperature"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:volume forKey:@"volume"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:efficiency forKey:@"heatingEfficiency"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self awakeWithContext:nil];
}

//Show the goalValue which is to be set on the watch
-(void)showGoal {
    [self presentControllerWithName:@"goalView" context:nil];
}

//Handle Local Notification Actions
-(void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UNNotification *)localNotification{
    
    //Always opens the interface
    //The app calls this method when the user taps an action button in an alert displayed in response to a local notification. Local notifications that include a registered category name in their category property display buttons for the actions in that category. If the user taps one of those buttons, the system wakes up the app (launching it if needed) and calls this method in the background. Your implementation of this method should perform the action associated with the specified identifier and execute the block in the completionHandler parameter as soon as you are done. Failure to execute the completion handler block at the end of your implementation will cause your app to be terminated.
    
    //If Pairing amphiro was clicked -> Try to get iOS back in active/Foreground
    if([identifier isEqualToString:@"action"]){
        
        
        
        //Setup WCSession
        if ([WCSession isSupported]) {
            [[WCSession defaultSession] setDelegate:self];
            [[WCSession defaultSession] activateSession];
            
            //Get the value from slider
            NSString *someString = [[NSUserDefaults standardUserDefaults]
                                    stringForKey:@"Update"];
            NSString *Update = @"Update";
            NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[Update] forKeys:@[@"Update"]];
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
    }
    
    //If Goal Setting was clicked -> Show Goal Set View
    if([identifier isEqualToString:@"action3"]){
        [self showGoal];
        
    }
}

- (IBAction)wakeUP {
    
    //Setup WCSession
    if ([WCSession isSupported]) {
        [[WCSession defaultSession] setDelegate:self];
        [[WCSession defaultSession] activateSession];
        
        //Get the value from slider
        NSString *someString = [[NSUserDefaults standardUserDefaults]
                                stringForKey:@"Update"];
        NSString *Update;
        if(self.switchStatus==true){
            Update = @"yes";
        }
        if(self.switchStatus==false){
            Update = @"no";
        }
        
        NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[Update] forKeys:@[@"Update"]];
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
}

- (IBAction)switch:(BOOL)value {
    self.switchStatus = value;
}



////Get Background Transfer Data
//- (void)session:(WCSession *)session
//didReceiveApplicationContext:(nonnull NSDictionary<NSString *,id> *)applicationContext
//{
//    NSData*jsonData = [applicationContext objectForKey:@"JSONData"];
//    NSArray *jsonArray = [NSKeyedUnarchiver unarchiveObjectWithData:jsonData];
//    
//     //In the event that the app is not running when the context data is transferred the method will be called next time the app is launched by the user.
//    
//    //Save array as NSUserDefault
//    //[[NSUserDefaults standardUserDefaults] setObject:jsonArray forKey:@"jsonData"];
//    //[[NSUserDefaults standardUserDefaults] synchronize];
//    
//    
//    //Get latest shower records
//    NSString *volume = [[jsonArray objectAtIndex: 0] objectForKey:@"volume"];
//    NSString *temp = [[jsonArray  objectAtIndex: 0] objectForKey:@"temperature"];
//    NSString *efficiency = [[jsonArray  objectAtIndex: 0] objectForKey:@"heatingEfficiency"];
//    
//    //Store data into UserDefaults
//    //Save value as NSUserDefault
//    [[NSUserDefaults standardUserDefaults] setObject:temp forKey:@"temperature"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    [[NSUserDefaults standardUserDefaults] setObject:volume forKey:@"volume"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    [[NSUserDefaults standardUserDefaults] setObject:efficiency forKey:@"heatingEfficiency"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    [self awakeWithContext:nil];
//    
//}





@end



