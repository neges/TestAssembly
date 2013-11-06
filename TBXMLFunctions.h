//
//  TBXMLFunctions.h
//  Template
//
//  Created by Mac on 25.10.13.
//  Copyright (c) 2013 itm. All rights reserved.
//

#import "TBXML.h"

@interface TBXMLFunctions : TBXML


+(TBXMLElement*) getElement:(TBXMLElement*)element
					 ByName:(NSString*) elementName;


+(void)getAllElements:(TBXMLElement*)element;

+(void)getAllElements:(TBXMLElement*)element
		   withGroups:(bool)wGroups
			  toArray:(NSMutableArray *)elementArray;




+(NSString*)getAttribute:(NSString*)attrib
			   OfElement:(TBXMLElement*)element;


+(NSString*)getTypeOfElement:(TBXMLElement*)element;

+(NSMutableArray*)getAllParentElementsFrom:(TBXMLElement*)element;
+(NSMutableArray *)getAllTableViewSubElements:(TBXMLElement*)element;

@end
