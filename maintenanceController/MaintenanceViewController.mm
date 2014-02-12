//
//  MaintenanceViewController.m
//  Template
//
//  Created by Mac on 25.10.13.
//  Copyright (c) 2013 itm. All rights reserved.
//

#import "MaintenanceViewController.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MaintenanceViewController ()

@end


@implementation MaintenanceViewController
	const NSInteger UNIQUE_TAG = 11111;
	static NSString *CellIdentifier = @"Cell";
	static NSString *SubDivider = @"   ├ ";
	static NSString *TopDivider = @"   ";

@synthesize structurTableView;
@synthesize workTableViewController;




#pragma mark -
#pragma mark View
#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       workTableViewController = [[WorkTableViewController alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self initTrackingDataFileName:@"TrackingData"];
	
	
	[self initLight];
	[self initShaders];
	
	
	[self loadObjectsInFolder:@"3D" forCosID:1];
	
	tableParents = [[NSMutableArray alloc]init];
	tableModels = [[NSMutableArray alloc]init];
	isBtoEnable = true;
	offlineMode = false;
	
	[self initTabBar];
	
	[tabBarView addSubview:workView];
	workView.frame = CGRectMake(0, 49, workView.frame.size.width, workView.frame.size.height);
	
	
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark table View
#pragma mark -


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	
	tableParents = [TBXMLFunctions getAllParentElementsFrom:selectedElement];
	
	tableModels = [TBXMLFunctions getAllTableViewSubElements:selectedElement];

	
    return [tableModels count] + [tableParents count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
		
		

	}
	
	//Button für clickEvent erzeigen
	UIButton *button = (UIButton *)[cell viewWithTag:UNIQUE_TAG];
	
	if (!button)
	{
		
		button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		button.tag = UNIQUE_TAG;
		
		[button addTarget: self
				   action: @selector(buttonPressed:withEvent:)
		 forControlEvents: UIControlEventTouchDown];
		
		
		button.frame = CGRectMake(3, (cell.frame.size.height - 20) / 2 ,20,20);
		[button setBackgroundImage: [UIImage imageNamed:@"checked.png"] forState:UIControlStateSelected];
		[button setBackgroundImage: [UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];
		
		[cell addSubview:button];
	}
    
	NSArray* tempArray;
	
    if (indexPath.row < [tableParents count])
    {

		tempArray = [tableParents objectAtIndex:indexPath.row];
        
        NSString *topObjectText = [NSString stringWithFormat:@"%@%@",TopDivider, [tempArray objectAtIndex:1]];
        
        // Configure the cell...
        cell.textLabel.text = topObjectText;
		
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.backgroundColor = [UIColor lightGrayColor];

		
    }
    else
    {

        tempArray = [tableModels objectAtIndex:indexPath.row - [tableParents count]];
        
        NSString* subObjectText = [NSString stringWithFormat:@"%@%@",SubDivider, [tempArray objectAtIndex:1]];
        
        // Configure the cell...
        cell.textLabel.text = subObjectText;

		cell.imageView.frame.size = CGSizeMake(cell.frame.size.height, cell.frame.size.height);
		
		cell.backgroundColor = [UIColor whiteColor];
		
        
        //ist eine Group also Pfeile hinzufügen
        if ([[tempArray objectAtIndex:0] isEqualToString:@"group"])
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
		
		
		//Button deaktivieren wenn Überbaugruppe nicht sichtbar
		[button setEnabled:isBtoEnable];
		
    }
	
		
	if ([[tempArray objectAtIndex:2] isEqualToString:@"true"])
	{
		[button setSelected:true];
	}else{
		[button setSelected:false];
	}

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	//Celle holen
	UITableViewCell *Cell = (UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
	//Button aus  Celle holen
	UIButton *Button = (UIButton *)[Cell viewWithTag:UNIQUE_TAG];
	
	
	//Obergruppe wurde selektiert => eine Ebene zurück
	if (indexPath.row < [tableParents count])
	{
		NSArray* tempArray = [tableParents objectAtIndex:indexPath.row ];
		
		//Wenn eine Element darüber dann neu Laden eine Ebene darüber
		if (indexPath.row < [tableParents count] - 1)
		{
			//mögliche selektierung löschen
			[self select3dContentWithName:nil withUIColor:nil toGroup:true	];
			
			selectedElement = [TBXMLFunctions getElement:[structureXML rootXMLElement] ByName:[tempArray objectAtIndex:1]];
			
			if (selectedElement)
			{

				if (Button)
				{
					if (Button.isEnabled && Button.isSelected)
						isBtoEnable = true;
					else
						isBtoEnable = false;
				}else
					isBtoEnable = true;
				
				[tableView reloadData];
			}
			
		}
		else //letzte Top element also 3D selektieren
		{
			[self select3dContentWithName:[tempArray objectAtIndex:1] withUIColor:@"green" toGroup:true	];
			if (!theSelectedModel)
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
		
	}else{

		NSArray* tempArray = [tableModels objectAtIndex:(indexPath.row - [tableParents count]) ];
		
		if ([[tempArray objectAtIndex:0] isEqualToString:@"group"])
		{

			if (Button)
			{
				if (Button.isEnabled && Button.isSelected)
					isBtoEnable = true;
				else
					isBtoEnable = false;
			}else
				isBtoEnable = true;
			
			
			selectedElement = [TBXMLFunctions getElement:[structureXML rootXMLElement] ByName:[tempArray objectAtIndex:1]];
			[tableView reloadData];
			
		}
		else
		{
			[self select3dContentWithName:[tempArray objectAtIndex:1] withUIColor:@"green" toGroup:false];
			if (!theSelectedModel)
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
	}
	
  	[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[tableParents count] inSection:indexPath.section]
					 atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	/*
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
		[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[tableParents count]-1 inSection:indexPath.section]
						 atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
	 */
}







#pragma mark -
#pragma mark tab bar
#pragma mark -

- (void)initTabBar
{
	[tabBarView setFrame:CGRectMake(0, [[UIScreen mainScreen] bounds ].size.width - 49 ,tabBarView.frame.size.width    ,tabBarView.frame.size.height )];
	[glView	addSubview:tabBarView];
	
	[structurTableView setFrame:CGRectMake([[UIScreen mainScreen] bounds ].size.height + 1, 0 ,structurTableView.frame.size.width    ,structurTableView.frame.size.height )];
	[glView addSubview:structurTableView];
    
    savedCosID = 1;
	tabBarTag = 0;
	
}


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{

	switch (item.tag) {
		case 0:
			tabBarTag = 0;
			[self slideTabBarIn:true];
			[self slideTableIn:false];

		
			
			break;
		case 1:
			tabBarTag = 1;
			[self slideTabBarIn:true];
			[self slideTableIn:false];
			
			break;
		case 2:
			tabBarTag = 2;
			[self slideTabBarIn:false];
			[self slideTableIn:true];
			
			
			break;
        case 3:
			
            metaio::IGeometry* tempModel = [self modelForObjectname:[[tableParents objectAtIndex:0]objectAtIndex:1]];

            if (tempModel && offlineMode == false)
			{
                offlineMode = true;
				metaio::TrackingValues holdedPose = m_metaioSDK->getTrackingValues(tempModel->getCoordinateSystemID());
				
				[self setModel:tempModel toCosID:0];
				
				//[self fitModel:tempModel toMaxScreenSize:[[UIScreen mainScreen] bounds].size];
				
				tempModel->setRotation(holdedPose.rotation);
				tempModel->setTranslation(holdedPose.translation);
				
				[item setTitle:@"trackingOff"];
				[item setImage:[UIImage imageNamed:@"camOFF.png"]];
				
								
            }
			else if (tempModel && offlineMode == true)
			{
				
                offlineMode = false;
				
				[self setModel:tempModel toCosID:savedCosID];
				
				tempModel->setRotation(metaio::Rotation(0,0,0));
				tempModel->setTranslation(metaio::Vector3d(0,0,0));
				
				[item setTitle:@"trackingOn"];
				[item setImage:[UIImage imageNamed:@"camON.png"]];
				
            }

            //altes TabItem wieder selktieren
            [tabBar setSelectedItem:[tabBar.items objectAtIndex:tabBarTag]];
			
			break;
	}


	
	
}

-(void)slideTabBarIn:(bool)ingoing
{

	NSInteger showY = [[UIScreen mainScreen] bounds ].size.width - tabBarView.frame.size.height;
	NSInteger hideY = [[UIScreen mainScreen] bounds ].size.width - 49;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:tabBarView cache:YES];
	
	if (ingoing == true)
		[tabBarView setFrame:CGRectMake(0, showY ,tabBarView.frame.size.width    ,tabBarView.frame.size.height )];
	else
		[tabBarView setFrame:CGRectMake(0,hideY ,tabBarView.frame.size.width    ,tabBarView.frame.size.height )];
	
	[UIView commitAnimations];

}


-(void)slideTableIn:(bool)ingoing
{
	
	NSInteger showX = [[UIScreen mainScreen] bounds ].size.height - structurTableView.frame.size.width;
	NSInteger hideX = [[UIScreen mainScreen] bounds ].size.height;
	
	//UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f,460.0f,320.0f,260.0f)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:tabBarView cache:YES];
	
	if (ingoing == true)
		[structurTableView setFrame:CGRectMake(showX,0 ,structurTableView.frame.size.width    ,structurTableView.frame.size.height )];
	else
		[structurTableView setFrame:CGRectMake(hideX,0 ,structurTableView.frame.size.width    ,structurTableView.frame.size.height )];
	
	[UIView commitAnimations];
	
}


#pragma mark -
#pragma mark load 3D content
#pragma mark -

- (void)loadObjectsInFolder:(NSString *)oFolder
				   forCosID:(int)oCos

{
	
	NSString *objectFolderPath = [[NSBundle mainBundle] pathForResource:@"Assets" ofType:nil];
	NSString *pathString =  [NSString stringWithFormat:@"%@/%@",objectFolderPath,oFolder];
	
	NSString *fullPath = [NSString stringWithFormat:@"%@/models.xml",pathString];
	
	NSString* theContents = [[NSString alloc] initWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
	
	
	//xml laden falls vorhanden
	structureXML = [TBXML newTBXMLWithXMLString:theContents error:nil];
	TBXMLElement* rootElement = structureXML.rootXMLElement;
	
	if (!structureXML) {
		NSLog(@"No structur file could be found or structur file i incorrect : %@", fullPath);
		return;
	}
	
	NSString* topModelName = [TBXMLFunctions getAttribute:@"name" OfElement:rootElement];
	BOOL visible = [[TBXMLFunctions getAttribute:@"visible" OfElement:rootElement] boolValue];
	
	metaio::IGeometry* topModel = [self createGroupWithName:topModelName andParentObject:nil toCosID:oCos isVisible:visible];
	
	//Sub elemente laden falls vorhanden
	if (rootElement->firstChild)
	{
		[self loadObjectsFromElement:rootElement->firstChild toCosID:oCos withParentObject:topModel fromFolder:pathString];
	
		loadedModels = m_metaioSDK->getLoadedGeometries();
        
        //Werte für die tableView holen
        selectedElement = rootElement;
        
	}
	
	
    
    
	
	
}

-(void)loadObjectsFromElement: (TBXMLElement*) oElement
						toCosID: (int) oCos
			   withParentObject: (metaio::IGeometry*) pObject
					 fromFolder: (NSString*) oFolder
{
	
	do{
		
		
		
		NSString *objectName = [TBXMLFunctions getAttribute:@"name" OfElement:oElement];
		BOOL visible = [[TBXMLFunctions getAttribute:@"visible" OfElement:oElement]boolValue];
		
		
		//Element hat Childs => Group
		if (oElement->firstChild)
		{
			//leere geometrie laden als parent
			
			metaio::IGeometry* groupModel = [self createGroupWithName:objectName andParentObject:pObject toCosID:oCos isVisible:visible];
			
			//Rekursiv durchlaufen
			[self loadObjectsFromElement: oElement->firstChild
								 toCosID: oCos
						withParentObject: groupModel
							  fromFolder: oFolder];
			
		}
		else //Element ist ein Object
		{
			
			[self loadObjectFromFolder:oFolder withName:objectName andParentObject:pObject toCosID:oCos isVisible:visible];
			
		}
		
		
	}while ((oElement = oElement->nextSibling));
	
	
}

-(metaio::IGeometry*)   createGroupWithName:(NSString*) oName
							andParentObject: (metaio::IGeometry*) pObject
									toCosID: (int) oCos
								  isVisible:(bool)visible


{
	// load content
	NSString* emptyModel = [[NSBundle mainBundle] pathForResource:@"_empty_" ofType:@"obj"];
	
	theLoadedModel =  m_metaioSDK->createGeometry([emptyModel UTF8String]);
	theLoadedModel->setName(*new std::string([oName UTF8String]));
	theLoadedModel->setCoordinateSystemID(oCos);
	theLoadedModel->setVisible(visible);
	
	if (pObject) {
		theLoadedModel->setParentGeometry(pObject);
		//NSLog(@"Create Group : %@ with Parent : %s",oName, pObject->getName().c_str());
	}else{
		//NSLog(@"Create Top Model : %@",oName);
	}
	
	
	return theLoadedModel;
	
}



-(metaio::IGeometry*)	loadObjectFromFolder: (NSString*) oFolder
									withName: (NSString*) oName
							andParentObject: (metaio::IGeometry*) pObject
									toCosID: (int) oCos
								  isVisible: (bool)visible
{
	
	
	//laden beschleunigen in dem kein 3D object herrangezogen wird
	//return nil;
	
	
	// load content
	NSString* objModel = [NSString stringWithFormat:@"%@/%@.obj",oFolder,oName];
	
	
	if(objModel)
	{
		// if this call was successful, theLoadedModel will contain a pointer to the 3D model
		theLoadedModel =  m_metaioSDK->createGeometry([objModel UTF8String]);
		if( theLoadedModel )
		{
			// scale it a bit up
			
            theLoadedModel->setTranslation (metaio::Vector3d(0,0,0)); //0,5,-70
			
			//theLoadedModel->setScale(metaio::Vector3d(0.5,0.5,0.5));
			
			theLoadedModel->setName(*new std::string([oName UTF8String]));
			
			theLoadedModel->setCoordinateSystemID(oCos);
			
			theLoadedModel->setVisible(visible);
			
			if (pObject) {
				theLoadedModel->setParentGeometry(pObject);
				//NSLog(@"Load : %@ with Parent : %s",oName, pObject->getName().c_str());
			}
			
			
			
			return theLoadedModel;
			
			
		}
		else
		{
			NSLog(@"error, could not load %@", oName);
			
			return nil;
		}
		
	}
	
	return nil;
}







#pragma mark -
#pragma mark Content Setter
#pragma mark -

-(bool)setModelWithName:(NSString *)sName
				 visible:(bool)visible
{

	metaio::IGeometry *sObject = [self modelForObjectname:sName];
	
	if (sObject)
	{
		sObject->setVisible(visible);
		return true;
	}else
		return false;
}

-(bool)setModel:(metaio::IGeometry*) sObject
				 toCosID:(NSInteger)sCos
{

	
	if (sObject)
	{
        //alte cosid speichern wenn nicht 0
        if (sObject->getCoordinateSystemID() > 0)
            savedCosID = sObject->getCoordinateSystemID();
        //Neue CosID setzen
		sObject->setCoordinateSystemID(sCos);

		
	}
	
	if (sCos == 0)
		return true;
	else
		return false;
	
}


-(void)fitModel:(metaio::IGeometry*) oModel
toMaxScreenSize:(CGSize)sSize
{
	
	
		NSMutableArray *allSubElements = [[NSMutableArray alloc]init];
		
		TBXMLElement *topElement = [TBXMLFunctions getElement:[structureXML rootXMLElement] ByName:[self modelnameForModel:oModel]];
		[TBXMLFunctions getAllElements:topElement withGroups:true toArray:allSubElements];
		
		NSMutableArray *xBoundingBox = [[NSMutableArray alloc]init];
		NSMutableArray *yBoundingBox = [[NSMutableArray alloc]init];
		
		
		//Alle geladen Objecte druchlaufen
		for ( std::vector<metaio::IGeometry*>::iterator modelItr = loadedModels.begin(); modelItr != loadedModels.end(); ++modelItr )
		{
			
			// Abfragen des i-ten Models
			metaio::IGeometry *model = *modelItr;
			
			// Wir fragen den Namen des Models ab und wandeln diesen in einen NSString um
			NSString *modelname = [ NSString stringWithUTF8String: model->getName().c_str() ];
			
			
			// Wenn der Name des Objektes übereinstimmt mit einem Object aus der Liste
			for (int i = 0; i < [allSubElements count] ;i++)
			{
				
				if( [ modelname isEqualToString: [allSubElements objectAtIndex:i ]] )
				{
					
					
					metaio::BoundingBox objectBounding = model->getBoundingBox(true);
					metaio::Vector3d objectBoundingMax = objectBounding.max;

					[xBoundingBox addObject:[NSNumber numberWithFloat:objectBoundingMax.x] ];
					[yBoundingBox addObject:[NSNumber numberWithFloat:objectBoundingMax.y] ];
					
					break;
					
				}
			
			
			
			}

			
		}
		
		//Min und Max des Arrays und alles Zahlen positiv machen
		CGFloat xBouncing = [[xBoundingBox valueForKeyPath:@"@max.self"] floatValue] - [[xBoundingBox valueForKeyPath:@"@min.self"] floatValue];
		CGFloat yBouncing = [[yBoundingBox valueForKeyPath:@"@max.self"] floatValue] - [[yBoundingBox valueForKeyPath:@"@min.self"] floatValue];

		
		//Werte mit Screen Größe vergleichen
		
		CGFloat transZ;

		if (xBouncing / 197 > yBouncing / 147) //iPadDisplay in mm
			transZ = xBouncing*2 ;
		else
			transZ = yBouncing*2 ;
		
		//Verschieben
		
		CGFloat transX = [[xBoundingBox valueForKeyPath:@"@max.self"] floatValue] - xBouncing/2;
		CGFloat transY = [[yBoundingBox valueForKeyPath:@"@max.self"] floatValue] - yBouncing/2;
		
		
		//setzen
		oModel->setTranslation(metaio::Vector3d(transX,transY,-transZ));

}

#pragma mark -
#pragma mark Content Getter
#pragma mark -

- (metaio::IGeometry *)modelForObjectname: (NSString *)objectname
{
	
	
	for ( std::vector<metaio::IGeometry*>::iterator modelItr = loadedModels.begin(); modelItr != loadedModels.end(); ++modelItr )
	{
		
		// Abfragen des i-ten Models
		metaio::IGeometry *model = *modelItr;
		
		// Wir fragen den Namen des Models ab und wandeln diesen in einen NSString um
		NSString *modelname = [ NSString stringWithUTF8String: model->getName().c_str() ];
		
		// Wenn der Name des Objektes übereinstimmt
		if( [ modelname isEqualToString: objectname ] )
		{
			
			return model;
			
		}
		
	}
	
	return nil;
	
}





- (NSString *)modelnameForModel: (metaio:: IGeometry *)model
{
	
	// Wir fragen den Namen des Models ab
	NSString *modelname = [ NSString stringWithUTF8String: model->getName().c_str() ];
	
	// Wenn der Modelname eine Endung hat
	if( [ modelname hasSuffix: @".obj" ] )
	{
		
		// .obj entfernen
		modelname = [ modelname stringByReplacingOccurrencesOfString: @".obj"
														  withString: @"" ];
		
	}
	
	return modelname;
	
}


#pragma mark -
#pragma mark Object Interaction
#pragma mark -

-(void)select3dContentWithName:(NSString*)content
				   withUIColor:(NSString*)sColor
					   toGroup:(bool)group
{
	
	//alten Timer löschen
	if (highlightTimer)
	{
		[highlightTimer invalidate]; //to stop and invalidate the timer.
		highlightTimer = nil;
		[self unsetShaderToGeometry:theSelectedModel];
		
		if (selectedModels)
		{
			for (NSString* oName in selectedModels)
			{
				metaio::IGeometry* tempModel = [self modelForObjectname:oName];
				[self unsetShaderToGeometry:tempModel];
				selectedModels = nil;
			}
		}
	}
	
	if (!content)
		return;

	if (theSelectedModel)
	{
		theSelectedModel->setVisible(saveVisibleBeforSelection);
		theSelectedModel = nil;
	}
	else
	{

		//neues Selektiertes Object holen
		theSelectedModel = [self modelForObjectname:content];
		saveVisibleBeforSelection = theSelectedModel->isVisible();
		theSelectedModel->setVisible(true);
		
		if (group == true)
		{
			selectedModels = [[NSMutableArray alloc]init];
			
			[TBXMLFunctions getAllElements:selectedElement withGroups:false toArray:selectedModels];
			
			if ([sColor isEqualToString:@"green"])
				highlightTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(HighlightGroupWithFlushGreen) userInfo:nil repeats:YES];
			else
				highlightTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(HighlightGroupWithFlushRed) userInfo:nil repeats:YES];
		}
		else
		{
			if ([sColor isEqualToString:@"green"])
				highlightTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(HighlightWithFlushGreen) userInfo:nil repeats:YES];
			else
				highlightTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(HighlightWithFlushRed) userInfo:nil repeats:YES];
		}
	}
	
	
}





#pragma mark -
#pragma mark Tracking Data
#pragma mark -

-(void)initTrackingDataFileName:(NSString*)trackingDataFileName
{
	
    // load our tracking configuration
    NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:trackingDataFileName ofType:@"xml" inDirectory:@"Assets"];
	if(trackingDataFile)
	{
		bool success = m_metaioSDK->setTrackingConfiguration([trackingDataFile UTF8String]);
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	}
	
	
}

#pragma mark -
#pragma mark Touches & Actions
#pragma mark -

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	// Here's how to pick a geometry
	UITouch *touch = [touches anyObject];
	CGPoint loc = [touch locationInView:glView];
	
	
    // get the scale factor (will be 2 for retina screens)
    float scale = glView.contentScaleFactor;
    
	// ask sdk if the user picked an object
	// the 'true' flag tells sdk to actually use the vertices for a hit-test, instead of just the bounding box
	metaio::IGeometry* model = m_metaioSDK->getGeometryFromScreenCoordinates(loc.x * scale, loc.y * scale, true);
	
	if ( model )
	{
		//Speicher, das das Object berührt wurde
		objectTouch = true;
		
		//Strukur der Tabelle neu aufbauen:
		//Namen holen
		NSString* touchObjectsName = [self modelnameForModel:model];
		//das structureXML element
		TBXMLElement* touchElement = [TBXMLFunctions getElement:[structureXML rootXMLElement] ByName:touchObjectsName];
		//das parent davon
		TBXMLElement* touchElementParent = touchElement->parentElement;
		
		if (touchElementParent)
		{
			//parent setzen und neu laden -> richtige tableview struktur
			selectedElement = touchElementParent;
			[structurTableView reloadData];
		}
		
		//cell selektieren
		for (NSInteger j = 0; j < [structurTableView numberOfRowsInSection:0]; ++j)
		{
			UITableViewCell * tempCell = [structurTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0]];
			

			
			if ([tempCell.textLabel.text isEqual:[NSString stringWithFormat:@"%@%@", SubDivider,touchObjectsName]])
			{
				[structurTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
			}
		}
		
		
	}
	else
	{
		//Kein Object getouched
		objectTouch = false;
		
		[structurTableView deselectRowAtIndexPath:[structurTableView indexPathForSelectedRow] animated:YES];
		[self select3dContentWithName:nil withUIColor:nil toGroup:true	];
		
		
		return;
		
		//--------Test for Exposure
		NSArray *devices = [AVCaptureDevice devices];
		
		for (AVCaptureDevice *device in devices) {
			
			
			
			if ([device position] == AVCaptureDevicePositionBack) {
				
				
				[device lockForConfiguration:nil];
				if ([device exposureMode] == AVCaptureExposureModeContinuousAutoExposure)
				{
					[device setExposureMode:AVCaptureExposureModeLocked];
					NSLog(@"AVCaptureExposureModeLocked");
				}else{
					
					CGPoint expPoint;
					expPoint.x = loc.x / [[UIScreen mainScreen] bounds ].size.height;
					expPoint.y = loc.y / [[UIScreen mainScreen] bounds ].size.width;
					
					[device setExposurePointOfInterest:expPoint];
					[device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
				
				
					NSLog(@"Exposure Point: %f / %f - %f / %f", expPoint.x, expPoint.y, loc.x, loc.y);
				}
						[device unlockForConfiguration];
			}
			
			
		}
		
		//-------
		
	}

	
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
}


- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Here's how to pick a geometry
	UITouch *touch = [touches anyObject];
	CGPoint loc = [touch locationInView:glView];
	
	if ( !objectTouch && offlineMode )
	{
		
		if (loc.x > 0)
		{
			
			CGPoint lastLocationOfTouch = [touch previousLocationInView:glView];
			loc = [touch locationInView:glView];
			
			
			CGFloat tempRotationX;
			CGFloat tempRotationY;
			
			tempRotationY = (lastLocationOfTouch.x - loc.x);
			tempRotationX = (lastLocationOfTouch.y - loc.y);
			
			//get Top Element
			NSString* tempName = [[tableParents objectAtIndex:0] objectAtIndex:1];
			
			//igeometry holen
			metaio::IGeometry *sObject = [self modelForObjectname:tempName];
			
			
			//Rotation holen
			metaio::Rotation xRot = sObject->getRotation();
			
			//umrechnen in Deg
			metaio::Vector3d xRotDeg = xRot.getEulerAngleDegrees();
			
			//Rotation anpassen
			xRotDeg.x = xRotDeg.x - tempRotationX;
			xRotDeg.y = xRotDeg.y - tempRotationY;
			
			xRot.setFromEulerAngleDegrees(xRotDeg);
			
			sObject->setRotation(xRot);
			
		}
	}
}




- (void) buttonPressed: (id) sender withEvent: (UIEvent *) event
{
	//Touchposition als Indexpath
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.structurTableView];
    NSIndexPath * indexPath = [self.structurTableView indexPathForRowAtPoint: location];
    
	NSArray* tempArray;
	
	if (indexPath.row == [tableParents count]-1) //Letzte Top element
		tempArray = [tableParents objectAtIndex:indexPath.row ];
	else if((indexPath.row > [tableParents count] - 1)) //Subelement
		tempArray = [tableModels objectAtIndex:(indexPath.row - [tableParents count]) ];
	else //Parent des letzten Top elements also mach nix
		return;

	
	//VisibelAttribute umsetzen!!
	UIButton* senderButton = sender;
	
	if (senderButton.selected == true)
	{
		[TBXMLFunctions saveAttributForName:@"visible" withValue:(char*)"false" toElement:[TBXMLFunctions getElement:[structureXML rootXMLElement] ByName:[tempArray objectAtIndex:1]]];
		senderButton.selected = false;
		isBtoEnable = false;
		
	}else{
		[TBXMLFunctions saveAttributForName:@"visible" withValue:(char*)"true" toElement:[TBXMLFunctions getElement:[structureXML rootXMLElement] ByName:[tempArray objectAtIndex:1]]];
		senderButton.selected = true;
		isBtoEnable = true;
	}
	
	
	//3D Object umschalten
	[self setModelWithName:[tempArray objectAtIndex:1] visible:senderButton.selected];
	
	//Neuladen wenn es ein Top Element ist
	if (indexPath.row < [tableParents count])
		[structurTableView reloadData];

}


- (IBAction)toogleScreen:(id)sender
{

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	
	//toggle taBarView
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:tabBarView cache:YES];
	
	NSInteger showY = [[UIScreen mainScreen] bounds ].size.width - tabBarView.frame.size.height - 20;
	NSInteger hideY = [[UIScreen mainScreen] bounds ].size.width - 49 - 20;
	
	//get Position
	CGPoint tabBarPoint = [tabBarView convertPoint:tabBarView.bounds.origin toView:glView];
	CGPoint tablePoint = [structurTableView convertPoint:structurTableView.bounds.origin toView:glView];
	
	NSLog(@"%f", [[UIScreen mainScreen] bounds ].size.width);
	
	if (tabBarPoint.y == 800)//war eingelappt
	{
		[tabBarView setFrame:CGRectMake(0, hideY ,tabBarView.frame.size.width    ,tabBarView.frame.size.height )];
		//da zu begin kein tab selektier wurde ist die tableView noch auf 1025
		if (tablePoint.x == [[UIScreen mainScreen] bounds ].size.height) {
			[self slideTableIn:true];
		}
		
	}
	else if (tabBarPoint.y == 900)//war ausgeklappt
	{
		[tabBarView setFrame:CGRectMake(0,showY ,tabBarView.frame.size.width    ,tabBarView.frame.size.height )];
	}
	else if (tabBarPoint.y == showY)//ist ausgeklappt
	{
		[tabBarView setFrame:CGRectMake(0,900 ,tabBarView.frame.size.width    ,tabBarView.frame.size.height )];
	}
	else if (tabBarPoint.y == hideY)//ist eingeklappt
	{
		[tabBarView setFrame:CGRectMake(0,800 ,tabBarView.frame.size.width    ,tabBarView.frame.size.height )];
		if (tablePoint.x == [[UIScreen mainScreen] bounds ].size.height - structurTableView.frame.size.width) {
			[self slideTableIn:false];
		}
	}
	
	
	
	[UIView commitAnimations];
		
}








#pragma mark -
#pragma mark Light
#pragma mark -

-(void)initLight
{
	
    metaio::ILight*		m_pLight;
    
    m_pLight = m_metaioSDK->createLight();
    m_pLight->setType(metaio::ELIGHT_TYPE_DIRECTIONAL);
    
    m_metaioSDK->setAmbientLight(metaio::Vector3d(0.05f));
    m_pLight->setDiffuseColor(metaio::Vector3d(1, 1, 1)); // white
    
    m_pLight->setCoordinateSystemID(0);
	
    
}







#pragma mark -
#pragma mark Shaders
#pragma mark -

-(void)initShaders
{
    
    //load ShaderMaterials
    
    NSString* shaderMaterialsFilename = [[NSBundle mainBundle] pathForResource:@"shader_materials" ofType:@"xml" inDirectory:@""];
    
	if (shaderMaterialsFilename)
	{
		if (!m_metaioSDK->loadShaderMaterials([shaderMaterialsFilename UTF8String]))
		{
			NSLog(@"Failed to load shader materials from %@", shaderMaterialsFilename);
		}
        
    }
    else
    {
		NSLog(@"Shader materials XML file not found");
    }
    
    
}

-(void)applyShader:(NSString*)shaderColor
        toGeometry:(metaio::IGeometry*)shaderObject
{
    
    
    // Successfully loaded shader materials
    if (shaderObject)
    {
        shaderObject->setShaderMaterial([shaderColor UTF8String]);
    }
    
    
    
}

-(void)unsetShaderToGeometry:(metaio::IGeometry*)shaderObject
{
    
    // Successfully loaded shader materials
    if (shaderObject)
    {
        shaderObject->unsetShaderMaterial();
    }
    
}






#pragma mark -
#pragma mark Timer
#pragma mark -

-(void)HighlightWithFlushGreen
{
		if (highlightOn == false)
		{
			
			highlightOn = true;
			[self applyShader:@"green" toGeometry:theSelectedModel];
			
		}else{
			
			highlightOn = false;
			[self unsetShaderToGeometry:theSelectedModel];
			
		}
		
		
}

-(void)HighlightWithFlushRed
{
	if (highlightOn == false)
	{
		
		highlightOn = true;
		[self applyShader:@"red" toGeometry:theSelectedModel];
		
	}else{
		
		highlightOn = false;
		[self unsetShaderToGeometry:theSelectedModel];
		
	}
	

}

-(void)HighlightGroupWithFlushGreen
{
	if (highlightOn == false)
	{
		
		highlightOn = true;
		
		for (NSString* oName in selectedModels)
		{
			
			metaio::IGeometry* tempModel = [self modelForObjectname:oName];
			[self applyShader:@"green" toGeometry:tempModel];
			
		}

	}else{
		
		highlightOn = false;
		
		for (NSString* oName in selectedModels)
		{
			
			metaio::IGeometry* tempModel = [self modelForObjectname:oName];
			[self unsetShaderToGeometry:tempModel];
			
		}
	}
}

-(void)HighlightGroupWithFlushRed
{
	if (highlightOn == false)
	{
		
		highlightOn = true;
		
		for (NSString* oName in selectedModels)
		{
			
			metaio::IGeometry* tempModel = [self modelForObjectname:oName];
			[self applyShader:@"red" toGeometry:tempModel];
			
		}
		
		
	}else{
		
		highlightOn = false;
		
		for (NSString* oName in selectedModels)
		{
			
			metaio::IGeometry* tempModel = [self modelForObjectname:oName];
			[self unsetShaderToGeometry:tempModel];
			
		}
	}
}



#pragma mark -
#pragma mark @protocol metaioSDKDelegate
#pragma mark -


- (void) drawFrame
{
    [super drawFrame];
	
}

- (void) onSDKReady
{
    NSLog(@"The SDK is ready");
	
}

- (void) onAnimationEnd: (metaio::IGeometry*) geometry  andName:(NSString*) animationName
{
    NSLog(@"animation ended %@", animationName);
}


- (void) onMovieEnd: (metaio::IGeometry*) geometry  andName:(NSString*) movieName
{
	NSLog(@"movie ended %@", movieName);
	
}

- (void) onNewCameraFrame:(metaio::ImageStruct *)cameraFrame
{
    NSLog(@"a new camera frame image is delivered %f", cameraFrame->timestamp);
}

- (void) onCameraImageSaved:(NSString *)filepath
{
    NSLog(@"a new camera frame image is saved to %@", filepath);
}

-(void) onScreenshotImage:(metaio::ImageStruct *)image
{
    
    NSLog(@"screenshot image is received %f", image->timestamp);
}

- (void) onScreenshotImageIOS:(UIImage *)image
{
    NSLog(@"screenshot image is received %@", [image description]);
}

-(void) onScreenshot:(NSString *)filepath
{
    NSLog(@"screenshot is saved to %@", filepath);
}

- (void) onTrackingEvent:(const metaio::stlcompat::Vector<metaio::TrackingValues>&)trackingValues
{
    NSLog(@"The tracking time is: %f", trackingValues[0].timeElapsed);
}

- (void) onInstantTrackingEvent:(bool)success file:(NSString*)file
{
    if (success)
    {
        NSLog(@"Instant 3D tracking is successful");
    }
}

- (void) onVisualSearchResult:(bool)success error:(NSString *)errorMsg response:(std::vector<metaio::VisualSearchResponse>)response
{
    if (success)
    {
        NSLog(@"Visual search is successful");
    }
}

- (void) onVisualSearchStatusChanged:(metaio::EVISUAL_SEARCH_STATE)state
{
    if (state == metaio::EVSS_SERVER_COMMUNICATION)
    {
        NSLog(@"Visual search is currently communicating with the server");
    }
}








@end
