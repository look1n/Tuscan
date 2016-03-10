//
//  CameraViewController.h
//  Campibara
//
//  Created by Anton Lookin on 3/4/16.
//  Copyright © 2016 NimbleCommerce. All rights reserved.
//

#import <tuscan/tuscan.h>


@interface CameraViewController : TSCCameraViewController

@property (strong, nonatomic) IBOutlet UIView *topControlView;

@property (strong, nonatomic) IBOutlet UIView *interestView;
@property (strong, nonatomic) IBOutlet UIView *loadingView;

@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UIButton *torchButton;

@end
