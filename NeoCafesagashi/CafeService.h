//
//  CafeService.h
//  NeoCafesagashi
//
//  Created by HIRATSUKA SHUNSUKE on 2014/04/29.
//  Copyright (c) 2014年 HIRATSUKA SHUNSUKE. All rights reserved.
//

#import "SqliteBaseService.h"

@interface CafeService : SqliteBaseService

-(void)feedCafe:(NSString *)conditionString withLat:(double )lat andlng:(double )lon;

@end
