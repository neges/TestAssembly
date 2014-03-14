//
//  navigationViewController.m
//  Template
//
//  Created by Mac on 25.02.14.
//  Copyright (c) 2014 itm. All rights reserved.
//

#import "navigationViewController.h"

@interface navigationViewController ()

@end

@implementation navigationViewController
@synthesize mapView;
@synthesize currentPosition;
@synthesize locationManager;
@synthesize cmStepCounter;
@synthesize operationQueue;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Map View
#pragma mark -

- (void)initMapView
{
    [self loadMapFromXML:@"map"];
	
	
	
	// Absoluter String zur XML-Datei
	NSString *mapFile = [NSString stringWithFormat:@"%@/%@",navigationDirectory, loadedMap.map  ];
	
	
	//Plan laden
	UIImage* image = [UIImage imageWithContentsOfFile:mapFile];
	
	
	[loadedMap setHeight:image.size.height];
	[loadedMap setWidth:image.size.width];
	
	//scale der map auf pixel umrechnen
	loadedMap.scale =  loadedMap.scale * loadedMap.ySize / loadedMap.height;
	
	//Anpassung durch CustomRendere ?!?!?!?
	loadedMap.scale =  loadedMap.scale * [[UIScreen mainScreen] scale]  ;

	
	//mapView Hauptansicht
	mapView = [[UIView alloc]initWithFrame:CGRectMake(glView.frame.size.width-400, 0, 400, glView.frame.size.height)];
	
	
	//map ScrollView init
	mapScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height)];
	mapScrollView.delegate = self;
	mapScrollView.minimumZoomScale = 0.1;
	mapScrollView.maximumZoomScale = 100.0;
	mapScrollView.zoomScale = 1;
	mapScrollView.contentSize = image.size;
	
	
	
	//map ImageView init
	mapImageView = [[UIImageView alloc]initWithFrame:mapScrollView.frame];
	mapImageView.image =  image	;
	
	[mapImageView sizeToFit];
	
	
	//Detected Sign View
	detectSignView = [[UIImageView alloc]initWithFrame:CGRectMake(10, mapView.frame.size.height-90, 120, 90)];
	[detectSignView setBackgroundColor:[UIColor clearColor]];
	
	
	
	
	
	
	//Tab Actions
	mapImageView.userInteractionEnabled = YES;
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	[singleTap setNumberOfTapsRequired:1];
	[singleTap setNumberOfTouchesRequired:1];
	[mapImageView addGestureRecognizer:singleTap];
	
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	[doubleTap setNumberOfTapsRequired:2];
	[mapImageView addGestureRecognizer:doubleTap];
	
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(receivedLongPress:)];
	[longPress setMinimumPressDuration:2];
	[mapImageView addGestureRecognizer:longPress];
	


	//Views hinzufügen
	[mapScrollView addSubview:mapImageView];
	[mapView addSubview:mapScrollView];
	[mapView addSubview:detectSignView];
	
	
	
	
	//Anpassen der SChrittweite entprechend der Skallierung der Map
	meter =  meter / loadedMap.scale;
	
	
	//Position und Blickwinkel anzeigen
	[self drawPositionAtPoint:currentPosition withDirection:(mapDirection)];
	
	//Am Start einen Kreis zeichnen
	[self drawCircleAtPoint:currentPosition withColor:[UIColor redColor] toLayer:@"startPoint"];
		
	//Position in View mittig setzen
	[self setNewPosition:currentPosition];
	
	
	mapScrollView.zoomScale = 0.5;
	
	
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return mapImageView;
	
	
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	mapScrollView.zoomScale = scale;
	
	[self setNewPosition:currentPosition];
	
}



- (void) setNewPosition: (CGPoint) cPosition

{
	
	//Mitellpunkt der Scroll View verscheiben
	CGFloat mapOffset = 100 / mapScrollView.zoomScale;
	
	CGPoint mapPosition = CGPointMake(cPosition.x, loadedMap.height - cPosition.y - mapOffset);
	
	mapPosition = [self getPointInCurrentScale:mapPosition];
	
	mapScrollView.contentOffset = CGPointMake( mapPosition.x - mapScrollView.frame.size.width/2  , mapPosition.y - mapScrollView.frame.size.height/2 );
	
	
	if (allSigns)
	{
		//Abstand der Zeichen berechnen
		nearSigns = [self sortSigns:allSigns byMaximumdistance:10000]; //0 = all , 10000 = 10meter
		
		tableViewRows = nearSigns.count;
		
		//Zeichenanzeige aktualisieren
		[self updateSingsViewWithDirectionOnly:false];
	}

	
}


- (void) loadMapFromXML: (NSString*) xmlFile
{
	
	// Absoluter String zur XML-Datei
	NSString *fullPath = [ navigationDirectory stringByAppendingPathComponent: [xmlFile stringByAppendingPathExtension:@"xml"] ];
	
    NSString* theContents = [[NSString alloc] initWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
	
    
    if ([theContents length] == 0) {
        NSLog(@"%@ - map.xml cannot be found", fullPath);
    }
	
	// Parse the XML into a dictionary
	TBXML *mapXMLFile = [TBXML newTBXMLWithXMLString:theContents error:nil];;
	TBXMLElement *mapXML = mapXMLFile.rootXMLElement;
	
	loadedMap = [[MapClass alloc]init];
	
	[loadedMap setMap: [TBXMLFunctions getValue:@"map" OfElement:mapXML]];
    [loadedMap setOrientation:[[TBXMLFunctions getValue:@"orientation" OfElement:mapXML]floatValue]];
    [loadedMap setXSize:[[TBXMLFunctions getValue:@"xSizeMM" OfElement:mapXML]floatValue]];
    [loadedMap setYSize:[[TBXMLFunctions getValue:@"ySizeMM" OfElement:mapXML]floatValue]];
    [loadedMap setScale:[[TBXMLFunctions getValue:@"scale" OfElement:mapXML]floatValue]];
	
}


#pragma mark -
#pragma mark Touches in MapView
#pragma mark -


- (void) handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
	
	
	[self setNewPosition:currentPosition];
	
	
	
}

- (void) handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
	
	
	mapScrollView.zoomScale = 0.5;
	
	[self setNewPosition:currentPosition];
	
}

- (void)receivedLongPress:(UIGestureRecognizer *)gestureRecognizer
{
	//View erzeugen
	if (!setPostitonView) {
		setPostitonView = [[UIView alloc]initWithFrame:CGRectMake((glView.frame.size.width/2) - 100, glView.frame.size.height/2 - 50, 200, 100)];
	}
	
	
	if ([mapScrollView.superview.superview.subviews containsObject:setPostitonView] == false) {
		
		[setPostitonView setBackgroundColor:[UIColor whiteColor]];
		
		//cancle Button
		UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[cancelButton addTarget:self action:@selector(handleExitSetPosition:) forControlEvents:UIControlEventTouchDown];
		[cancelButton setFrame:CGRectMake(10, 10, 180, 32)];
		[cancelButton setTitle:@"cancel" forState:UIControlStateNormal];
		
		[setPostitonView addSubview:cancelButton];
		
		//set button
		UIButton *okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[okButton addTarget:self action:@selector(handleSetPosition:) forControlEvents:UIControlEventTouchDown];
		[okButton setFrame:CGRectMake(10, 58, 180, 32)];
		[okButton setTitle:@"set new position" forState:UIControlStateNormal];
		
		[setPostitonView addSubview:okButton];
		
		
		[mapScrollView.superview.superview addSubview:setPostitonView];
		
		
		
		CGPoint tapPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
		tapPointInView = [mapScrollView convertPoint:tapPoint toView:gestureRecognizer.view ];
		
		tapPointInView.x = tapPointInView.x * mapScrollView.zoomScale;
		tapPointInView.y = mapImageView.image.size.height - (tapPointInView.y * mapScrollView.zoomScale);
		
		[self drawCircleAtPoint:tapPointInView withColor:[UIColor magentaColor] toLayer:@"newPosition"];
		
	}
	
}



- (void) handleSetPosition:(UIGestureRecognizer *)gestureRecognizer
{
	
	
	currentPosition = tapPointInView;
	
    [self resetToCurrentPosition];
	
	NSLog(@"new Start Position %@", NSStringFromCGPoint(currentPosition));
	
	[self deleteLayerWithName:@"newPosition"];
	
	[setPostitonView removeFromSuperview];
	
	
	
}

- (void) handleExitSetPosition:(UIGestureRecognizer *)gestureRecognizer {
	
	[self deleteLayerWithName:@"newPosition"];
	
	[setPostitonView removeFromSuperview];
	
}


#pragma mark -
#pragma mark Signs
#pragma mark -

- (void) loadSignsFromXML: (NSString*) xmlFile
{
	
	
	// Absoluter String zur XML-Datei
	NSString *fullPath = [ navigationDirectory stringByAppendingPathComponent: [xmlFile stringByAppendingPathExtension:@"xml"] ];
	
    NSString* theContents = [[NSString alloc] initWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
	
    if ([theContents length] == 0) {
        NSLog(@"%@ - signs.xml cannot be found", fullPath);
		return;
    }
    
	
	// Parse the XML
	TBXML *signsXMLFile = [TBXML newTBXMLWithXMLString:theContents error:nil];;
	TBXMLElement *signsXML = signsXMLFile.rootXMLElement;
	
	allSigns = [[NSMutableArray alloc]init];
	
	TBXMLElement* element = signsXML->firstChild;
	if (!element)
		return;
	do
	{
		
		SignClass *nextSign = [[SignClass alloc]init];
		
		//Marker Bild laden wenn gefunden
		BOOL checkSignPNG = [[NSFileManager defaultManager] fileExistsAtPath:[navigationDirectory stringByAppendingPathComponent:[TBXMLFunctions getValue:@"marker" OfElement:element]]];
		
        if (checkSignPNG) {
			
            [nextSign setName:[TBXMLFunctions getValue:@"marker" OfElement:element]];
            
            [nextSign setOrientation:[TBXMLFunctions getValue:@"orientation" OfElement:element].floatValue];
			
			[nextSign setXPos:[TBXMLFunctions getValue:@"xPos" OfElement:element].floatValue];
			[nextSign setYPos:[TBXMLFunctions getValue:@"yPos" OfElement:element].floatValue];
			
            [nextSign setWidth:[TBXMLFunctions getValue:@"widthMM" OfElement:element].floatValue];
			[nextSign setHeight:[TBXMLFunctions getValue:@"heightMM" OfElement:element].floatValue];
			
            
		}else{
            
            NSLog(@"Sign: %@ could not be found", [TBXMLFunctions getValue:@"marker" OfElement:element]);
			
        }
		
		
		
		//MarkerRev Bild laden wenn gefunden
		if ([TBXMLFunctions getValue:@"markerRev" OfElement:element])
		{
            checkSignPNG = [[NSFileManager defaultManager] fileExistsAtPath:[navigationDirectory stringByAppendingPathComponent:[TBXMLFunctions getValue:@"markerRev" OfElement:element]]];
			
            {
                if (checkSignPNG) {
					
					[nextSign setNameRev:[TBXMLFunctions getValue:@"markerRev" OfElement:element]];
					
					[nextSign setOrientationRev:[TBXMLFunctions getValue:@"orientationRev" OfElement:element].floatValue];
					
					[nextSign setWidthRev:[TBXMLFunctions getValue:@"widthMMRev" OfElement:element].floatValue];
					[nextSign setHeightRev:[TBXMLFunctions getValue:@"heightMMRev" OfElement:element].floatValue];
					
                }else{
					
                    NSLog(@"Sign: %@ could not be found", [TBXMLFunctions getValue:@"markerRev" OfElement:element]);
                }
            }
		}
		
		
        //Zeichen ablegen und in map zeichnen
		if (nextSign)
        {
            [allSigns addObject:nextSign];
            
			
			// HARDCODED - verschiedene Farben für RW und FL - Hier flexibler machen und aus xml lesen
			if ([nextSign.Name rangeOfString:@"fire"].location == NSNotFound) {
				
				[self drawSignToPoint:CGPointMake(nextSign.xPos, nextSign.yPos) withAngel:nextSign.Orientation withSize:nextSign.width/loadedMap.scale withColor:[UIColor greenColor] withLayerName:@"signs"];
				
			}else{
				
				[self drawSignToPoint:CGPointMake(nextSign.xPos, nextSign.yPos) withAngel:nextSign.Orientation withSize:nextSign.width/loadedMap.scale withColor:[UIColor redColor] withLayerName:@"signs"];
			}
        }
		
		
	}while ((element = element->nextSibling));
	
	// Zeichen nach Distanz sortieren
	nearSigns = [[NSMutableArray alloc]init];
	
	nearSigns = [self sortSigns:allSigns byMaximumdistance:0];
	
    
	
	//Zeichen auch als marker speichern für die TrackingXML
	//Objecte für die spätere TrackingXML
	NSMutableArray *markerList = [[NSMutableArray alloc]init];
	
	
	
	for (SignClass *nextSign in allSigns)
	{
        NSPredicate *predicate;
        if (![nextSign.Name isEqualToString:@""]){
			predicate = [NSPredicate predicateWithFormat:@"name MATCHES %@", nextSign.Name];
			if ([[markerList filteredArrayUsingPredicate:predicate] count] == 0)
			{
				ARMarker *marker = [[ARMarker alloc]init];
				
				[marker setName:nextSign.Name];
				[marker setFilename:nextSign.Name];
				[marker setWidthMM:nextSign.width];
				[marker setHeightMM:nextSign.height];
				[marker setType:ARMarkerTypePictureMarker];
				
				[markerList addObject:marker];
				
			}
        }
		
		
        if (![nextSign.NameRev isEqualToString:@""]){
			predicate = [NSPredicate predicateWithFormat:@"name MATCHES %@", nextSign.NameRev];
			if ([[markerList filteredArrayUsingPredicate:predicate] count] == 0)
			{
				
				ARMarker *markerRev = [[ARMarker alloc]init];
				
				[markerRev setName:nextSign.NameRev];
				[markerRev setFilename:nextSign.NameRev];
				[markerRev setWidthMM:nextSign.widthRev];
				[markerRev setHeightMM:nextSign.heightRev];
				[markerRev setType:ARMarkerTypePictureMarker];
				
				[markerList addObject:markerRev];
				
			}
        }
	}
		
	
	//Schreiben der TrackingXML und darin laden
	[self writeTrackingXMLforSigns:[NSArray arrayWithArray:markerList] toFile:@"TrackingSignsConfiguration.xml" withThresholdQuality:0.7];
	
	
}


- (NSMutableArray*) sortSigns:(NSMutableArray*) iSigns
			byMaximumdistance:(CGFloat)maxDistance
{
    
	//Distanz checken
	for (SignClass *dSign in iSigns)
	{
		[dSign setDistance:DistanceBetween(currentPosition, CGPointMake(dSign.xPos, dSign.yPos))*loadedMap.scale];
	}
	
	
	
	
	
	NSSortDescriptor * sortByScore = [NSSortDescriptor sortDescriptorWithKey:@"Distance" ascending:YES];
	[iSigns sortUsingDescriptors:[NSArray arrayWithObject:sortByScore]];
	
	
	
	
	if (maxDistance>0)
	{
		NSMutableArray* eSigns = [[NSMutableArray alloc]init];
		for (SignClass *nSign in iSigns) {
			if (nSign.Distance <= maxDistance)
			{
				[eSigns addObject:nSign];
			}else{
				break;
				
			}
		}
		return eSigns;
	}else{
		return iSigns;
		
	}
	
}

- (void) writeTrackingXMLforSigns: (NSArray*) markerList
						   toFile: (NSString*) xmlName
			 withThresholdQuality: (CGFloat) thresholdQuality
{
	
	
	if (markerList)
	{
		markerListXML = markerList;
	}
	
	// Absoluter String zur XML-Datei
	NSString *xmlFile = [ navigationDirectory stringByAppendingPathComponent: xmlName ];
	
    ARPictureMarkerConfiguration *ARConfiguration = [[ARPictureMarkerConfiguration alloc] init];
	
	[ARConfiguration setQualityThreshold:thresholdQuality];
	
    
	NSString *xmlString = [ARConfiguration trackingConfigurationForMarkers:markerListXML];
	
	
	
	
	
	NSFileManager *fileManager = [ [ NSFileManager alloc ] init ];
	
	NSError *removeError;
	
	// Alte Datei löschen, bevor die neue angelegt werden soll
	[ fileManager removeItemAtPath: xmlFile
							 error: &removeError ];
	
	
	// Wenn das Schreiben der XML-Datei eroflgreich war
	if( [ xmlString writeToFile:xmlFile atomically:YES encoding:NSUTF8StringEncoding error:nil ] )
	{
		if( xmlFile )
		{
			bool success = m_metaioSDK->setTrackingConfiguration([xmlFile UTF8String]);
			if (!success){
				NSLog(@"Failed to load tracking configuration");
				m_metaioSDK->pauseTracking();
			}
			m_metaioSDK->resumeTracking();
			
		}else{
			NSLog(@"Could not find tracking configuration file");
			m_metaioSDK->pauseTracking();
		}
	}
	else
	{
		NSLog( @"Konfiguration konnte für Metaio nicht bereitgestellt werden" );
		m_metaioSDK->pauseTracking();
	}
	
}

- (BOOL) isSiteVisibleForView: (CGFloat) view
		  WithSignOrientation: (CGFloat) sOrientation
{
    //Orientierung um 180Grad drehen damit in blickrichtung
    CGFloat temp = correctDirection(sOrientation - 180);
    
    //Blickrichtung und Zeichenausrichtung abziehnen
    temp = temp - view;
	
	
	//falls negativ dann positiv machen um später nur eine überprüfung machen zu müssen
    if (temp < 0) {
        temp = -temp;
    }
	
	//Falls Winkel 0 - 180 => 360 - 180 - daher abziehen damit später nur noch ein wert < 180 übrig bleiben kann
	if (temp >180)
	{
		temp = 360 - temp;
	}
    
	
    
    //Wenn Zeichenseite sichbar wäre, dann muß der wert zwischen als 90 und -90 liegen -> 180Grad
    if (temp < 90)
    {
        return true;
    }else{
        //also andere Seite
        return false;
    }
    
}


#pragma mark -
#pragma mark SignsView
#pragma mark -

-(void)initSignsView
{
	NSArray* signsViewArray = [[NSArray alloc]initWithArray:signsView.subviews];
	
	
	
	for (int arrayCounter = 0; arrayCounter < [signsViewArray count]; ++arrayCounter )
	{
	
		UIView* currentView = [signsViewArray objectAtIndex:arrayCounter];
		
			//Richtung als Pfeil
				UIImageView* directionImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 4, 48, currentView.frame.size.height-8)];
				directionImage.tag = 111;
				directionImage.image = [UIImage imageNamed:@"pfeil.png"];
				directionImage.contentMode = UIViewContentModeScaleAspectFit;
				[currentView addSubview:directionImage];
			
			
			//Entfernung als Text
				UILabel* signLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 1, 70, currentView.frame.size.height-2)];
				signLabel.textAlignment = NSTextAlignmentRight;
				signLabel.tag = 222;
				[currentView addSubview:signLabel];

			
			//Zeichen als reverseLabel
				UILabel * reverseLable = [[UILabel alloc]initWithFrame:CGRectMake(125, 1, currentView.frame.size.width - 135, currentView.frame.size.height-2)];
				reverseLable.textAlignment = NSTextAlignmentLeft;
				reverseLable.backgroundColor = [UIColor clearColor];
				reverseLable.tag = 333;
				reverseLable.text = [NSString stringWithFormat:@"↷"];
				[reverseLable setHidden:true];
				[currentView addSubview:reverseLable];
		
		
			//Zeichen als bild
				UIImageView * signImage = [[UIImageView alloc]init];
				signImage.frame = CGRectMake(135, 1, currentView.frame.size.width - 135, currentView.frame.size.height-2);
				signImage.contentMode = UIViewContentModeScaleAspectFit;
				signImage.tag = 444;
				[currentView addSubview:signImage];
	
	
	}
	
	//signsView einblenden
	[signsView setFrame:CGRectMake(glView.frame.size.width - 230, 0, 230, 132)];
	[glView addSubview:signsView];
	
	[self updateSingsViewWithDirectionOnly:false];

}


- (void) updateSingsViewWithDirectionOnly:(BOOL)onlyDirection
{
	
	NSArray* signsViewArray = [[NSArray alloc]initWithArray:signsView.subviews];
	

	for (int arrayCounter = 0; arrayCounter < [signsViewArray count]; ++arrayCounter )
	{
	
		UIView* currentView = [signsViewArray objectAtIndex:arrayCounter];
		
		SignClass *cellSign = [nearSigns objectAtIndex:arrayCounter];
		

		//Richtung als Pfeil
			UIImageView *directionImage = (UIImageView*)[currentView viewWithTag:111];
					
			//Pfeil drehen
			CGFloat arrowOrientation = [self angleOfPoint:CGPointMake(cellSign.xPos, cellSign.yPos) toPoint:currentPosition withZeroDirection:mapDirection];
			directionImage.transform = CGAffineTransformMakeRotation(DegreesToRadians (correctDirection(arrowOrientation)) );
		
		if (!onlyDirection)
		{
		
			//Entfernung als Text
				UILabel *signLabel = (UILabel*)[currentView viewWithTag:222];

				CGFloat signDistance = cellSign.Distance / 1000; //Anzeige in Meter
				signLabel.text = [NSString stringWithFormat:@"%1.2f m", signDistance];
			

			//Zeichen als bild
				UIImageView *signImage = (UIImageView*)[currentView viewWithTag:444];
				UILabel *reverseLable = (UILabel*)[currentView viewWithTag:333];
			
			
				//Prüfen welches Bild
				if ([self isSiteVisibleForView:arrowOrientation WithSignOrientation:cellSign.Orientation] == true)
				{
					
					signImage.image = [UIImage imageWithContentsOfFile:[ navigationDirectory stringByAppendingPathComponent:cellSign.Name]];
					[reverseLable setHidden:true];
					
				}else{
					
					if ([cellSign.NameRev isEqualToString:@""]) //Fals kein RevBild hinterleg dann normal aber kennzeichnen
					{
						
						signImage.image = [UIImage imageWithContentsOfFile:[ navigationDirectory stringByAppendingPathComponent:cellSign.Name]];
						[reverseLable setHidden:false];

						
						
					}else{
						
						signImage.image = [UIImage imageWithContentsOfFile:[ navigationDirectory stringByAppendingPathComponent:cellSign.NameRev]];
						[reverseLable setHidden:true];
					}
					
				}
		}
	
	}

}

#pragma mark -
#pragma mark Draw Functions
#pragma mark -


- (void) drawLineFromPoint: (CGPoint) sPoint
				   toPoint: (CGPoint) ePoint
				 withColor: (UIColor*) drawColor
				  asDashed: (BOOL) dash
				   toLayer: (NSString*) dlayer
		 andSetNewPosition: (BOOL) setPos
{
	
	CGMutablePathRef linePath = nil;
	linePath = CGPathCreateMutable();
	CAShapeLayer *routeLineShape = [CAShapeLayer layer];
	
	routeLineShape.lineWidth = 8.0f;
	routeLineShape.lineCap = kCALineCapRound;;
	routeLineShape.strokeColor = [drawColor CGColor];
	
	if (dash)
	{
		routeLineShape.FillColor = [[UIColor clearColor] CGColor];
		[routeLineShape setLineJoin:kCALineJoinRound];
		[routeLineShape setLineDashPattern:
		 [NSArray arrayWithObjects:[NSNumber numberWithInt:20],
		  [NSNumber numberWithInt:20],nil]];
	}
	
	
	
	//umrechnen der Y coorinate, da der Layer Y = 0 oben hat und nicht unten
	CGPathMoveToPoint(linePath, NULL,  sPoint.x , loadedMap.height - sPoint.y );
	CGPathAddLineToPoint(linePath, NULL, ePoint.x , loadedMap.height - ePoint.y );
	
	routeLineShape.name = dlayer;
	routeLineShape.path = linePath;
	
	
	CGPathRelease(linePath);
	
	
	[[mapImageView layer] addSublayer:routeLineShape];
	
	if (setPos == true) {
		currentPosition = ePoint;
		[self setNewPosition:currentPosition];
		
	}
	
	
	
}

- (void) drawCircleAtPoint: (CGPoint) circlePoint
				 withColor: (UIColor*) drawColor
				   toLayer: (NSString*) dLayer
{
	
	
	CGMutablePathRef linePath = nil;
	linePath = CGPathCreateMutable();
	CAShapeLayer *routeLineShape = [CAShapeLayer layer];
	
	routeLineShape.lineWidth = 4.0f;
	routeLineShape.lineCap = kCALineCapRound;;
	routeLineShape.strokeColor = [drawColor CGColor];
	
	CGPathAddEllipseInRect( linePath , NULL , CGRectMake( circlePoint.x - 15, loadedMap.height - circlePoint.y - 15 ,30, 30 ) );
	
	routeLineShape.name = dLayer;
	routeLineShape.path = linePath;
	CGPathRelease(linePath);
	
	
	[[mapImageView layer] addSublayer:routeLineShape];
	
	
	//[self setNewPosition:currentPosition];
	
}


- (void) drawSignToPoint: (CGPoint) mPoint
			   withAngel: (CGFloat) angel
				withSize: (CGFloat) size
			   withColor: (UIColor*) color
		   withLayerName: (NSString*) layerName

{
	
	CGMutablePathRef linePath = nil;
	linePath = CGPathCreateMutable();
	CAShapeLayer *routeLineShape = [CAShapeLayer layer];
	
	routeLineShape.lineWidth = 4.0f;
	routeLineShape.lineCap = kCALineCapRound;;
	routeLineShape.strokeColor = [color CGColor];
	
	
	//Schild
	//umrechnen der Y coorinate, da der Layer Y = 0 oben hat und nicht unten
	CGPoint sPoint = [self movePoint:mPoint toDirection:angel+90 andDistance:size/2];
	CGPoint ePoint = [self movePoint:mPoint toDirection:angel-90 andDistance:size/2];
	
	CGPathMoveToPoint(linePath, NULL,  sPoint.x , loadedMap.height - sPoint.y );
	CGPathAddLineToPoint(linePath, NULL, ePoint.x , loadedMap.height - ePoint.y );
	
	routeLineShape.name = layerName;
	
	routeLineShape.path = linePath;
	CGPathRelease(linePath);
	
	
	[[mapImageView layer] addSublayer:routeLineShape];
	
	
	
	
	
}

- (void) deleteLayerWithName:(NSString*)layerName
{
	
	for (CALayer *layer in [mapImageView.layer.sublayers copy]) {
		
		
		if ([layer.name isEqualToString:layerName]) {
			[layer removeFromSuperlayer];
		}
		
		
	}
	
	
}

-(void) drawPositionAtPoint:(CGPoint) pPoint
			  withDirection:(CGFloat) pDirection
{
	
	[self deleteLayerWithName:@"position"];
	
	
	//Positionsanzeige mit Blickwinkel laden
	UIImage* imagePos = [UIImage imageNamed:@"position.png"];
	mapPositionLayer = [CALayer layer];
	//[[CAShapeLayer alloc]initWithFrame:CGRectMake(currentPosition.x - imagePos.size.width, currentPosition.y - imagePos.size.height, imagePos.size.width , imagePos.size.height)];
	mapPositionLayer.frame = CGRectMake(currentPosition.x - imagePos.size.width/2, loadedMap.height - currentPosition.y - imagePos.size.height/2, imagePos.size.width , imagePos.size.height);
	mapPositionLayer.contents =  (id)imagePos.CGImage;
	mapPositionLayer.transform = CATransform3DMakeRotation(DegreesToRadians(pDirection), 0, 0, 1);	mapPositionLayer.name = @"position";
	
	//Layer hinzufügen
	[mapImageView.layer addSublayer:mapPositionLayer];
	
}

- (CGPoint) getPointInCurrentScale: (CGPoint) iPoint
{
	
	iPoint.x = iPoint.x * mapScrollView.zoomScale;
	iPoint.y = iPoint.y * mapScrollView.zoomScale;
	
	return iPoint;
}

- (void) resetToCurrentPosition
{
	
	[self deleteLayerWithName:@"startPoint"];
	
	//Am Start einen Kreis zeichnen
	[self drawCircleAtPoint:currentPosition withColor:[UIColor redColor] toLayer:@"startPoint"];
	
	//Draw Position
	[self drawPositionAtPoint:currentPosition withDirection:mapDirection];
	
	//Position in View mittig setzen
	[self setNewPosition:currentPosition];
	
	
}

#pragma mark -
#pragma mark Punktberechnungen
#pragma mark -

double DistanceBetween(CGPoint point1, CGPoint point2)
{
    
	return sqrt(pow((point2.x - point1.x), 2.0) + pow((point2.y - point1.y), 2.0));
	
}


-(CGPoint) movePoint:(CGPoint) sPoint
		 toDirection:(CGFloat) angle
		 andDistance:(CGFloat) dist
{
	
	angle = correctDirection(angle);
	
	
	CGFloat directionNew = 0;
	CGFloat directionX = 0;
	CGFloat directionY = 0;
	
	
	//direction in 4 Segmente zerlegen
	
	if (angle>=0 && angle<=90) {
		
		directionNew = DegreesToRadians(angle);
		
		
		directionX = sPoint.x + sin(directionNew) * dist;
		directionY = sPoint.y + cos(directionNew) * dist;
		
		
	}else if (angle >90 && angle<=180)
	{
		
		directionNew = DegreesToRadians((angle-90));
		
		directionX = sPoint.x + cos(directionNew) * dist;
		directionY = sPoint.y - sin(directionNew) * dist;
		
		
	}else if (angle>180 && angle<=270)
	{
		directionNew = DegreesToRadians((angle-180));
		
		directionX = sPoint.x - sin(directionNew) * dist;
		directionY = sPoint.y - cos(directionNew) * dist;
		
		
	}else if (angle>270 && angle<=360)
	{
		directionNew = DegreesToRadians((angle-270));
		
		directionX = sPoint.x - cos(directionNew) * dist;
		directionY = sPoint.y + sin(directionNew) * dist;
		
	}
	
	return CGPointMake(directionX, directionY);
	
}

- (CGFloat) angleOfPoint: (CGPoint) point2
				 toPoint: (CGPoint) point1
       withZeroDirection: (CGFloat) zDirection
{
	
    CGFloat angleVal;
    angleVal = (((atan2((point2.x - point1.x) , (point2.y - point1.y)))*180)/M_PI);
    
    angleVal = correctDirection(angleVal - zDirection);
	
    return angleVal;
    
    
}




#pragma mark -
#pragma mark Schrittzähler
#pragma mark -

- (NSOperationQueue *)operationQueue
{
    if (operationQueue == nil)
    {
        operationQueue = [NSOperationQueue new];
    }
    return operationQueue;
}


- (void)initSchrittzaehler
{
	if ([CMStepCounter isStepCountingAvailable]) {
		NSLog(@"Step Counter");
	} else {
		
		NSLog(@"no Step Counter");
		UIButton *stepBTO = [[UIButton alloc] initWithFrame:CGRectMake(mapView.frame.size.width-100, mapView.frame.size.height-100, 100, 100)];
		[stepBTO setTitle:@"step" forState:UIControlStateNormal];
		[stepBTO setBackgroundColor:[UIColor blackColor] ];
		[stepBTO setAlpha:0.3];
		[stepBTO addTarget:self action:@selector(detectStep) forControlEvents:UIControlEventTouchUpInside];
		[stepBTO setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[mapView addSubview:stepBTO];
	}
	
	if ([CMMotionActivityManager isActivityAvailable]) {
		NSLog(@"Motion Activity");
	} else {
		NSLog(@"no Motion Activity");
	}
	
	
    if ([CMStepCounter isStepCountingAvailable])
    {
        self.cmStepCounter = [[CMStepCounter alloc] init];
        [self.cmStepCounter startStepCountingUpdatesToQueue:self.operationQueue updateOn:1 withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error)
         {
			 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
				 [self detectStep];
			 }];
		 }];
    }
	
    steps = 0;
	
	isSignDetected = false;
	
}

-(void) detectStep
{
		
	//Strittzähler deaktivieren wenn nach Schild gesucht wird oder ein Schild gefunden wurde
	if (isSignDetected == true)
	{
		return;
	}
	
	
	
	CGFloat directionNew = 0;
	CGFloat directionX = 0;
	CGFloat directionY = 0;
	
	
	//direction in 4 Segmente zerlegen
	
	if (mapDirection>=0 && mapDirection<=90) {
		
		directionNew = DegreesToRadians(mapDirection);
		
		
		directionX = currentPosition.x + sin(directionNew) * meter;
		directionY = currentPosition.y + cos(directionNew) * meter;
		
		
	}else if (mapDirection >90 && mapDirection<=180)
	{
		
		directionNew = DegreesToRadians((mapDirection-90));
		
		directionX = currentPosition.x + cos(directionNew) * meter;
		directionY = currentPosition.y - sin(directionNew) * meter;
		
		
	}else if (mapDirection>180 && mapDirection<=270)
	{
		directionNew = DegreesToRadians((mapDirection-180));
		
		directionX = currentPosition.x - sin(directionNew) * meter;
		directionY = currentPosition.y - cos(directionNew) * meter;
		
		
	}else if (mapDirection>270 && mapDirection<=360)
	{
		directionNew = DegreesToRadians((mapDirection-270));
		
		directionX = currentPosition.x - cos(directionNew) * meter;
		directionY = currentPosition.y + sin(directionNew) * meter;
		
	}
	
	
	CGPoint endPoint = CGPointMake(directionX, directionY);
	
	//Draw line
	[self drawLineFromPoint:currentPosition toPoint:endPoint withColor:[UIColor blueColor] asDashed:true toLayer:@"path" andSetNewPosition:true];
	
	//Draw Position
	[self drawPositionAtPoint:currentPosition withDirection:mapDirection];
	
	
	
	
	steps = steps + 1;
	
	
	
}



#pragma mark -
#pragma mark Detected Marker Methode
#pragma mark -


- (void) detectMarkerNamed: (NSString*) dMarker
			   withQuality: (CGFloat) dQuality
				inDistance: (CGFloat) dDistance
				  andAngel: (CGFloat) dAngle
{
	
	if (dMarker && aktivateDetection == true)
	{
		if (isSignDetected == false)
		{
			//Maximale Entfernung der Zeichen in Meter
			CGFloat maxDistance = 20;
			
			//Blickwinkels = 60 => 120° Range
			CGFloat angleViewToleranz = 50; // z.B. 60 für 120Grad, von -60 bis - +60
			
			//Toleranz für Distanzabweichung
			CGFloat distDeviationRef = 100 - (devRatio * 10);
			
			//Toleranz für Winkelabweichung
			CGFloat angleDeviationRef = (devRatio * 2);
			
			
			
			//1.			//alle Zeichen innerhalb der möglichen Distanz
			
			NSMutableArray *singsInView= [[NSMutableArray alloc] initWithArray:[self sortSigns:allSigns byMaximumdistance:maxDistance * 1000]]; //Meter in Millilimeter umrechen
			
			
			
			
			
			
			//2.			//alle Zeichen die innerhalb des Blickwinkels
			
			NSMutableArray *discardedSigns = [NSMutableArray array];
			for (SignClass *dSign in singsInView)
			{
				//Winkel zwischen Zeichen und Position im Bezug auf Blickwinkel = 0 - 360
				dSign.Angle = [self angleOfPoint:CGPointMake(dSign.xPos, dSign.yPos) toPoint:currentPosition withZeroDirection:mapDirection];
				
				if (!(dSign.Angle > 360 - angleViewToleranz) && !(dSign.Angle < angleViewToleranz))
				{
					[discardedSigns addObject:dSign];
				}
				
			}
			[singsInView removeObjectsInArray:discardedSigns];
			[discardedSigns removeAllObjects];
			
			
			
			
			
			
			//3.		Prüfen ob das Bild stimmt Bezogen auf die Blickrichtung
			
			NSMutableArray *possibleSigns = [[NSMutableArray alloc]init];
			for (SignClass *dSign in singsInView)
			{
				
				//Prüfen ob das Bild stimmt (normal) und auf Orientierung des Zeichens
				if([dSign.Name isEqualToString:dMarker] && [self isSiteVisibleForView:mapDirection WithSignOrientation:(dSign.Orientation)] == true)
				{
                    
                    SignClass *tempSign = [[SignClass alloc]init];
                    [tempSign setName:dSign.Name];
                    [tempSign setOrientation:dSign.Orientation];
                    [tempSign setXPos:dSign.xPos];
                    [tempSign setYPos:dSign.yPos];
                    [tempSign setWidth:dSign.width];
                    [tempSign setHeight:dSign.height];
                    [tempSign setAngle:dSign.Angle];
                    [tempSign setDistance:dSign.Distance];
                    
                    [possibleSigns addObject:tempSign];
					
				}
				//Prüfen ob das Bild stimmt (Rev) und auf Orientierung des Zeichens
				else if ([dSign.NameRev isEqualToString:dMarker] && [self isSiteVisibleForView:mapDirection WithSignOrientation:(dSign.OrientationRev)]  == true)
				{
                    
                    SignClass *tempSign = [[SignClass alloc]init];
                    [tempSign setName:dSign.NameRev];
                    [tempSign setOrientation:dSign.OrientationRev];
                    [tempSign setXPos:dSign.xPos];
                    [tempSign setYPos:dSign.yPos];
                    [tempSign setWidth:dSign.widthRev];
                    [tempSign setHeight:dSign.heightRev];
                    [tempSign setAngle:dSign.Angle];
                    [tempSign setDistance:dSign.Distance];
                    
                    [possibleSigns addObject:tempSign];
					
				}
				
				
				
			}
			
			
			
			
			
			//3.		Berechnen der Abweichung der Distanz und des Winkels in %
			
			//aber nur wenn überhaupt mehr als 1 Zeichen übrig geblieben ist
			if ([possibleSigns count] > 1)
			{
				
				
				for (SignClass *dSign in possibleSigns)
				{
					
					//Berechnung der Winkelabweichung in Grad
					CGFloat divAngle = 0;
					CGFloat mapAngle = dSign.Angle;
					if (mapAngle > 180) {
						mapAngle = 360 - mapAngle;
						mapAngle = -mapAngle;
					}
					
					divAngle = dAngle - mapAngle;
					divAngle = percentOf(divAngle, angleDeviationRef);
					
					
					//Berechnung der Distanzabweichung in Meter
					CGFloat divDistance;
					divDistance = dDistance - dSign.Distance;
					divDistance = percentOf(divDistance, distDeviationRef);
					
					[dSign setDeviation:divAngle + divDistance];
					
				}
				
				NSSortDescriptor * sortByScore = [NSSortDescriptor sortDescriptorWithKey:@"Deviation" ascending:YES];
				[possibleSigns sortUsingDescriptors:[NSArray arrayWithObject:sortByScore]];
				
			}
			
			
			if (!detectedSign) {
				detectedSign = [[SignClass alloc]init];
			}
			
			if ([possibleSigns count] > 0) {
				detectedSign = [possibleSigns objectAtIndex:0];
			}
		}
		
		
		if (!(detectedSign.xPos==0))
		{
			
			//detektierte Position
			CGPoint detectedPosition = [self movePoint:CGPointMake(detectedSign.xPos, detectedSign.yPos) toDirection:(detectedSign.Orientation - dAngle) andDistance:dDistance/loadedMap.scale];
			CGFloat detectedAngle = correctDirection(detectedSign.Orientation - 180 - dAngle);
			
			//Nur wenn die Psotionsabweichung unter 5Meter liegt
			if (DistanceBetween(currentPosition, detectedPosition) < 5000 / loadedMap.scale)
			{
				
				//Draw Line
				[self drawLineFromPoint:currentPosition toPoint:detectedPosition withColor:[UIColor blueColor] asDashed:false toLayer:@"path" andSetNewPosition:true];
				
				//Draw Position
				[self drawPositionAtPoint:currentPosition withDirection:detectedAngle];
				
				
				if (isSignDetected == false) {
					//detektiertes Zeichen markieren, wenn noch nicht geschehen
					[self drawCircleAtPoint:CGPointMake(detectedSign.xPos, detectedSign.yPos) withColor:[UIColor yellowColor] toLayer:@"detectedSign"];
					
					//					//Compass nachkalibirieren wenn qualität hoch genug ist
					//					if (dQuality > 0.80)
					//					{
					//						[self correctTrueNorthWith: correctDirection(detectedSign.Orientation - 180 - dAngle)];
					//					}
					
					
					
					
				}
				
				[self deleteLayerWithName:@"detectedSignLine"];
				[self drawLineFromPoint:currentPosition toPoint:CGPointMake(detectedSign.xPos, detectedSign.yPos)withColor:[UIColor yellowColor]  asDashed:false toLayer:@"detectedSignLine" andSetNewPosition:false];
				
				
				isSignDetected = true;
				
				
			}
			
			
			
		}
		
	}
	
	
	
	
	else
		
	{
		
		[self deleteLayerWithName:@"detectedSign"];
		[self deleteLayerWithName:@"detectedSignLine"];
		
		detectedSign = nil;
		
		isSignDetected = false;
	}
	
}


#pragma mark -
#pragma mark Compass
#pragma mark -

- (void)initCompass
{
	locationManager=[[CLLocationManager alloc] init];
	locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
	//locationManager.headingFilter = 5;
	locationManager.delegate=self;
	//[locationManager startUpdatingLocation]; //GPS loacation
	[locationManager startUpdatingHeading];
	
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
	NSLog(@"Compass Calibration needed");
	
	return NO	;
}


- (void)locationManager:(CLLocationManager*)manager

	   didUpdateHeading:(CLHeading*)newHeading

{
	
	
	if (isSignDetected == true)
	{
		return;
	}

	
	trueDirection = newHeading.trueHeading;
		
	
	//Umrechnen auf Landscape left
	trueDirection = correctDirection(trueDirection + 90);

	//Map Korrektur aufschlagen
	mapDirection = correctDirection( trueDirection -	 loadedMap.orientation + trueNorthCorrection);
	
	[self drawPositionAtPoint:currentPosition withDirection:mapDirection];
	
	[self updateSingsViewWithDirectionOnly:true];
	
	
}

- (void) correctTrueNorthWith: (CGFloat)correctionAngle
{
	if (correctionAngle == 0) //manuell gesetzt
	{
		if (mapDirection > 180)
		{
			trueNorthCorrection = correctDirection(360 - (trueDirection - loadedMap.orientation));
		}else{
			
			trueNorthCorrection = - (trueDirection - loadedMap.orientation);
		}
		
		//Zeichenanzeige aktualisieren
		[self updateSingsViewWithDirectionOnly:true];
		
	}else{
		
		CGFloat difference = (correctDirection(correctionAngle) - mapDirection);
		if (difference > 180)
		{
			difference = difference - 360;
		}
		trueNorthCorrection = trueNorthCorrection + difference;
		
	}
	
	
	//Map Korrektur aufschlagen
	mapDirection = correctDirection( trueDirection - loadedMap.orientation + trueNorthCorrection);
	[self drawPositionAtPoint:currentPosition withDirection:mapDirection];
	
}


#pragma mark -
#pragma mark Config View
#pragma mark -

-(void)initConfigView
{

	qualityThresold = 70;
	emptyFrame = 0;
    detectFrame = 0;
	
    
    
	//ConfigView
	keepMarkerForMaxFrames.text = @"12";
	stepLengthField.text = @"800";
	qualityThresoldField.text = @"70";
	minQualityField.text = @"50";
	aktivDetectionSwitch.on = true;
	aktivPedometerSwitch.on = true;
	distCorrection.text = @"1.28";
	
	minQuality = minQualityField.text.floatValue / 100;
	
	[configView setFrame:CGRectMake(0, 0, 220, 635)];

	
}


- (void)setConfigForPedometer: (bool)aktiv
				   sensitvity:(CGFloat) sensitivity
				   stepLength:(CGFloat) stepLength

{
	//Schrittlänge
	meter = stepLength / loadedMap.scale;
	
}

- (void)setConfigForDetection: (bool)aktiv
					   ration:(CGFloat) ratio

{
	//Wert setzen wenn aktiv
	aktivateDetection = aktiv;
	
	//Ration übernehmen
	devRatio = ratio;
	
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



- (void)toggleMap
{
	
	if ([glView.subviews containsObject:mapView])
	{
		
		[UIView animateWithDuration:0.5
							  delay:0.0
							options: UIViewAnimationCurveEaseIn
						 animations:^{
							 mapView.frame = CGRectMake(glView.frame.size.width, 0, mapView.frame.size.width, mapView.frame.size.height);
						 }
						 completion:^(BOOL finished){
							 [mapView removeFromSuperview];
						 }];
		
		
		
		
	}else{
		//view mit animation einblenden
		mapView.frame = CGRectMake(glView.frame.size.width, 0, mapView.frame.size.width, mapView.frame.size.height);
		
		[UIView animateWithDuration:0.5
							  delay:0.0
							options: UIViewAnimationCurveEaseIn
						 animations:^{
							 mapView.frame = CGRectMake(glView.frame.size.width - mapView.frame.size.width, 0, mapView.frame.size.width, mapView.frame.size.height);
						 }
						 completion:^(BOOL finished){
						 }];
		
		
		[glView addSubview:mapView];
	}
	
	[glView bringSubviewToFront:signsView];
	[glView bringSubviewToFront:navigationButtonsView];
	
	
	
}


-(void)fullscreenToggle
{
	
	if ([glView.subviews containsObject:mapView])
	{
		
		[signsView setHidden:YES];
		
		[UIView animateWithDuration:0.5
							  delay:0.0
							options: UIViewAnimationCurveEaseIn
						 animations:^{
							 mapView.frame = CGRectMake(glView.frame.size.width, 0, mapView.frame.size.width, mapView.frame.size.height);
						 }
						 completion:^(BOOL finished){
							 [mapView removeFromSuperview];
						 }];
		
		
		
		
		
	}else{
		//view mit animation einblenden
		mapView.frame = CGRectMake(glView.frame.size.width, 0, mapView.frame.size.width, mapView.frame.size.height);
		
		[UIView animateWithDuration:0.5
							  delay:0.0
							options: UIViewAnimationCurveEaseIn
						 animations:^{
							 mapView.frame = CGRectMake(glView.frame.size.width - mapView.frame.size.width, 0, mapView.frame.size.width, mapView.frame.size.height);
						 }
						 completion:^(BOOL finished){
							 [signsView setHidden:false];
						 }];
		
		
		[glView addSubview:mapView];
	}
	
	[glView bringSubviewToFront:signsView];
	[glView bringSubviewToFront:navigationButtonsView];
	
	
	
}


- (void)lockExposure
{

	//--------Test for Exposure
	NSArray *devices = [AVCaptureDevice devices];
	
	for (AVCaptureDevice *device in devices)
	{
		
		
		
		if ([device position] == AVCaptureDevicePositionBack)
		{
			
			UIButton *btn = (UIButton*)[navigationButtonsView viewWithTag:5];
			[device lockForConfiguration:nil];
			if ([device exposureMode] == AVCaptureExposureModeContinuousAutoExposure)
			{
				[device setExposureMode:AVCaptureExposureModeLocked];
				
				[btn setTitle:@"exposure auto" forState:UIControlStateNormal];

			}else{
				
				[device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
				[btn setTitle:@"exposure lock" forState:UIControlStateNormal];
			}
			[device unlockForConfiguration];
		}
	}
	
	

}
- (void)showConfigView
{
	
	if ([glView.subviews containsObject:configView])
	{
		[self closeConfigView];
		
	}else{
		//view mit animation einblenden
		configView.frame = CGRectMake(-configView.frame.size.width, 0, configView.frame.size.width, configView.frame.size.height);
		
		[UIView animateWithDuration:0.5
							  delay:0.0
							options: UIViewAnimationCurveEaseIn
						 animations:^{
							 configView.frame = CGRectMake(0, 0, configView.frame.size.width, configView.frame.size.height);
						 }
						 completion:^(BOOL finished){
						 }];
		
		
		[glView addSubview:configView];
	}
}


-(void)initNavButtons
{


	UIFont* textFont = [UIFont systemFontOfSize:12];
	CGFloat textAlpha = 0.3;
	UIColor* textColor = [UIColor whiteColor];
	UIColor* textBackgroundColor = [UIColor blackColor] ;
	CGFloat textWidth = 90;
	
	navigationButtonsView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5*(textWidth + 1), 30)];
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
	
	UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(3*(textWidth + 1), 0, textWidth, 30)];
	[button3 setTitle:@"info" forState:UIControlStateNormal];
	[button3 setBackgroundColor:textBackgroundColor ];
	[button3 setAlpha:textAlpha];
	button3.titleLabel.font = textFont;
	[button3 addTarget:self action:@selector(showConfigView) forControlEvents:UIControlEventTouchUpInside];
	[button3 setTitleColor:textColor forState:UIControlStateNormal];
	
	[navigationButtonsView addSubview:button3];
	
	
	UIButton *button4 = [[UIButton alloc] initWithFrame:CGRectMake(2*(textWidth + 1), 0, textWidth, 30)];
	[button4 setTitle:@"map" forState:UIControlStateNormal];
	[button4 setBackgroundColor:textBackgroundColor ];
	[button4 setAlpha:textAlpha];
	button4.titleLabel.font = textFont;
	[button4 addTarget:self action:@selector(toggleMap) forControlEvents:UIControlEventTouchUpInside];
	[button4 setTitleColor:textColor forState:UIControlStateNormal];
	
	[navigationButtonsView addSubview:button4];
	
	UIButton *button5 = [[UIButton alloc] initWithFrame:CGRectMake(4*(textWidth + 1), 0, textWidth, 30)];
	[button5 setTitle:@"exposure lock" forState:UIControlStateNormal];
	[button5 setBackgroundColor:textBackgroundColor ];
	[button5 setAlpha:textAlpha];
	[button5 setTag:5];
	button5.titleLabel.font = textFont;
	[button5 addTarget:self action:@selector(lockExposure) forControlEvents:UIControlEventTouchUpInside];
	[button5 setTitleColor:textColor forState:UIControlStateNormal];
	
	[navigationButtonsView addSubview:button5];
	
	
	
	
	
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
#pragma mark Touches & Actions
#pragma mark -

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	// Here's how to pick a geometry
	UITouch *touch = [touches anyObject];
	CGPoint loc = [touch locationInView:glView];
	
		
	//--------Test for Exposure
	NSArray *devices = [AVCaptureDevice devices];
	
	for (AVCaptureDevice *device in devices)
	{
		
		
		
		if ([device position] == AVCaptureDevicePositionBack)
		{
			
			
			[device lockForConfiguration:nil];

				
				CGPoint expPoint;
				expPoint.x = loc.x / [[UIScreen mainScreen] bounds ].size.height;
				expPoint.y = loc.y / [[UIScreen mainScreen] bounds ].size.width;
				
				[device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
				[device setExposurePointOfInterest:expPoint];
				
				
				NSLog(@"Exposure Point: %f / %f - %f / %f", expPoint.x, expPoint.y, loc.x, loc.y);
		
			[device unlockForConfiguration];
		}
	}
			
			

	
	
	
}


#pragma mark -
#pragma mark Actions
#pragma mark -


- (void)closeConfigView
{
	[self setConfigForDetection:aktivDetectionSwitch.isOn ration:ratioSlider.value];
	
	minQuality = minQualityField.text.floatValue / 100;
	
	
	if (!(qualityThresold == qualityThresoldField.text.floatValue))
	{
		NSLog(@"rewrite TrackingSignsConfiguration.xml");
		
		[self writeTrackingXMLforSigns:nil toFile:@"TrackingSignsConfiguration.xml" withThresholdQuality:qualityThresoldField.text.floatValue / 100];
		qualityThresold = qualityThresoldField.text.floatValue;
	}
	
	
	//view mit animation ausblenden
	[UIView animateWithDuration:0.5
						  delay:0.0
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 configView.frame = CGRectMake(-configView.frame.size.width, 0, configView.frame.size.width, configView.frame.size.height);
					 }
					 completion:^(BOOL finished){
						 [configView removeFromSuperview];
					 }];
	
	
	
}


- (IBAction)setLiklihoodToMid :(id)sender
{
	
	[ratioSlider setValue:5];
	
}


- (IBAction)setTrueNorth:(id)sender
{
	
	[self correctTrueNorthWith:0]; //automatischer Modus
	
}

- (IBAction)deletePath:(id)sender
{
	
	[self deleteLayerWithName:@"path"];
	
	[self resetToCurrentPosition];
	
}


#pragma mark -
#pragma mark Berechnungen
#pragma mark -

CGFloat averageOfArray(NSArray* inputArray)
{
    
    CGFloat average = 0;
    int count = inputArray.count;
    
    for (int z = 0; z < count; z++)
    {
        average = average + [[inputArray objectAtIndex:z]floatValue];
        
    }
    
    return average / count;
    
    
}

CGFloat DegreesToRadians(CGFloat degrees)
{
	return degrees * M_PI / 180;
};

CGFloat RadiansToDegrees(CGFloat radians)
{
	return radians * 180 / M_PI;
};

CGFloat correctDirection(CGFloat dir)
{
	
    //Umrechnen falls <0 und >360
	if (dir<0)
	{
		dir = 360 + dir;
		
	}else if (dir>360)
	{
		
		dir = dir - 360;
		
	}
    
    return dir;
	
};


CGFloat percentOf(CGFloat inpValue, CGFloat fromValue)
{
	if (inpValue < 0)
	{
		inpValue = -inpValue;
	}
	
	if (fromValue < 0)
	{
		fromValue = -fromValue;
	}
	
	CGFloat value;
	value = inpValue / (fromValue / 100);
	
	
	return value;
	
};

#pragma mark -
#pragma mark @protocol metaioSDKDelegate
#pragma mark -


- (void) drawFrame
{
    [super drawFrame];
	
	// return if the metaio SDK has not been initialiyed yet
    if( !m_metaioSDK )
        return;
	
	detectedMarkerQuality = 0;
	
	if (aktivDetectionSwitch.isOn)
	{
		//Alle Cos abfragen und das Cos mit der besten Qualität speichern
		for (int i=1; i<=m_metaioSDK->getNumberOfDefinedCoordinateSystems(); i++)
		{
			CGFloat quality = m_metaioSDK->getTrackingValues(i).quality;
			
			CGFloat rotationZ = fabs(m_metaioSDK->getTrackingValues(i).rotation.getEulerAngleDegrees().z);
			
			if (quality > 0 && rotationZ < 100)
			{
				if (quality > detectedMarkerQuality) {
					detectedMarkerCosID = i;
					detectedMarkerQuality = quality;
					
				}
				
			}
		}
	}
	
	//Wenn ein Cos gefunden wurde dann Werte abfragen und übergeben
	if (detectedMarkerQuality > minQuality && aktivDetectionSwitch.isOn)
	{
		metaio::TrackingValues trackingValues = m_metaioSDK->getTrackingValues(detectedMarkerCosID);
		
		
		//Namen des gefundenen markers zurückgeben
		std::string stdString = trackingValues.cosName;
		NSString *cosName = [NSString stringWithUTF8String:stdString.c_str()];
		
		//Marker in Anzeigen laden
		[detectSignView setImage:[UIImage imageWithContentsOfFile:[ navigationDirectory stringByAppendingPathComponent:cosName]]];
		[detectSignView setContentMode:UIViewContentModeScaleAspectFit];
		
		
		//prüfen ob es sich um eine neue cosID handelt
		if (detectedMarkerCosID == detectedMarkerCosIDSave)
		{ //gleiche CosID
			
			//Winkel zum gefundenen Marker zurückgeben
			CGFloat angle = - trackingValues.rotation.getEulerAngleDegrees().y;
			
			
			//Distanze zum gefundenen Winkel zurückgeben
			CGFloat distance = - trackingValues.translation.z;
			
			//Korrektur
			distance = distance * distCorrection.text.floatValue;
			
			
			if (detectFrame < 15)
			{
				//daten sammeln wenn vorhanden
				if (!(angle == 0) && !(distance == 0)) {
					if (!detectedMarkerAngleAray)
						detectedMarkerAngleAray = [[NSMutableArray alloc]init];
					
					if (!detectedMarkerDistanceArray)
						detectedMarkerDistanceArray = [[NSMutableArray alloc]init];
					
					[detectedMarkerAngleAray addObject:[NSNumber numberWithFloat:angle]];
					[detectedMarkerDistanceArray addObject:[NSNumber numberWithFloat:distance]];
					
					detectFrame++;
				}
				
				
				
				
			}else{ //Daten über 15Frames hinweg gesammelt
				
				detectFrame = 0;
				
				//mittelwert bilden
				
				CGFloat detectedMarkerDistance = averageOfArray([NSArray arrayWithArray:detectedMarkerDistanceArray]);
				CGFloat detectedMarkerAngle = averageOfArray([NSArray arrayWithArray:detectedMarkerAngleAray]);
				
				
				//arrays zum sammel löschen
				[detectedMarkerAngleAray removeAllObjects];
				[detectedMarkerDistanceArray removeAllObjects];
				
				
				//Werte zurückgeben
				[self detectMarkerNamed:cosName
							withQuality:detectedMarkerQuality
							 inDistance:detectedMarkerDistance
							   andAngel:detectedMarkerAngle];
								
				//Logs
				if ([glView.subviews containsObject:configView])
				{
					nameLabel.text = [NSString stringWithFormat:@"Name: %@",cosName];;
					qualityLabel.text = [NSString stringWithFormat:@"Quality: %f",detectedMarkerQuality];
					angleLabel.text = [NSString stringWithFormat:@"Angle: %f",detectedMarkerAngle];
					distanceLabel.text = [NSString stringWithFormat:@"Distance: %f",detectedMarkerDistance];
				}
				
				
			}
			
			
			
		}
		else //neue CosID
		{
			
			detectedMarkerCosIDSave = detectedMarkerCosID;
			
		}
		
		
		
		
		
		
		
	}
	
	//Sonst keine Marker weitergeben oder Frame hochzählen
	else
	{
		//Detektieten Marker aus Anzeige löschen
		[detectSignView setImage:nil];
		
		//Prüfen ob schon mal was gefunden wurde (frame > 0)
		//Wenn schon mal was gefunden wurde und das nicht mehr als x Frames her ist dann hochzählen
		if ((emptyFrame > 0) && (emptyFrame < keepMarkerForMaxFrames.text.floatValue))
		{
			emptyFrame++;
			return;
		}
		
		if (detectedMarkerCosID)
		{
			//sonst nichts  übergeben
			[self detectMarkerNamed:nil  withQuality:0 inDistance:0 andAngel:0];
			emptyFrame = 0;
			
			
			//detectedMarkerCos reseten
			detectedMarkerCosID = nil;
            
            
			
		}
		
		
	}

	
}

- (void) onSDKReady
{
    NSLog(@"The SDK is ready");
	
	// Benutzerpfade abfragen
	NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,
														 NSUserDomainMask,
														 YES );
	
	// Dokumentenverzeichnis
	navigationDirectory = [NSString stringWithFormat:@"%@/navigation",[ paths objectAtIndex: 0 ] ];
	
	
	meter = 800 ;
	devRatio = 5;
	aktivateDetection = true;
	
	
	currentPosition = CGPointMake(855, 2840);
	
	
	[self initMapView];
	
	[self loadSignsFromXML:@"signs"];
	
	[self initCompass];
	
	[self initConfigView];
		
	//MapView mit animation einblenden
	mapView.frame = CGRectMake(glView.frame.size.width, 0, 400, glView.frame.size.height);
	
	[UIView animateWithDuration:0.5
						  delay:0.0
						options: UIViewAnimationCurveEaseIn
					 animations:^{
						 mapView.frame = CGRectMake(glView.frame.size.width - mapView.frame.size.width, 0, mapView.frame.size.width, mapView.frame.size.height);
					 }
					 completion:^(BOOL finished){
						 [self initSignsView];
					 }];
	[glView addSubview:mapView];
	
	
	[self initSchrittzaehler];
	
	
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

- (void) onScreenshotImageIOS:(UIImage *)image
{
    NSLog(@"screenshot IOS image is received %@", [image description]);
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
