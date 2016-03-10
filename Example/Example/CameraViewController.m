//
//  CameraViewController.m
//  Campibara
//
//  Created by Anton Lookin on 3/4/16.
//  Copyright © 2016 NimbleCommerce. All rights reserved.
//

#import "CameraFocusView.h"

#import "CameraViewController.h"


@interface CameraViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;

@end


@implementation CameraViewController


#pragma mark - Lifecycle methods

-(void) viewDidLoad {
	[super viewDidLoad];
	
	self.camera.barcodeTypes = @[AVMetadataObjectTypeQRCode];
	self.tapGestureRecognizer.enabled = NO;
	self.torchButton.enabled = NO;
	
	self.focusView = [[CameraFocusView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
}


-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceOrientationDidChangeNotification:)
												 name:UIDeviceOrientationDidChangeNotification
											   object:nil];
}


-(BOOL) prefersStatusBarHidden {
	return NO;
}


-(UIStatusBarStyle) preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}


-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self deviceOrientationDidChangeNotification:nil];
	self.rectOfInterest = CGRectMake(0.1f, 0.25f, 0.8f, 0.65f);
}


#pragma mark - Private methods

-(void) setRectOfInterest:(CGRect)rectOfInterest {
	[super setRectOfInterest:rectOfInterest];
	
	CGRect scanFrame;
	scanFrame.origin.x = rectOfInterest.origin.x * self.captureView.frame.size.width;
	scanFrame.origin.y = rectOfInterest.origin.y * self.captureView.frame.size.height;
	scanFrame.size.width = rectOfInterest.size.width * self.captureView.frame.size.width;
	scanFrame.size.height = rectOfInterest.size.height * self.captureView.frame.size.height;
	
	if (!self.interestView) {
		self.interestView = [[UIView alloc] initWithFrame:scanFrame];
		self.interestView.layer.borderWidth = 1.0f;
		self.interestView.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.3f].CGColor;

		[self.captureView insertSubview:self.interestView belowSubview:self.topControlView];
	} else {
		[UIView animateWithDuration:0.2f
							  delay:0.0f
							options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
						 animations:^(void) {
							 self.interestView.frame = scanFrame;
						 } completion:NULL];
	}
	
	
	self.interestView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
}


-(IBAction) tapGestureRecognized:(UITapGestureRecognizer *)recognizer {
	CGPoint touchPoint = [recognizer locationInView:self.captureView];
	[self focusInTouchPoint:touchPoint];
}


#pragma mark - Public methods

-(void) cameraWillStart {
	self.captureView.alpha = 0.01f;
	self.tapGestureRecognizer.enabled = NO;
	self.torchButton.enabled = NO;
}


-(void) cameraDidStart {
	self.tapGestureRecognizer.enabled = YES;
	self.torchButton.enabled = YES;
	
	[self startSearch];
	
	[UIView animateWithDuration:0.3f
						  delay:0.0f
						options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState
					 animations:^(void) {
						 self.captureView.alpha = 1.0f;
						 self.loadingView.alpha = 0.0f;
					 } completion:NULL];
}


-(void) cameraDidFindBarcode:(NSString *)barcode {
	self.torchEnabled = false;
	[self stopSearch];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:barcode
														message:nil
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}


-(IBAction) closeButtonTapped:(id)sender {
	[self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Notification observers

-(void) deviceOrientationDidChangeNotification:(NSNotification *)notification {
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	NSInteger degress;
	
	switch (orientation) {
		case UIDeviceOrientationFaceUp:
		case UIDeviceOrientationPortrait:
		case UIDeviceOrientationUnknown:
			degress = 0;
			break;
			
		case UIDeviceOrientationLandscapeLeft:
			degress = 90;
			break;
			
		case UIDeviceOrientationFaceDown:
		case UIDeviceOrientationPortraitUpsideDown:
			degress = 180;
			break;
			
		case UIDeviceOrientationLandscapeRight:
			degress = 270;
			break;
	}
	
	CGFloat radians = degress * M_PI / 180;
	CGAffineTransform transform = CGAffineTransformMakeRotation(radians);
	
	[UIView animateWithDuration:0.3f animations:^{
		self.closeButton.transform =
		self.torchButton.transform = transform;
	}];
}


#pragma mark - Delegated methods

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[self startSearch];
}


@end
