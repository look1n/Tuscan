//
//  CameraFocusView.m
//  Example
//
//  Created by Anton Lookin on 3/9/16.
//  Copyright © 2016 look.in.corporated. All rights reserved.
//

#import "CameraFocusView.h"


@implementation CameraFocusView


#pragma mark - Public methods

-(instancetype) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (!self) {
		return nil;
	}
	
	self.tintColor = [UIColor colorWithRed:234.0f / 255.0f green:105.0f / 255.0f blue:21.0f / 255.0f alpha:1.0f];
	
	return self;
}


@end
