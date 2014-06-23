//
//  Web.h
//  NeoCafesagashi
//
//  Created by HIRATSUKA SHUNSUKE on 2014/05/06.
//  Copyright (c) 2014年 HIRATSUKA SHUNSUKE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Web : UIViewController
<UIWebViewDelegate>
{
    __strong NSString *serviceUrl;
    __strong NSString *sequenceNo;
    __strong IBOutlet UIWebView *webView;
}
@property(strong,readwrite) NSString *serviceUrl;
@property(strong,readwrite) NSString *sequenceNo;
@property(strong,readwrite) IBOutlet UIWebView *webView;

@end
