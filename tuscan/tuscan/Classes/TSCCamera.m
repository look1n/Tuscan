//
//  TSCCamera.m
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

#import "TSCCamera.h"
#import "TSCCameraFlash.h"
#import "TSCCameraFocus.h"
#import "TSCCameraFocusView.h"
#import "TSCCameraShot.h"
#import "TSCCameraToggle.h"


@interface TSCCamera () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureMetadataOutput *metadataOutput;
@property (copy, nonatomic) void (^barcodeHandler)(NSString *barcode);

@end



@implementation TSCCamera


#pragma mark - Instance initialization

-(instancetype) init {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	[self setup];
	
	return self;
}


-(instancetype) initWithDevicePosition:(AVCaptureDevicePosition)devicePosition {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	[self setupWithDevicePosition:devicePosition];
	
	return self;
}



#pragma mark - Memory management

-(void) dealloc {
    self.session = nil;
    self.previewLayer = nil;
    self.stillImageOutput = nil;
	self.metadataOutput = nil;
	self.barcodeHandler = nil;
}


#pragma mark - Public methods

-(void) startRunning {
    [self.session startRunning];
}


-(void) stopRunning {
    [self.session stopRunning];
	[self.previewLayer removeFromSuperlayer];
	self.previewLayer = nil;
}


-(void) previewLayer:(void (^)(AVCaptureVideoPreviewLayer *previewLayer))result {
	if (self.previewLayer) {
		result(self.previewLayer);
		return;
	}
	__weak typeof(self) Self = self;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
		Self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:Self.session];
		Self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			if (result) {
				result(Self.previewLayer);
			}
		});
	});
}


-(void) focusInView:(UIView *)view touchPoint:(CGPoint)touchPoint focusView:(UIView <TSCCameraFocusView> *)focusView {
    [TSCCameraFocus focusWithCaptureSession:self.session
									   view:view
								 touchPoint:touchPoint
								  focusView:focusView];
}


-(void) takePhotoWithCaptureView:(UIView *)captureView videoOrientation:(AVCaptureVideoOrientation)videoOrientation cropSize:(CGSize)cropSize completion:(void (^)(UIImage *))completion {
    [TSCCameraShot takePhotoCaptureView:captureView
					   stillImageOutput:self.stillImageOutput
					   videoOrientation:videoOrientation
							   cropSize:cropSize
							 completion:^(UIImage *photo) {
								 if (completion) {
									 completion(photo);
								 }
							 }];
}


-(void) startSearch:(void (^)(NSString *barcode))completion {
	self.barcodeHandler = completion;
	if (!self.metadataOutput) {
		self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
		[self.session addOutput:self.metadataOutput];
	}

	if (!self.metadataOutput.metadataObjectsDelegate) {
		[self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
		[self.metadataOutput setMetadataObjectTypes:self.barcodeTypes];
	}
}


-(void) stopSearch {
	self.barcodeHandler = nil;
	if (!self.metadataOutput) {
		return;
	}
	[self.metadataOutput setMetadataObjectsDelegate:nil queue:dispatch_get_main_queue()];
}


-(void) setBarcodeTypes:(NSArray *)barcodeTypes {
	_barcodeTypes = barcodeTypes;
	
	[self.metadataOutput setMetadataObjectTypes:self.barcodeTypes];
}


#pragma mark - Private methods

-(void) setup {
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if (!device) {
		return;
	}

	[self configureWithDevice:device];
}


-(void) setupWithDevicePosition:(AVCaptureDevicePosition)devicePosition {
    AVCaptureDevice *device = [self deviceWithPosition:devicePosition];
    if (!device) {
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
	if (!device) {
		return;
	}
	
	[self configureWithDevice:device];
}


-(void) configureWithDevice:(AVCaptureDevice *)device {
	if ([device lockForConfiguration:nil]) {
		if (device.autoFocusRangeRestrictionSupported) {
			device.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
		}
		
		if (device.smoothAutoFocusSupported) {
			device.smoothAutoFocusEnabled = YES;
		}
		
		if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
			device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
		}
		
		device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
		
		[device unlockForConfiguration];
	}
	
	self.session = [[AVCaptureSession alloc] init];
	self.session.sessionPreset = AVCaptureSessionPresetPhoto;
	
	NSError *error = nil;
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (error) {
		NSLog(@"Tuscan: %@", error.localizedDescription);
		return;
	}
	[self.session addInput:deviceInput];
	
	NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
	self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
	self.stillImageOutput.outputSettings = outputSettings;
	[self.session addOutput:self.stillImageOutput];
}


-(AVCaptureDevice *) deviceWithPosition:(AVCaptureDevicePosition)devicePosition {
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices) {
		if (device.position == devicePosition) {
			return device;
		}
	}
	return nil;
}


-(void) captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
	for (AVMetadataObject *metadataObject in metadataObjects) {
		if ([metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
			AVMetadataMachineReadableCodeObject *codeObject = (AVMetadataMachineReadableCodeObject *)metadataObject;
			if (self.barcodeHandler) {
				self.barcodeHandler(codeObject.stringValue);
			}
			return;
		}
	}
}


@end
