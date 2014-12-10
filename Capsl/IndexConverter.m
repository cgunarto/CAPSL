//
//  IndexConverter.m
//  Capsl
//
//  Created by Mobile Making on 12/9/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "IndexConverter.h"
#import "Capsl.h"

@implementation IndexConverter

+ (NSIndexPath *)timelineCapsuleIndexPathFromTableViewIndexPath
{
    return nil;
}

+ (NSInteger)indexForSoonestUnopenedCapsuleInArray:(NSArray *)dataArray
{
    for (int x = 0; x < dataArray.count; x++)
    {
        Capsl *capsl = dataArray[x];

        if (!capsl.viewedAt)
        {
            return x;
            break;
        }

    }

    return dataArray.count - 1;

}

+ (NSInteger)indexForSoonestUnopenedCapsuleInArrayInItsOwnMonth:(NSArray*)dataArray
{

    Capsl *soonestCapsl = dataArray[[self indexForSoonestUnopenedCapsuleInArray:dataArray]];
    NSInteger year = [soonestCapsl getYearForCapsl];
    NSInteger month = [soonestCapsl getMonthForCapsl];

    NSMutableArray *capslsFromTheSameMonth = [@[] mutableCopy];

    for (Capsl *capsl in dataArray)
    {
        if (([capsl getYearForCapsl] == year) && ([capsl getMonthForCapsl] == month))
        {

            [capslsFromTheSameMonth addObject:capsl];

        }
    }

    NSInteger index = [self indexForSoonestUnopenedCapsuleInArray:capslsFromTheSameMonth];

    return index;

}

@end
