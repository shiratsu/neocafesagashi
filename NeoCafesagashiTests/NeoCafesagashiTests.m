//
//  NeoCafesagashiTests.m
//  NeoCafesagashiTests
//
//  Created by HIRATSUKA SHUNSUKE on 2014/04/16.
//  Copyright (c) 2014年 HIRATSUKA SHUNSUKE. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock.h"
#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Utility.h"
#import "CafeService.h"


// MyClass.hに宣言してないメソッドのカテゴリ
@interface ViewController (Test)

@property(strong,nonatomic) GMSMapView *mapView;
@property(strong,nonatomic) CLLocationManager *lm;
@property(strong,nonatomic) CafeService *cafe;
@property(strong,nonatomic) NSMutableArray *cafeAry;
- (void)startLocation;
- (void)stopLocation;
-(NSString *)createCondDistance:(double )underLat
                   withUnderLon:(double )underLon
                    withOverLat:(double )overLat
                    withOverLon:(double )overLon;
-(void)searchCafe:(double )latitude withLon:(double )longitude withDistance:(double)distance;
-(void)setCafeAnnotation;
-(void)setPin;
@end


@interface NeoCafesagashiTests : XCTestCase
{
    ViewController *vc;
}

@end

@implementation NeoCafesagashiTests{
    
}

- (void)setUp
{
    [super setUp];
    vc = [[ViewController alloc] init];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    //vc = [storyboard instantiateViewControllerWithIdentifier:@"neocafesagashi"];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

/**
 *  viewDidLoadの呼び出しの確認
 */
-(void)testViewDidLoad{
    
    [vc viewDidLoad];
    NSLog(@"LM:%@",vc.lm);
    XCTAssertNotNil(vc.lm, @"cllocationはnilじゃない");
    XCTAssertNotNil(vc.mapView, @"mapView_はnilじゃない");
    
}


/**
 *  カフェの検索
 */
-(void)testSearchCafe{
    
//    ViewController *vc = [[ViewController alloc] init];
    [vc viewDidLoad];
    
    double lat = 36.014982;
    double lng = 139.660778;
    double distance = 5000;
    
    [vc searchCafe:lat withLon:lng withDistance:distance];
//    NSLog(@"aaaaaaaaaaa");
//    
//    NSLog(@"ary1:%@",vc.cafeAry);
    
    XCTAssertNotNil(vc.cafeAry, @"検索がちゃんと出来ている");
}

/**
 *  where句作成のテスト
 */
-(void)testCreateCondDistance{
    
    ViewController *vc = [[ViewController alloc] init];
    
    double lat = 34.389186;
    double lng = 132.462544;
    double distance = 5000;
    
    NSMutableArray *latlonAry = [Utility feedCalcLatLon:lat withLatLon:lng withDistance:distance];
    
    double lat1 = [[latlonAry objectAtIndex:0] doubleValue];
	double lon1 = [[latlonAry objectAtIndex:1] doubleValue];
	double lat2 = [[latlonAry objectAtIndex:2] doubleValue];
	double lon2 = [[latlonAry objectAtIndex:3] doubleValue];
    
    NSString *condDistance = [vc createCondDistance:lat1
										 withUnderLon:lon1
										  withOverLat:lat2
										  withOverLon:lon2];
    XCTAssertNotNil(condDistance, @"where句がちゃんと動いてる");
}



@end
