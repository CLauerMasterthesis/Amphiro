//
//  ComplicationController.m
//  Notifications WatchKit Extension
//
//  Created by Christian Lauer on 14.12.16.
//  Copyright © 2016 Christian Lauer. All rights reserved.
//

#import "ComplicationController.h"

@interface ComplicationController ()

@end

@implementation ComplicationController

#pragma mark - Timeline Configuration

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    handler(CLKComplicationTimeTravelDirectionForward|CLKComplicationTimeTravelDirectionBackward);
}

- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    handler(nil);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    handler(nil);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    // Call the handler with the current timeline entry
    handler(nil);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries prior to the given date
    handler(nil);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries after to the given date
    handler(nil);
}

#pragma mark - Placeholder Templates

- (void)getLocalizableSampleTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
    // This method will be called once per supported complication, and the results will be cached
    handler(nil);
}

//Create a simple Complication as a Starter for the App (Is recommended by Apple)
-(void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void (^)(CLKComplicationTemplate * _Nullable))handler{
    
    if (complication.family == CLKComplicationFamilyModularSmall)
    {

        CLKImageProvider *image = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"Modular"]];
        CLKComplicationTemplateModularSmallSimpleImage* textTemplate =
        [[CLKComplicationTemplateModularSmallSimpleImage alloc] init];
        textTemplate.imageProvider = image;
        
        CLKComplicationTemplateModularSmallSimpleText* text = [[CLKComplicationTemplateModularSmallSimpleText alloc]init];
        CLKTextProvider *t =[CLKSimpleTextProvider textProviderWithText:@"--"];
        text.textProvider =t;
        handler(textTemplate);

    }
}

@end
