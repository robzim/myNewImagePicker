//  SceneDelegate.m
//  GameApp

#import "SceneDelegate.h"

@implementation SceneDelegate

- (void)sceneWillResignActive:(UIScene *)scene {
    // Post notification to pause game when scene becomes inactive (modern lifecycle)
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playpause" object:nil];
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Handle transition to background
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appDidEnterBackground" object:nil];
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Handle transition back to foreground
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appWillEnterForeground" object:nil];
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Handle app becoming active
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appDidBecomeActive" object:nil];
}

@end
