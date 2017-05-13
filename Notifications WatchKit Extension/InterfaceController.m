
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
@property WCSession *session;

@end



/*!
 @InterfaceController
 
 @brief The Interface Controller class
 
 @discussion    This class was designed and implemented to help people to get an overview over their water/energy consumption.
 */
@implementation InterfaceController


- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    //Configure interface objects here.
    [self loadTable];
}


/**
 * Presents the "goalView" Controller in which the user can set
 * a goal for their water consumption
 @helper Helper class for this method is the OrdinaryEventRow class which populates the table.
 */
- (void)loadTable{

    //Load Shower Data
    [_tb setNumberOfRows:0 withRowType:@"OrdinaryEventRow"];
    [_tb setNumberOfRows:3 withRowType:@"OrdinaryEventRow"];
    //Get the value UserDefaults(Json)
    NSString *temp = [[NSUserDefaults standardUserDefaults]
                      stringForKey:@"temperature"];
    //add temperature to table
    NSString *text = temp;
    NSMutableArray *rowTypesList = [NSMutableArray array];
    [rowTypesList addObject:@"OrdinaryEventRow"];
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
    
    [self loadTable];
    
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



/**
 * Presents the "goalView" Controller in which the user can set 
 * a goal for their water consumption
 */
-(void)showGoal {
    [self presentControllerWithName:@"goalView" context:nil];
}

//Handle Local Notification Actions
-(void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UNNotification *)localNotification{
    
    //If Pairing amphiro was clicked -> Try to get iOS back in active/Foreground
    if([identifier isEqualToString:@"action"]){
        [self wakeUP];
    }
    
    //If Goal Setting was clicked -> Show Goal Set View
    if([identifier isEqualToString:@"action3"]){
        [self showGoal];
        
    }
}

/**
 * Wakes up the iOS App with SendMessage-Method if iPhone is reachable and
 * provides an alert if not.
 * If iOS is reachable but a synchronisation with amphiro was not successful
 * an alert will also be presented.
 *(Because this is only a prototype and synchronisation with amphiro is not implemented yet a alert will be shown anyway)
 */
- (IBAction)wakeUP {
    
    //Setup WCSession
    if ([WCSession isSupported]) {
        
        _session = [WCSession defaultSession];
        _session.delegate = self;
        [_session activateSession];
        
        //Get the value from slider
        NSString *someString = [[NSUserDefaults standardUserDefaults]
                                stringForKey:@"Update"];
        NSString *Update = @"wakeUp";
        NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[Update] forKeys:@[@"Update"]];
  
        //Send Message to the iPhone (handle over the goal value)
        [[WCSession defaultSession] sendMessage:applicationData
                                   replyHandler:^(NSDictionary *reply) {
                                       //handle reply from iPhone app here
                                       
                                       WKAlertAction *act = [WKAlertAction actionWithTitle:@"OK" style:WKAlertActionStyleCancel handler:^(void){
                                           NSLog(@"ALERT YES ");}];
                                       NSArray *testing = @[act];
                                       [self presentAlertControllerWithTitle:@"Keine Verbindung" message:@"Es konnte leider keine Verbindung zu deinem amphiro hergestellt werden" preferredStyle:WKAlertControllerStyleAlert actions:testing];
                                        }
         
                                   errorHandler:^(NSError *error) {
                                       WKAlertAction *act = [WKAlertAction actionWithTitle:@"OK" style:WKAlertActionStyleCancel handler:^(void){
                                           NSLog(@"ALERT YES ");}];
                                       NSArray *testing = @[act];
                                       [self presentAlertControllerWithTitle:@"Keine Verbindung" message:@"Kein iPhone in der Nähe" preferredStyle:WKAlertControllerStyleAlert actions:testing];
                                   }
         ];
    }
}



/**
 * Same Method as implemented in the Extension Delegate.
 * Called when the session receives context data from the counterpart.
 * Implementation in Interface Controller to handle Application Data in case WatchKit is active.
 */
- (void)session:(WCSession *)session
didReceiveApplicationContext:(nonnull NSDictionary<NSString *,id> *)applicationContext
{
    NSData*jsonData = [applicationContext objectForKey:@"JSONData"];
    NSArray *jsonArray = [NSKeyedUnarchiver unarchiveObjectWithData:jsonData];
    NSString *volume = [[jsonArray objectAtIndex: 0] objectForKey:@"volume"];
    NSString *temp = [[jsonArray  objectAtIndex: 0] objectForKey:@"temperature"];
    NSString *efficiency = [[jsonArray  objectAtIndex: 0] objectForKey:@"heatingEfficiency"];
    [[NSUserDefaults standardUserDefaults] setObject:temp forKey:@"temperature"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:volume forKey:@"volume"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:efficiency forKey:@"heatingEfficiency"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self loadTable];
}


/**
 * Called when the session receives a Message from the counterpart.
 * Watch has to be connected to the iPhone.
 * Receive Messages from iPhone (in this case the JSON data).
 * Gets the latest shower data and stores it as an NSUserDefault (Volume, Temperature, Heating Efficiency).
 *
 */
- (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message replyHandler:(nonnull void (^)(NSDictionary * __nonnull))replyHandler {
    NSData*jsonData = [message objectForKey:@"JSONData"];
    NSArray *jsonArray = [NSKeyedUnarchiver unarchiveObjectWithData:jsonData];
    [[NSUserDefaults standardUserDefaults] setObject:jsonData forKey:@"jsonData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *volume = [[jsonArray objectAtIndex: 0] objectForKey:@"volume"];
    NSString *temp = [[jsonArray objectAtIndex: 0] objectForKey:@"temperature"];
    NSString *efficiency = [[jsonArray objectAtIndex: 0] objectForKey:@"heatingEfficiency"];
    [[NSUserDefaults standardUserDefaults] setObject:temp forKey:@"temperature"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:volume forKey:@"volume"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:efficiency forKey:@"heatingEfficiency"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self loadTable];
    [self awakeWithContext:nil];
}

@end



