//
//  AppDelegate.h
//  NeoCafesagashi
//
//  Created by HIRATSUKA SHUNSUKE on 2014/04/16.
//  Copyright (c) 2014年 HIRATSUKA SHUNSUKE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIWindow *window;

@end
