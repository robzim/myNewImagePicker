//  SceneDelegate.m
//  GameApp

#import "SceneDelegate.h"

@implementation SceneDelegate

- (void)sceneWillResignActive:(UIScene *)scene {
    // Post notification to pause game when scene becomes inactive (modern lifecycle)
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playpause" object:nil];
}

@end
