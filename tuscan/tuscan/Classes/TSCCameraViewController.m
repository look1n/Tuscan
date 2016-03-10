//
//  TSCCameraViewController.m
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

#import "TSCCameraViewController.h"


@interface TSCCameraViewController ()

-(AVCaptureVideoOrientation) videoOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

@end



@implementation TSCCameraViewController


#pragma mark - Instance intitialization

-(instancetype) initWithDelegate:(id <TSCCameraDelegate>)delegate {
	self = [super initWithNibName:nil bundle:nil];
	if (!self) {
		return nil;
	}
	
	self.delegate = delegate;
	
	return self;
}


#pragma mark - Lifecycle methods

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	[self.camera startRunning];
	[self cameraWillStart];
	if ([self.delegate respondsToSelector:@selector(cameraWillStart)] && (id)self.delegate != self) {
		[self.delegate cameraWillStart];
	}
	
    if (!self.isLoading && !self.isRunning) {
        self.isLoading = YES;
		__weak typeof(self) Self = self;
		[self.camera previewLayer:^(AVCaptureVideoPreviewLayer *previewLayer) {
			CALayer *rootLayer = [Self.captureView layer];
			rootLayer.masksToBounds = YES;
			CGRect frame = Self.captureView.frame;
			previewLayer.frame = frame;
			[rootLayer insertSublayer:previewLayer atIndex:0];
			Self.isLoading = NO;
			Self.isRunning = YES;
			[Self cameraDidStart];
			if ([Self.delegate respondsToSelector:@selector(cameraDidStart)] && (id)Self.delegate != Self) {
				[Self.delegate cameraDidStart];
			}
		}];
    }
}


-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.camera stopRunning];
	self.isLoading = NO;
	self.isRunning = NO;
	
	if ([self.delegate respondsToSelector:@selector(cameraDidStop)] && (id)self.delegate != self) {
		[self.delegate cameraDidStop];
	}
}


-(void) dealloc {
    self.captureView = nil;
    self.camera = nil;
}


#pragma mark - Public methods

-(TSCCamera *) camera {
	if (!_camera) {
		_camera = [[TSCCamera alloc] init];
	}
	
	return _camera;
}


-(BOOL) torchEnabled {
	return [TSCCameraTorch modeForCaptureSession:self.camera.session] == AVCaptureTorchModeOn;
}
	 

-(void) setTorchEnabled:(BOOL)enabled {
	if (enabled) {
		[TSCCameraTorch setMode:AVCaptureTorchModeOn captureSession:self.camera.session];
	} else {
		[TSCCameraTorch setMode:AVCaptureTorchModeOff captureSession:self.camera.session];
	}
}


-(IBAction) toggleTorch {
	self.torchEnabled = !self.torchEnabled;
}


-(void) setRectOfInterest:(CGRect)rectOfInterest {
	self.camera.metadataOutput.rectOfInterest = rectOfInterest;
}


-(IBAction) takeShot {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation videoOrientation = [self videoOrientationForDeviceOrientation:deviceOrientation];
	
	[self cameraWillTakePhoto];
	if ([self.delegate respondsToSelector:@selector(cameraWillTakePhoto)] && (id)self.delegate != self) {
		[self.delegate cameraWillTakePhoto];
	}
	
	__weak typeof(self) Self = self;
	[self.camera takePhotoWithCaptureView:self.captureView
							videoOrientation:videoOrientation
									cropSize:self.captureView.frame.size
							   completion:^(UIImage *photo) {
								   [Self cameraDidTakePhoto:photo];
								   if ([Self.delegate respondsToSelector:@selector(cameraDidTakePhoto:)] && (id)self.delegate != self) {
									   [self.delegate cameraDidTakePhoto:photo];
								   }
							   }];
}


-(void) focusInTouchPoint:(CGPoint)touchPoint {
	[self.camera focusInView:self.captureView touchPoint:touchPoint focusView:self.focusView];
}


-(void) startSearch {
	[self startSearch:NULL];
}


-(void) startSearch:(void (^)(NSString *barcode))completion {
	__weak typeof(self) Self = self;
	[self.camera startSearch:^(NSString *barcode) {
		if (completion) {
			completion(barcode);
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			[Self cameraDidFindBarcode:barcode];
			if ([Self.delegate respondsToSelector:@selector(cameraDidFindBarcode:)] && (id)Self.delegate != self) {
				[Self.delegate cameraDidFindBarcode:barcode];
			}
		});
	}];
}


-(void) stopSearch {
	[self.camera stopSearch];
}


-(void) cameraWillStart {

}


-(void) cameraDidStart {
	
}


-(void) cameraDidStop {

}


-(void) cameraWillTakePhoto {

}


-(void) cameraDidTakePhoto:(UIImage *)photo {
	
}


-(void) cameraDidFindBarcode:(NSString *)barcode {
	
}


#pragma mark - Private methods

-(AVCaptureVideoOrientation) videoOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation) deviceOrientation;
    
    switch (deviceOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            result = AVCaptureVideoOrientationLandscapeRight;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            result = AVCaptureVideoOrientationLandscapeLeft;
            break;
            
        default:
            break;
    }
    
    return result;
}


@end
