//
//  TSCCameraFocus.m
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

@import AVFoundation;
@import UIKit;

#import "TSCCameraFocusView.h"
#import "TSCCameraFocus.h"


@interface TSCCameraFocus ()

+(CGPoint) pointOfInterestWithTouchPoint:(CGPoint)touchPoint;

@end


@implementation TSCCameraFocus


#pragma mark - Public methods

+(void) focusWithCaptureSession:(AVCaptureSession *)session view:(UIView *)view touchPoint:(CGPoint)touchPoint focusView:(UIView <TSCCameraFocusView> *)focusView {
	static CAAnimationGroup *stopAnimation = nil;
	
    AVCaptureDevice *device = [[session.inputs lastObject] device];
	
	stopAnimation = nil;
	[focusView.layer removeAnimationForKey:@"startAnimation"];
	[focusView.layer removeAnimationForKey:@"stopAnimation"];
	[focusView removeFromSuperview];
	
	focusView.center = touchPoint;
	[view addSubview:focusView];
	[focusView.layer addAnimation:[focusView startAnimation] forKey:@"startAnimation"];
	
	if ([device lockForConfiguration:nil]) {
		CGPoint pointOfInterest = [self pointOfInterestWithTouchPoint:touchPoint];
		
		if (device.focusPointOfInterestSupported) {
			device.focusPointOfInterest = pointOfInterest;
		}
		
		if (device.exposurePointOfInterestSupported) {
			device.exposurePointOfInterest = pointOfInterest;
		}
		
		if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
			device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
		}
		
		if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
			device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
		}
		
		[device unlockForConfiguration];
	}
	
	__block CAAnimationGroup *runningAnimation = [focusView stopAnimation];
	stopAnimation = runningAnimation;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^(void) {
		[NSThread sleepForTimeInterval:0.1f];
		while ([device isAdjustingWhiteBalance] || [device isAdjustingFocus] || [device isAdjustingExposure]);
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			if (stopAnimation != runningAnimation) {
				return;
			}
			[focusView.layer removeAnimationForKey:@"stopAnimation"];
			[focusView.layer removeAnimationForKey:@"startAnimation"];
			[focusView.layer addAnimation:stopAnimation forKey:@"stopAnimation"];
		});
	});
}


#pragma mark - Private methods

+(CGPoint) pointOfInterestWithTouchPoint:(CGPoint)touchPoint {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGPoint pointOfInterest;
    pointOfInterest.x = touchPoint.x / screenSize.width;
    pointOfInterest.y = touchPoint.y / screenSize.height;
    
    return pointOfInterest;
}


@end
