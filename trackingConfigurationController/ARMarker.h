/*!
 * @file			
 * @charset         UTF-8
 * @author			Andreas Malik <a@ogogogo.com>
 * @copyright		ogogogo UG (haftungsbeschränkt)
 * @license			http://ogogogo.com
 * @sinceversion	0.1.1
 * @sincedate		2012-
 * @updated			2012-
 **/
typedef enum 
{
	
	ARMarkerTypeIDMarker			= 0x49444,
	ARMarkerTypePictureMarker		= 0x50696,
	ARMarkerTypeMarkerless			= 0x4d617

} ARMarkerType;





/*!
 * @class			
 * @package			
 * @abstract		
 * @discussion 		
 * @author			Andreas Malik <a@ogogogo.com>
 * @version			0.1.1
 * @sinceversion	0.1.1
 * @sincedate		2012-
 * @updated			2012-
 **/
@interface ARMarker : NSObject
{
	
	
    /*!
     * @var
     * @abstract
     * @sinceversion	0.1.1
     * @sincedate		2011-
     * @updated			2011-
     **/
	ARMarkerType type;
	
	
    /*!
     * @var
     * @abstract
     * @sinceversion	0.1.1
     * @sincedate		2013-
     * @updated			2013-
     **/
	NSString *identification;
	
	
    /*!
     * @var				
     * @abstract		
     * @sinceversion	0.1.1
     * @sincedate		2012-
     * @updated			2012-
     **/
	NSNumber *cosID;
	
	
    /*!
     * @var				
     * @abstract		
     * @sinceversion	0.1.1
     * @sincedate		2012-
     * @updated			2012-
     **/
	NSString *name;
	
	
    /*!
     * @var
     * @abstract
     * @sinceversion	0.1.1
     * @sincedate		2011-
     * @updated			2011-
     **/
	NSString *description;
	
	
    /*!
     * @var				
     * @abstract		
     * @sinceversion	0.1.1
     * @sincedate		2012-
     * @updated			2012-
     **/
	NSString *filename;
	
	
	
	CGFloat widthMM;
	
	CGFloat heightMM;
	
	
	
}





#pragma mark -
#pragma mark Eigenschaften
#pragma mark -





@property( nonatomic, readwrite ) ARMarkerType type;

@property( strong,  ) NSString *identification;

@property( nonatomic, strong ) NSNumber *cosID;

@property( nonatomic, strong ) NSString *name;

@property( nonatomic, strong ) NSString *description;

@property( nonatomic, strong ) NSString *filename;


@property( nonatomic ) CGFloat widthMM;

@property( nonatomic ) CGFloat heightMM;


@end
