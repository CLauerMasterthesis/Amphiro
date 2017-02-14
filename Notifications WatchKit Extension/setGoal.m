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

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *counter;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceSlider *slider;

@end

@implementation setGoal

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    //Set the label with a minimum goal value
    [_label1 setText:@"20"];
}

//Handle save button
- (IBAction)save_Goal {
    
    //WCSession for data transfer
    WCSession* session = [WCSession defaultSession];
    session.delegate = self;
    [session activateSession];
    
    //Get the value from slider
    NSString *someString = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"goalValue"];
    NSArray *counterString = [NSArray arrayWithObjects:someString,nil];
    NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[counterString] forKeys:@[@"counterValue"]];
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

//Handle Slider Input
- (IBAction)set_Goal:(float)value {
    NSString *sliderText = [[NSNumber numberWithFloat:value] stringValue];
    //Save the value as UserDefault
    [[NSUserDefaults standardUserDefaults] setObject:sliderText forKey:@"goalValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //Update View Controller
    [self willActivate:sliderText];
}

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
