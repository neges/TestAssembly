#import "ARPictureMarkerConfiguration.h"





@implementation ARPictureMarkerConfiguration





#pragma mark -
#pragma mark Eigenschaften
#pragma mark -





@synthesize trackingQuality;

@synthesize thresholdOffset;

@synthesize numberOfSearchIterations;

@synthesize matrixID;

@synthesize qualityThreshold;

@synthesize binary;

@synthesize widthMM;

@synthesize heightMM;





#pragma mark -
#pragma mark Initialisierung
#pragma mark -





- (id)init
{

	self = [ super init ];
	
	if( self )
	{
	
		// fast / robust
		[ self setTrackingQuality: @"robust" ];
		
		[ self setThresholdOffset: @128 ];
		
		[ self setNumberOfSearchIterations: @5 ];
        
        [ self setMatrixID: @102 ];
        
        [ self setBinary: @0];
        
        [ self setQualityThreshold:0.70];
		
	}
	
	return self;
	
}





#pragma mark -
#pragma mark Protocol
#pragma mark -





- (NSString *)trackingConfigurationForMarkers: (NSArray *)markers
{
	
	 
	 NSMutableString *xmlString = [ NSMutableString stringWithString: @"<?xml version=\"1.0\"?>\n" ];
	 
	 [ xmlString appendString: @"<TrackingData>\n" ];
	 
	 [ xmlString appendString: @"\t<Sensors>\n" ];
	 
	 [ xmlString appendFormat: @"\t\t<Sensor Type=\"MarkerBasedSensorSource\">\n" ];

	 
	 [ xmlString appendString: @"\t\t\t<SensorID>Markertracking1</SensorID>\n" ];
	 
	 
     [ xmlString appendString: @"\t\t\t<Parameters>\n" ];
    
     [ xmlString appendFormat: @"\t\t\t\t<MarkerTrackingParameters>\n"];
	 
	 [ xmlString appendFormat: @"\t\t\t\t\t<trackingQuality>%@</trackingQuality>\n", [ self trackingQuality ]  ] ;
	 
	 [ xmlString appendFormat: @"\t\t\t\t\t<thresholdOffset>%1.0f</thresholdOffset>\n", [ [ self thresholdOffset ] floatValue ] ];

     [ xmlString appendFormat: @"\t\t\t\t\t<numberOfSearchIterations>%1.0f</numberOfSearchIterations>\n", [ [ self numberOfSearchIterations ] floatValue ] ];
    
     [ xmlString appendString: @"\t\t\t\t</MarkerTrackingParameters>\n" ];

	 [ xmlString appendString: @"\t\t\t</Parameters>\n" ];
	 
	 
	 
	 NSInteger cosID = 1;
	 
	 for( ARMarker *marker in markers )
	 {
	 
	 [ xmlString appendString: @"\t\t\t<SensorCOS>\n" ];
	 
	 [ xmlString appendFormat: @"\t\t\t\t<SensorCosID>%@</SensorCosID>\n", [ marker filename ] ];
	 
	 [ xmlString appendString: @"\t\t\t\t<Parameters>\n" ];
         
     [ xmlString appendString: @"\t\t\t\t\t<MarkerParameters>\n" ];
         
	 [ xmlString appendFormat: @"\t\t\t\t\t\t<MatrixID>%i</MatrixID>\n", cosID  ];
         
     [ xmlString appendFormat: @"\t\t\t\t\t\t\t<referenceImage widthMM=\"%f\" heightMM=\"%f\" binary=\"%1.0f\" qualityThreshold=\"%1.2f\">%@</referenceImage>\n", [marker widthMM], [marker heightMM], [[self binary] floatValue], [self qualityThreshold], [ marker filename ] ];
         
     [ xmlString appendString: @"\t\t\t\t\t</MarkerParameters>\n" ];    
	 
	 [ xmlString appendString: @"\t\t\t\t</Parameters>\n" ];
	 
	 [ xmlString appendString: @"\t\t\t</SensorCOS>\n" ];
	 
	 
	 // CosID für den Marker setzen
	 [ marker setCosID: [ NSNumber numberWithInteger: cosID ] ];
	 
	 
	 cosID++;
	 
	 }
	
	 
	 [ xmlString appendString: @"\t\t</Sensor>\n" ];
	 
	 [ xmlString appendString: @"\t</Sensors>\n" ];
	

	//------------Connection------------
	
	 [ xmlString appendString: @"\t<Connections>\n" ];
	
	for( ARMarker *marker in markers )
	{
		
		[ xmlString appendString: @"\t\t<Cos>\n" ];
		
		
		[ xmlString appendFormat: @"\t\t\t<Name>%@</Name>\n", [ marker filename ]   ] ;
		
		[ xmlString appendString: @"\t\t\t<SensorSource>\n" ];
		
		[ xmlString appendFormat: @"\t\t\t\t<SensorCosID>%@</SensorCosID>\n", [ marker filename ]   ] ;
		
		[ xmlString appendString: @"\t\t\t</SensorSource>\n" ];
		
				
		[ xmlString appendString: @"\t\t</Cos>\n" ];
		
	}
	

	 [ xmlString appendString: @"\t</Connections>\n" ];
	
	
	//------------Connection------------

	
	 
	 [ xmlString appendString: @"</TrackingData>" ];
	 
	 return xmlString;
	
}


@end
