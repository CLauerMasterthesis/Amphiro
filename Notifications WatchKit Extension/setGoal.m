//
//  WKInterfaceController+set_goal.m
//  Amphiro
//
//  Created by Christian Lauer on 31.01.17.
//  Copyright © 2017 Christian Lauer. All rights reserved.
//

#import "setGoal.h"
#import <UIKit/UIKit.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface setGoal()
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceSlider *slider;
@end

/*!
 @setGoal
 
 @brief The setGoal class
 
 @discussion    This class was designed and implemented to help people to set a goal (water consumption), save this value and transfer it to the Watch.
 */
@implementation setGoal

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    //Set the label with a minimum goal value
    [_label1 setText:@"20"];
    //Set UserDefault goal Value per default to 20
    [[NSUserDefaults standardUserDefaults] setObject:@"20" forKey:@"goalValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 * Handles when the user pressed the save button.
 * Goal Value will be transferred to the Watch via background transfer
 * Alert that the value had been saved will be shown.
 */
- (IBAction)save_Goal {
    //Message that value had been saved (at least as NSUserDefault)
    WKAlertAction *act = [WKAlertAction actionWithTitle:@"OK" style:WKAlertActionStyleCancel handler:^(void){
        NSLog(@"ALERT YES ");}];
    NSArray *testing = @[act];
    [self presentAlertControllerWithTitle:@"Gespeichert" message:@"Dein neues Ziel wurde gespeichert" preferredStyle:WKAlertControllerStyleAlert actions:testing];
    //WCSession for data transfer
    WCSession* session = [WCSession defaultSession];
    session.delegate = self;
    [session activateSession];
    //Get the value from slider or default 20 l
    NSString *someString = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"goalValue"];
    NSArray *counterString = [NSArray arrayWithObjects:someString,nil];
    NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[counterString] forKeys:@[@"counterValue"]];
    //Send Message to the iPhone (handle over the goal value)
    NSError *error = nil;
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
}

/**
 * Handles the changes of the slider for goal setting function.
 * Saves the new values as a UserDefault
 @param value Input value of the slider (goal value).
 */
- (IBAction)set_Goal:(float)value {
    NSString *sliderText = [[NSNumber numberWithFloat:value] stringValue];
    //Save the new value as UserDefault
    [[NSUserDefaults standardUserDefaults] setObject:sliderText forKey:@"goalValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //Update View Controller
    [self willActivate:sliderText];
}

/**
 * Updates the label (goal value) if slider value has been changed
 */
- (void)willActivate:(NSString *) sliderText{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    //Update the label (Goal-Value)
    dispatch_async(dispatch_get_main_queue(), ^{
        [_label1 setText:sliderText];
        });
    //Setup WCSession
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}

@end
