//
//  Sign.m
//  test
//
//  Created by Mac on 28.06.13.
//  Copyright (c) 2013 itm. All rights reserved.
//

#import "SignClass.h"

@implementation SignClass
@synthesize Name,xPos,yPos,Orientation,Distance, NameRev, OrientationRev, width, height, widthRev, heightRev, Angle, Deviation;


-(id) init
{
	if (!Distance) {
		Distance = -1;
	}
	
	if (!Angle) {
		Angle = -1;
	}
	
	if (!Deviation) {
		Deviation = -1;
	}
    
    return self;
	
}

@end
