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

@interface MaintenanceViewController : MetaioSDKViewController
{
    metaio::IGeometry* theLoadedModel; //Temporär aktuelle Geometry
	std::vector<metaio::IGeometry*> loadedModels; //Pointer zu allen geladenen models

    bool highlightOn; //Variable wenn etwas selektiert wurde
	bool setHighlight; //Variable wenn der Highlight-Shader aktiv ist

}




- (void)loadObjectsInFolder:(NSString *)oFolder forCosID:(int)oCos;


-(IBAction)test:(id)sender;



@end
