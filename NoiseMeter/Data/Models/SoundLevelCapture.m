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

/**
 *  rated by noise level
 */
+ (NSArray *) sortedScoreArrayByNoiseLevel {
    NSArray *scores = [self all];
    
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"soundLevel" ascending:NO];
    scores = [scores sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
    
    return  scores;
}

/**
 *  rated by date
 */
+ (NSArray *) sortedScoreArrayByDate {
    NSArray *scores = [self all];
    
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    scores = [scores sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
    
    return  scores;
}


+ (void) remove:(SoundLevelCapture *) capture {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:[NMDataManager defaultManager].managedObjectContext]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"date==%@", capture.date]];
    
    NSError* error = nil;
    NSArray* results = [[NMDataManager defaultManager].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([results count] > 0) {
        [[NMDataManager defaultManager].managedObjectContext deleteObject:[results objectAtIndex:0]];
        
        if ([[NMDataManager defaultManager].managedObjectContext hasChanges] && ![[NMDataManager defaultManager].managedObjectContext save:&error]) {
            NSLog(@"save execute error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

+ (void) updateCapture:(SoundLevelCapture *) capture withNewName:(NSString *) nameStr {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:[NMDataManager defaultManager].managedObjectContext]];
    
    //更新谁的条件在这里配置；
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"date==%@", capture.date]];
    
    NSError* error = nil;
    NSArray* results = [[NMDataManager defaultManager].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (results.count > 0) {
        NSLog(@"%@",results);
        SoundLevelCapture *capture = [results objectAtIndex:0];
        capture.name = nameStr;
        
        if ([[NMDataManager defaultManager].managedObjectContext hasChanges] && ![[NMDataManager defaultManager].managedObjectContext save:&error]) {
            NSLog(@"save execute error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
}


@end
