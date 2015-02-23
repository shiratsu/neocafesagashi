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
#import "MBProgressHUD.h"
#import "Web.h"
#import <dispatch/dispatch.h>


static const CGFloat CalloutYOffset = 10.0f;
static NSString * const urlKey = @"url";

@interface ViewController ()<GMSMapViewDelegate>
{
    BOOL _pinclflag;
}

@property(strong,nonatomic) IBOutlet GMSMapView *mapView;
@property(weak,nonatomic) IBOutlet GADBannerView *bannerView;
@property(strong,nonatomic) CLLocationManager *lm;
@property(strong,nonatomic) CafeService *cafe;
@property(weak,nonatomic) NSMutableArray *cafeAry;
@property(strong,nonatomic) NSMutableArray *backupAry;
@property (strong, nonatomic) SMCalloutView *calloutView;
@property (strong, nonatomic) UIView *emptyCalloutView;
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
    
    
    
    
    //ピンに表示する情報Window
    self.calloutView = [[SMCalloutView alloc] init];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button addTarget:self
               action:@selector(calloutAccessoryButtonTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    self.calloutView.rightAccessoryView = button;
    
    self.emptyCalloutView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //_mapView = [[GMSMapView alloc] initWithFrame:self.view.bounds];
    _mapView.myLocationEnabled = YES;
    _mapView.delegate = self;
    
    /*
    _bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0,
                                                                   60.0,
                                                                   GAD_SIZE_320x50.width,
                                                                   GAD_SIZE_320x50.height)];
    */
    // 広告ユニット ID を指定する
    _bannerView.adUnitID = @"ca-app-pub-8789201169323567/1907251504";
    _bannerView.rootViewController = self;
    [self.view addSubview:_bannerView];
    
    GADRequest *request = [GADRequest request];
    [_bannerView loadRequest:request];
    
    
    _lm = [[CLLocationManager alloc] init];
    _lm.delegate = self;
    // 取得精度の指定
    _lm.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    // 取得頻度（指定したメートル移動したら再取得する）
    _lm.distanceFilter = 300;    // 5m移動するごとに取得
    
    _defaultRadius = 300;
    _backupAry = [[NSMutableArray alloc] init];
    
    
    
    
    //DBサービス初期化
    _cafe = [[CafeService alloc] init];
    
    
    if([_lm respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [_lm requestWhenInUseAuthorization];
    }
    
    
    //現在地を取得する
    [self startLocation];
	// Do any additional setup after loading the view, typically from a nib.
}




/**
 *  現在地取得を再開
 *
 *  @param sender uibarbuttonitemが入ってる
 */
- (IBAction)reloadPosition:(id)sender {
    [self startLocation];
}


/**
 *  現在地の取得を開始
 */
- (void)startLocation {
    NSLog(@"start to get now position");
    _backupAry = nil;
    _backupAry = [[NSMutableArray alloc] init];
    //NSLog(@"start now location");
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
    
    NSLog(@"get now position");
    // この緯度経度で何かやる・・・
    GMSCameraPosition *now = [GMSCameraPosition cameraWithLatitude:coordinate.latitude longitude:coordinate.longitude zoom:18.0];
    [_mapView setCamera:now];
    
    //緯度経度、検索する範囲をこの時点で保存しておく
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%f",coordinate.latitude] forKey:@"lat"];
	[defaults setObject:[NSString stringWithFormat:@"%f",coordinate.longitude] forKey:@"lon"];
	[defaults setObject:[NSString stringWithFormat:@"%f",_defaultRadius] forKey:@"distance"];
    defaults=nil;
    [self stopLocation];
    //[self searchCafe:coordinate.latitude withLon:coordinate.longitude withDistance:_defaultRadius];
    [_mapView clear];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Background operations
        [self searchCafe:coordinate.latitude withLon:coordinate.longitude withDistance:_defaultRadius];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Main Thread
            [self setCafeAnnotation];
        });
    });
    
    //カフェを検索する
//    dispatch_queue_t global   = dispatch_get_global_queue(0, 0);
//    dispatch_async(global, ^{
//        [self searchCafe:coordinate.latitude withLon:coordinate.longitude withDistance:_defaultRadius];
//    });
    
}

/**
 *  現在地の取得に失敗したら呼ばれる
 *
 *  @param manager <#manager description#>
 *  @param error   <#error description#>
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"failed now location");
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
//    NSLog(@"lat:%f",latitude);
//    NSLog(@"lng:%f",longitude);
//    NSLog(@"distance:%f",distance);
    
    
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
    //[self setCafeAnnotation];
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
 *  ピンをたてる
 */
-(void)setPin{
    
    
    
    //ピンをたてる
    BOOL checkFlag;
    int count = [_cafeAry count];
    
    NSArray* newArray=[NSArray arrayWithArray:_backupAry];
    
    UIImage *pinImage = [UIImage imageNamed:@"pin1"];
    
    for (int i=0; i<[_cafeAry count]; i++) {
        
        NSString *storename = [[_cafeAry objectAtIndex:i] objectForKey:@"store_name"];
        
        //すでに一回セットしてるなら無視
        if([newArray count] > 0){
            
            checkFlag = [newArray containsObject:storename];
            
            
            if(checkFlag == TRUE){
                continue;
            }
        }
        if(storename != nil){
            [_backupAry addObject:storename];
        }
        
        
        double d_lat = [[[_cafeAry objectAtIndex:i] objectForKey:@"lat"] doubleValue];
        double d_lon = [[[_cafeAry objectAtIndex:i] objectForKey:@"lng"] doubleValue];
        
        
        GMSMarker *cafeMarker = [[GMSMarker alloc] init];
        
        cafeMarker.title = [[_cafeAry objectAtIndex:i] objectForKey:@"store_name"];
        cafeMarker.position = CLLocationCoordinate2DMake(d_lat,d_lon);
        cafeMarker.appearAnimation = kGMSMarkerAnimationPop;
        
        
        if(i <= count){
            if([_cafeAry objectAtIndex:i] != nil){
                NSDictionary *markerInfo =
                @{
                  urlKey: [[_cafeAry objectAtIndex:i] objectForKey:@"url"]
                  }
                ;
                cafeMarker.userData = markerInfo;
            }
        }
        

        
        cafeMarker.icon = pinImage;
        cafeMarker.flat = YES;
        cafeMarker.draggable = YES;
        cafeMarker.groundAnchor = CGPointMake(0.5, 0.5);
        cafeMarker.map = _mapView;
    }
    
    
    if([_backupAry count] > 500){
        _backupAry = nil;
        _backupAry = [[NSMutableArray alloc] init];
        _pinclflag = true;
    }
    
    
    
}

/**
 *  カフェのマーカーをつける
 */
-(void)setCafeAnnotation{
    _cafeAry = _cafe.checkListAry;
    
	
	if([_cafeAry count] == 0){
		//NSLog(@"ああああああ");
		return;
	}
    
    //NSLog(@"ary1:%@",_cafeAry);
    
    [self setPin];
    
    //[self setPin];
    
    
//    [NSThread
//     detachNewThreadSelector:@selector(setPin:)
//     toTarget:self
//     withObject:nil];
    
//    [self performSelectorInBackground:@selector(setPin:)
//                           withObject:nil];
    
//    [self performSelectorOnMainThread:@selector(setPin:) withObject:nil waitUntilDone:NO];
    
    
}


- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    CLLocationCoordinate2D anchor = marker.position;
    
    CGPoint point = [mapView.projection pointForCoordinate:anchor];
    
    self.calloutView.title = marker.title;
    
    self.calloutView.calloutOffset = CGPointMake(0, -CalloutYOffset);
    
    self.calloutView.hidden = NO;
    
    CGRect calloutRect = CGRectZero;
    calloutRect.origin = point;
    calloutRect.size = CGSizeZero;
    
    [self.calloutView presentCalloutFromRect:calloutRect
                                      inView:mapView
                           constrainedToView:mapView
                                    animated:YES];
    
    return self.emptyCalloutView;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    self.calloutView.hidden = YES;
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    /* don't move map camera to center marker on tap */
    mapView.selectedMarker = marker;
    return YES;
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
    
    if (self.mapView.selectedMarker) {
        
        GMSMarker *marker = self.mapView.selectedMarker;
        NSDictionary *userData = marker.userData;
        
        //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        
        Web *w = [self.storyboard instantiateViewControllerWithIdentifier:@"web_storyboard"];
        //NSLog(@"%@",userData[urlKey]);
        [w setServiceUrl:userData[urlKey]];
        [self.navigationController pushViewController:w animated:YES];
        w=nil;
    }
    
}

/**
 *  地図の視点変更時（移動や縮尺変更）
 *
 *  @param map_view_ グーグルマップ
 *  @param position_ 位置
 */
-(void)mapView:(GMSMapView*)map_view_ idleAtCameraPosition:(GMSCameraPosition *)position_{
    self.calloutView.hidden = YES;
    //NSLog(@"map move");
    //縮尺を取得
    double zoom = position_.zoom;
    double lat = position_.target.latitude;
    double lng = position_.target.longitude;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%f",lat] forKey:@"lat"];
    [defaults setObject:[NSString stringWithFormat:@"%f",lng] forKey:@"lon"];
    [defaults setObject:[NSString stringWithFormat:@"%f",zoom*30] forKey:@"distance"];
    defaults=nil;
    //NSLog(@"%f",zoom*_defaultRadius);
    //[self searchCafe:lat withLon:lng withDistance:_defaultRadius];
    
    //非同期で検索して、表示は、同期処理で行っている
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Background operations
        [self searchCafe:lat withLon:lng withDistance:_defaultRadius];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Main Thread
            [self setCafeAnnotation];
        });
    });

    
//    dispatch_queue_t global   = dispatch_get_global_queue(0, 0);
//    dispatch_async(global, ^{
//
//        [self searchCafe:lat withLon:lng withDistance:_defaultRadius];
//    });
}


/**
 *  画面が表示になる直前
 *
 *  @param animated アニメーションがあるかどうか
 */
-(void)viewWillappear:(BOOL)animated{
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    NSString *latStr = (NSString*)[defaults objectForKey:@"lat"];
//    NSString *lonStr = (NSString*)[defaults objectForKey:@"lon"];
//    NSString *distanceStr = (NSString*)[defaults objectForKey:@"distance"];
//    
//    double lat = latStr.doubleValue;
//    double lng = lonStr.doubleValue;
//    double distance = distanceStr.doubleValue;
//
//    [self searchCafe:lat withLon:lng withDistance:distance];
    
//    dispatch_queue_t global   = dispatch_get_global_queue(0, 0);
//    dispatch_async(global, ^{
//        [self searchCafe:lat withLon:lng withDistance:distance];
//    }); 
}


/**
 *  画面が非表示になる直前
 *
 *  @param animated アニメーションがあるかどうか
 */
-(void)viewWillDisappear:(BOOL)animated{
    
    //マーカー削除
    [_mapView clear];
    _backupAry = nil;
    _backupAry = [[NSMutableArray alloc] init];
    
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [_mapView clear];
    _backupAry = nil;
    _backupAry = [[NSMutableArray alloc] init];
    
    // Dispose of any resources that can be recreated.
}

@end
