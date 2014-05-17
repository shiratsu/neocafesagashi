//
//  Cafes.m
//  NeoCafesagashi
//
//  Created by HIRATSUKA SHUNSUKE on 2014/04/29.
//  Copyright (c) 2014年 HIRATSUKA SHUNSUKE. All rights reserved.
//

#import "Cafes.h"

@implementation Cafes

- (id)init
{
    if(self = [super init]){
		self.columnAry = [[NSArray alloc] initWithObjects:
                          @"id",
                          @"store_name",
                          @"address",
                          @"lat",
                          @"lng",
                          @"url",
                          nil];
    }
    return self;
}


@end
