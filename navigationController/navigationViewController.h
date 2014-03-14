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
#import <AVFoundation/AVCaptureDevice.h>


@interface navigationViewController : MetaioSDKViewController < UITableViewDelegate, CLLocationManagerDelegate>

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
	
	
	UIImageView * detectSignView;
	
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

	//Navigation Buttons
	UIView* navigationButtonsView;
	
	
	//SignsView
	IBOutlet UIView* signsView;
	IBOutlet UIView* sign1;
	IBOutlet UIView* sign2;
	IBOutlet UIView* sign3;
	
	NSString *navigationDirectory;
	
	UIView *mapView; //view für die map
	UIScrollView *mapScrollView;  //Scroll View für die Map
	UIImageView	*mapImageView; //ImageView die in der ScrollView liegt und die map.png läd
	CALayer *mapPositionLayer; //layer für die Position mit Blickwinkel
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
	
	BOOL isSignDetected; //Bool um abzufragen ob das derektierte Schild bereits erkannt wurde
	
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


- (IBAction)setLiklihoodToMid :(id)sender;

- (IBAction)setTrueNorth :(id)sender;

- (IBAction)deletePath :(id)sender;


@end