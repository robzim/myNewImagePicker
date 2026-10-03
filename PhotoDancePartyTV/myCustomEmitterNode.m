//
//  myCustomEmitterNode.m
//  PhotoDancePartyTV
//
//  Created by Robert Zimmelman.
//  Copyright © 2024 Robert Zimmelman. All rights reserved.
//

#import "myCustomEmitterNode.h"

@implementation myCustomEmitterNode {
    int myEmitterNodeResizeValue;
}

-(void)setResizeValue: (int) theValue{
    myEmitterNodeResizeValue = theValue;
}

-(int)myResizeValue{
    return myEmitterNodeResizeValue;
}

@end
