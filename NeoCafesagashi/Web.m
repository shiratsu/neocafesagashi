//
//  Web.m
//  NeoCafesagashi
//
//  Created by HIRATSUKA SHUNSUKE on 2014/05/06.
//  Copyright (c) 2014年 HIRATSUKA SHUNSUKE. All rights reserved.
//

#import "Web.h"
#import <GoogleMobileAds/GADBannerView.h>
#import "Common.h"

@interface Web ()

@property(strong,nonatomic) IBOutlet GADBannerView *bannerView;
@end

@implementation Web
@synthesize serviceUrl;
@synthesize sequenceNo;
@synthesize webView=_webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //NSLog(@"%@",serviceUrl);
    NSURL *url = [NSURL URLWithString:serviceUrl];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:req];
    
    _bannerView.adUnitID = @"ca-app-pub-8789201169323567/1907251504";
    _bannerView.rootViewController = self;
    [self.view addSubview:_bannerView];
    
    GADRequest *request = [GADRequest request];
    [_bannerView loadRequest:request];
}
// ページ読込開始時にインジケータをくるくるさせる
-(void)webViewDidStartLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

// ページ読込完了時にインジケータを非表示にする
-(void)webViewDidFinishLoad:(UIWebView*)webView{
    //NSLog(@"end");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (IBAction)reload:(id)sender {
    [_webView reload];
}
- (IBAction)nextPage:(id)sender {
    [_webView goForward];
}
- (IBAction)back:(id)sender {
    
    [_webView goBack];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
