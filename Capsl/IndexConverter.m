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

@end
