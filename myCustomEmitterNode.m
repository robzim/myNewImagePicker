//
//  myCustomEmitterNode.m
//  TV Photo Chaos
//
//  Created by Robert Zimmelman on 12/28/16.
//  Copyright © 2016 Robert Zimmelman. All rights reserved.
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
