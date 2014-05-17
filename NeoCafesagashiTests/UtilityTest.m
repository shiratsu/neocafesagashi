//
//  UtilityTest.m
//  NeoCafesagashi
//
//  Created by HIRATSUKA SHUNSUKE on 2014/04/26.
//  Copyright (c) 2014年 HIRATSUKA SHUNSUKE. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Utility.h"

@interface UtilityTest : XCTestCase

@end

@implementation UtilityTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

-(void)testIdokeido{
    double lat = 34.389186;
    double lng = 132.462544;
    double distance = 5000;
    XCTAssertNotNil([Utility feedCalcLatLon:lat withLatLon:lng withDistance:distance], "feedCalcLatLon");
}

@end
