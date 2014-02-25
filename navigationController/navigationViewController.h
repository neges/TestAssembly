//
//  navigationViewController.h
//  Template
//
//  Created by Mac on 25.02.14.
//  Copyright (c) 2014 itm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "SignClass.h"
#import "MapClass.h"
#import "ARMarkerConfiguration.h"
#import "ARPictureMarkerConfiguration.h"
#import "TBXML.h"
#import "TBXMLFunctions.h"
#import "EAGLView.h"
#import "MetaioSDKViewController.h"



@protocol navigationViewControllerDelegate;


@interface navigationViewController : MetaioSDKViewController < UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, CLLocationManagerDelegate>

{
	
	
	
	CGFloat emptyFrame; //zähler für die frames wenn nichts gefunden
    CGFloat detectFrame; //zähler für die frames wenn detekiert
	CGFloat qualityThresold; //Wert zwischenspeichern
	CGFloat minQuality; //Wert zwischenspeichern
	bool freezeDetection;
    
    //Daten des Markers speichern
    int detectedMarkerCosID;
    int detectedMarkerCosIDSave;
    CGFloat detectedMarkerQuality;
    NSMutableArray *detectedMarkerAngleAray;
    NSMutableArray *detectedMarkerDistanceArray;
    
	
	
	NSString* docDir; //Documents Ordner
	
	
	IBOutlet UIImageView * detectSignView;
	
	//config View
	IBOutlet UIView *configView;
	IBOutlet UITextField *keepMarkerForMaxFrames;
	IBOutlet UITextField *stepLengthField;
	IBOutlet UISlider *ratioSlider;
	IBOutlet UISwitch *aktivPedometerSwitch;
	IBOutlet UISwitch *aktivDetectionSwitch;
	IBOutlet UITextField *qualityThresoldField;
	IBOutlet UITextField *minQualityField;
	IBOutlet UITextField *distCorrection;
	
	//Logs
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *qualityLabel;
	IBOutlet UILabel *angleLabel;
	IBOutlet UILabel *distanceLabel;

	
	
	NSString *navigationDirectory;
	
	UIView *mapView; //view für die map
	IBOutlet UIScrollView *mapScrollView;  //Scroll View für die Map
	IBOutlet UIImageView	*mapImageView; //ImageView die in der ScrollView liegt und die map.png läd
	CALayer *mapPositionLayer; //layer für die Position mit Blickwinkel
	UITableView *signsTableView; //TableView für das einblenden der Signs
	NSArray *markerListXML; //Array mit allen Marker werden gespeichert
	
	//Variablen für die dynamische TableView
	int tableViewRows;
	
	CLLocationManager *locationManager;
	CGFloat trueDirection; //Richtung aus Kompass
    CGFloat mapDirection; //Richtung mit Korrektur durch die Karte
	CGFloat trueNorthCorrection; //Korrektur für Kompass
	
	CGPoint currentPosition; //aktuelle position
	CGFloat mapOrientation; //Ausrichtung der map.png bezühlich Norden = 0°
	
	CGFloat meter; //Schrittweite
    int steps; //Schritte seit letzter Kalibrirung
	CMStepCounter *cmStepCounter;
	NSOperationQueue *operationQueue;
	
	
	NSMutableArray *allSigns; //alle geladen Schilder
	NSMutableArray *nearSigns; //alle Schilder in der Nähe
	SignClass *detectedSign; //detektiertes Schild
    MapClass *loadedMap; //Daten zur geladene Map
	
	UIView *detectionView; //Button für die aktivierung der Erkennung / deaktivierung des Schrittzählers
	BOOL isSignDetected; //Bool um abzufragen ob das derektierte Schild bereits erkannt wurde
	BOOL searchForSign; //Bool wenn die Markerkennung genutzt und er Schirttzähler deaktiviert wird
	
	UIView *setPostitonView; //View mit der eine neue Position gesetzt werden kann
	CGPoint tapPointInView; //longPress Point Coords
	
	CGFloat devRatio; //Verhältnis zwischen Distnaz und Winkelabweichung
	BOOL aktivateDetection; //zum deaktivieren des Markerabgleichs
}

@property CGPoint currentPosition;
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (nonatomic, strong) IBOutlet UIView * mapView;
@property (nonatomic, strong) CMStepCounter *cmStepCounter;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@property(nonatomic)id<navigationViewControllerDelegate>myNavigationViewControllerDelegate;

- (IBAction)showConfigView :(id)sender;

- (IBAction)closeConfigView :(id)sender;

- (IBAction)setLiklihoodToMid :(id)sender;

- (IBAction)setTrueNorth :(id)sender;

- (IBAction)deletePath :(id)sender;



- (void) isTouch: (bool) isTouched
	  atLocation: (CGPoint) touchPoint;


- (void) drawCircleAtPoint: (CGPoint) circlePoint
				 withColor: (UIColor*) drawColor
				   toLayer: (NSString*) dLayer;

- (void) deleteLayerWithName:(NSString*)layerName;

- (void) loadSignsFromXML: (NSString*) xmlFile;

- (void) detectMarkerNamed: (NSString*) dMarker
			   withQuality: (CGFloat) dQuality
				inDistance: (CGFloat) dDistance
				  andAngel: (CGFloat) dAngle;

- (void)setConfigForPedometer: (bool)aktiv
				   sensitvity:(CGFloat) sensitivity
				   stepLength:(CGFloat) stepLength;


- (void)setConfigForDetection: (bool)aktiv
					   ration:(CGFloat) ratio;

- (void) writeTrackingXMLforSigns: (NSArray*) markerList
						   toFile: (NSString*) xmlName
			 withThresholdQuality: (CGFloat) thresholdQuality;

- (void) correctTrueNorthWith: (CGFloat)correctionAngle;


- (void) resetToCurrentPosition;


@end