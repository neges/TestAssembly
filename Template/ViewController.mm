//
//  ViewController.m
//  Template
//
//  Created by Mac on 30.04.13.
//  Copyright (c) 2013 itm. All rights reserved.
//


//-------------------
//Template für metaio5.0 beta
//-------------------


#import "ViewController.h"


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    if( !m_metaioSDK )
    {
        NSLog(@"SDK instance is 0x0. Please check the license string");
        return;
    }
    
    
    [self initContent ];
    [self initLight];
    [self initShaders];
	

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initContent
{
  
    // load our tracking configuration
    NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData" ofType:@"xml" inDirectory:@"Assets"];
	if(trackingDataFile)
	{
		bool success = m_metaioSDK->setTrackingConfiguration([trackingDataFile UTF8String]);
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	}
    
	[self loadObjectsInFolder:@"3D" forCosID:1];
    

}

#pragma mark - 3D Objects
//Hier werden die Objecte der reihe nach geladen
// in der h.Datei müssen die IUnifeyeMobileGeometry für jedes 3D Object erzeugt werden
- (void)loadObjectsInFolder:(NSString *)oFolder
				   forCosID:(int)oCos

{
	NSString *objectFolderPath = [[NSBundle mainBundle] pathForResource:@"Assets" ofType:nil];
	NSString *pathString =  [NSString stringWithFormat:@"%@/%@",objectFolderPath,oFolder];
	
    NSString *fullPath = [NSString stringWithFormat:@"%@/models.xml",pathString];
    
    NSString* theContents = [[NSString alloc] initWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
    
    //xml laden falls vorhanden
    structur = nil;
    
    structur = [XMLReader dictionaryForXMLString:theContents error:Nil];
    
    if (!structur) {
        NSLog(@"No structur file could be found : %@", fullPath);
        return;
    }
    
    NSLog(@"XML: %@", structur);

    
    //Hauptbaugruppe als geometry laden
    int cosID = 1;
    
    NSString* topModelName = [[[structur objectForKey:@"models"] objectForKey:@"group"] valueForKey:@"name"];
    metaio::IGeometry* topModel = [self createGroupWithName:topModelName andParentObject:nil toCosID:cosID];
    
    //Sub elemente laden
    [self loadObjectsFromDictonary:[[structur objectForKey:@"models"] objectForKey:@"group"] toCosID:cosID withParentObject:topModel fromFolder:pathString];
    

}

-(void)loadObjectsFromDictonary: (NSDictionary*) oDict
                        toCosID: (int) oCos
               withParentObject: (metaio::IGeometry*) pObject
                     fromFolder: (NSString*) oFolder
{
    
    //alle models direkt unter dem parent laden
    for (NSDictionary *tempDict in [oDict objectForKey:@"model"] )
	{

        NSString* objectName = [tempDict valueForKey:@"name"];
        
        [self loadObjectFromFolder:oFolder withName:objectName andParentObject:pObject toCosID:oCos];

    }
    
    
    //alle groups unter dem parent laden    
    for (NSDictionary *tempDict in [oDict objectForKey:@"group"] )
    {
        //leere geometrie laden als parent
        NSString* groupModelName = [tempDict valueForKey:@"name"];
        metaio::IGeometry* groupModel = [self createGroupWithName:groupModelName andParentObject:pObject toCosID:oCos];
        
        [self loadObjectsFromDictonary:tempDict toCosID:oCos withParentObject:groupModel fromFolder:oFolder];
        
    }
}

-(metaio::IGeometry*)   createGroupWithName:(NSString*) oName
                            andParentObject: (metaio::IGeometry*) pObject
                                    toCosID: (int) oCos

{
    // load content
    NSString* emptyModel = [[NSBundle mainBundle] pathForResource:@"_empty_" ofType:@"obj"];
    
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



-(metaio::IGeometry*)   loadObjectFromFolder: (NSString*) oFolder
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


#pragma mark - Touches

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

#pragma mark - Light

-(void)initLight
{

    metaio::ILight*		m_pLight;
    
    m_pLight = m_metaioSDK->createLight();
    m_pLight->setType(metaio::ELIGHT_TYPE_DIRECTIONAL);
    
    m_metaioSDK->setAmbientLight(metaio::Vector3d(0.05f));
    m_pLight->setDiffuseColor(metaio::Vector3d(1, 1, 1)); // white
    
    m_pLight->setCoordinateSystemID(0);

    
}

#pragma mark - Shaders

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

#pragma mark - @protocol metaioSDKDelegate

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
