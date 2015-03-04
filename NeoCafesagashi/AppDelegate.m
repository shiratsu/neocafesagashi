//
//  AppDelegate.m
//  NeoCafesagashi
//
//  Created by HIRATSUKA SHUNSUKE on 2014/04/16.
//  Copyright (c) 2014年 HIRATSUKA SHUNSUKE. All rights reserved.
//

#import "AppDelegate.h"
#import "GoogleMapAPIKey.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#if ENABLE_PONYDEBUGGER
#import <PonyDebugger/PonyDebugger.h>
#endif

@implementation AppDelegate{
    id services_;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
#if ENABLE_PONYDEBUGGER
    
    PDDebugger *debugger = [PDDebugger defaultInstance];
    
    // Enable Network debugging, and automatically track network traffic that comes through any classes that implement either NSURLConnectionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate or NSURLSessionDataDelegate methods.
    [debugger enableNetworkTrafficDebugging];
    [debugger forwardAllNetworkTraffic];
    
    // Enable Core Data debugging, and broadcast the main managed object context.
    [debugger enableCoreDataDebugging];
    //[debugger addManagedObjectContext:self.managedObjectContext withName:@"PonyDebugger Test App MOC"];
    
    // Enable View Hierarchy debugging. This will swizzle UIView methods to monitor changes in the hierarchy
    // Choose a few UIView key paths to display as attributes of the dom nodes
    [debugger enableViewHierarchyDebugging];
    [debugger setDisplayedViewAttributeKeyPaths:@[@"frame", @"hidden", @"alpha", @"opaque", @"accessibilityLabel", @"text"]];
    
    // Connect to a specific host
    [debugger connectToURL:[NSURL URLWithString:@"ws://localhost:9000/device"]];
    // Or auto connect via bonjour discovery
    //[debugger autoConnect];
    // Or to a specific ponyd bonjour service
    //[debugger autoConnectToBonjourServiceNamed:@"MY PONY"];
    
    // Enable remote logging to the DevTools Console via PDLog()/PDLogObjects().
    [debugger enableRemoteLogging];
    
#endif
    
    [NewRelicAgent startWithApplicationToken:@"AA36b8e16b17171a669fd081efa83d433273c0ff23"];
    
    // ハンドラを登録
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    
    if ([kAPIKey length] == 0) {
        // Blow up if APIKey has not yet been set.
        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
        NSString *format = @"Configure APIKey inside GoogleMapAPIKey.h for your "
        @"bundle `%@`, see README.GoogleMapsSDKDemos for more information";
        @throw [NSException exceptionWithName:@"AppDelegate"
                                       reason:[NSString stringWithFormat:format, bundleId]
                                     userInfo:nil];
    }
    [GMSServices provideAPIKey:kAPIKey];
    services_ = [GMSServices sharedServices];
    
    // Log the required open source licenses!  Yes, just NSLog-ing them is not
    // enough but is good for a demo.
    NSLog(@"Open source licenses:\n%@", [GMSServices openSourceLicenseInfo]);
    [Fabric with:@[CrashlyticsKit]];
    // Override point for customization after application launch.
    return YES;
}

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"Exception: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
