//
//  MapClass.h
//  test
//
//  Created by matze on 29.06.13.
//  Copyright (c) 2013 itm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapClass : NSObject
{
	CGFloat scale;
	CGFloat xSize;
	CGFloat ySize;
    CGFloat height;
	CGFloat width;
	NSString *map;
	CGFloat orientation;
	
}

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGFloat xSize;
@property (nonatomic) CGFloat ySize;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;
@property (nonatomic) NSString *map;
@property (nonatomic) CGFloat orientation;


@end
