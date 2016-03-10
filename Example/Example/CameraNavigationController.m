//
//  CameraNavigationController.m
//  Example
//
//  Created by Anton Lookin on 3/9/16.
//  Copyright © 2016 look.in.corporated. All rights reserved.
//

#import "CameraViewController.h"

#import "CameraNavigationController.h"


@interface CameraNavigationController ()

@end


@implementation CameraNavigationController


#pragma mark - Public methods

-(TSCCameraViewController *) cameraViewController {
	return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CameraViewController"];
}


@end
