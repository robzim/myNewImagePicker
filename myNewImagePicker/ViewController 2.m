//
//  ViewController.m
//  myNewImagePicker
//
//  Created by Robert Zimmelman on 11/29/14.
//  Copyright (c) 2014 Robert Zimmelman. All rights reserved.
//

#import "ViewController.h"
#import "GameScene.h"



@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSError *myError = nil;
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&myError];
    if (myError) {
        NSLog(@"Error unarchiving: %@", myError);
        return nil;
    }
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    return scene;
}
@end


@implementation ViewController

@synthesize myImage1, myPicker1, myImage2, myPicker2, myImage3, myPicker3, myImage4, myImage5, myPicker4, myPicker5, myCameraPicker1, myCameraPicker2, myCameraPicker3, myCameraPicker4, myCameraPicker5;

@synthesize myTempURL;

@synthesize myTimeRemaining;

//@synthesize mySceneFromTheView;
//@synthesize myViewFromTheScene;

@synthesize myPhotos;
@synthesize myImageManager;

@synthesize backgroundGradient;
@synthesize particleEmitter;
@synthesize lightHaptic;
@synthesize mediumHaptic;
@synthesize selectionHaptic;
@synthesize gradientAnimationTimer;
@synthesize gradientHue;

GameScene *myScene2;
SKView *myView2;

bool myTestMode = NO;

bool myRandomImagesFlag = NO;

float myWidth;
float myViewImageSize;

// Modern UI color palette
#define MAGIC_PURPLE [UIColor colorWithRed:0.4 green:0.2 blue:0.8 alpha:1.0]
#define MAGIC_PINK [UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0]
#define MAGIC_CYAN [UIColor colorWithRed:0.2 green:0.8 blue:1.0 alpha:1.0]
#define MAGIC_GOLD [UIColor colorWithRed:1.0 green:0.85 blue:0.3 alpha:1.0]
#define GLASS_WHITE [UIColor colorWithWhite:1.0 alpha:0.15]
#define GLASS_BORDER [UIColor colorWithWhite:1.0 alpha:0.3]



-(void)myRemoveImageObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"assignimage1" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"assignimage2" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"assignimage3" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"assignimage4" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"assignimage5" object:nil];
    
}


-(void)myAddImageObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage1:) name:@"assignimage1" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage2:) name:@"assignimage2" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage3:) name:@"assignimage3" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage4:) name:@"assignimage4" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myAssignImage5:) name:@"assignimage5" object:nil];
}

#pragma mark - Modern UI Setup

-(void)setupHapticFeedback {
    lightHaptic = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    mediumHaptic = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    selectionHaptic = [[UISelectionFeedbackGenerator alloc] init];
    [lightHaptic prepare];
    [mediumHaptic prepare];
    [selectionHaptic prepare];
}

-(UIColor *)colorFromHue:(CGFloat)hue saturation:(CGFloat)sat brightness:(CGFloat)bright alpha:(CGFloat)alpha {
    return [UIColor colorWithHue:hue saturation:sat brightness:bright alpha:alpha];
}

-(void)setupAnimatedGradientBackground {
    backgroundGradient = [CAGradientLayer layer];
    backgroundGradient.frame = self.view.bounds;

    // Initial cosmic gradient colors
    backgroundGradient.colors = @[
        (id)[UIColor colorWithRed:0.05 green:0.0 blue:0.15 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.15 green:0.05 blue:0.3 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.1 green:0.0 blue:0.25 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.0 green:0.05 blue:0.2 alpha:1.0].CGColor
    ];

    backgroundGradient.locations = @[@0.0, @0.35, @0.7, @1.0];
    backgroundGradient.startPoint = CGPointMake(0, 0);
    backgroundGradient.endPoint = CGPointMake(1, 1);

    [self.view.layer insertSublayer:backgroundGradient atIndex:0];

    // Start gradient animation timer
    gradientHue = 0.0;
    gradientAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(animateGradientColors) userInfo:nil repeats:YES];
}

-(void)animateGradientColors {
    gradientHue += 0.002;
    if (gradientHue > 1.0) gradientHue = 0.0;

    CGFloat baseHue = gradientHue;

    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    backgroundGradient.colors = @[
        (id)[self colorFromHue:baseHue saturation:0.8 brightness:0.15 alpha:1.0].CGColor,
        (id)[self colorFromHue:fmod(baseHue + 0.1, 1.0) saturation:0.7 brightness:0.25 alpha:1.0].CGColor,
        (id)[self colorFromHue:fmod(baseHue + 0.2, 1.0) saturation:0.75 brightness:0.2 alpha:1.0].CGColor,
        (id)[self colorFromHue:fmod(baseHue + 0.3, 1.0) saturation:0.8 brightness:0.1 alpha:1.0].CGColor
    ];

    [CATransaction commit];
}

-(void)setupFloatingParticles {
    particleEmitter = [CAEmitterLayer layer];
    particleEmitter.emitterPosition = CGPointMake(self.view.bounds.size.width / 2, -50);
    particleEmitter.emitterSize = CGSizeMake(self.view.bounds.size.width * 2, 1);
    particleEmitter.emitterShape = kCAEmitterLayerLine;
    particleEmitter.renderMode = kCAEmitterLayerAdditive;

    // Sparkle particles
    CAEmitterCell *sparkle = [CAEmitterCell emitterCell];
    sparkle.birthRate = 3;
    sparkle.lifetime = 12.0;
    sparkle.velocity = 30;
    sparkle.velocityRange = 20;
    sparkle.yAcceleration = 5;
    sparkle.emissionRange = M_PI;
    sparkle.scale = 0.08;
    sparkle.scaleRange = 0.04;
    sparkle.scaleSpeed = -0.002;
    sparkle.alphaSpeed = -0.05;
    sparkle.spin = 0.5;
    sparkle.spinRange = 1.0;
    sparkle.color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8].CGColor;
    sparkle.redRange = 0.3;
    sparkle.greenRange = 0.3;
    sparkle.blueRange = 0.5;
    sparkle.contents = (id)[self createSparkleImage].CGImage;

    // Glowing orbs
    CAEmitterCell *orb = [CAEmitterCell emitterCell];
    orb.birthRate = 1;
    orb.lifetime = 15.0;
    orb.velocity = 15;
    orb.velocityRange = 10;
    orb.yAcceleration = 3;
    orb.emissionRange = M_PI;
    orb.scale = 0.15;
    orb.scaleRange = 0.1;
    orb.alphaSpeed = -0.03;
    orb.color = [UIColor colorWithRed:0.6 green:0.4 blue:1.0 alpha:0.6].CGColor;
    orb.redRange = 0.4;
    orb.blueRange = 0.3;
    orb.contents = (id)[self createGlowImage].CGImage;

    particleEmitter.emitterCells = @[sparkle, orb];
    [self.view.layer insertSublayer:particleEmitter atIndex:1];
}

-(UIImage *)createSparkleImage {
    CGSize size = CGSizeMake(32, 32);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // Create a soft white sparkle
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat colors[] = {1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0};
    CGFloat locations[] = {0.0, 1.0};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 2);

    CGPoint center = CGPointMake(16, 16);
    CGContextDrawRadialGradient(ctx, gradient, center, 0, center, 16, kCGGradientDrawsBeforeStartLocation);

    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage *)createGlowImage {
    CGSize size = CGSizeMake(64, 64);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat colors[] = {0.8, 0.6, 1.0, 0.8, 0.8, 0.6, 1.0, 0.0};
    CGFloat locations[] = {0.0, 1.0};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 2);

    CGPoint center = CGPointMake(32, 32);
    CGContextDrawRadialGradient(ctx, gradient, center, 0, center, 32, kCGGradientDrawsBeforeStartLocation);

    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)styleModernButton:(UIButton *)button withStyle:(NSString *)style {
    // Remove default styling
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    // Standard size for right-side buttons
    CGFloat btnWidth = 90.0;
    CGFloat btnHeight = 36.0;
    CGFloat cornerRadius = btnHeight / 2.0;

    // Center text for right-side styled buttons
    BOOL isRightSideButton = ([style isEqualToString:@"go"] ||
                              [style isEqualToString:@"random"] ||
                              [style isEqualToString:@"refresh"] ||
                              [style isEqualToString:@"secondary"] ||
                              [style isEqualToString:@"quit"]);

    if (isRightSideButton) {
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    }

    if ([style isEqualToString:@"go"]) {
        // Special prominent style for Go button
        button.layer.cornerRadius = cornerRadius;
        button.clipsToBounds = NO;

        // Remove any existing gradient layers
        NSArray *sublayers = [button.layer.sublayers copy];
        for (CALayer *layer in sublayers) {
            if ([layer isKindOfClass:[CAGradientLayer class]]) {
                [layer removeFromSuperlayer];
            }
        }

        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, btnWidth, btnHeight);
        gradient.colors = @[
            (id)[UIColor colorWithRed:1.0 green:0.45 blue:0.55 alpha:1.0].CGColor,
            (id)[UIColor colorWithRed:0.9 green:0.35 blue:0.7 alpha:1.0].CGColor
        ];
        gradient.startPoint = CGPointMake(0, 0);
        gradient.endPoint = CGPointMake(1, 1);
        gradient.cornerRadius = cornerRadius;
        [button.layer insertSublayer:gradient atIndex:0];

        button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];

        // Strong glow effect
        button.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0].CGColor;
        button.layer.shadowOffset = CGSizeMake(0, 2);
        button.layer.shadowRadius = 10;
        button.layer.shadowOpacity = 0.6;

    } else if ([style isEqualToString:@"random"]) {
        // Gradient style for Random button
        button.layer.cornerRadius = cornerRadius;
        button.clipsToBounds = NO;

        // Remove any existing gradient layers
        NSArray *sublayers = [button.layer.sublayers copy];
        for (CALayer *layer in sublayers) {
            if ([layer isKindOfClass:[CAGradientLayer class]]) {
                [layer removeFromSuperlayer];
            }
        }

        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, btnWidth, btnHeight);
        gradient.colors = @[
            (id)[UIColor colorWithRed:0.9 green:0.35 blue:0.7 alpha:1.0].CGColor,
            (id)[UIColor colorWithRed:0.7 green:0.3 blue:0.85 alpha:1.0].CGColor
        ];
        gradient.startPoint = CGPointMake(0, 0);
        gradient.endPoint = CGPointMake(1, 1);
        gradient.cornerRadius = cornerRadius;
        [button.layer insertSublayer:gradient atIndex:0];

        button.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];

        // Glow effect
        button.layer.shadowColor = [UIColor colorWithRed:0.8 green:0.3 blue:0.8 alpha:1.0].CGColor;
        button.layer.shadowOffset = CGSizeMake(0, 2);
        button.layer.shadowRadius = 8;
        button.layer.shadowOpacity = 0.5;

    } else if ([style isEqualToString:@"refresh"]) {
        // Glass style for Refresh button
        button.layer.cornerRadius = cornerRadius;
        button.clipsToBounds = YES;
        button.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.12];
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.25].CGColor;
        button.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];

    } else if ([style isEqualToString:@"secondary"]) {
        // Glass effect for secondary buttons (Music, Help)
        button.layer.cornerRadius = cornerRadius;
        button.clipsToBounds = YES;
        button.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
        button.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];

    } else if ([style isEqualToString:@"action"]) {
        // Clean minimal style for Camera, Library buttons
        button.layer.cornerRadius = 6;
        button.clipsToBounds = YES;
        button.backgroundColor = [UIColor clearColor];
        button.layer.borderWidth = 0;

        [button setTitleColor:[UIColor colorWithRed:0.4 green:0.85 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];

    } else if ([style isEqualToString:@"danger"]) {
        // Clean minimal style for Remove buttons
        button.layer.cornerRadius = 6;
        button.clipsToBounds = YES;
        button.backgroundColor = [UIColor clearColor];
        button.layer.borderWidth = 0;

        [button setTitleColor:[UIColor colorWithRed:1.0 green:0.45 blue:0.5 alpha:1.0] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];

    } else if ([style isEqualToString:@"quit"]) {
        // Quit button - minimal with red text
        button.layer.cornerRadius = cornerRadius;
        button.clipsToBounds = YES;
        button.backgroundColor = [UIColor clearColor];
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.45 alpha:0.4].CGColor;

        [button setTitleColor:[UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    }

    // Add touch animations
    [button addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
}

-(void)buttonTouchDown:(UIButton *)button {
    [lightHaptic impactOccurred];
    [UIView animateWithDuration:0.1 animations:^{
        button.transform = CGAffineTransformMakeScale(0.95, 0.95);
        button.alpha = 0.8;
    }];
}

-(void)buttonTouchUp:(UIButton *)button {
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        button.transform = CGAffineTransformIdentity;
        button.alpha = 1.0;
    } completion:nil];
}

-(void)styleGlassImageView:(UIImageView *)imageView {
    imageView.layer.cornerRadius = 16;
    imageView.layer.masksToBounds = YES;
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;

    // Glass border effect
    imageView.layer.borderWidth = 2;
    imageView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.25].CGColor;

    // Glow shadow
    imageView.layer.shadowColor = [UIColor colorWithRed:0.5 green:0.3 blue:1.0 alpha:1.0].CGColor;
    imageView.layer.shadowOffset = CGSizeMake(0, 4);
    imageView.layer.shadowRadius = 12;
    imageView.layer.shadowOpacity = 0.4;

    // Add subtle background blur effect
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    blurView.frame = imageView.bounds;
    blurView.alpha = 0.3;
    blurView.layer.cornerRadius = 16;
    blurView.layer.masksToBounds = YES;
    [imageView insertSubview:blurView atIndex:0];
}

-(void)styleAllButtons {
    // Find and style all buttons in the view hierarchy
    [self styleButtonsInView:self.view];
}

-(void)styleButtonsInView:(UIView *)view {
    // Collect right-side buttons to resize them uniformly
    NSMutableArray *rightSideButtons = [NSMutableArray array];
    NSMutableDictionary *buttonStyles = [NSMutableDictionary dictionary];

    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            NSString *title = [button titleForState:UIControlStateNormal];

            if ([title isEqualToString:@"Go"]) {
                [rightSideButtons addObject:button];
                buttonStyles[[NSValue valueWithNonretainedObject:button]] = @"go";
                // Replace with play icon
                if (@available(iOS 13.0, *)) {
                    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightBold];
                    UIImage *icon = [UIImage systemImageNamed:@"play.fill" withConfiguration:config];
                    [button setImage:icon forState:UIControlStateNormal];
                    [button setTitle:@"" forState:UIControlStateNormal];
                    button.tintColor = [UIColor whiteColor];
                }
            } else if ([title isEqualToString:@"Random"]) {
                [rightSideButtons addObject:button];
                buttonStyles[[NSValue valueWithNonretainedObject:button]] = @"random";
                // Replace with shuffle/dice icon
                if (@available(iOS 13.0, *)) {
                    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:16 weight:UIImageSymbolWeightSemibold];
                    UIImage *icon = [UIImage systemImageNamed:@"shuffle" withConfiguration:config];
                    [button setImage:icon forState:UIControlStateNormal];
                    [button setTitle:@"" forState:UIControlStateNormal];
                    button.tintColor = [UIColor whiteColor];
                }
            } else if ([title isEqualToString:@"Refresh"]) {
                [rightSideButtons addObject:button];
                buttonStyles[[NSValue valueWithNonretainedObject:button]] = @"refresh";
                // Replace with refresh icon
                if (@available(iOS 13.0, *)) {
                    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:16 weight:UIImageSymbolWeightMedium];
                    UIImage *icon = [UIImage systemImageNamed:@"arrow.clockwise" withConfiguration:config];
                    [button setImage:icon forState:UIControlStateNormal];
                    [button setTitle:@"" forState:UIControlStateNormal];
                    button.tintColor = [UIColor whiteColor];
                }
            } else if ([title isEqualToString:@"Quit"]) {
                [rightSideButtons addObject:button];
                buttonStyles[[NSValue valueWithNonretainedObject:button]] = @"quit";
                // Replace with power/exit icon
                if (@available(iOS 13.0, *)) {
                    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:16 weight:UIImageSymbolWeightMedium];
                    UIImage *icon = [UIImage systemImageNamed:@"power" withConfiguration:config];
                    [button setImage:icon forState:UIControlStateNormal];
                    [button setTitle:@"" forState:UIControlStateNormal];
                    button.tintColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0];
                }
            } else if ([title isEqualToString:@"Music"]) {
                [rightSideButtons addObject:button];
                buttonStyles[[NSValue valueWithNonretainedObject:button]] = @"secondary";
                // Replace with music icon
                if (@available(iOS 13.0, *)) {
                    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:16 weight:UIImageSymbolWeightMedium];
                    UIImage *icon = [UIImage systemImageNamed:@"music.note" withConfiguration:config];
                    [button setImage:icon forState:UIControlStateNormal];
                    [button setTitle:@"" forState:UIControlStateNormal];
                    button.tintColor = [UIColor whiteColor];
                }
            } else if ([title isEqualToString:@"Help"]) {
                [rightSideButtons addObject:button];
                buttonStyles[[NSValue valueWithNonretainedObject:button]] = @"secondary";
                // Replace with help icon
                if (@available(iOS 13.0, *)) {
                    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:16 weight:UIImageSymbolWeightMedium];
                    UIImage *icon = [UIImage systemImageNamed:@"questionmark.circle" withConfiguration:config];
                    [button setImage:icon forState:UIControlStateNormal];
                    [button setTitle:@"" forState:UIControlStateNormal];
                    button.tintColor = [UIColor whiteColor];
                }
            } else if ([title isEqualToString:@"Remove"]) {
                [self styleModernButton:button withStyle:@"danger"];
                // Replace text with SF Symbol icon
                if (@available(iOS 13.0, *)) {
                    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightMedium];
                    UIImage *icon = [UIImage systemImageNamed:@"xmark.circle.fill" withConfiguration:config];
                    [button setImage:icon forState:UIControlStateNormal];
                    [button setTitle:@"" forState:UIControlStateNormal];
                    button.tintColor = [UIColor colorWithRed:1.0 green:0.45 blue:0.5 alpha:1.0];
                }
            } else if ([title isEqualToString:@"Camera"]) {
                [self styleModernButton:button withStyle:@"action"];
                // Replace text with SF Symbol icon
                if (@available(iOS 13.0, *)) {
                    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightMedium];
                    UIImage *icon = [UIImage systemImageNamed:@"camera.fill" withConfiguration:config];
                    [button setImage:icon forState:UIControlStateNormal];
                    [button setTitle:@"" forState:UIControlStateNormal];
                    button.tintColor = [UIColor colorWithRed:0.4 green:0.85 blue:1.0 alpha:1.0];
                }
            } else if ([title isEqualToString:@"Library"]) {
                [self styleModernButton:button withStyle:@"action"];
                // Replace text with SF Symbol icon
                if (@available(iOS 13.0, *)) {
                    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightMedium];
                    UIImage *icon = [UIImage systemImageNamed:@"photo.on.rectangle" withConfiguration:config];
                    [button setImage:icon forState:UIControlStateNormal];
                    [button setTitle:@"" forState:UIControlStateNormal];
                    button.tintColor = [UIColor colorWithRed:0.5 green:0.9 blue:0.5 alpha:1.0];
                }
            }
        } else if ([subview isKindOfClass:[UIStackView class]]) {
            [self styleButtonsInView:subview];
        }
    }

    // Make all right-side buttons the same size, then style them
    if (rightSideButtons.count > 0) {
        CGFloat uniformWidth = 90.0;
        CGFloat uniformHeight = 36.0;

        for (UIButton *button in rightSideButtons) {
            // Set explicit frame for button
            CGRect frame = button.frame;
            frame.size.width = uniformWidth;
            frame.size.height = uniformHeight;
            button.frame = frame;

            // Add size constraints
            button.translatesAutoresizingMaskIntoConstraints = NO;

            // Remove any existing width/height constraints
            NSMutableArray *constraintsToRemove = [NSMutableArray array];
            for (NSLayoutConstraint *constraint in button.constraints) {
                if (constraint.firstAttribute == NSLayoutAttributeWidth ||
                    constraint.firstAttribute == NSLayoutAttributeHeight) {
                    [constraintsToRemove addObject:constraint];
                }
            }
            [button removeConstraints:constraintsToRemove];

            // Add new constraints
            NSLayoutConstraint *widthConstraint = [button.widthAnchor constraintEqualToConstant:uniformWidth];
            NSLayoutConstraint *heightConstraint = [button.heightAnchor constraintEqualToConstant:uniformHeight];
            widthConstraint.priority = UILayoutPriorityRequired;
            heightConstraint.priority = UILayoutPriorityRequired;
            widthConstraint.active = YES;
            heightConstraint.active = YES;

            // Force layout update
            [button layoutIfNeeded];

            // Now apply styling with correct frame
            NSString *style = buttonStyles[[NSValue valueWithNonretainedObject:button]];
            [self styleModernButton:button withStyle:style];
        }
    }
}

-(void)styleAllImageViews {
    [self styleGlassImageView:myImage1];
    [self styleGlassImageView:myImage2];
    [self styleGlassImageView:myImage3];
    [self styleGlassImageView:myImage4];
    [self styleGlassImageView:myImage5];
}

-(void)updateRemoveButtonIcon:(UIButton *)button isRemoved:(BOOL)isRemoved {
    [self updateButtonIconForRemoveState:button isRemoved:isRemoved];
}

-(void)updateButtonIconForRemoveState:(UIButton *)button isRemoved:(BOOL)isRemoved {
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:16 weight:UIImageSymbolWeightMedium];
        if (isRemoved) {
            // Photo is hidden, show "add" icon to restore it
            UIImage *icon = [UIImage systemImageNamed:@"plus.circle.fill" withConfiguration:config];
            [button setImage:icon forState:UIControlStateNormal];
            button.tintColor = [UIColor colorWithRed:0.4 green:0.9 blue:0.5 alpha:1.0]; // Green for add
        } else {
            // Photo is visible, show "remove" icon
            UIImage *icon = [UIImage systemImageNamed:@"xmark.circle.fill" withConfiguration:config];
            [button setImage:icon forState:UIControlStateNormal];
            button.tintColor = [UIColor colorWithRed:1.0 green:0.45 blue:0.5 alpha:1.0]; // Pink/red for remove
        }
    }
}

-(void)updateOverlayRemoveButton:(int)index isRemoved:(BOOL)isRemoved {
    // Find the overlay button by tag (100 + index)
    UIButton *overlayButton = [self.view viewWithTag:100 + index];
    if (overlayButton) {
        [self updateButtonIconForRemoveState:overlayButton isRemoved:isRemoved];
    }
}

-(void)animateEntranceEffects {
    // Start with everything hidden/transformed
    NSArray *imageViews = @[myImage1, myImage2, myImage3, myImage4, myImage5];

    for (int i = 0; i < imageViews.count; i++) {
        UIImageView *imageView = imageViews[i];
        imageView.alpha = 0;
        imageView.transform = CGAffineTransformMakeScale(0.5, 0.5);

        // Staggered animation
        [UIView animateWithDuration:0.6 delay:0.1 * i usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            imageView.alpha = 1.0;
            imageView.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

-(void)addFloatingAnimationToImageViews {
    NSArray *imageViews = @[myImage1, myImage2, myImage3, myImage4, myImage5];

    for (int i = 0; i < imageViews.count; i++) {
        UIImageView *imageView = imageViews[i];

        // Create subtle floating animation
        CABasicAnimation *floatAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        floatAnimation.fromValue = @(-3.0 + (i % 2) * 6.0);
        floatAnimation.toValue = @(3.0 - (i % 2) * 6.0);
        floatAnimation.duration = 2.0 + (i * 0.2);
        floatAnimation.repeatCount = HUGE_VALF;
        floatAnimation.autoreverses = YES;
        floatAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

        [imageView.layer addAnimation:floatAnimation forKey:@"floating"];
    }
}

-(void)viewDidLoad{
    [super viewDidLoad];

    myWidth = self.view.bounds.size.width;
    myViewImageSize = myWidth / 4.0;
    NSLog(@"Width = %f",myWidth);

    // Setup modern UI
    [self setupHapticFeedback];
    [self setupAnimatedGradientBackground];
    [self setupFloatingParticles];

    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];

    myPhotos = [[PHFetchResult alloc] init];
    PHFetchOptions *myFetchOptions = [[PHFetchOptions alloc] init];

    [myFetchOptions setSortDescriptors:(NSArray<NSSortDescriptor *> * _Nullable) @[
                                                                                   [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES selector:NULL]]];
    myPhotos = [PHAsset fetchAssetsWithOptions:myFetchOptions];
    if (myPhotos.count != 0) {
        if (myTestMode) {
            [self myListAllPhotoAssets];
        }
        myImageManager = [[PHImageManager alloc] init];
        [self myAssignImages:self.view];
    }
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // Update gradient frame on layout changes
    backgroundGradient.frame = self.view.bounds;
    particleEmitter.emitterPosition = CGPointMake(self.view.bounds.size.width / 2, -50);
    particleEmitter.emitterSize = CGSizeMake(self.view.bounds.size.width * 2, 1);
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Apply modern styling after views are laid out
    static BOOL hasAppliedStyling = NO;
    if (!hasAppliedStyling) {
        hasAppliedStyling = YES;
        [self reorganizeLayoutForCenteredPhotos];
        [self styleAllButtons];
        [self styleAllImageViews];
        [self animateEntranceEffects];

        // Add floating animation after entrance animation completes
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self addFloatingAnimationToImageViews];
        });
    }
}

-(void)reorganizeLayoutForCenteredPhotos {
    // Find and hide the main stack view
    UIStackView *menuStackView = [self.view viewWithTag:10];
    if (menuStackView) {
        menuStackView.hidden = YES;
    }

    // Hide Music/Help stack too
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIStackView class]] && subview != menuStackView) {
            UIStackView *stack = (UIStackView *)subview;
            if (stack.arrangedSubviews.count == 2) {
                stack.hidden = YES;
            }
        }
    }

    // Create diagonal layout for photos
    [self createDiagonalPhotoLayout];

    // Create side action bar (on right)
    [self createBottomActionBar];

    // Create overlay buttons for each photo
    [self createPhotoOverlayButtons];
}

-(void)createDiagonalPhotoLayout {
    NSArray *imageViews = @[myImage1, myImage2, myImage3, myImage4, myImage5];

    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;

    // Side buttons are 40pt wide + 12pt from edge = 52pt from right
    CGFloat rightMargin = 60; // Space for side buttons
    CGFloat topMargin = 60;   // Safe area at top
    CGFloat bottomMargin = 40; // Safe area at bottom

    // Available space
    CGFloat availableWidth = screenWidth - rightMargin - 10;
    CGFloat availableHeight = screenHeight - topMargin - bottomMargin;

    // Calculate photo size based on width (to fit horizontally with overlap)
    CGFloat horizontalOverlapRatio = 0.28;
    CGFloat photoSize = availableWidth / (horizontalOverlapRatio * 4 + 1);

    // Calculate vertical step to spread across full screen height
    // verticalStep * 4 + photoSize = availableHeight
    CGFloat verticalStep = (availableHeight - photoSize) / 4;
    CGFloat horizontalStep = photoSize * horizontalOverlapRatio;

    // Starting positions
    CGFloat startX = 10;
    CGFloat startY = topMargin;

    for (int i = 0; i < imageViews.count; i++) {
        UIImageView *imageView = imageViews[i];

        // Remove from current parent
        [imageView removeFromSuperview];

        // Reset transform and prepare for manual positioning
        imageView.translatesAutoresizingMaskIntoConstraints = YES;

        // Calculate diagonal position
        CGFloat x = startX + (i * horizontalStep);
        CGFloat y = startY + (i * verticalStep);

        // Set frame for diagonal cascade
        imageView.frame = CGRectMake(x, y, photoSize, photoSize);

        // Ensure proper content mode
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;

        // Add directly to main view
        [self.view addSubview:imageView];
    }

    // Photo 1 on top (front), cascading down to photo 5 at back
    for (int i = (int)imageViews.count - 1; i >= 0; i--) {
        [self.view bringSubviewToFront:imageViews[i]];
    }
}

-(void)createBottomActionBar {
    // Create VERTICAL stack for action buttons on right side
    UIStackView *sideBar = [[UIStackView alloc] init];
    sideBar.axis = UILayoutConstraintAxisVertical;
    sideBar.distribution = UIStackViewDistributionEqualSpacing;
    sideBar.alignment = UIStackViewAlignmentCenter;
    sideBar.spacing = 6;
    sideBar.translatesAutoresizingMaskIntoConstraints = NO;

    // Create action buttons with icons only
    NSArray *buttonConfigs = @[
        @{@"action": @"mySetNoRandomImages:", @"icon": @"play.fill", @"r": @1.0, @"g": @0.4, @"b": @0.6},
        @{@"action": @"myPickFiveImages:", @"icon": @"arrow.clockwise", @"r": @0.7, @"g": @0.7, @"b": @0.8},
        @{@"action": @"mySetRandomImages:", @"icon": @"shuffle", @"r": @0.8, @"g": @0.5, @"b": @1.0},
        @{@"action": @"SelectMusic:", @"icon": @"music.note", @"r": @0.5, @"g": @0.8, @"b": @0.9},
        @{@"action": @"toggleMicMode:", @"icon": @"mic.fill", @"r": @0.3, @"g": @0.9, @"b": @0.7, @"tag": @999},
        @{@"action": @"showHelpScreen", @"icon": @"questionmark.circle", @"r": @0.6, @"g": @0.7, @"b": @0.8},
        @{@"action": @"quitGame:", @"icon": @"power", @"r": @1.0, @"g": @0.5, @"b": @0.5}
    ];

    for (NSDictionary *config in buttonConfigs) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];

        if (@available(iOS 13.0, *)) {
            UIImageSymbolConfiguration *iconConfig = [UIImageSymbolConfiguration configurationWithPointSize:16 weight:UIImageSymbolWeightMedium];
            UIImage *icon = [UIImage systemImageNamed:config[@"icon"] withConfiguration:iconConfig];
            [button setImage:icon forState:UIControlStateNormal];
        }

        UIColor *buttonColor = [UIColor colorWithRed:[config[@"r"] floatValue]
                                               green:[config[@"g"] floatValue]
                                                blue:[config[@"b"] floatValue]
                                               alpha:1.0];
        button.tintColor = buttonColor;
        button.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.85];
        button.layer.cornerRadius = 20;
        button.clipsToBounds = YES;
        button.layer.borderWidth = 1.5;
        button.layer.borderColor = [buttonColor colorWithAlphaComponent:0.4].CGColor;

        SEL selector = NSSelectorFromString(config[@"action"]);
        [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];

        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button.heightAnchor constraintEqualToConstant:40].active = YES;
        [button.widthAnchor constraintEqualToConstant:40].active = YES;

        // Store reference to mic button
        if (config[@"tag"] && [config[@"tag"] intValue] == 999) {
            button.tag = 999;
            self.myMicButton = button;
        }

        [sideBar addArrangedSubview:button];
    }

    [self.view addSubview:sideBar];

    // Position on right side, vertically centered
    [NSLayoutConstraint activateConstraints:@[
        [sideBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-12],
        [sideBar.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [sideBar.widthAnchor constraintEqualToConstant:40]
    ]];

    // Ensure side bar is always on top of photos
    [self.view bringSubviewToFront:sideBar];
}

-(void)createPhotoOverlayButtons {
    NSArray *imageViews = @[myImage1, myImage2, myImage3, myImage4, myImage5];

    // Selectors for each photo's buttons
    NSArray *cameraSelectors = @[@"pickMyImage1:", @"pickMyImage2:", @"pickMyImage3:", @"pickMyImage4:", @"pickMyImage5:"];
    NSArray *removeSelectors = @[@"removeMyImage1:", @"removeMyImage2:", @"removeMyImage3:", @"removeMyImage4:", @"removeMyImage5:"];
    NSArray *librarySelectors = @[@"SelectMyImage1FromLib:", @"SelectMyImage2FromLib:", @"SelectMyImage3FromLib:", @"SelectMyImage4FromLib:", @"SelectMyImage5FromLib:"];

    for (int i = 0; i < imageViews.count; i++) {
        UIImageView *imageView = imageViews[i];

        // Make sure imageView allows user interaction for buttons
        imageView.userInteractionEnabled = YES;

        // Create horizontal stack for the 3 icon buttons
        UIStackView *buttonStack = [[UIStackView alloc] init];
        buttonStack.axis = UILayoutConstraintAxisHorizontal;
        buttonStack.distribution = UIStackViewDistributionFillEqually;
        buttonStack.spacing = 8;
        buttonStack.translatesAutoresizingMaskIntoConstraints = NO;

        // Camera button
        UIButton *cameraBtn = [self createOverlayButton:@"camera.fill"
                                               selector:NSSelectorFromString(cameraSelectors[i])
                                              tintColor:[UIColor colorWithRed:0.4 green:0.85 blue:1.0 alpha:1.0]];

        // Remove button
        UIButton *removeBtn = [self createOverlayButton:@"xmark.circle.fill"
                                               selector:NSSelectorFromString(removeSelectors[i])
                                              tintColor:[UIColor colorWithRed:1.0 green:0.45 blue:0.5 alpha:1.0]];
        removeBtn.tag = 100 + i; // Tag for updating icon later

        // Library button
        UIButton *libraryBtn = [self createOverlayButton:@"photo.on.rectangle"
                                                selector:NSSelectorFromString(librarySelectors[i])
                                               tintColor:[UIColor colorWithRed:0.5 green:0.9 blue:0.5 alpha:1.0]];

        [buttonStack addArrangedSubview:cameraBtn];
        [buttonStack addArrangedSubview:removeBtn];
        [buttonStack addArrangedSubview:libraryBtn];

        // Add buttons overlaying the bottom of the imageView
        buttonStack.translatesAutoresizingMaskIntoConstraints = YES;
        [self.view addSubview:buttonStack];

        // Position buttons at bottom of each photo, overlapping the photo
        CGFloat buttonWidth = 100;
        CGFloat buttonHeight = 26;
        buttonStack.frame = CGRectMake(imageView.frame.origin.x + (imageView.frame.size.width - buttonWidth) / 2,
                                       imageView.frame.origin.y + imageView.frame.size.height - buttonHeight - 6,
                                       buttonWidth, buttonHeight);
    }
}

-(UIButton *)createOverlayButton:(NSString *)iconName selector:(SEL)selector tintColor:(UIColor *)tintColor {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;

    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:14 weight:UIImageSymbolWeightSemibold];
        UIImage *icon = [UIImage systemImageNamed:iconName withConfiguration:config];
        [button setImage:icon forState:UIControlStateNormal];
    }

    button.tintColor = tintColor;
    button.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    button.layer.cornerRadius = 12;
    button.clipsToBounds = YES;
    button.layer.borderWidth = 1.5;
    button.layer.borderColor = [tintColor colorWithAlphaComponent:0.5].CGColor;

    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];

    [button.widthAnchor constraintEqualToConstant:32].active = YES;
    [button.heightAnchor constraintEqualToConstant:24].active = YES;

    return button;
}

-(IBAction)toggleMicMode:(id)sender {
    // Toggle mic mode selection
    self.myMicModeSelected = !self.myMicModeSelected;

    // Update button appearance to show selected state
    if (@available(iOS 13.0, *)) {
        UIColor *micColor = self.myMicModeSelected ?
            [UIColor colorWithRed:0.3 green:1.0 blue:0.7 alpha:1.0] :  // Bright when selected
            [UIColor colorWithRed:0.3 green:0.9 blue:0.7 alpha:1.0];   // Normal

        self.myMicButton.tintColor = micColor;
        self.myMicButton.backgroundColor = self.myMicModeSelected ?
            [UIColor colorWithRed:0.1 green:0.3 blue:0.25 alpha:0.95] :  // Highlighted background
            [UIColor colorWithWhite:0.1 alpha:0.85];
        self.myMicButton.layer.borderWidth = self.myMicModeSelected ? 2.5 : 1.5;
        self.myMicButton.layer.borderColor = [micColor colorWithAlphaComponent:self.myMicModeSelected ? 0.8 : 0.4].CGColor;

        // Animate the button
        [UIView animateWithDuration:0.2 animations:^{
            self.myMicButton.transform = CGAffineTransformMakeScale(1.15, 1.15);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 animations:^{
                self.myMicButton.transform = CGAffineTransformIdentity;
            }];
        }];
    }

    // Haptic feedback
    [lightHaptic impactOccurred];

    NSLog(@"Mic mode %@", self.myMicModeSelected ? @"enabled" : @"disabled");
}

-(void)showMicErrorAlert:(NSNotification *)notification {
    NSString *message = notification.object;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Microphone Error"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];

    // Present on the root view controller to ensure it shows over the game scene
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (rootVC.presentedViewController) {
        rootVC = rootVC.presentedViewController;
    }
    [rootVC presentViewController:alert animated:YES completion:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Stop gradient animation when leaving
    [gradientAnimationTimer invalidate];
    gradientAnimationTimer = nil;
}

-(IBAction) myAssignImage1: (id) sender {
    NSLog(@"View Controller in Assign Image 1");
    if (myPhotos.count<=4) {
        UIAlertController *myNoPhotosAlertController = [UIAlertController alertControllerWithTitle:@"Photos Library" message:@"Grant Access to the Photos Library.  Go to Settings, then to Apps Meny then Select 'TV Photo Chaos' and make sure that 'Always' is selected. Then you will see YOUR PHOTOS in the Game." preferredStyle:UIAlertControllerStyleAlert];
        [myNoPhotosAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self showViewController:myNoPhotosAlertController sender:self];
    } else {
        [myImageManager requestImageForAsset:myPhotos[arc4random()%myPhotos.count] targetSize:CGSizeMake(myViewImageSize, myViewImageSize) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                [self->myImage1 setImage:result];
                [myScene2 setMySpriteImage1:self->myImage1.image];
            } else {
                NSLog(@"error retreiving photo");
            }
            
        }];
    }
}





-(IBAction) myAssignImage2: (id) sender {
    if (myPhotos.count<=4) {
        UIAlertController *myNoPhotosAlertController = [UIAlertController alertControllerWithTitle:@"Photos Library" message:@"Grant Access to the Photos Library.  Go to Settings, then to Apps Meny then Select 'TV Photo Chaos' and make sure that 'Always' is selected. Then you will see YOUR PHOTOS in the Game." preferredStyle:UIAlertControllerStyleAlert];
        [myNoPhotosAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self showViewController:myNoPhotosAlertController sender:self];
    } else {
        
        [myImageManager requestImageForAsset:myPhotos[arc4random()%myPhotos.count] targetSize:CGSizeMake(myViewImageSize, myViewImageSize) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                [self->myImage2 setImage:result];
                [myScene2 setMySpriteImage2:self->myImage2.image];
            } else {
                NSLog(@"error retreiving photo");
            }
        }];
    }
}




-(IBAction) myAssignImage3: (id) sender {
    if (myPhotos.count<=4) {
        UIAlertController *myNoPhotosAlertController = [UIAlertController alertControllerWithTitle:@"Photos Library" message:@"Grant Access to the Photos Library.  Go to Settings, then to Apps Meny then Select 'TV Photo Chaos' and make sure that 'Always' is selected. Then you will see YOUR PHOTOS in the Game." preferredStyle:UIAlertControllerStyleAlert];
        [myNoPhotosAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self showViewController:myNoPhotosAlertController sender:self];
    } else {
        [myImageManager requestImageForAsset:myPhotos[arc4random()%myPhotos.count] targetSize:CGSizeMake(myViewImageSize, myViewImageSize) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                [self->myImage3 setImage:result];
                [myScene2 setMySpriteImage3:self->myImage3.image];
            } else {
                NSLog(@"error retreiving photo");
            }
        }];
    }
    
}


-(IBAction) myAssignImage4: (id) sender {
    if (myPhotos.count<=4) {
        UIAlertController *myNoPhotosAlertController = [UIAlertController alertControllerWithTitle:@"Photos Library" message:@"Grant Access to the Photos Library.  Go to Settings, then to Apps Meny then Select 'TV Photo Chaos' and make sure that 'Always' is selected. Then you will see YOUR PHOTOS in the Game." preferredStyle:UIAlertControllerStyleAlert];
        [myNoPhotosAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self showViewController:myNoPhotosAlertController sender:self];
    }
    else {
        [myImageManager requestImageForAsset:myPhotos[arc4random()%myPhotos.count] targetSize:CGSizeMake(myViewImageSize, myViewImageSize) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                [self->myImage4 setImage:result];
                [myScene2 setMySpriteImage4:self->myImage4.image];
            } else {
                NSLog(@"error retreiving photo");
            }
        }];
    }
}


-(IBAction) myAssignImage5: (id) sender {
    if (myPhotos.count<=4) {
        UIAlertController *myNoPhotosAlertController = [UIAlertController alertControllerWithTitle:@"Photos Library" message:@"Grant Access to the Photos Library.  Go to Settings, then to Apps Meny then Select 'TV Photo Chaos' and make sure that 'Always' is selected. Then you will see YOUR PHOTOS in the Game." preferredStyle:UIAlertControllerStyleAlert];
        [myNoPhotosAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self showViewController:myNoPhotosAlertController sender:self];
    }
    else {
        [myImageManager requestImageForAsset:myPhotos[arc4random()%myPhotos.count] targetSize:CGSizeMake(myViewImageSize, myViewImageSize) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                [self->myImage5 setImage:result];
                [myScene2 setMySpriteImage5:self->myImage5.image];
            } else {
                NSLog(@"error retreiving photo");
            }
        }];
    }
}

- (IBAction)myPickFiveImages:(UIButton *)sender {
    //
    // this is when the user presses the 'Refresh' button
    //
    [self myAssignImage1:self];
    [self myAssignImage2:self];
    [self myAssignImage3:self];
    [self myAssignImage4:self];
    [self myAssignImage5:self];

}

- (IBAction)mySetRandomImages:(id)sender {
    //
    // this is when the user presses the 'Random' button
    [self myPlayGame:self withRandomImages:YES];
}

- (IBAction)mySetNoRandomImages:(UIButton *)sender {
    //
    //
    // this is when the user presses the 'Go' button
    [self myPlayGame:self withRandomImages:NO];
}

-(IBAction) myAssignImages: (id) sender {
    if (myPhotos.count<=4) {
        UIAlertController *myNoPhotosAlertController = [UIAlertController alertControllerWithTitle:@"Photos Library" message:@"Grant Access to the Photos Library.  Go to Settings, then to Apps Meny then Select 'TV Photo Chaos' and make sure that 'Always' is selected. Then you will see YOUR PHOTOS in the Game." preferredStyle:UIAlertControllerStyleAlert];
        [myNoPhotosAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self showViewController:myNoPhotosAlertController sender:self];
    }
    if (myPhotos.count > 4) {
        //    [myPhotos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //        NSLog(@"Object: %@",  (PHAsset *)  obj   );
        //        NSLog(@"Description: %@, #%ld",  (PHAsset *)  [obj description], idx   );
        //    }];
        //    NSLog(@"Photos: %@",myPhotos.description);
        //
        //    NSLog(@"Photos First Object: %@",myPhotos.firstObject);
        
        [self myAssignImage1:self];
        [self myAssignImage2:self];
        [self myAssignImage3:self];
        [self myAssignImage4:self];
        [self myAssignImage5:self];
        [myScene2 myAssignImage1];
        [myScene2 myAssignImage2];
        [myScene2 myAssignImage3];
        [myScene2 myAssignImage4];
        [myScene2 myAssignImage5];
    }
    
}





-(void)photoLibraryDidChange:(PHChange *)changeInstance{
    NSLog(@"View Controller - Photo Library Changed");
}


-(void)myListAllPhotoAssets{
    [myPhotos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@",obj);
    }];
}


-(void)myFetchPhotosFromLibrary{
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    myPhotos = [[PHFetchResult alloc] init];
    //    PHFetchResult *myAlbums = [[PHFetchResult alloc] init];
    //    PHFetchResult *myCollections = [[PHFetchResult alloc] init];
    PHFetchOptions *myFetchOptions = [[PHFetchOptions alloc] init];
    
    [myFetchOptions setSortDescriptors:(NSArray<NSSortDescriptor *> * _Nullable) @[
                                                                                   [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES selector:NULL]]];
    myPhotos = [PHAsset fetchAssetsWithOptions:myFetchOptions];
    
    if (myPhotos.count != 0) {
        if (myTestMode) {
            [self myListAllPhotoAssets];
        }
        
        myImageManager = [[PHImageManager alloc] init];
        
        [self myAssignImages:self.view];
    }
}



-(void)myShowQuitAlertController{
    NSLog(@" in myShowQuitAlertController");

    // Create modern menu overlay
    UIView *menuOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
    menuOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    menuOverlay.tag = 88888;
    menuOverlay.alpha = 0;

    // Create blur background for menu
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    blurView.frame = CGRectMake(20, 80, self.view.bounds.size.width - 40, self.view.bounds.size.height - 160);
    blurView.layer.cornerRadius = 24;
    blurView.clipsToBounds = YES;
    blurView.layer.borderWidth = 1;
    blurView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.2].CGColor;

    // Create scroll view for menu items
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:blurView.bounds];
    scrollView.showsVerticalScrollIndicator = YES;

    // Menu items with icons - "row" key groups items on same row (2 per row)
    NSArray *menuItems = @[
        @{@"title": @"Resume", @"icon": @"play.circle.fill", @"color": @[@0.4, @0.9, @0.5], @"action": @"menuResume", @"row": @0},
        @{@"title": @"Random", @"icon": @"photo.stack.fill", @"color": @[@0.5, @0.8, @1.0], @"action": @"menuRandomPhotos", @"row": @1},
        @{@"title": @"All Photos", @"icon": @"photo.on.rectangle.angled", @"color": @[@0.9, @0.7, @0.4], @"action": @"menuAllPhotos", @"row": @1},
        @{@"title": @"Song", @"icon": @"music.note.list", @"color": @[@1.0, @0.5, @0.8], @"action": @"menuChooseSong", @"row": @2},
        @{@"title": @"Play/Pause", @"icon": @"playpause.fill", @"color": @[@0.6, @0.8, @1.0], @"action": @"menuPlayPause", @"row": @2},
        @{@"title": @"Restart", @"icon": @"arrow.counterclockwise", @"color": @[@0.8, @0.6, @1.0], @"action": @"menuRestartMusic", @"row": @3},
        @{@"title": @"Pulse", @"icon": @"waveform.path", @"color": @[@1.0, @0.6, @0.4], @"action": @"menuPulseSize", @"row": @3},
        @{@"title": @"Instant", @"icon": @"bolt.fill", @"color": @[@1.0, @0.9, @0.3], @"action": @"menuInstantSize", @"row": @4},
        @{@"title": @"No Resize", @"icon": @"lock.fill", @"color": @[@0.7, @0.7, @0.8], @"action": @"menuNoResize", @"row": @4},
        @{@"title": @"Mic Pulse", @"icon": @"mic.fill", @"color": @[@0.3, @0.9, @0.7], @"action": @"menuMicPulse", @"row": @5},
        @{@"title": @"Mic Instant", @"icon": @"mic.badge.plus", @"color": @[@0.2, @0.8, @1.0], @"action": @"menuMicInstant", @"row": @5},
        @{@"title": @"Vibrate", @"icon": @"iphone.radiowaves.left.and.right", @"color": @[@0.5, @1.0, @0.8], @"action": @"menuVibrate", @"row": @6},
        @{@"title": @"Quit", @"icon": @"power", @"color": @[@1.0, @0.4, @0.4], @"action": @"menuQuit", @"row": @6}
    ];

    CGFloat buttonHeight = 46;
    CGFloat padding = 10;
    CGFloat spacing = 8;
    CGFloat halfWidth = (scrollView.bounds.size.width - (padding * 2) - spacing) / 2;
    CGFloat fullWidth = scrollView.bounds.size.width - (padding * 2);
    CGFloat yOffset = padding;

    int currentRow = -1;
    int colIndex = 0;
    NSMutableArray *rowItems = [NSMutableArray array];

    for (int i = 0; i < menuItems.count; i++) {
        NSDictionary *item = menuItems[i];

        // Skip vibrate option if OS version < 10
        if ([item[@"action"] isEqualToString:@"menuVibrate"] && myScene2.myOSVersion < 10) {
            continue;
        }

        int itemRow = [item[@"row"] intValue];

        // Check if this starts a new row
        if (itemRow != currentRow) {
            currentRow = itemRow;
            colIndex = 0;

            // Count items in this row
            [rowItems removeAllObjects];
            for (NSDictionary *checkItem in menuItems) {
                if ([checkItem[@"row"] intValue] == itemRow) {
                    if (!([checkItem[@"action"] isEqualToString:@"menuVibrate"] && myScene2.myOSVersion < 10)) {
                        [rowItems addObject:checkItem];
                    }
                }
            }
        }

        BOOL isFullWidth = (rowItems.count == 1);
        CGFloat buttonWidth = isFullWidth ? fullWidth : halfWidth;
        CGFloat xOffset = isFullWidth ? padding : (padding + colIndex * (halfWidth + spacing));

        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(xOffset, yOffset, buttonWidth, buttonHeight);

        // Style the button
        button.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.9];
        button.layer.cornerRadius = 12;
        button.clipsToBounds = YES;

        // Create icon
        if (@available(iOS 13.0, *)) {
            NSArray *colorComps = item[@"color"];
            UIColor *iconColor = [UIColor colorWithRed:[colorComps[0] floatValue]
                                                 green:[colorComps[1] floatValue]
                                                  blue:[colorComps[2] floatValue]
                                                 alpha:1.0];

            UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightMedium];
            UIImage *icon = [UIImage systemImageNamed:item[@"icon"] withConfiguration:config];

            UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
            iconView.tintColor = iconColor;
            iconView.frame = CGRectMake(12, (buttonHeight - 22) / 2, 22, 22);
            iconView.contentMode = UIViewContentModeScaleAspectFit;
            [button addSubview:iconView];

            // Add border with icon color
            button.layer.borderWidth = 1;
            button.layer.borderColor = [iconColor colorWithAlphaComponent:0.3].CGColor;
        }

        // Create label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, buttonWidth - 50, buttonHeight)];
        label.text = item[@"title"];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        [button addSubview:label];

        // Store action name
        button.accessibilityIdentifier = item[@"action"];
        [button addTarget:self action:@selector(menuItemTapped:) forControlEvents:UIControlEventTouchUpInside];

        [scrollView addSubview:button];

        colIndex++;

        // Move to next row after last item in row
        if (colIndex >= rowItems.count || colIndex >= 2) {
            yOffset += buttonHeight + spacing;
        }
    }

    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, yOffset + padding);
    [blurView.contentView addSubview:scrollView];
    [menuOverlay addSubview:blurView];
    [self.view addSubview:menuOverlay];

    // Animate in
    blurView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
        menuOverlay.alpha = 1;
        blurView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

-(void)menuItemTapped:(UIButton *)sender {
    NSString *action = sender.accessibilityIdentifier;

    // Animate out and remove menu
    UIView *menuOverlay = [self.view viewWithTag:88888];
    [UIView animateWithDuration:0.2 animations:^{
        menuOverlay.alpha = 0;
    } completion:^(BOOL finished) {
        [menuOverlay removeFromSuperview];

        // Execute action
        if ([action isEqualToString:@"menuResume"]) {
            [[myScene2 myDropPicturesTimer] invalidate];
            [myScene2 myStartDropPicturesTimer];
        } else if ([action isEqualToString:@"menuRandomPhotos"]) {
            [myScene2 myAssignImage1];
            [myScene2 myAssignImage2];
            [myScene2 myAssignImage3];
            [myScene2 myAssignImage4];
            [myScene2 myAssignImage5];
        } else if ([action isEqualToString:@"menuAllPhotos"]) {
            [myScene2 setMyAllRandomImagesFlag:YES];
        } else if ([action isEqualToString:@"menuChooseSong"]) {
            // Switch from mic mode to music mode if needed
            [myScene2 myStopMicInput];
            [myScene2 setMyStartedInMicMode:NO];
            [myScene2 setMyResizeMethod:2];  // Music pulse mode
            [self SelectMusic:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedmusic" object:nil];
        } else if ([action isEqualToString:@"menuPlayPause"]) {
            [myScene2 myPlayPause];
        } else if ([action isEqualToString:@"menuRestartMusic"]) {
            [myScene2 myRestartTheMusic];
        } else if ([action isEqualToString:@"menuPulseSize"]) {
            [myScene2 setMyResizeMethod:2];
            [myScene2 setMyStartedInMicMode:NO];
            [myScene2 myStopMicInput];
            [[myScene2 myAudioPlayer] play];
            [myScene2 mySetupAudioDisplay];  // Refresh to show music mode
        } else if ([action isEqualToString:@"menuInstantSize"]) {
            [myScene2 setMyResizeMethod:1];
            [myScene2 setMyStartedInMicMode:NO];
            [myScene2 myStopMicInput];
            [[myScene2 myAudioPlayer] play];
            [myScene2 mySetupAudioDisplay];  // Refresh to show music mode
        } else if ([action isEqualToString:@"menuNoResize"]) {
            [myScene2 setMyResizeMethod:0];
            [myScene2 setMyStartedInMicMode:NO];
            [myScene2 myStopMicInput];
        } else if ([action isEqualToString:@"menuMicPulse"]) {
            [myScene2 setMyResizeMethod:4];
            [myScene2 setMyStartedInMicMode:YES];
            [[myScene2 myAudioPlayer] pause];
            [myScene2 myStartMicInput];
            [myScene2 mySetupAudioDisplay];  // Refresh to show mic mode
        } else if ([action isEqualToString:@"menuMicInstant"]) {
            [myScene2 setMyResizeMethod:3];
            [myScene2 setMyStartedInMicMode:YES];
            [[myScene2 myAudioPlayer] pause];
            [myScene2 myStartMicInput];
            [myScene2 mySetupAudioDisplay];  // Refresh to show mic mode
        } else if ([action isEqualToString:@"menuVibrate"]) {
            myScene2.myVibrateFlag = !myScene2.myVibrateFlag;
        } else if ([action isEqualToString:@"menuQuit"]) {
            exit(0);
        }
    }];
}



- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
{
    NSLog(@"unwound to here");
}


-(void)myShowTimesUpController{
    [myScene2 removeAllChildren];
    [[myScene2 myDropPicturesTimer] invalidate];
//    [myCountdownTimer invalidate];
//    myCountdownTimer=nil;
    //    [myScene2 removeFromParent];
    UIAlertController *myQuitAlertController = [UIAlertController alertControllerWithTitle:@"Time's UP!" message:@"Do you want to Quit or Continue?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *myCancelAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
//        [self myStartCountdownTimer];
        [myScene2 myStartTheGame];
        [[self.view viewWithTag:11111] setHidden:NO];
        [myQuitAlertController removeFromParentViewController];
    }];
    UIAlertAction *myQuitAction = [UIAlertAction actionWithTitle:@"Quit" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        exit(0);
    }];
    [myQuitAlertController addAction:myCancelAction];
    [myQuitAlertController addAction:myQuitAction];
    [self presentViewController:myQuitAlertController animated:YES completion:^{
        [[[self view]viewWithTag:99999] setHidden:YES];
        //
        //
    }];
    
    //Do something interesting here.
    
    
}


- (IBAction)myPlayGame: (id) sender withRandomImages: (BOOL)myRandomImagesFlag{

    // Haptic feedback for game start
    [mediumHaptic impactOccurred];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myShowQuitAlertController) name:@"quitnotifictaion" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMicErrorAlert:) name:@"micError" object:nil];

    // Create magical transition flash
    UIView *flashView = [[UIView alloc] initWithFrame:self.view.bounds];
    flashView.backgroundColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.8 alpha:0.0];
    flashView.alpha = 0;
    [self.view addSubview:flashView];

    // Flash animation
    [UIView animateWithDuration:0.15 animations:^{
        flashView.alpha = 1.0;
        flashView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    } completion:^(BOOL finished) {
        // Setup the game scene during flash
        SKView *skView = [[SKView alloc] initWithFrame:self.view.bounds];
        [skView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        skView.ignoresSiblingOrder = YES;
        skView.alpha = 0;

        // Create and configure the scene
        GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
        if (!scene) {
            scene = [[GameScene alloc] initWithSize:self.view.bounds.size];
        }
        [scene setSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;

        // Set resize method based on mic mode selection
        NSLog(@">>> ViewController: self.myMicModeSelected = %d", self.myMicModeSelected);
        if (self.myMicModeSelected) {
            NSLog(@">>> ViewController: Setting mic mode - myStartedInMicMode=YES, myResizeMethod=4");
            [scene setMyStartedInMicMode:YES];  // Sticky flag - SET THIS FIRST
            [scene setMyResizeMethod:4];  // Mic pulse mode
        } else {
            NSLog(@">>> ViewController: Setting music mode - myStartedInMicMode=NO, myResizeMethod=2");
            [scene setMyStartedInMicMode:NO];
            [scene setMyResizeMethod:2];  // Music pulse mode
        }
        NSLog(@">>> ViewController: After setting - scene.myStartedInMicMode = %d", scene.myStartedInMicMode);

        [scene setMyMusicURL:self->myTempURL];
        [scene setMyTestNumber:[NSNumber numberWithInt:100]];
        NSLog(@"Setting Test Number %@",scene.myTestNumber);
        [scene setMyTestInt:10];
        NSLog(@"Setting Test Int %d",scene.myTestInt);

        // Set images
        [scene setMySpriteImage1:self->myImage1.image];
        [scene setMySpriteImage2:self->myImage2.image];
        [scene setMySpriteImage3:self->myImage3.image];
        [scene setMySpriteImage4:self->myImage4.image];
        [scene setMySpriteImage5:self->myImage5.image];

        // Remove existing subviews and add SKView
        for (UIView *subview in self.view.subviews) {
            if (subview != flashView) {
                [subview removeFromSuperview];
            }
        }
        [self.view insertSubview:skView belowSubview:flashView];

        // Present the scene
        NSLog(@">>> ViewController: About to presentScene - scene.myStartedInMicMode=%d", scene.myStartedInMicMode);
        [skView presentScene:scene];
        NSLog(@">>> ViewController: After presentScene");

        // Store references
        myView2 = skView;
        myScene2 = scene;

        myScene2.mySceneImageSize = myWidth/4.0;

        myScene2.myImage1Flag=self->myImage1.isHighlighted?0:1;
        myScene2.myImage2Flag=self->myImage2.isHighlighted?0:1;
        myScene2.myImage3Flag=self->myImage3.isHighlighted?0:1;
        myScene2.myImage4Flag=self->myImage4.isHighlighted?0:1;
        myScene2.myImage5Flag=self->myImage5.isHighlighted?0:1;

        NSMutableArray *myTempArray = [[NSMutableArray alloc] init];
        if (myScene2.myImage1Flag == 1) {
            [myTempArray addObject:[NSNumber numberWithInt:1]];
        }
        if (myScene2.myImage2Flag == 1) {
            [myTempArray addObject:[NSNumber numberWithInt:2]];
        }
        if (myScene2.myImage3Flag == 1) {
            [myTempArray addObject:[NSNumber numberWithInt:3]];
        }
        if (myScene2.myImage4Flag == 1) {
            [myTempArray addObject:[NSNumber numberWithInt:4]];
        }
        if (myScene2.myImage5Flag == 1) {
            [myTempArray addObject:[NSNumber numberWithInt:5]];
        }

        myScene2.myPicturesArray = [myTempArray copy];

        if (myRandomImagesFlag) {
            [scene setMyAllRandomImagesFlag:YES];
        } else {
            [scene setMyAllRandomImagesFlag:NO];
        }

        [scene myStartTheGame];

        // Fade out flash and reveal game with zoom effect
        skView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            flashView.alpha = 0;
            skView.alpha = 1.0;
            skView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [flashView removeFromSuperview];
        }];
    }];

}


- (IBAction)myPlayGameWithRandomPictures:(UIButton *)sender {
    [myScene2 setMyVibrateFlag:YES];
    [self myPlayGame:self withRandomImages:YES];
}


-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    myTempURL = nil;
    NSLog(@"Temp URL in did cancel %@",myTempURL);
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}




-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    MPMediaItem *item = [mediaItemCollection.items  objectAtIndex:0];
    //    NSLog(@"Media Item in DidPickMediaItems %@",item);
    myTempURL = [item valueForProperty: MPMediaItemPropertyAssetURL];
    //    NSLog (@"URL from Library  %@", myTempURL);
    myScene2.myMusicURL = myTempURL;
    myScene2.mySongTitle = item.title;
    myScene2.mySongArtist = item.artist;
    //    NSLog(@"Media Item Title in DidPickMediaItems %@, Temp URL = %@",item.title ,myReallyTempURL);
    NSLog(@"Media Item Title in DidPickMediaItems %@, URL = %@",item.title ,item.assetURL);
    // let's get the song ready to play in the game
    [mediaPicker dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"musicselected" object:nil];
    }];
}



- (IBAction)SelectMusic:(UIButton *)sender {
    MPMediaPickerController *myMediaPickerController = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
//    MPMediaQuery *myMediaQuery = [MPMediaQuery songsQuery];
    [myMediaPickerController setDelegate:self];
    [myMediaPickerController setAllowsPickingMultipleItems:NO];
    [myMediaPickerController setShowsCloudItems:NO];
    [myMediaPickerController setPrompt:@"Pick a Song!"];
    [self presentViewController:myMediaPickerController animated:YES completion:nil];
}


- (IBAction)SelectMyImage1FromLib:(id)sender {
    myImageNum = 1 ;
    myPicker1 = [[ UIImagePickerController alloc] init];
    myPicker1.delegate = self;
    myPicker1.allowsEditing = YES;
    [myPicker1 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:myPicker1 animated:YES completion:nil];
}

- (IBAction)SelectMyImage2FromLib:(id)sender {
    myImageNum = 2 ;
    myPicker2 = [[ UIImagePickerController alloc] init];
    myPicker2.delegate = self;
    myPicker2.allowsEditing = YES;
    [myPicker2 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:myPicker2 animated:YES completion:nil];
}

- (IBAction)SelectMyImage3FromLib:(id)sender {
    myImageNum = 3 ;
    myPicker3 = [[ UIImagePickerController alloc] init];
    myPicker3.delegate = self;
    myPicker3.allowsEditing = YES;
    [myPicker3 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:myPicker3 animated:YES completion:nil];
}

- (IBAction)SelectMyImage5FromLib:(id)sender {
    myImageNum = 5 ;
    myPicker5 = [[ UIImagePickerController alloc] init];
    myPicker5.delegate = self;
    myPicker5.allowsEditing = YES;
    [myPicker5 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:myPicker5 animated:YES completion:nil];
    
}

- (IBAction)SelectMyImage4FromLib:(id)sender {
    myImageNum = 4 ;
    myPicker4 = [[ UIImagePickerController alloc] init];
    myPicker4.delegate = self;
    myPicker4.allowsEditing = YES;
    [myPicker4 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:myPicker4 animated:YES completion:nil];
}

- (IBAction)pickMyImage1:(id)sender {
    myImageNum = 1 ;
    ///
    //    NSLog(@"just before the test");
    bool myTest1 = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    myCameraPicker1 = [[ UIImagePickerController alloc] init];
    //    NSLog(@"mytest1 = %o",myTest1);
    myCameraPicker1.delegate = self;
    myCameraPicker1.allowsEditing = YES;
    //    NSLog(@"before camera avail check");
    if (myTest1) {
        //        NSLog(@"setting to camera");
        [myCameraPicker1 setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else {
        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"No Camera" message:@"This device has no camera or the camera is disabled.  Select images from the Photo Library." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *myAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [myAlertController addAction:myAlertAction];
        [self presentViewController:myAlertController animated:YES completion:nil ];
        //        NSLog(@"setting to photo library");
        [myCameraPicker1 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [self presentViewController:myCameraPicker1 animated:YES completion:nil];
}



- (IBAction)pickMyImage2:(id)sender {
    myImageNum = 2 ;
    bool myTest1 = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    myCameraPicker2 = [[ UIImagePickerController alloc] init];
    myCameraPicker2.delegate = self;
    myCameraPicker2.allowsEditing = YES;
    if (myTest1) {
        [myCameraPicker2 setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else {
        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"No Camera" message:@"This device has no camera or the camera is disabled.  Select images from the Photo Library." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *myAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [myAlertController addAction:myAlertAction];
        [self presentViewController:myAlertController animated:YES completion:nil ];
        [myCameraPicker2 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [self presentViewController:myCameraPicker2 animated:YES completion:nil];
}

- (IBAction)pickMyImage3:(id)sender {
    myImageNum = 3 ;
    bool myTest1 = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    myCameraPicker3 = [[ UIImagePickerController alloc] init];
    myCameraPicker3.delegate = self;
    myCameraPicker3.allowsEditing = YES;
    if (myTest1) {
        [myCameraPicker3 setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"No Camera" message:@"This device has no camera or the camera is disabled.  Select images from the Photo Library." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *myAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [myAlertController addAction:myAlertAction];
        [self presentViewController:myAlertController animated:YES completion:nil ];
        [myCameraPicker3 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [self presentViewController:myCameraPicker3 animated:YES completion:nil];
    
    
}

- (IBAction)pickMyImage4:(id)sender {
    myImageNum = 4 ;
    bool myTest1 = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    myCameraPicker4 = [[ UIImagePickerController alloc] init];
    myCameraPicker4.delegate = self;
    myCameraPicker4.allowsEditing = YES;
    if (myTest1) {
        [myCameraPicker4 setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"No Camera" message:@"This device has no camera or the camera is disabled.  Select images from the Photo Library." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *myAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [myAlertController addAction:myAlertAction];
        [self presentViewController:myAlertController animated:YES completion:nil ];
        [myCameraPicker4 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [self presentViewController:myCameraPicker4 animated:YES completion:nil];
}

- (IBAction)pickMyImage5:(id)sender {
    myImageNum = 5 ;
    bool myTest1 = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    myCameraPicker5 = [[ UIImagePickerController alloc] init];
    myCameraPicker5.delegate = self;
    myCameraPicker5.allowsEditing = YES;
    if (myTest1) {
        
        //        [myCameraPicker5 setMediaTypes:@[  ]];
        [myCameraPicker5 setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"No Camera" message:@"This device has no camera or the camera is disabled.  Select images from the Photo Library." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *myAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [myAlertController addAction:myAlertAction];
        [self presentViewController:myAlertController animated:YES completion:nil ];
        [myCameraPicker5 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [self presentViewController:myCameraPicker5 animated:YES completion:nil];
}

- (IBAction)removeMyImage1:(id)sender {
    if (myImage1.isHighlighted) {
        [myImage1 setHighlighted:NO];
        [self updateRemoveButtonIcon:(UIButton *)sender isRemoved:NO];
        [self updateOverlayRemoveButton:0 isRemoved:NO];
    } else {
        [myImage1 setHighlighted:YES];
        [self updateRemoveButtonIcon:(UIButton *)sender isRemoved:YES];
        [self updateOverlayRemoveButton:0 isRemoved:YES];
    }
}

- (IBAction)removeMyImage2:(id)sender {
    if (myImage2.isHighlighted) {
        [myImage2 setHighlighted:NO];
        [self updateRemoveButtonIcon:(UIButton *)sender isRemoved:NO];
        [self updateOverlayRemoveButton:1 isRemoved:NO];
    } else {
        [myImage2 setHighlighted:YES];
        [self updateRemoveButtonIcon:(UIButton *)sender isRemoved:YES];
        [self updateOverlayRemoveButton:1 isRemoved:YES];
    }
}

- (IBAction)removeMyImage3:(id)sender {
    if (myImage3.isHighlighted) {
        [myImage3 setHighlighted:NO];
        [self updateRemoveButtonIcon:(UIButton *)sender isRemoved:NO];
        [self updateOverlayRemoveButton:2 isRemoved:NO];
    } else {
        [myImage3 setHighlighted:YES];
        [self updateRemoveButtonIcon:(UIButton *)sender isRemoved:YES];
        [self updateOverlayRemoveButton:2 isRemoved:YES];
    }
}

- (IBAction)removeMyImage4:(id)sender {
    if (myImage4.isHighlighted) {
        [myImage4 setHighlighted:NO];
        [self updateRemoveButtonIcon:(UIButton *)sender isRemoved:NO];
        [self updateOverlayRemoveButton:3 isRemoved:NO];
    } else {
        [myImage4 setHighlighted:YES];
        [self updateRemoveButtonIcon:(UIButton *)sender isRemoved:YES];
        [self updateOverlayRemoveButton:3 isRemoved:YES];
    }
}

- (IBAction)removeMyImage5:(id)sender {
    if (myImage5.isHighlighted) {
        [myImage5 setHighlighted:NO];
        [self updateRemoveButtonIcon:(UIButton *)sender isRemoved:NO];
        [self updateOverlayRemoveButton:4 isRemoved:NO];
    } else {
        [myImage5 setHighlighted:YES];
        [self updateRemoveButtonIcon:(UIButton *)sender isRemoved:YES];
        [self updateOverlayRemoveButton:4 isRemoved:YES];
    }
}



-(void)showHelpScreen {
    // Present help screen from storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *helpVC = [storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    if (helpVC) {
        [self presentViewController:helpVC animated:YES completion:nil];
    }
}

- (IBAction)quitGame:(id)sender {
    exit(0);
}


- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImageView *targetImageView = nil;
    switch (myImageNum) {
        case 1:
            myImage1.image = [ info objectForKey:UIImagePickerControllerEditedImage];
            targetImageView = myImage1;
            break;
        case 2:
            myImage2.image = [ info objectForKey:UIImagePickerControllerEditedImage];
            targetImageView = myImage2;
            break;
        case 3:
            myImage3.image = [ info objectForKey:UIImagePickerControllerEditedImage];
            targetImageView = myImage3;
            break;
        case 4:
            myImage4.image = [ info objectForKey:UIImagePickerControllerEditedImage];
            targetImageView = myImage4;
            break;
        case 5:
            myImage5.image = [ info objectForKey:UIImagePickerControllerEditedImage];
            targetImageView = myImage5;
            break;
        default:
            break;
    }

    // Ensure image view maintains proper sizing and content mode
    if (targetImageView) {
        targetImageView.contentMode = UIViewContentModeScaleAspectFill;
        targetImageView.clipsToBounds = YES;
    }

    [picker dismissViewControllerAnimated:YES completion:nil];
}



- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [ picker dismissViewControllerAnimated:YES completion:nil];
}

//
//
//
//    rz
//   setting prefersStatusBarHidden makes the top of the screen (status bar) hidden so the buttons work all
//    the way to the top of the screen
//
- (BOOL)prefersStatusBarHidden {
    return YES;
}



@end
