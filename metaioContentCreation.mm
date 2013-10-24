//
//  metaioContentCreation.m
//  Template
//
//  Created by Mac on 24.10.13.
//  Copyright (c) 2013 itm. All rights reserved.
//

#import "metaioContentCreation.h"
#import "EAGLView.h"

@interface metaioContentCreation ()

@end

@implementation metaioContentCreation

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
	NSDictionary* structur = nil;
	
	structur = [XMLReader dictionaryForXMLString:theContents error:Nil];
	
	if (!structur) {
		NSLog(@"No structur file could be found or structur file i incorrect : %@", fullPath);
		return;
	}
		
	//Hauptbaugruppe als geometry laden
	int cosID = 1;
	
	NSString* topModelName = [[structur objectForKey:@"model"] valueForKey:@"name"];
	metaio::IGeometry* topModel = [self createGroupWithName:topModelName andParentObject:nil toCosID:cosID];
	
	//Sub elemente laden
	[self loadObjectsFromDictonary:[structur objectForKey:@"model"] toCosID:cosID withParentObject:topModel fromFolder:pathString];
	
	
}

-(void)loadObjectsFromDictonary: (NSDictionary*) oDict
						toCosID: (int) oCos
			   withParentObject: (metaio::IGeometry*) pObject
					 fromFolder: (NSString*) oFolder
{
	
	NSArray *listObject = [oDict objectForKey:@"object"];
	if (listObject)
	{
		
		NSString* objectName;
		
		if (![listObject isKindOfClass:[NSArray class]])
		{
			//nur ein Array
			listObject = [NSArray arrayWithObject:listObject];
			
			objectName = [[listObject valueForKey:@"name"] objectAtIndex:0];
			
			[self loadObjectFromFolder:oFolder withName:objectName andParentObject:pObject toCosID:oCos];
			
			
			
		}else{
			//alle obejcts direkt unter dem parent laden
			for (NSDictionary *tempDict in listObject)
			{
				
				objectName = [tempDict valueForKey:@"name"];
				
				[self loadObjectFromFolder:oFolder withName:objectName andParentObject:pObject toCosID:oCos];
				
			}
		}
		
	}
	
	
	NSArray *listGroup = [oDict objectForKey:@"group"];
	if (listGroup)
	{
		
		if (![listGroup isKindOfClass:[NSArray class]])
		{
			//nur ein Array
			listGroup = [NSArray arrayWithObject:listGroup];
			
			//leere geometrie laden als parent
			NSString* groupModelName = [[listGroup valueForKey:@"name"] objectAtIndex:0];
			metaio::IGeometry* groupModel = [self createGroupWithName:groupModelName andParentObject:pObject toCosID:oCos];
			
			NSDictionary* listDict = [listGroup objectAtIndex:0] ;
			[self loadObjectsFromDictonary:listDict toCosID:oCos withParentObject:groupModel fromFolder:oFolder];
			
			
		}else{
			//alle groups unter dem parent laden
			for (NSDictionary *tempDict in listGroup)
			{
				//leere geometrie laden als parent
				NSString* groupModelName = [tempDict valueForKey:@"name"];
				metaio::IGeometry* groupModel = [self createGroupWithName:groupModelName andParentObject:pObject toCosID:oCos];
				
				[self loadObjectsFromDictonary:tempDict toCosID:oCos withParentObject:groupModel fromFolder:oFolder];
				
			}
		}
	}
}

-(metaio::IGeometry*)   createGroupWithName:(NSString*) oName
							andParentObject: (metaio::IGeometry*) pObject
									toCosID: (int) oCos

{
	// load content
	NSString* emptyModel = [[NSBundle mainBundle] pathForResource:@"_empty_" ofType:@"obj"];
	
	if (!m_metaioSDK)
	{
		NSLog(@"Metaio Problem");
	}
	
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



-(metaio::IGeometry*)	loadObjectFromFolder: (NSString*) oFolder
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

@end
