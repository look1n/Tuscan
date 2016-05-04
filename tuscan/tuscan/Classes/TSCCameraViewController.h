//
//  TSCCameraViewController.h
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

#import <UIKit/UIKit.h>

#import "TSCCamera.h"
#import "TSCCameraFocusView.h"
#import "TSCCameraNavigationController.h"


@protocol TSCCameraDelegate <NSObject>

@optional
-(void) cameraWillStart;
-(void) cameraDidStart;
-(void) cameraDidStop;
-(void) cameraWillTakePhoto;
-(void) cameraDidTakePhoto:(UIImage *)image;
-(void) cameraDidFindBarcode:(NSString *)barcode;

@end


@interface TSCCameraViewController : UIViewController

@property (weak, nonatomic) id <TSCCameraDelegate> delegate;

-(instancetype) initWithDelegate:(id <TSCCameraDelegate>)delegate;

@property (strong, nonatomic) TSCCamera *camera;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL isRunning;

@property (strong, nonatomic) IBOutlet UIView *captureView;
@property (strong, nonatomic) IBOutlet UIView <TSCCameraFocusView> *focusView;
-(void) focusInTouchPoint:(CGPoint)touchPoint;


-(IBAction) toggleTorch;
@property (nonatomic) BOOL torchEnabled;

@property (nonatomic) CGRect rectOfInterest;

-(void) startSearch;
-(void) startSearch:(void (^)(NSString *barcode))completion;
-(void) stopSearch;

-(void) cameraWillStart;
-(void) cameraDidStart;
-(void) cameraDidStop;
-(void) cameraDidFindBarcode:(NSString *)barcode;
-(void) cameraDidTakePhoto:(UIImage *)photo;

@end