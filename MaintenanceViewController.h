//
//  MaintenanceViewController.h
//  Template
//
//  Created by Mac on 25.10.13.
//  Copyright (c) 2013 itm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"
#import "MetaioSDKViewController.h"
#import "TBXML.h"
#import "TBXMLFunctions.h"

@interface MaintenanceViewController : MetaioSDKViewController
{
    metaio::IGeometry* theLoadedModel; //Temporär aktuelle Geometry
	std::vector<metaio::IGeometry*> loadedModels; //Pointer zu allen geladenen models
	
	NSMutableArray* selectedModels; //Array in dem die betroffenen Models und Groups abgelegt sind
	

    bool highlightOn; //Variable wenn etwas selektiert wurde
	bool setHighlight; //Variable wenn der Highlight-Shader aktiv ist

	
	TBXML* tbxml;
	

}

- (void)loadObjectsInFolder:(NSString *)oFolder forCosID:(int)oCos;


-(IBAction)test:(id)sender;



@end
