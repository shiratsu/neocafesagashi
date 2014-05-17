//
//  CafeService.m
//  NeoCafesagashi
//
//  Created by HIRATSUKA SHUNSUKE on 2014/04/29.
//  Copyright (c) 2014年 HIRATSUKA SHUNSUKE. All rights reserved.
//

#import "CafeService.h"
#import "Cafes.h"
#define DBFILE     @"cafesagashi.db"

@interface CafeService ()
- (double)calcDistance:(double )baseLat
		   withBaseLon:(double )baseLon
		withAnotherLat:(double )anotherLat
		withAnotherLon:(double )anotherLon;

@end


@implementation CafeService


/**
 *  条件に合わせたカフェを取得する
 *
 *  @param conditionString where句
 *  @param lat             中心の緯度
 *  @param lon             中心の軽度
 */
-(void)feedCafe:(NSString *)conditionString withLat:(double )lat andlng:(double )lon{
    
    checkListAry = [[NSMutableArray alloc] init];
	
    FMDatabase *db = [self _getDB:DBFILE];
    
    NSString *selectColumn = [self createSelectColumn:@"Cafes"];
    
    NSString *query = [NSString stringWithFormat:@"SELECT %@"
					   " FROM cafes %@",selectColumn,conditionString];
    
    FMResultSet *rs = [db executeQuery:query];
    NSLog(@"%@",query);
    
    while ([rs next]) {
		
        double cafeLat = [[rs stringForColumn:@"lat"] doubleValue];
		double cafeLon = [[rs stringForColumn:@"lng"] doubleValue];
		double distance = [self calcDistance:lat
								 withBaseLon:lon
							  withAnotherLat:cafeLat
							  withAnotherLon:cafeLon];
		
		NSMutableDictionary *hDict = [NSMutableDictionary dictionary];
		
		for (id obj in columnAry) {
			
			if([rs stringForColumn:obj] != nil){
				[hDict setObject:[rs stringForColumn:obj] forKey:obj];
			}else{
				[hDict setObject:@"" forKey:obj];
			}
            [hDict setValue:[NSString stringWithFormat:@"%.2f",distance] forKey:@"distance"];
		}
		
		[checkListAry addObject:hDict];
	}
	NSLog(@"%@",checkListAry);
    return;
}

- (double)calcDistance:(double )baseLat
		   withBaseLon:(double )baseLon
		withAnotherLat:(double )anotherLat
		withAnotherLon:(double )anotherLon{
	
	double distance = 0.0;
	double xDistance = baseLat-anotherLat;
	double yDistance = baseLon-anotherLon;
	double fxabs = fabs(xDistance);
	double fyabs = fabs(yDistance);
	distance = sqrt((fxabs * fxabs) + (fyabs * fyabs))*111;
	distance = [[NSString stringWithFormat:@"%.2f",distance] doubleValue];
	return distance;
}

@end
