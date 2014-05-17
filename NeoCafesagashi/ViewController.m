//
//  ViewController.m
//  NeoCafesagashi
//
//  Created by HIRATSUKA SHUNSUKE on 2014/04/16.
//  Copyright (c) 2014年 HIRATSUKA SHUNSUKE. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "GADBannerView.h"
#import "Utility.h"
#import "CafeService.h"
#import <SMCalloutView/SMCalloutView.h>

@interface ViewController ()<GMSMapViewDelegate>

@property(strong,nonatomic) GMSMapView *mapView;
@property(strong,nonatomic) GADBannerView *bannerView;
@property(strong,nonatomic) CLLocationManager *lm;
@property(strong,nonatomic) CafeService *cafe;
@property(weak,nonatomic) NSMutableArray *cafeAry;
@property(strong,nonatomic) NSMutableArray *backupAry;
@property (strong, nonatomic) SMCalloutView *calloutView;
@property(assign) float defaultRadius;
- (void)startLocation;
- (void)stopLocation;
-(void)openMenu:(id)sender;
-(void)reloadPosition:(id)sender;
-(NSString *)createCondDistance:(double )underLat
                   withUnderLon:(double )underLon
                    withOverLat:(double )overLat
                    withOverLon:(double )overLon;
-(void)setCafeAnnotation;
-(void)setPin;
-(void)searchCafe:(double )latitude withLon:(double )longitude withDistance:(double)distance;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mapView = [[GMSMapView alloc] initWithFrame:self.view.bounds];
    _mapView.myLocationEnabled = YES;
    _mapView.delegate = self;
    self.view = _mapView;
    
    _lm = [[CLLocationManager alloc] init];
    _lm.delegate = self;
    // 取得精度の指定
    _lm.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    // 取得頻度（指定したメートル移動したら再取得する）
    _lm.distanceFilter = 300;    // 5m移動するごとに取得
    
    _defaultRadius = 300;
    _backupAry = [[NSMutableArray alloc] init];
    
    //左上にメニューボタン的な何か
    UIBarButtonItem *btn =
    [[UIBarButtonItem alloc]
     initWithTitle:@"MENU" style:UIBarButtonItemStylePlain target:self action:@selector(openMenu:)
     ];
    self.navigationItem.leftBarButtonItem = btn;
    self.navigationItem.title = @"カフェ探し";
    
    //右上に現在地でデータを取得する処理
    UIBarButtonItem *rbtn =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadPosition:)
     ];
    self.navigationItem.rightBarButtonItem = rbtn;
    
    
    
    //DBサービス初期化
    _cafe = [[CafeService alloc] init];
    [_cafe init];
    
    //現在地を取得する
    [self startLocation];
	// Do any additional setup after loading the view, typically from a nib.
}


/**
 *  メニューを開く
 *
 *  @param sender uibarbuttonitemが入ってる
 */
-(void)openMenu:(id)sender{
    
}

/**
 *  現在地取得を再開
 *
 *  @param sender uibarbuttonitemが入ってる
 */
-(void)reloadPosition:(id)sender{
    [self startLocation];
}

/**
 *  現在地の取得を開始
 */
- (void)startLocation {
    [_lm startUpdatingLocation];
}

/**
 *  現在地の取得を終了
 */
- (void)stopLocation {
    [_lm stopUpdatingLocation];
}

/**
 *  現在地の取得を完了したら呼ばれる
 *
 *  @param manager     Locationオブジェクト
 *  @param newLocation 新しい位置
 *  @param oldLocation 古い位置
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = newLocation.coordinate.latitude;
    coordinate.longitude = newLocation.coordinate.longitude;
    //NSLog(@"get now position");
    // この緯度経度で何かやる・・・
    GMSCameraPosition *now = [GMSCameraPosition cameraWithLatitude:coordinate.latitude longitude:coordinate.longitude zoom:17];
    [_mapView setCamera:now];
    
    //緯度経度、検索する範囲をこの時点で保存しておく
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%f",coordinate.latitude] forKey:@"lat"];
	[defaults setObject:[NSString stringWithFormat:@"%f",coordinate.longitude] forKey:@"lon"];
	[defaults setObject:[NSString stringWithFormat:@"%f",_defaultRadius] forKey:@"distance"];
    defaults=nil;
    
    //カフェを検索する
    [self searchCafe:coordinate.latitude withLon:coordinate.longitude withDistance:_defaultRadius];
    
}

/**
 *  現在地の取得に失敗したら呼ばれる
 *
 *  @param manager <#manager description#>
 *  @param error   <#error description#>
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [_lm stopUpdatingLocation];
}

/**
 *  カフェを検索する
 *
 *  @param latitude  現在地の緯度
 *  @param longitude 現在地の軽度
 *  @param distance  現在地から半径どのくらいを検索対象とするか
 */
-(void)searchCafe:(double )latitude withLon:(double )longitude withDistance:(double)distance{
    NSLog(@"lat:%f",latitude);
    NSLog(@"lng:%f",longitude);
    NSLog(@"distance:%f",distance);
    
    
    //半径Xキロに該当する範囲の緯度経度を導きだす
    NSMutableArray *latlonAry = [Utility feedCalcLatLon:latitude withLatLon:longitude withDistance:distance];
    
    double lat1 = [[latlonAry objectAtIndex:0] doubleValue];
	double lon1 = [[latlonAry objectAtIndex:1] doubleValue];
	double lat2 = [[latlonAry objectAtIndex:2] doubleValue];
	double lon2 = [[latlonAry objectAtIndex:3] doubleValue];
    
    NSString *condDistance = [self createCondDistance:lat1
										 withUnderLon:lon1
										  withOverLat:lat2
										  withOverLon:lon2];
    [_cafe feedCafe:condDistance withLat:latitude andlng:longitude];
    
    
    
    //アノテーションつける
    [self setCafeAnnotation];
}

/**
 *  現在地から半径Xメートル以内のデータを取得するwhere句を作成
 *
 *  @param underLat from緯度
 *  @param underLon from軽度
 *  @param overLat  to緯度
 *  @param overLon  to軽度
 *
 *  @return where句
 */
-(NSString *)createCondDistance:(double )underLat
                   withUnderLon:(double )underLon
                    withOverLat:(double )overLat
                    withOverLon:(double )overLon{
    
    NSString *cond = @"where (";
	NSString *latStartCond = @"(";
	NSString *latBetween = [NSString stringWithFormat:@"lat between '%f' and '%f'",underLat,overLat];
	NSString *latEndCond = @")";
	NSString *andCond = @" and ";
	NSString *lonStartCond = @"(";
	NSString *lonBetween = [NSString stringWithFormat:@"lng between '%f' and '%f'",underLon,overLon];
	NSString *lonEndCond = @")";
	NSString *end = @")";
	
	
	cond = [cond stringByAppendingString:latStartCond];
	cond = [cond stringByAppendingString:latBetween];
	cond = [cond stringByAppendingString:latEndCond];
	cond = [cond stringByAppendingString:andCond];
	cond = [cond stringByAppendingString:lonStartCond];
	cond = [cond stringByAppendingString:lonBetween];
	cond = [cond stringByAppendingString:lonEndCond];
	cond = [cond stringByAppendingString:end];
	
	return cond;

}

/**
 *  カフェのマーカーをつける
 */
-(void)setCafeAnnotation{
    _cafeAry = [_cafe checkListAry];
	
	if([_cafeAry count] == 0){
		//NSLog(@"ああああああ");
		return;
	}
    
    //NSLog(@"ary1:%@",_cafeAry);
    [self setPin];
    
}

/**
 *  ピンをたてる
 */
-(void)setPin{
    NSLog(@"ary2:%@",_cafeAry);
    //ピンをたてる
    BOOL checkFlag;
    for (int i=0; i<[_cafeAry count]; i++) {
        
        //すでに一回セットしてるなら無視
        if([_backupAry count] > 0){
            
            checkFlag = [_backupAry containsObject:[[_cafeAry objectAtIndex:i] objectForKey:@"store_name"]];
            
            
            if(checkFlag == TRUE){
                continue;
            }
        }
        [_backupAry addObject:[[_cafeAry objectAtIndex:i] objectForKey:@"store_name"]];
        
        double d_lat = [[[_cafeAry objectAtIndex:i] objectForKey:@"lat"] doubleValue];
        double d_lon = [[[_cafeAry objectAtIndex:i] objectForKey:@"lng"] doubleValue];
        
                
        GMSMarker *cafeMarker = [[GMSMarker alloc] init];
        
        cafeMarker.title = [[_cafeAry objectAtIndex:i] objectForKey:@"store_name"];
        cafeMarker.position = CLLocationCoordinate2DMake(d_lat,d_lon);
        cafeMarker.appearAnimation = kGMSMarkerAnimationPop;
        cafeMarker.flat = YES;
        cafeMarker.draggable = YES;
        cafeMarker.groundAnchor = CGPointMake(0.5, 0.5);
        cafeMarker.map = _mapView;
    }
    
}

/**
 *  マーカーのウィンドウをタップした際に通知される。(結論使わない)
 *  ここに画面遷移を追記する
 *  @param mapView google map
 *  @param marker  gms marker
 */
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(id)marker{
    
}


/**
 *  マーカーのウィンドウをタップした際に通知される。(結論使わない)
 *
 *  @param sender 多分マーカー
 */
- (void)calloutAccessoryButtonTapped:(id)sender {
    
}

/**
 *  地図の視点変更時（移動や縮尺変更）
 *
 *  @param map_view_ グーグルマップ
 *  @param position_ 位置
 */
-(void)mapView:(GMSMapView*)map_view_ didChangeCameraPosition:(GMSCameraPosition *)position_{
    NSLog(@"map move");
    //縮尺を取得
    double zoom = position_.zoom;
    double lat = position_.target.latitude;
    double lng = position_.target.longitude;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%f",lat] forKey:@"lat"];
    [defaults setObject:[NSString stringWithFormat:@"%f",lng] forKey:@"lon"];
    [defaults setObject:[NSString stringWithFormat:@"%f",zoom*_defaultRadius] forKey:@"distance"];
    defaults=nil;

    [self searchCafe:lat withLon:lng withDistance:_defaultRadius];
    
}


/**
 *  画面が非表示になる直前
 *
 *  @param animated アニメーションがあるかどうか
 */
-(void)viewWillDisappear:(BOOL)animated{
    
    //マーカー削除
    [_mapView clear];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _backupAry = nil;
    // Dispose of any resources that can be recreated.
}

@end
