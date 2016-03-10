//
//  TSCCameraFocusView.m
//  tuscan
//
//  Created by Anton Lookin on 09/03/16.
//  Copyright (c) 2016 Anton Lookin. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "TSCCameraFocusView.h"


@interface TSCCameraFocusView ()

@property (nonatomic, weak) UIView *subview;

@end


@implementation TSCCameraFocusView


#pragma mark - Instance initialization

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
		return nil;
	}
	
	self.backgroundColor = [UIColor clearColor];
	self.contentMode = UIViewContentModeScaleToFill;
	
	UIView *subview = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 10.0f, 10.0f)];
	subview.tag = 102;
	
	subview.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
	
	subview.layer.borderWidth = 5;
	subview.layer.cornerRadius = CGRectGetHeight(subview.frame) / 2;
	
	[self addSubview:subview];

	self.subview = subview;
	
    return self;
}


#pragma mark - Public methods

-(void) drawRect:(CGRect)rect {
	CGFloat side = self.frame.size.width;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	[self.tintColor setStroke];
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGMutablePathRef path2 = CGPathCreateMutable();
	CGMutablePathRef path3 = CGPathCreateMutable();
	
	float lineWidth = 3.0f;
	static const CGFloat kMGDegreeToRadianFactor = 0.0174532925;
	
	CGPathAddArc(path, NULL, side / 2.0, side / 2.0, (side - lineWidth) / 2.0, 180.0 * kMGDegreeToRadianFactor, 280.0 * kMGDegreeToRadianFactor, 0);
	CGPathAddArc(path2, NULL, side / 2.0, side / 2.0, (side - lineWidth) / 2.0, 300.0 * kMGDegreeToRadianFactor, 40.0 * kMGDegreeToRadianFactor, 0);
	CGPathAddArc(path3, NULL, side / 2.0, side / 2.0, (side - lineWidth) / 2.0, 60.0 * kMGDegreeToRadianFactor, 160.0 * kMGDegreeToRadianFactor, 0);
	
	CGContextAddPath(context, path);
	CGContextAddPath(context, path2);
	CGContextAddPath(context, path3);
	
	CGContextSetLineWidth(context, lineWidth);
	CGContextStrokePath(context);
}

-(void) setTintColor:(UIColor *)tintColor {
	[super setTintColor:tintColor];
	
	self.subview.layer.borderColor = tintColor.CGColor;
	[self setNeedsDisplay];
}


#pragma mark - Animation Method

-(CAAnimationGroup *) startAnimation {
	CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	CATransform3D fromTransform = CATransform3DIdentity;
	fromTransform = CATransform3DScale(fromTransform, 1.0, 1.0, 1);
	scaleAnimation.fromValue = [NSValue valueWithCATransform3D:fromTransform];
	CATransform3D toTransform = CATransform3DIdentity;
	toTransform = CATransform3DScale(toTransform, 1.1, 1.1, 1);
	scaleAnimation.toValue = [NSValue valueWithCATransform3D:toTransform];
	scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	scaleAnimation.repeatCount = HUGE_VALF;
	scaleAnimation.autoreverses = YES;
	CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeAnimation.fillMode = kCAFillModeForwards;
	fadeAnimation.additive = NO;
	fadeAnimation.fromValue = @1.05f;
	fadeAnimation.toValue = @0.5f;
	CABasicAnimation *rotationAnimation;
	rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
	rotationAnimation.duration = 1.0f;
	rotationAnimation.cumulative = NO;
	rotationAnimation.repeatCount = INFINITY;
	rotationAnimation.removedOnCompletion = NO;
	CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc] init];
	animationGroup.duration = 0.3f;
	animationGroup.fillMode = kCAFillModeForwards;
	animationGroup.autoreverses = YES;
	animationGroup.repeatCount = HUGE_VALF;
	animationGroup.animations = @[scaleAnimation, fadeAnimation, rotationAnimation];
	animationGroup.removedOnCompletion = NO;
	return animationGroup;
}


-(CAAnimationGroup *) stopAnimation {
	CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scaleAnimation.fromValue = @1.0f;
	scaleAnimation.toValue = @0.0f;
	scaleAnimation.fillMode = kCAFillModeForwards;
	scaleAnimation.removedOnCompletion = NO;
	CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeAnimation.fillMode = kCAFillModeForwards;
	fadeAnimation.additive = NO;
	fadeAnimation.fromValue = @1.0f;
	fadeAnimation.toValue = @0.01f;
	CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc] init];
	animationGroup.animations = @[scaleAnimation, fadeAnimation];
	animationGroup.fillMode = kCAFillModeForwards;
	animationGroup.duration = 0.2f;
	animationGroup.removedOnCompletion = NO;
	return animationGroup;
}


@end
