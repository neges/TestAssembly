//
//  ViewController.h
//  Template
//
//  Created by Mac on 30.04.13.
//  Copyright (c) 2013 itm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"
#import "MetaioSDKViewController.h"
#import "XMLReader.h"

@interface ViewController : MetaioSDKViewController
{
    metaio::IGeometry* theLoadedModel; //Temporär aktuelle Geometry
	
    
    bool highlightOn; //Variable wenn etwas selektiert wurde
	bool setHighlight; //Variable wenn der Highlight-Shader aktiv ist
	
    
    NSDictionary *structur; //Struktur der Baugruppe aus XML

	
    
}

@end
