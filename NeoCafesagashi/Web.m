//
//  Web.m
//  NeoCafesagashi
//
//  Created by HIRATSUKA SHUNSUKE on 2014/05/06.
//  Copyright (c) 2014年 HIRATSUKA SHUNSUKE. All rights reserved.
//

#import "Web.h"
#import "GADBannerView.h"

@interface Web ()<UIWebViewDelegate>

@property(weak,nonatomic) IBOutlet UIWebView *webView;
@property(weak,nonatomic) IBOutlet UIToolbar *toolbar;
@property(weak,nonatomic) IBOutlet UIBarButtonItem *back;
@property(weak,nonatomic) IBOutlet UIBarButtonItem *play;
@property(weak,nonatomic) IBOutlet UIBarButtonItem *refresh;
@property(weak,nonatomic) IBOutlet GADBannerView *bannerView;

@end

@implementation Web
@synthesize url;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
