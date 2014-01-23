//
//  SOSRotationViewController.m
//  Rotation
//
//  Created by Sam Symons on 1/22/2014.
//  Copyright (c) 2014 Sam Symons. All rights reserved.
//

@import CoreMotion;

#import "SOSRotationViewController.h"

@interface SOSRotationViewController ()

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CALayer *rotatingLayer;

@property (nonatomic, strong) NSOperationQueue *motionQueue;

- (void)beginHandlingGyroscopeData;

@end

@implementation SOSRotationViewController

- (id)init
{
    if (self = [super initWithNibName:nil bundle:nil])
    {
        self.title = NSLocalizedString(@"Rotation", @"Rotation");
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up the rotating layer, centered in its parent view:
    
    CGFloat width = 200;
    CGFloat height = 250;
    
    CGFloat x = (self.view.bounds.size.width / 2) - (width / 2);
    CGFloat y = (self.view.bounds.size.height / 2) - (height / 2);
    
    self.rotatingLayer = [CALayer layer];
    self.rotatingLayer.frame = CGRectMake(x, y, width, height);
    self.rotatingLayer.backgroundColor = [[UIColor colorWithRed:0.78 green:0.91 blue:0.69 alpha:1.0] CGColor];
    self.rotatingLayer.borderColor = [[UIColor colorWithRed:0.59 green:0.82 blue:0.49 alpha:1.0] CGColor];
    self.rotatingLayer.borderWidth = 3.0;
    self.rotatingLayer.cornerRadius = 6.0;
    
    CATextLayer *textLayer = [CATextLayer layer];
    
    textLayer.foregroundColor = [[UIColor whiteColor] CGColor];
    textLayer.frame = CGRectMake(10, 10, width - 20, 50);
    textLayer.contentsScale = [[UIScreen mainScreen] scale];
    textLayer.alignmentMode = kCAAlignmentCenter;
    
    textLayer.string = @"Layer";
    
    [[self rotatingLayer] addSublayer:textLayer];
    
    [[[self view] layer] addSublayer:self.rotatingLayer];
    
    // Add a sublayer transform to the parent view, to add perspective:
    
    CATransform3D perspectiveTransform = CATransform3DIdentity;
    perspectiveTransform.m34 = -1.0 / 1000;
    
    self.view.layer.sublayerTransform = perspectiveTransform;
    
    // Kick off rotation data handling:
    
    [self beginHandlingGyroscopeData];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSOperationQueue *)motionQueue
{
    if (!_motionQueue)
    {
        _motionQueue = [[NSOperationQueue alloc] init];
    }
    
    return _motionQueue;
}

#pragma mark - Private

- (void)beginHandlingGyroscopeData
{
    self.motionManager = [[CMMotionManager alloc] init];
    
    [[self motionManager] startDeviceMotionUpdatesToQueue:self.motionQueue withHandler:^(CMDeviceMotion *motion, NSError *error) {
        CMAttitude *attitude = motion.attitude;
        
        CATransform3D zTransform = CATransform3DMakeRotation(attitude.yaw, 0.0, 0.0, 1.0);
        CATransform3D xTransform = CATransform3DMakeRotation(attitude.pitch, 1.0, 0.0, 0.0);
        
        CATransform3D transform = CATransform3DConcat(zTransform, xTransform);
        CATransform3D yTransform = CATransform3DMakeRotation(-attitude.roll, 0.0, 1.0, 0.0);
        
        transform = CATransform3DConcat(transform, yTransform);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.rotatingLayer.transform = transform;
        });
    }];
}

@end
