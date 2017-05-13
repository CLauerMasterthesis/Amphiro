//
//  InterfaceController.h
//  Notifications WatchKit Extension
//
//  Created by Christian Lauer on 14.12.16.
//  Copyright © 2016 Christian Lauer. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h> 


@interface InterfaceController : WKInterfaceController

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *tb;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *tb_text;


-(void)showGoal;

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *image;
@end
