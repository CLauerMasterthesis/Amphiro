//
//  ExtensionDelegate.h
//  Notifications WatchKit Extension
//
//  Created by Christian Lauer on 14.12.16.
//  Copyright © 2016 Christian Lauer. All rights reserved.
//

#import "InterfaceController.h"
#import "setGoal.h"
@import WatchConnectivity;
#import <WatchKit/WatchKit.h>

@interface ExtensionDelegate : NSObject <WKExtensionDelegate, WCSessionDelegate>

@end
