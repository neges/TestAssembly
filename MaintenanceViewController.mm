//
//  MaintenanceViewController.m
//  Template
//
//  Created by Mac on 25.10.13.
//  Copyright (c) 2013 itm. All rights reserved.
//

#import "MaintenanceViewController.h"

@interface MaintenanceViewController ()

@end

@implementation MaintenanceViewController


#pragma mark -
#pragma mark View
#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self initTrackingDate];
	
	
	[self initLight];
	[self initShaders];
	
	
	[self loadObjectsInFolder:@"3D" forCosID:1];
	
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
	TBXML* tbxml = [TBXML newTBXMLWithXMLString:theContents error:nil];
	TBXMLElement* rootElement = tbxml.rootXMLElement;
	
	if (!tbxml) {
		NSLog(@"No structur file could be found or structur file i incorrect : %@", fullPath);
		return;
	}
	
	


	
	//Hauptbaugruppe als geometry laden
	int cosID = 1;
	
	NSString* topModelName = [self getNameOfElement:rootElement];
	metaio::IGeometry* topModel = [self createGroupWithName:topModelName andParentObject:nil toCosID:cosID];
	
	//Sub elemente laden falls vorhanden
	if (rootElement->firstChild)
	{
		[self loadObjectsFromElement:rootElement->firstChild toCosID:cosID withParentObject:topModel fromFolder:pathString];
	
		loadedModels = m_metaioSDK->getLoadedGeometries();
	}
	
	
}

-(void)loadObjectsFromElement: (TBXMLElement*) oElement
						toCosID: (int) oCos
			   withParentObject: (metaio::IGeometry*) pObject
					 fromFolder: (NSString*) oFolder
{
	
	do{
		
		
		
		NSString *objectName = [self getNameOfElement:oElement];

		
		//Element hat Childs => Group
		if (oElement->firstChild)
		{
			//leere geometrie laden als parent
			
			metaio::IGeometry* groupModel = [self createGroupWithName:objectName andParentObject:pObject toCosID:oCos];
			
			[self loadObjectsFromElement: oElement->firstChild
								 toCosID: oCos
						withParentObject: groupModel
							  fromFolder: oFolder];
			
		}
		else //Element ist ein Object
		{
			
			[self loadObjectFromFolder:oFolder withName:objectName andParentObject:pObject toCosID:oCos];
		}
		
		
	}while ((oElement = oElement->nextSibling));
	
	
}

-(metaio::IGeometry*)   createGroupWithName:(NSString*) oName
							andParentObject: (metaio::IGeometry*) pObject
									toCosID: (int) oCos

{
	// load content
	NSString* emptyModel = [[NSBundle mainBundle] pathForResource:@"_empty_" ofType:@"obj"];
	
	if (!m_metaioSDK)
	{
		NSLog(@"Metaio Problem");
	}
	
	theLoadedModel =  m_metaioSDK->createGeometry([emptyModel UTF8String]);
	theLoadedModel->setName(*new std::string([oName UTF8String]));
	theLoadedModel->setCoordinateSystemID(oCos);
	
	if (pObject) {
		theLoadedModel->setParentGeometry(pObject);
		NSLog(@"Create Group : %@ with Parent : %s",oName, pObject->getName().c_str());
	}else{
		NSLog(@"Create Top Model : %@",oName);
	}
	
	
	return theLoadedModel;
	
}



-(metaio::IGeometry*)	loadObjectFromFolder: (NSString*) oFolder
									withName: (NSString*) oName
							andParentObject: (metaio::IGeometry*) pObject
									toCosID: (int) oCos
{
	// load content
	NSString* objModel = [NSString stringWithFormat:@"%@/%@.obj",oFolder,oName];
	
	
	if(objModel)
	{
		// if this call was successful, theLoadedModel will contain a pointer to the 3D model
		theLoadedModel =  m_metaioSDK->createGeometry([objModel UTF8String]);
		if( theLoadedModel )
		{
			// scale it a bit up
			
			CGFloat scale = 0.5;
			
			theLoadedModel->setTranslation (metaio::Vector3d(0,0,0)); //0,5,-70
			
			theLoadedModel->setScale(metaio::Vector3d(scale,scale,scale));
			
			theLoadedModel->setName(*new std::string([oName UTF8String]));
			
			theLoadedModel->setCoordinateSystemID(oCos);
			
			if (pObject) {
				theLoadedModel->setParentGeometry(pObject);
				NSLog(@"Load : %@ with Parent : %s",oName, pObject->getName().c_str());
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
#pragma mark Content Getter
#pragma mark -

- (metaio::IGeometry *)modelForObjectname: (NSString *)objectname
{
	
	// Wenn der Modelname eine Endung hat
	if( ! [ objectname hasSuffix: @".obj" ] )
	{
		
		// .obj hinzufügen
		objectname = [ objectname stringByAppendingString: @".obj" ];
		
	}
	
	
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
#pragma mark Tracking Data
#pragma mark -

-(void)initTrackingDate
{
	
    // load our tracking configuration
    NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData" ofType:@"xml" inDirectory:@"Assets"];
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
	
	if ( model && setHighlight == false)
	{
		[self unsetShaderToGeometry:theLoadedModel];
		
		theLoadedModel = model;
		setHighlight = true;
		[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(myHighlightTimer:) userInfo:nil repeats:YES];
		
		
	}
	else if (model && setHighlight == true)
	{
		
		[self unsetShaderToGeometry:theLoadedModel];
		
		theLoadedModel = model;
		setHighlight = true;
		
	}
	else
	{
		setHighlight = false;
	}
	
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
}

-(IBAction)test:(id)sender
{
	
	theLoadedModel = [self modelForObjectname:@"Parts"];
	
	theLoadedModel->setVisible(false);
	
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

-(void)myHighlightTimer:(NSTimer *)timer
{
    if(setHighlight)
    {
		if (highlightOn == false)
		{
			
			highlightOn = true;
			[self applyShader:@"red" toGeometry:theLoadedModel];
			
		}else{
			
			highlightOn = false;
			[self unsetShaderToGeometry:theLoadedModel];
			
		}
		
		
		
    }
    else
    {
        [timer invalidate]; //to stop and invalidate the timer.
		[self unsetShaderToGeometry:theLoadedModel];
    }
}





#pragma mark -
#pragma mark tbxml Methodes
#pragma mark -

-(TBXMLElement*) getElement:(TBXMLElement*)element
					 ByName:(NSString*) elementName
{
	
	do{
		
		
		TBXMLAttribute *attribute = element->firstAttribute;
		
		while (attribute)
		{
			if ([[TBXML attributeValue:attribute] isEqualToString:elementName])
			{
				return element;
			}
			
			attribute = attribute->next;
			
		}
		
		if (element->firstChild)
		{
			TBXMLElement* tempElement = [self getElement:element->firstChild ByName:elementName];
			if (tempElement) {
				return tempElement;
			}
		}
		
		
	}while ((element = element->nextSibling));
	
	return nil;
	
	
}

-(void)getAllElements:(TBXMLElement*)element
{
	
	
	do{
		
		
		TBXMLAttribute *attribute = element->firstAttribute;
		
		while (attribute)
		{
			//NSLog(@"%@ : %@ = %@", [TBXML elementName:element], [TBXML attributeName:attribute], [TBXML attributeValue:attribute]);
			
			NSLog(@"%@ = %@", [TBXML elementName:element], [TBXML attributeValue:attribute]);
			
			attribute = attribute->next;
			
		}
		
		if (element->firstChild)
		{
			[self getAllElements:element->firstChild];
		}
		
		
	}while ((element = element->nextSibling));
	
}

-(NSString*)getNameOfElement:(TBXMLElement*)element
{
	
	do {
		
		TBXMLAttribute *attribute = element->firstAttribute;
		
		if ([[TBXML attributeName:attribute] isEqualToString:@"name"])
		{
			return [TBXML attributeValue:attribute];
		}
		
		attribute = attribute->next;
	}
	
	while (element->nextSibling);
	
	return @"";

}

-(NSString*)getTypeOfElement:(TBXMLElement*)element
{
	
	return [TBXML elementName:element];
	
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
