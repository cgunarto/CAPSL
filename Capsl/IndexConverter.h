//
//  IndexConverter.h
//  Capsl
//
//  Created by Mobile Making on 12/9/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IndexConverter : NSObject

+ (NSIndexPath *)timelineCapsuleIndexPathFromTableViewIndexPath;

+ (NSInteger)indexForSoonestUnopenedCapsuleInArray:(NSArray *)dataArray;

+ (NSInteger)indexForSoonestUnopenedCapsuleInArrayInItsOwnMonth:(NSArray*)dataArray;


@end
