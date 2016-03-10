//
//  TSCCameraFlash.m
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

#import "TSCCameraFlash.h"


@implementation TSCCameraFlash


#pragma mark - Public methods

+(void) changeModeWithCaptureSession:(AVCaptureSession *)session {
	AVCaptureDevice *device = [session.inputs.lastObject device];
	AVCaptureFlashMode mode = [device flashMode];
	switch ([device flashMode]) {
		case AVCaptureFlashModeAuto:
			mode = AVCaptureFlashModeOn;
			break;
			
		case AVCaptureFlashModeOn:
			mode = AVCaptureFlashModeOff;
			break;
			
		case AVCaptureFlashModeOff:
			mode = AVCaptureFlashModeAuto;
			break;
	}
	
	[TSCCameraFlash setMode:mode captureSession:session];
}


+(void) setMode:(AVCaptureFlashMode)mode captureSession:(AVCaptureSession *)session {
	AVCaptureDevice *device = [[session.inputs lastObject] device];
	if ([device isFlashModeSupported:mode] && [device lockForConfiguration:nil]) {
		device.flashMode = mode;
		[device unlockForConfiguration];
	}
}


+(AVCaptureFlashMode) modeForCaptureSession:(AVCaptureSession *)session {
	AVCaptureDevice *device = [[session.inputs lastObject] device];
	return device.flashMode;
}


@end
