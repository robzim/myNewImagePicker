//
//  myCustomSpriteNode.m
//  TV Photo Chaos
//
//  Created by Robert Zimmelman on 12/2/16.
//  Copyright © 2016 Robert Zimmelman. All rights reserved.
//

#import "myCustomSpriteNode.h"

int myDeallocCount = 0;

@implementation myCustomSpriteNode
@synthesize myResizeValue;

-(void)dealloc{
    myDeallocCount++;
}

@end
