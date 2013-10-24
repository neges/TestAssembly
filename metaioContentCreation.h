//
//  metaioContentCreation.h
//  Template
//
//  Created by Mac on 24.10.13.
//  Copyright (c) 2013 itm. All rights reserved.
//

#import "MetaioSDKViewController.h"
#import "XMLReader.h"

@interface metaioContentCreation : MetaioSDKViewController
{
	metaio::IGeometry* theLoadedModel; //Temporär aktuelle Geometry
	
}




- (void)loadObjectsInFolder:(NSString *)oFolder forCosID:(int)oCos;


@end