//
//  Sign.h
//  test
//
//  Created by Mac on 28.06.13.
//  Copyright (c) 2013 itm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SignClass : NSObject

{
	CGFloat Distance;
	CGFloat Angle;
	CGFloat Deviation;
	CGFloat xPos;
	CGFloat yPos;
	NSString *Name;
	CGFloat Orientation;
	NSString *NameRev;
	CGFloat OrientationRev;
	CGFloat width;
	CGFloat height;
    CGFloat widthRev;
	CGFloat heightRev;
	
}

@property (nonatomic)CGFloat Distance;
@property (nonatomic)CGFloat Deviation;
@property (nonatomic)CGFloat Angle;
@property (nonatomic)CGFloat xPos;
@property (nonatomic)CGFloat yPos;
@property (nonatomic)CGFloat width;
@property (nonatomic)CGFloat height;
@property (nonatomic)CGFloat widthRev;
@property (nonatomic)CGFloat heightRev;
@property (nonatomic)NSString *Name;
@property (nonatomic)CGFloat Orientation;
@property (nonatomic)NSString *NameRev;
@property (nonatomic)CGFloat OrientationRev;

@end
