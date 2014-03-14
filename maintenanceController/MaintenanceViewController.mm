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
	const NSInteger UNIQUE_TAG2 = 22222;
	static NSString *CellIdentifier = @"Cell";
	static NSString *SubDivider = @"   ├ ";
	static NSString *TopDivider = @"   ";

@synthesize structurTableView;
@synthesize workTableViewController;
@synthesize reportViewController;

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
	
}

-(void)viewDidDisappear:(BOOL)animated
{
	workTableViewController = nil;
	
	m_metaioSDK = nil;
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) addView:(UIView*)aView
			 to:(bool)show
 withAnimationsFrom:(NSString*)ani
{
	BOOL doesContain = [glView.subviews containsObject:aView];
	
	CGFloat showX = 0;
	CGFloat showY = 0;
	CGFloat hideX = 0;
	CGFloat hideY = 0;
	
		
	if (show && !doesContain) //einblenden
	{
		
		if ([ani isEqualToString:@"top"])
		{
			showX = aView.frame.origin.x;
			showY = 0;
			hideX = aView.frame.origin.x;
			hideY = - aView.frame.size.height;
			
		}
		else if ([ani isEqualToString:@"right"])
		{
		
			showX = 1024 - aView.frame.size.width;
			showY = aView.frame.origin.y;
			hideX = 1024;
			hideY = aView.frame.origin.y;

		}
		else if ([ani isEqualToString:@"bottom"])
		{
			
			showX = aView.frame.origin.x;
			showY = 768 - aView.frame.size.height;
			hideX = aView.frame.origin.x;
			hideY = 768 + aView.frame.size.height;
			
		}
		
		aView.frame = CGRectMake(hideX, hideY, aView.frame.size.width, aView.frame.size.height);
		
		[UIView animateWithDuration:0.5
							  delay:0.0
							options: UIViewAnimationCurveEaseIn
						 animations:^{
							 aView.frame = CGRectMake(showX, showY , aView.frame.size.width, aView.frame.size.height);
						 }
						 completion:^(BOOL finished){
						 }];
		
		
		[glView addSubview:aView];
		
		
		
	}else if (!show && doesContain) //ausblenden
	{
		
		[self.view endEditing:YES];
		
		if ([ani isEqualToString:@"top"])
		{
			hideX = aView.frame.origin.x;
			hideY = - aView.frame.size.height;
			
		}else if ([ani isEqualToString:@"right"])
		{
			hideX = 1024 + aView.frame.origin.y;
			hideY = aView.frame.origin.y;
			
		}else if ([ani isEqualToString:@"bottom"])
		{
			hideX = aView.frame.origin.x;
			hideY = 768 + aView.frame.size.height;
			
		}
		
		[UIView animateWithDuration:0.5
							  delay:0.0
							options: UIViewAnimationCurveEaseIn
						 animations:^{
							 aView.frame = CGRectMake(hideX, hideY , aView.frame.size.width, aView.frame.size.height);
						 }
						 completion:^(BOOL finished){
							 [aView removeFromSuperview];
						 }];
		
	}
}


-(void) removeWorkView:(bool)front
{


	if (front)
		[tabBarView setHidden:true];
	else
		[tabBarView setHidden:false];
	


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
		
        
        //Grün bei selektierung
		UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor greenColor];
        //bgColorView.layer.cornerRadius = 10;
        bgColorView.layer.masksToBounds = YES;
        [cell setSelectedBackgroundView:bgColorView];

	}
	
	//Button für clickEvent erzeugen
	UIButton *button = (UIButton *)[cell viewWithTag:UNIQUE_TAG];
	
	if (!button)
	{
		
		button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.tag = UNIQUE_TAG;
		
		[button addTarget: self
				   action: @selector(buttonPressed:withEvent:)
		 forControlEvents: UIControlEventTouchDown];
		
		
		button.frame = CGRectMake(3, (cell.frame.size.height - 20) / 2 ,20,20);
		[button setBackgroundImage: [UIImage imageNamed:@"checked.png"] forState:UIControlStateSelected];
		[button setBackgroundImage: [UIImage imageNamed:@"unchecked.png"] forState:UIControlStateNormal];

		
		[cell addSubview:button];
	}
	
	//Button für Reports erzeugen
	UIButton *button2 = (UIButton *)[cell viewWithTag:UNIQUE_TAG2];
	
	if (!button2)
	{
		
		button2 = [UIButton buttonWithType:UIButtonTypeCustom];
		button2.tag = UNIQUE_TAG2;
		
		[button2 addTarget: self
				   action: @selector(reportsButtonPressed:withEvent:)
		 forControlEvents: UIControlEventTouchDown];
		
		button2.frame = CGRectMake(210, (cell.frame.size.height - 20) / 2 ,20,20);
		[button2 setBackgroundImage: [UIImage imageNamed:@"document.png"] forState:UIControlStateNormal];
		
		[cell addSubview:button2];
	}
	
	
    
	NSArray* tempArray;
	
    if (indexPath.row < [tableParents count])
    {

		tempArray = [tableParents objectAtIndex:indexPath.row];
        
        NSString *topObjectText = [NSString stringWithFormat:@"%@%@",TopDivider, [tempArray objectAtIndex:1]];
        
        // Configure the cell...
        cell.textLabel.text = topObjectText;
		
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];

		
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
	
	
	//Button hinzufügen wenn für das Element Reports vorliegen
	button2 = (UIButton *)[cell viewWithTag:UNIQUE_TAG2];
	[button2 setHidden:YES];
	
	if (reportElements)
	{
		for (int re = 0 ; re < [reportElements count]; ++re)
		{
			if ([[tempArray objectAtIndex:1] isEqualToString:[[reportElements objectAtIndex:re]objectAtIndex:0]] ) {
				[button2 setHidden:NO];
				break;
			}
		}
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
			[self select3dContentWithName:nil withUIColor:nil toGroup:true	withObjects:nil];
			
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
			[self select3dContentWithName:[tempArray objectAtIndex:1] withUIColor:@"green" toGroup:true	withObjects:nil];
			if (!theSelectedModel)
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
			
			[workTableViewController getSelectedElement:[tempArray objectAtIndex:1]];
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
			[self select3dContentWithName:[tempArray objectAtIndex:1] withUIColor:@"green" toGroup:false	withObjects:nil];
			if (!theSelectedModel)
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
			
			[workTableViewController getSelectedElement:[tempArray objectAtIndex:1]];
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




-(void) reloadStructerTable
{

	[structurTableView reloadData];
}


- (void) selectTabBarItem:(NSInteger)tabBarItemIndex
{

	[structureTabBar setSelectedItem:[structureTabBar.items objectAtIndex:tabBarItemIndex]];


}


#pragma mark -
#pragma mark tab bar
#pragma mark -

- (void)initTabBar
{
	[tabBarView setFrame:CGRectMake(0, glView.frame.size.height ,tabBarView.frame.size.width    ,tabBarView.frame.size.height )];
	
	//tabBarView mit animation einblenden
	
	[UIView animateWithDuration:0.5
						  delay:0.0
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 tabBarView.frame = CGRectMake(0, glView.frame.size.height - 49 ,tabBarView.frame.size.width    ,tabBarView.frame.size.height );
					 }
					 completion:^(BOOL finished){
					 }];
	[glView addSubview:tabBarView];

	   
    savedCosID = 1;
	tabBarTag = 0;
	
}


- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{

	switch (item.tag) {
		case 0:
			tabBarTag = 0;
			[self slideTabBarIn:true];
			[self addView:structurTableView to:false withAnimationsFrom:@"right"];

			[self addView:[workTableViewController reportAddView] to:false withAnimationsFrom:@"top"];
			
			break;
		case 1:
			[self slideTabBarIn:true];
			[self addView:structurTableView to:false withAnimationsFrom:@"right"];
			
			[workTableViewController addNewReport];
			
			
			//altes TabItem wieder selektieren
            [tabBar setSelectedItem:[tabBar.items objectAtIndex:tabBarTag]];
			
			break;
		case 2:
			tabBarTag = 2;
			[self slideTabBarIn:false];
			[self addView:structurTableView to:true withAnimationsFrom:@"right"];
			[self addView:[workTableViewController reportAddView] to:false withAnimationsFrom:@"top"];
			
			
			break;
        case 3:
			
			[self addView:[workTableViewController reportAddView] to:false withAnimationsFrom:@"top"];
			
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

            //altes TabItem wieder selektieren
            [tabBar setSelectedItem:[tabBar.items objectAtIndex:tabBarTag]];
			
			break;
	}


	
	
}

-(void)slideTabBarIn:(bool)ingoing
{

	NSInteger showY = [[UIScreen mainScreen] bounds ].size.width - tabBarView.frame.size.height;
	NSInteger hideY = [[UIScreen mainScreen] bounds ].size.width - 49;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:tabBarView cache:YES];
	
	if (ingoing == true)
		[tabBarView setFrame:CGRectMake(0, showY ,tabBarView.frame.size.width    ,tabBarView.frame.size.height )];
	else
		[tabBarView setFrame:CGRectMake(0,hideY ,tabBarView.frame.size.width    ,tabBarView.frame.size.height )];
	
	[UIView commitAnimations];

}


-(void)slideTableIn:(bool)ingoing
{
	[self addView:structurTableView to:ingoing withAnimationsFrom:@"right"];
}


#pragma mark -
#pragma mark load 3D content
#pragma mark -

- (void)loadObjectsInFolder:(NSString *)oFolder
				   forCosID:(int)oCos

{
	
	NSString *pathString =  [NSString stringWithFormat:@"%@/%@",documentsDir,oFolder];
	
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
		
		
		//Element is eine Group
		if ([[TBXML elementName:oElement] isEqualToString:@"group"])
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
			if ([[TBXML elementName:oElement] isEqualToString:@"object"])
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

-(void)saveInXMLforObjectName:(NSString*)oName
					  toAttribute:(NSString*)atr
						withValue:(char*)val
{
	[TBXMLFunctions saveAttributForName:atr withValue:val toElement:[TBXMLFunctions getElement:[structureXML rootXMLElement] ByName:oName]];
}

-(void)setObjectToInvisibleCos
{


	metaio::IGeometry* tempModel = [self modelForObjectname:[[tableParents objectAtIndex:0]objectAtIndex:1]];
	
	if (tempModel)
	{
		if (tempModel->getCoordinateSystemID() == 9)
			[self setModel:tempModel toCosID:1];
		else
			[self setModel:tempModel toCosID:9];
	}

}

#pragma mark -
#pragma mark Content Getter
#pragma mark -


-(void)getMetaDataForObjectName:(NSString*)objectName
					 toPosition:(metaio::Vector3d) position
{
	
	if (objectName == nil)
		return;
	
	TBXMLElement* metaDataElement = [TBXMLFunctions getElement:[structureXML rootXMLElement] ByName:objectName];
	
	NSMutableArray* metaData = [TBXMLFunctions getMetaDateOfElements:metaDataElement];
	
	//String zusammenbauen
	NSString* metaDataString = [NSString stringWithFormat:@"Part Name : %@", objectName];
	
	for (NSMutableArray* metaArray in metaData)
	{
		NSString* metaDataStringComponent;

		metaDataString = [metaDataString stringByAppendingString: @"\r"];
		
		metaDataStringComponent = [NSString stringWithFormat:@"%@ : %@", [metaArray objectAtIndex:0], [metaArray objectAtIndex:1]];
		
		metaDataString = [metaDataString stringByAppendingString: [NSString stringWithFormat:@"%@", metaDataStringComponent ]];
	}

	

	UIImage *viewImage = [UIImage imageNamed:@"metaDataLabel.png"];
	viewImage = [self drawText:metaDataString inImage:viewImage atPoint:CGPointMake(0, 0)];
	
	m_metaioSDK->unloadGeometry(metaDataObject);
	metaDataObject = m_metaioSDK->createGeometryFromCGImage("metaData", viewImage.CGImage, true);
	metaDataObject->setCoordinateSystemID(1);
	metaio::Vector3d newPosition = metaio::Vector3d(position.x - (viewImage.size.width/2), position.y + (viewImage.size.height/2), position.z);
	metaDataObject->setTranslation(newPosition);

	
}

-(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, 220, image.size.height);
    
    UIFont *font = [UIFont systemFontOfSize:16];
	UIColor *textColor = [UIColor yellowColor];
	
	
    if([text respondsToSelector:@selector(drawInRect:withAttributes:)])
    {
        //iOS 7
		/// Make a copy of the default paragraph style
		NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		/// Set line break mode
		paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
		/// Set text alignment
		paragraphStyle.alignment = NSTextAlignmentRight;

		
        NSDictionary *att = @{NSForegroundColorAttributeName: textColor,
							  NSFontAttributeName:font,
							  NSParagraphStyleAttributeName: paragraphStyle };

        [text drawInRect:rect withAttributes:att];
    }
    else
    {
        //legacy support
        [text drawInRect:CGRectIntegral(rect) withFont:font];
    }
	
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	

	
    return newImage;
}


- (void)getReportsForElements:(NSMutableArray*)gArray //Übergabe der Elemente für die Reports vorliegen
{
	
	if (!reportElements)
	{
		reportElements = [[NSMutableArray alloc]init];
	}
	
	reportElements = gArray;
	
}

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


-(void)getScreenshotFromMetaio
{
	m_metaioSDK->requestScreenshot(glView->defaultFramebuffer, glView->colorRenderbuffer);
	
}

- (void) onScreenshotImageIOS:(UIImage *)image
{
	[workTableViewController requestCameraImage: image];
}




#pragma mark -
#pragma mark Object Interaction
#pragma mark -

- (void)select3dContentWithName:(NSString*)content
				   withUIColor:(NSString*)sColor
					   toGroup:(bool)group
					withObjects:(NSMutableArray*)wObjects
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

	if (theSelectedModel && !wObjects)
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
		
		if (group == true || wObjects)
		{
			if (selectedModels)
                [selectedModels removeAllObjects];
            else
                selectedModels = [[NSMutableArray alloc]init];
            
			
			if (!wObjects)
                if (selectedElement->firstChild)
                    [TBXMLFunctions getAllElements:selectedElement->firstChild withGroups:false toArray:selectedModels];
                else
                    [TBXMLFunctions getAllElements:selectedElement withGroups:false toArray:selectedModels];
			else
				selectedModels = wObjects;
			
			
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
    NSString* trackingDataFile = [NSString stringWithFormat:@"%@/%@.xml",documentsDir, trackingDataFileName];
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
	touchedModel = m_metaioSDK->getGeometryFromScreenCoordinates(loc.x * scale, loc.y * scale, true);
	
	if ( touchedModel )
	{
		//Speicher, das das Object berührt wurde
		objectTouch = true;
		
		//Strukur der Tabelle neu aufbauen:
		//Namen holen
		NSString* touchObjectsName = [self modelnameForModel:touchedModel];
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
		
		//Metadaten holen und anzeigen fals vorhanden
		metaio::Vector3d tPoint = m_metaioSDK->get3DPositionFromScreenCoordinates(1,(metaio::Vector2d(loc.x * scale,loc.y * scale)));

		[self getMetaDataForObjectName:touchObjectsName toPosition: tPoint];

		
		
		//cell selektieren
		for (NSInteger j = 0; j < [structurTableView numberOfRowsInSection:0]; ++j)
		{
			UITableViewCell * tempCell = [structurTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0]];
			

			
			if ([tempCell.textLabel.text isEqual:[NSString stringWithFormat:@"%@%@", SubDivider,touchObjectsName]])
			{
				[structurTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
				[workTableViewController getSelectedElement:touchObjectsName];
			}
		}
		
		
	}
	else
	{
		//Kein Object getouched
		objectTouch = false;
		
		[structurTableView deselectRowAtIndexPath:[structurTableView indexPathForSelectedRow] animated:YES];
		[self select3dContentWithName:nil withUIColor:nil toGroup:true	withObjects:nil	];
		
		
		//MetadatenView ausblenden
		if (metaDataObject)
			m_metaioSDK->unloadGeometry(metaDataObject);
		
		
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
		[self saveInXMLforObjectName:[tempArray objectAtIndex:1] toAttribute:@"visible" withValue:(char*)"false"];
		senderButton.selected = false;
		isBtoEnable = false;
		
	}else{
		[self saveInXMLforObjectName:[tempArray objectAtIndex:1] toAttribute:@"visible" withValue:(char*)"true"];
		senderButton.selected = true;
		isBtoEnable = true;
	}
	
	
	//3D Object umschalten
	[self setModelWithName:[tempArray objectAtIndex:1] visible:senderButton.selected];
	
	//Neuladen wenn es ein Top Element ist
	if (indexPath.row < [tableParents count])
		[structurTableView reloadData];

}

- (void) reportsButtonPressed: (id) sender withEvent: (UIEvent *) event
{
	
	//nur mache wenn man nicht gerade einen neuen report erstell
	if([workTableViewController addingReport])
		return;
	
	
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
	
	NSString* cellText = [tempArray objectAtIndex:1];
	
	[workTableViewController getReportsForElementNamed:cellText];


}



#pragma mark -
#pragma mark navigation toggles
#pragma mark -

-(void)backToSync
{
	
	UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"Back to sync view"];
	[alert setMessage:@"Return to maintenance syncronisation view ?"];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"YES"];
	[alert addButtonWithTitle:@"NO"];
	[alert show];
	
	
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)//delete report aus xml
		[self dismissViewControllerAnimated:YES completion:nil];
	
}



- (void)fullscreenToggle
{
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	
	//toggle taBarView
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:tabBarView cache:YES];
	
	NSInteger showY = [[UIScreen mainScreen] bounds ].size.width - tabBarView.frame.size.height;
	NSInteger hideY = [[UIScreen mainScreen] bounds ].size.width - 49;
	
	//get Position
	CGPoint tabBarPoint = [tabBarView convertPoint:tabBarView.bounds.origin toView:glView];
	CGPoint tablePoint = [structurTableView convertPoint:structurTableView.bounds.origin toView:glView];
	
	if (tabBarPoint.y == 800)//war eingelappt
	{
		[tabBarView setFrame:CGRectMake(0, hideY ,tabBarView.frame.size.width    ,tabBarView.frame.size.height )];
		if ([structureTabBar selectedItem]) {
			[self addView:structurTableView to:true withAnimationsFrom:@"right"];
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
			[self addView:structurTableView to:false withAnimationsFrom:@"right"];
		}
	}
	
	
	
	[UIView commitAnimations];
	
}


-(void)initNavButtons
{
	
	
	UIFont* textFont = [UIFont systemFontOfSize:12];
	CGFloat textAlpha = 0.3;
	UIColor* textColor = [UIColor whiteColor];
	UIColor* textBackgroundColor = [UIColor blackColor] ;
	CGFloat textWidth = 90;
	
	UIView* navigationButtonsView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 4*(textWidth + 1), 30)];
	navigationButtonsView.backgroundColor = [UIColor clearColor];
	
	
	
	UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, textWidth, 30)];
	[button1 setTitle:@"full screen" forState:UIControlStateNormal];
	[button1 setBackgroundColor:textBackgroundColor ];
	[button1 setAlpha:textAlpha];
	button1.titleLabel.font = textFont;
	[button1 addTarget:self action:@selector(fullscreenToggle) forControlEvents:UIControlEventTouchUpInside];
	[button1 setTitleColor:textColor forState:UIControlStateNormal];
	
	[navigationButtonsView addSubview:button1];
	
	
	UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(textWidth + 1, 0, textWidth, 30)];
	[button2 setTitle:@"sync" forState:UIControlStateNormal];
	[button2 setBackgroundColor:textBackgroundColor ];
	[button2 setAlpha:textAlpha];
	button2.titleLabel.font = textFont;
	[button2 addTarget:self action:@selector(backToSync) forControlEvents:UIControlEventTouchUpInside];
	[button2 setTitleColor:textColor forState:UIControlStateNormal];
	
	[navigationButtonsView addSubview:button2];

	
	
	
	
	//einblenden mit animation
	navigationButtonsView.frame = CGRectMake(0, -navigationButtonsView.frame.size.height, navigationButtonsView.frame.size.width, navigationButtonsView.frame.size.height);
	
	[UIView animateWithDuration:0.5
						  delay:0.0
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 navigationButtonsView.frame = CGRectMake(0, 0, navigationButtonsView.frame.size.width, navigationButtonsView.frame.size.height);
					 }
					 completion:^(BOOL finished){
					 }];
	
	
	[glView addSubview:navigationButtonsView];
	
	
	[glView bringSubviewToFront:navigationButtonsView];
	
	
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
	
	//Dokuenten Ordner holen
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	documentsDir = [paths objectAtIndex:0];
	
	
	[self initTrackingDataFileName:@"TrackingData"];
	
	
	[self initLight];
	[self initShaders];
	
	
	[self loadObjectsInFolder:@"3D" forCosID:1];
	
	tableParents = [[NSMutableArray alloc]init];
	tableModels = [[NSMutableArray alloc]init];
	isBtoEnable = true;
	offlineMode = false;
	
	[self initTabBar];
	
	workView.frame = CGRectMake(0, 49, workView.frame.size.width, workView.frame.size.height);
	
	
	workTableViewController.delegate = self;
	[workTableViewController loadContent];
	
	[self initNavButtons];
	
	
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

//- (void) onScreenshotImageIOS:(UIImage *)image
//{
//    NSLog(@"screenshot IOS image is received %@", [image description]);
//}

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
