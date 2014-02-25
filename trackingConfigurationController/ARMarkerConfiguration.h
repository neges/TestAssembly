#import "ARMarker.h"





@protocol ARMarkerConfiguration <NSObject>





/*!
 * @method
 * @abstract
 * @discussion
 * @param			(type)name:
 * @throws          NSException:
 * @return
 * @sinceversion	0.1.1
 * @sincedate		2011-
 * @updated			2011-
 **/
@required
- (NSString *)trackingConfigurationForMarkers: (NSArray *)markers;


@end
