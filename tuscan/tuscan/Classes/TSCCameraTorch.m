//
//  TSCCameraTorch.m
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

#import "TSCCameraTorch.h"


@implementation TSCCameraTorch


#pragma mark - Public methods

+(void) setMode:(AVCaptureTorchMode)mode captureSession:(AVCaptureSession *)session {
	AVCaptureDevice *device = [[session.inputs lastObject] device];
	if ([device hasTorch] && [device lockForConfiguration:nil]) {
		device.torchMode = mode;
		[device unlockForConfiguration];
	}
}


+(AVCaptureTorchMode) modeForCaptureSession:(AVCaptureSession *)session {
	AVCaptureDevice *device = [[session.inputs lastObject] device];
	return device.torchMode;
}


+(void) setModeOnWithLevel:(float)torchLevel captureSession:(AVCaptureSession *)session {
	AVCaptureDevice *device = [[session.inputs lastObject] device];
	if ([device hasTorch] && [device lockForConfiguration:nil]) {
		if (torchLevel <= 0.0f) {
			[device setTorchMode:AVCaptureTorchModeOff];
			[device unlockForConfiguration];
			return;
		}
		
		if (torchLevel >= 1.0f) {
			torchLevel = AVCaptureMaxAvailableTorchLevel;
		}

		NSError *error = nil;
		BOOL result = [device setTorchModeOnWithLevel:torchLevel error:&error];
		if (error) {
			NSLog(@"Tuscan: %@", [error localizedDescription]);
		}
		if (!result) {
			device.torchMode = AVCaptureTorchModeOn;
		}
		[device unlockForConfiguration];
	}
}


@end
