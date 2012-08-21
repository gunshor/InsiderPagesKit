//
//  IPKAbstractModel.m
//  InsiderPagesKit
//
//  Created by Truman, Christopher on 8/10/12.
//  Copyright (c) 2012 Nothing Magical. All rights reserved.
//

#import "IPKAbstractModel.h"

@implementation IPKAbstractModel

-(NSString*)formattedTimeElapsedSinceUpdated {
    NSDate *updatedDate = self.updatedAt;
    NSDate *todaysDate = [NSDate date];
    NSInteger days = [IPKAbstractModel daysBetweenDate:updatedDate andDate:todaysDate];
    if (days >= 1) {
        if (days == 1) {
            return [NSString stringWithFormat:@"%d day ago", days];
        }else{
            return [NSString stringWithFormat:@"%d days ago", days];
        }
    }else{
        NSInteger hours = [IPKAbstractModel hoursBetweenDate:updatedDate andDate:todaysDate];
        if (hours >= 1) {
            if (hours == 1) {
                return [NSString stringWithFormat:@"%d hour ago", hours];
            }else{
                return [NSString stringWithFormat:@"%d hours ago", hours];
            }
        }
        else{
            NSInteger minutes = [IPKAbstractModel minutesBetweenDate:updatedDate andDate:todaysDate];
            if (minutes >= 1) {
                if (minutes == 1) {
                    return [NSString stringWithFormat:@"%d minute ago", minutes];
                }else{
                    return [NSString stringWithFormat:@"%d minutes ago", minutes];
                }
            }
            else{
                NSInteger seconds = [IPKAbstractModel secondsBetweenDate:updatedDate andDate:todaysDate];
                if (seconds >= 1) {
                    if (seconds == 1) {
                        return [NSString stringWithFormat:@"%d second ago", seconds];
                    }else{
                        return [NSString stringWithFormat:@"%d seconds ago", seconds];
                    }
                }
                else{
                    return [NSString stringWithFormat:@"%d error", seconds];
                }
            }
        }
    }
}

-(NSString*)formattedTimeElapsedSinceCreated {
    NSDate *updatedDate = self.createdAt;
    NSDate *todaysDate = [NSDate date];
    NSInteger days = [IPKAbstractModel daysBetweenDate:updatedDate andDate:todaysDate];
    if (days >= 1) {
        if (days == 1) {
            return [NSString stringWithFormat:@"%d day ago", days];
        }else{
            return [NSString stringWithFormat:@"%d days ago", days];
        }
    }else{
        NSInteger hours = [IPKAbstractModel hoursBetweenDate:updatedDate andDate:todaysDate];
        if (hours >= 1) {
            if (hours == 1) {
                return [NSString stringWithFormat:@"%d hour ago", hours];
            }else{
                return [NSString stringWithFormat:@"%d hours ago", hours];
            }
        }
        else{
            NSInteger minutes = [IPKAbstractModel minutesBetweenDate:updatedDate andDate:todaysDate];
            if (minutes >= 1) {
                if (minutes == 1) {
                    return [NSString stringWithFormat:@"%d minute ago", minutes];
                }else{
                    return [NSString stringWithFormat:@"%d minutes ago", minutes];
                }
            }
            else{
                NSInteger seconds = [IPKAbstractModel secondsBetweenDate:updatedDate andDate:todaysDate];
                if (seconds >= 1) {
                    if (seconds == 1) {
                        return [NSString stringWithFormat:@"%d second ago", seconds];
                    }else{
                        return [NSString stringWithFormat:@"%d seconds ago", seconds];
                    }
                }
                else{
                    return [NSString stringWithFormat:@"%d error", seconds];
                }
            }
        }
    }
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

+ (NSInteger)hoursBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSHourCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference hour];
}

+ (NSInteger)minutesBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSMinuteCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference minute];
}

+ (NSInteger)secondsBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSSecondCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference second];
}

+(NSString*)defaultSortDescriptors{
    return @"createdAt,remoteID";
}
@end
