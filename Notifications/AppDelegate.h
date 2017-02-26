//
//  AppDelegate.h
//  Notifications
//
//  Created by Christian Lauer on 14.12.16.
//  Copyright © 2016 Christian Lauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
@import WatchConnectivity;
#import <WatchKit/WatchKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, WCSessionDelegate>

@property (strong, nonatomic) UIWindow *window;

//For saving Data in User Default-Array
-(void)saveData:(NSArray*)array;

@end

