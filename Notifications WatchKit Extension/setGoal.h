//
//  WKInterfaceController+set_goal.h
//  Amphiro
//
//  Created by Christian Lauer on 31.01.17.
//  Copyright © 2017 Christian Lauer. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface setGoal : WKInterfaceController
/*! @brief Displays the goal volume which is entered by the user with the help of a slider*/
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *label1;
@end
