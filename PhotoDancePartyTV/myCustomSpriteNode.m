//
//  myCustomSpriteNode.m
//  PhotoDancePartyTV
//
//  Created by Robert Zimmelman.
//  Copyright © 2024 Robert Zimmelman. All rights reserved.
//

#import "myCustomSpriteNode.h"

int myDeallocCount = 0;

@implementation myCustomSpriteNode
@synthesize myResizeValue;

-(void)dealloc{
    myDeallocCount++;
}

@end
