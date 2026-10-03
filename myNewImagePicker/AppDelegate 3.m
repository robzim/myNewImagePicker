//
//  AppDelegate.m
//  TV Photo Chaos
//
//  tvOS Application Delegate for Photo Dance Party
//
//  Created by Robert Zimmelman.
//  Copyright (c) 2024 Robert Zimmelman. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Post notification to pause game when app becomes inactive
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playpause" object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Game will pause automatically via notification
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Game will resume when user interacts
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // App became active
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // App is terminating
}

@end
