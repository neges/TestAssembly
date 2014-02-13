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
#import "WorkTableViewController.h"

@interface MaintenanceViewController : MetaioSDKViewController <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, WorkTableViewControllerDelegate
>
{
	
	
	
    metaio::IGeometry* theLoadedModel; //Temporär aktuelle Geometry
	metaio::IGeometry* theSelectedModel; //Temporär selektierte Geometry
	bool saveVisibleBeforSelection; //Speicher ob das Object vorher sichtbar war
	std::vector<metaio::IGeometry*> loadedModels; //Pointer zu allen geladenen models
    
    NSInteger savedCosID; //zum speichern der CosID wenn auf 0 gestzt wird
    bool offlineMode; //zum speichern des aktuellen modus (trackin an/aus)
	bool objectTouch; //Speicher ob das Touchevent auf ein 3D Object liegt für späteren move
    
	
	TBXML* structureXML; //structureXML
	
	//TableView
	
    NSMutableArray* tableModels; //Array für die jeweilige TableView
	NSMutableArray* tableParents; //Array für die jeweiligen TopElemente der TableView

	
	//Selektierung
    bool highlightOn; //Variable wenn etwas selektiert wurde
	bool setHighlight; //Variable wenn der Highlight-Shader aktiv ist
	NSTimer *highlightTimer; //Timmer für das Blinken
	
	bool isBtoEnable; //Variable die den Status des letzten Parents der TableView speicher --> wenn nicht aktiv dann alle Unterelemente bis zum ende nicht aktiv

	NSMutableArray* selectedModels; //Array in dem die selektierten Models und Groups abgelegt sind
    TBXMLElement *selectedElement; //selektiertes Element
	
    
	
	
	//tabBar
	IBOutlet UITabBar *structureTabBar;
	NSInteger tabBarTag; //speichert die akutelle tabBar selektion
	IBOutlet UIView *tabBarView;
	
	IBOutlet UIView *workView;

}

@property (nonatomic, strong) IBOutlet UITableView *structurTableView;
@property (nonatomic, strong) IBOutlet WorkTableViewController* workTableViewController;


- (void)loadObjectsInFolder:(NSString *)oFolder forCosID:(int)oCos;

- (IBAction)toogleScreen:(id)sender;



@end
