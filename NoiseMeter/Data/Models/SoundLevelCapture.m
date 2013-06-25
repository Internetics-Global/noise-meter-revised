//
//  SoundLevelCapture.m
//  NoiseMeter
//
//  Created by Dave Finster on 13/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "SoundLevelCapture.h"
#import "NMDataManager.h"

@implementation SoundLevelCapture

@dynamic name;
@dynamic soundLevel;
@dynamic date;

+ (id)instance
{
	return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:[NMDataManager defaultManager].managedObjectContext];
}

+ (NSEntityDescription *)entity
{
	return [[[[NMDataManager defaultManager] managedObjectModel] entitiesByName] objectForKey:NSStringFromClass(self)];
}

+ (NSArray *)all
{
	NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[self entity]];
	NSArray *array = [[NMDataManager defaultManager].managedObjectContext executeFetchRequest:request error:&error];
	if (array == nil) 
    {
		array = [[NSArray alloc] init];
	}
	return array;
}

@end
