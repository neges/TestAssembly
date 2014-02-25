#import "ARMarkerConfiguration.h"





@interface ARPictureMarkerConfiguration : NSObject <ARMarkerConfiguration>
{

	NSString *trackingQuality;
	
	NSNumber *thresholdOffset;
	
	NSNumber *numberOfSearchIterations;
    
    NSNumber *matrixID;
    
    NSNumber *binary;
    
    CGFloat qualityThreshold;
	
	CGFloat widthMM;
	
	CGFloat heightMM;
	
}





#pragma mark -
#pragma mark Eigenschaften
#pragma mark -



@property( nonatomic, strong ) NSString *trackingQuality;

@property( nonatomic, strong ) NSNumber *thresholdOffset;

@property( nonatomic, strong ) NSNumber *numberOfSearchIterations;

@property( nonatomic, strong ) NSNumber *matrixID;

@property( nonatomic, strong ) NSNumber *binary;

@property( nonatomic ) CGFloat qualityThreshold;

@property( nonatomic ) CGFloat widthMM;

@property( nonatomic ) CGFloat heightMM;



- (NSString *)trackingConfigurationForMarkers: (NSArray *)markers;

@end
