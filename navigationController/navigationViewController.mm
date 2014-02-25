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
@synthesize myNavigationViewControllerDelegate;


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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initController
{
	
	// Benutzerpfade abfragen
	NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,
														 NSUserDomainMask,
														 YES );
	
	// Dokumentenverzeichnis
	navigationDirectory = [NSString stringWithFormat:@"%@/navigation",[ paths objectAtIndex: 0 ] ];
	
	
	meter = 800 ;
	devRatio = 5;
	aktivateDetection = true;
	
	
	currentPosition = CGPointMake(855, 6840);
	
	[self initMap];
	
	[self initCompass];
	
	[self initSchrittzaehler];
	
	
	mapScrollView.zoomScale = 0.5;
}



#pragma mark -
#pragma mark Map View
#pragma mark -

- (void)initMap
{
    [self loadMapFromXML:@"map"];
	
	
	
	// Absoluter String zur XML-Datei
	NSString *mapFile = [ navigationDirectory stringByAppendingPathComponent: loadedMap.map ];
	
	
	//Plan laden
	UIImage* image = [UIImage imageWithContentsOfFile:mapFile];
	
	
	[loadedMap setHeight:image.size.height];
	[loadedMap setWidth:image.size.width];
	
	//scale der map auf pixel umrechnen
	loadedMap.scale =  (loadedMap.scale * loadedMap.ySize) / loadedMap.height;
	
	//Anpassung durch CustomRendere ?!?!?!?
	if ([[UIScreen mainScreen] scale] == 1) {
		loadedMap.scale =  loadedMap.scale * 4  ;
	}
	
	
	
	//Hauptview init
	mapView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 400, 748)];
	
	
	//map ScrollView init
	mapScrollView = [[UIScrollView alloc]initWithFrame:mapView.frame];
	mapScrollView.delegate = self;
	mapScrollView.minimumZoomScale = 0.1;
	mapScrollView.maximumZoomScale = 100.0;
	
	mapScrollView.zoomScale = 1;
	mapScrollView.contentSize = image.size;
	
	
	
	//map ImageView init
	mapImageView = [[UIImageView alloc]init];
	mapImageView.image =  image	;
	
	[mapImageView sizeToFit];
	
	
	
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
	
	
	
	
	
	//TableView
	signsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, 230, 0) style:UITableViewStylePlain];
	signsTableView.dataSource = self;
	signsTableView.delegate = self;
	signsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	
	
	//View für die Markerekennung hinzufügen um die Markererkennung zu aktivieren
	detectionView = [[UIView alloc] initWithFrame:CGRectMake(0, mapView.frame.size.height-100, 100, 100)];
	detectionView.backgroundColor = [UIColor blackColor];
	detectionView.alpha = 0.1;
	
	
	
	
	//Views hinzufügen
	[mapScrollView addSubview:mapImageView];
	[mapView addSubview:mapScrollView];
	[mapView addSubview:signsTableView];
	[mapView addSubview:detectionView];
	
	
	
	
	//Anpassen der SChrittweite entprechend der Skallierung der Map
	meter =  meter / loadedMap.scale;
	
	//Position und Blickwinkel anzeigen
	[self drawPositionAtPoint:currentPosition withDirection:(mapDirection)];
	
	//Am Start einen Kreis zeichnen
	[self drawCircleAtPoint:currentPosition withColor:[UIColor redColor] toLayer:@"startPoint"];
	
	
	//Position in View mittig setzen
	[self setNewPosition:currentPosition];
	
	
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    //erstmalige init
    if (cell == nil) {
		
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
	
	
	
	SignClass *cellSign = [nearSigns objectAtIndex:indexPath.row];
	
	
	
	
	
	//Richtung als Pfeil
    UIImageView *directionImage = (UIImageView*)[cell viewWithTag:111];
    
    //Wenn nicht existiert dann erstellen
    if (directionImage == nil) {
        directionImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 4, 48, cell.frame.size.height-8)];
        directionImage.tag = 111;
        directionImage.contentMode = UIViewContentModeScaleAspectFit;
        [cell addSubview:directionImage];
    }
    
    directionImage.image = [UIImage imageNamed:@"pfeil.png"];
    
	//Pfeil drehen
    CGFloat arrowOrientation = [self angleOfPoint:CGPointMake(cellSign.xPos, cellSign.yPos) toPoint:currentPosition withZeroDirection:mapDirection];
    directionImage.transform = CGAffineTransformMakeRotation(DegreesToRadians (correctDirection(arrowOrientation)) );
    
    
	
	
	
	
	
	//Entfernung als Text
    UILabel *signLabel = (UILabel*)[cell viewWithTag:222];
    
    //Wenn nicht existiert dann erstellen
    if (signLabel == nil) {
        signLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 1, 70, cell.frame.size.height-2)];
        signLabel.textAlignment = NSTextAlignmentRight;
        signLabel.tag = 222;
        [cell addSubview:signLabel];
    }
	
    CGFloat signDistance = cellSign.Distance / 1000; //Anzeige in Meter
    signLabel.text = [NSString stringWithFormat:@"%1.2f m", signDistance];
	
	
	
	
	
    
	//Zeichen als bild
    UIImageView *signImage = (UIImageView*)[cell viewWithTag:444];
    
    //Wenn nicht existiert dann erstellen
    if (signImage == nil) {
        signImage = [[UIImageView alloc]init];
        signImage.frame = CGRectMake(135, 1, tableView.frame.size.width - 135, cell.frame.size.height-2);
		signImage.contentMode = UIViewContentModeScaleAspectFit;
        signImage.tag = 444;
        [cell addSubview:signImage];
    }
    
    //Label um Rückseite zu signalisieren
    UILabel *reverseLable = (UILabel*)[cell viewWithTag:333];
    
    if (reverseLable == nil) {
        reverseLable = [[UILabel alloc]initWithFrame:CGRectMake(125, 1, tableView.frame.size.width - 135, cell.frame.size.height-2)];
        reverseLable.textAlignment = NSTextAlignmentLeft;
        reverseLable.backgroundColor = [UIColor clearColor];
        reverseLable.tag = 333;
        [cell addSubview:reverseLable];
    }
    reverseLable.text = [NSString stringWithFormat:@""]; //erstmal Leertext
    
	
    if ([self isSiteVisibleForView:arrowOrientation WithSignOrientation:cellSign.Orientation] == true)
    {
		
		signImage.image = [UIImage imageWithContentsOfFile:[ navigationDirectory stringByAppendingPathComponent:cellSign.Name]];
        
        
		
		
	}else{
		
		if (cellSign.NameRev == nil) //Fals kein RevBild hinterleg dann normal aber kennzeichnen
		{
            
			signImage.image = [UIImage imageWithContentsOfFile:[ navigationDirectory stringByAppendingPathComponent:cellSign.Name]];
			
            reverseLable.text = [NSString stringWithFormat:@"↷"];
			
			
		}else{
			
			signImage.image = [UIImage imageWithContentsOfFile:[ navigationDirectory stringByAppendingPathComponent:cellSign.NameRev]];
			
		}
		
	}
	
	
	
    return cell;
	
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	[tableView setFrame:CGRectMake(0,0, tableView.frame.size.width, 50 * tableViewRows) ];
	
	return tableViewRows;
    
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
	
	
	//Abstand der Zeichen berechnen
	nearSigns = [self sortSigns:allSigns byMaximumdistance:10000]; //0 = all , 10000 = 10meter
	
	tableViewRows = nearSigns.count;
	//Maximal 3 Zeichen anzeigen
	if (tableViewRows>3) {
		tableViewRows = 3;
	}
	
	//Zeichenanzeige aktualisieren
	[signsTableView reloadData];
	
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
	CGSize frameSize = mapScrollView.superview.superview.frame.size;
	
	//View erzeugen
	if (!setPostitonView) {
		setPostitonView = [[UIView alloc]initWithFrame:CGRectMake(frameSize.height/2 - 100, frameSize.width/2 - 50, 200, 100)];
	}
	
	
	if ([mapScrollView.superview.superview.subviews containsObject:setPostitonView] == false) {
		
		[setPostitonView setBackgroundColor:[UIColor lightGrayColor]];
		
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
#pragma mark Set Config
#pragma mark -

- (void)setConfigForPedometer: (bool)aktiv
				   sensitvity:(CGFloat) sensitivity
				   stepLength:(CGFloat) stepLength

{
	//Schrittlänge
	meter = stepLength / loadedMap.scale;
	
	
	//deaktivieren des Schrittzählers = gleiche Variable als wenn man das manuell per TouchFeld macht
	if (aktiv==true)
	{
		searchForSign = false;
	}else{
		searchForSign = true;
	}
	
	
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
#pragma mark Signs
#pragma mark -

- (void) loadSignsFromXML: (NSString*) xmlFile
{
	
	
	// Absoluter String zur XML-Datei
	NSString *fullPath = [ navigationDirectory stringByAppendingPathComponent: [xmlFile stringByAppendingPathExtension:@"xml"] ];
	
    NSString* theContents = [[NSString alloc] initWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
	
    if ([theContents length] == 0) {
        NSLog(@"%@ - signs.xml cannot be found", fullPath);
    }
    
	// Parse the XML into a dictionary
	
	// Parse the XML into a dictionary
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
			if ([nextSign.Name rangeOfString:@"FL"].location == NSNotFound) {
				
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
        if (nextSign.Name){
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
		
		
        if (nextSign.NameRev){
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
	
	//------------------für tests marker aus tracking entfernen------------------
	NSMutableArray *discardedItems = [NSMutableArray array];
	
	for (ARMarker *marker in markerList) {
		if (![marker.name isEqualToString:@"RW_left.png"] && ![marker.name isEqualToString:@"RW_right.png"] && ![marker.name isEqualToString:@"RW_down.png"] && ![marker.name isEqualToString:@"FL_small.png"])
		{
			[discardedItems addObject:marker];
		}
	}
	
	[markerList removeObjectsInArray:discardedItems];
	
	//------------------für tests marker aus tracking entfernen------------------
	
	
	
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
			if (!success)
				NSLog(@"Failed to load tracking configuration");
			
		}else
			NSLog(@"Could not find tracking configuration file");
		
			m_metaioSDK->pauseTracking();
	}
	else
	{
		
		NSLog( @"Konfiguration konnte für Metaio nicht bereitgestellt werden" );
		
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
		NSLog(@"No Step Counter");
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
				 [self stepDetection:numberOfSteps];
			 }];
		 }];
    }
	
    steps = 0;
	
	isSignDetected = false;
	
}

-(void) stepDetection:(NSInteger)countedSteps
{
	
	NSLog(@"Steps: %i",countedSteps);
	
	//Strittzähler deaktivieren wenn nach Schild gesucht wird oder ein Schild gefunden wurde
	if (searchForSign == true || isSignDetected == true)
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
		
		
		if (!detectedSign.xPos==0)
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
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	locationManager.headingFilter = 5;
	locationManager.delegate=self;
	//[locationManager startUpdatingLocation];
	[locationManager startUpdatingHeading];
	
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager{
	NSLog(@"Compass Calibration");
	
	return YES;
}


- (void)locationManager:(CLLocationManager*)manager

	   didUpdateHeading:(CLHeading*)newHeading

{
	
	return;
	
	if (isSignDetected == true)
	{
		return;
	}
	
	
	trueDirection = newHeading.trueHeading;
	
	
	//Umrechnen falls Landscape
	if ([[UIDevice currentDevice] orientation]== UIDeviceOrientationLandscapeLeft) {
		trueDirection = correctDirection(trueDirection + 90);
	} else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
		trueDirection = correctDirection(trueDirection + 270);
	}
	
	
	
	//Map Korrektur aufschlagen
	mapDirection = correctDirection( trueDirection -	 loadedMap.orientation + trueNorthCorrection);
	
	[self drawPositionAtPoint:currentPosition withDirection:mapDirection];
	
	[signsTableView reloadData];
	
	
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
		[signsTableView reloadData];
		
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
#pragma mark Touches
#pragma mark -

- (void) isTouch: (bool) isTouched
	  atLocation: (CGPoint) touchPoint;
{
	
	if (isTouched == true && CGRectContainsPoint(detectionView.frame, touchPoint))
	{
		
		//Zeichenanzeige aktualisieren
		[signsTableView reloadData];
		
		searchForSign = true;
		
		//Pedometer aus
		
		
	}else
	{
		searchForSign = false;
		
		//Pedometer ein
		
	}
	
	//Prototyp + Return in updateHeading
	
	
	if (CGRectContainsPoint(CGRectMake(1024-200, 550, 200, 500), touchPoint))
	{
		trueDirection = trueDirection + (45/4);
	}else if (CGRectContainsPoint(CGRectMake(1024-200, 0, 200, 500), touchPoint))
	{
		
		trueDirection = trueDirection - (45/4);
	}
	
	mapDirection = correctDirection( trueDirection -	 loadedMap.orientation + trueNorthCorrection);
	
	[self drawPositionAtPoint:currentPosition withDirection:mapDirection];
	
	[signsTableView reloadData];
	
}

#pragma mark -
#pragma mark Actions
#pragma mark -


- (IBAction)showConfigView :(id)sender
{
	
	[glView addSubview:configView];
}


- (IBAction)closeConfigView :(id)sender
{
	[self setConfigForDetection:aktivDetectionSwitch.isOn ration:ratioSlider.value];
	
	minQuality = minQualityField.text.floatValue / 100;
	
	
	if (!(qualityThresold == qualityThresoldField.text.floatValue))
	{
		NSLog(@"rewrite TrackingSignsConfiguration.xml");
		
		[self writeTrackingXMLforSigns:nil toFile:@"TrackingSignsConfiguration.xml" withThresholdQuality:qualityThresoldField.text.floatValue / 100];
		qualityThresold = qualityThresoldField.text.floatValue;
	}
	
	
	
	[configView removeFromSuperview];
	
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


#pragma mark -
#pragma mark Umrechnungen
#pragma mark -

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


@end
