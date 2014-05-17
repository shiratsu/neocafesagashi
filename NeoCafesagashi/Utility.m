//
//  Utility.m
//  NeoCafesagashi
//
//  Created by HIRATSUKA SHUNSUKE on 2014/04/19.
//  Copyright (c) 2014年 HIRATSUKA SHUNSUKE. All rights reserved.
//

#import "Utility.h"

@implementation Utility

/**
 *  feedCalcLatLon
 *
 *  @param latitude  <#latitude description#>
 *  @param longitude <#longitude description#>
 *  @param distance  <#distance description#>
 *
 *  @return <#return value description#>
 */
+(NSMutableArray *)feedCalcLatLon:(double )latitude withLatLon:(double )longitude withDistance:(double )distance{
    
    int base = 30;
	double baseDist = 0.000277778;
	
	NSMutableArray *latlonAry = [NSMutableArray array];
	
	double overLat = latitude+(baseDist*distance/base);
	double overLon = longitude+(baseDist*distance/base);
	
	double underLat = latitude-(baseDist*distance/base);
	double underLon = longitude-(baseDist*distance/base);
	[latlonAry addObject:[NSString stringWithFormat:@"%f",underLat]];
	[latlonAry addObject:[NSString stringWithFormat:@"%f",underLon]];
	[latlonAry addObject:[NSString stringWithFormat:@"%f",overLat]];
	[latlonAry addObject:[NSString stringWithFormat:@"%f",overLon]];
    
	return latlonAry;
    
}

@end
