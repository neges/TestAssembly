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

@interface MaintenanceViewController : MetaioSDKViewController <UITableViewDelegate, UITableViewDataSource>
{
    metaio::IGeometry* theLoadedModel; //Temporär aktuelle Geometry
	metaio::IGeometry* theSelectedModel; //Temporär selektierte Geometry
	bool saveVisibleBeforSelection; //Speicher ob das Object vorher sichtbar war
	std::vector<metaio::IGeometry*> loadedModels; //Pointer zu allen geladenen models
	
	NSMutableArray* selectedModels; //Array in dem die selektierten Models und Groups abgelegt sind
    NSMutableArray* tableModels; //Array für die jeweilige TableView
	NSMutableArray* tableParents; //Array für die jeweiligen TopElemente der TableView

    bool highlightOn; //Variable wenn etwas selektiert wurde
	bool setHighlight; //Variable wenn der Highlight-Shader aktiv ist
	NSTimer *highlightTimer; //Timmer für das Blinken
	
	bool isBtoEnable; //Variable die den Status des letzten Parents der TableView speicher --> wenn nicht aktiv dann alle Unterelemente bis zum ende nicht aktiv

	
	TBXML* tbxml;
    TBXMLElement *selectedElement;
	
	
	
    IBOutlet UILabel* test;
    

}

@property (nonatomic, strong) IBOutlet UITableView *structurTableView;

- (void)loadObjectsInFolder:(NSString *)oFolder forCosID:(int)oCos;



@end
