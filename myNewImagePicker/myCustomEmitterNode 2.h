//
//  myCustomEmitterNode.h
//  myNewImagePicker
//
//  Created by Robert Zimmelman on 12/28/16.
//  Copyright © 2016 Robert Zimmelman. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface myCustomEmitterNode : SKEmitterNode
-(void)setResizeValue: (int) theValue;
-(int)myResizeValue;
@end
