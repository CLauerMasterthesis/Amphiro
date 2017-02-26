//
//  OrdinaryEventRow.h
//  Notifications
//
//  Created by Christian Lauer on 18.12.16.
//  Copyright © 2016 Christian Lauer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface OrdinaryEventRow : NSObject

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *label;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *grp;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *table_text;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *plusMinus;


@end
