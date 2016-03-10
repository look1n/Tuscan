//
//  TSCCameraNavigationController.m
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

#import "TSCCameraViewController.h"

#import "TSCCameraNavigationController.h"


@interface TSCCameraNavigationController ()

-(void) onAuthorized:(id <TSCCameraDelegate>)delegate;
-(void) onDenied;
-(void) onUndefined:(id <TSCCameraDelegate>)delegate;

@end



@implementation TSCCameraNavigationController


#pragma mark - Instance initialization

-(instancetype) initWithCameraDelegate:(id <TSCCameraDelegate>)delegate {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	self.cameraDelegate = delegate;
	
	return self;
}


#pragma mark - Lifecycle

-(void) viewDidLoad {
    [super viewDidLoad];
	
//	self.navigationBarHidden = YES;
	AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
	
	switch (status) {
		case AVAuthorizationStatusAuthorized:
			[self onAuthorized:self.cameraDelegate];
			break;
			
		case AVAuthorizationStatusRestricted:
		case AVAuthorizationStatusDenied:
			[self onDenied];
			break;
			
		case AVAuthorizationStatusNotDetermined:
			[self onUndefined:self.cameraDelegate];
			break;
	}
	
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}


-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}


-(BOOL) shouldAutorotate {
    return NO;
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
-(NSUInteger) supportedInterfaceOrientations
#else
-(UIInterfaceOrientationMask) supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Public methods

-(TSCCameraViewController *) cameraViewController {
	return [[TSCCameraViewController alloc] initWithNibName:nil bundle:nil];
}


-(UIViewController *) deniedViewController {
	UIViewController *viewController = [[UIViewController alloc] init];
	viewController.title = @"Access Denied";
	return viewController;
}


#pragma mark - Private methods

-(void) onAuthorized:(id <TSCCameraDelegate>)delegate {
	TSCCameraViewController *viewController = [self cameraViewController];
	viewController.delegate = delegate;
    self.viewControllers = @[viewController];
}


-(void) onDenied {
	UIViewController *deniedViewController = [self deniedViewController];
    self.viewControllers = @[deniedViewController];
}


-(void) onUndefined:(id <TSCCameraDelegate>)delegate {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            [self onAuthorized:delegate];
        } else {
            [self onDenied];
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}


@end
