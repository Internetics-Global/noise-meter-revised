//
//  SoundLevelCapture.h
//  NoiseMeter
//
//  Created by Dave Finster on 13/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SoundLevelCapture : NSManagedObject

@property (nonatomic, retain) NSString        * name;
@property (nonatomic, retain) NSDecimalNumber * soundLevel;
@property (nonatomic, retain) NSDate          * date;

+ (id)instance;

+ (NSArray *)all;

+ (NSArray *) sortedScoreArray;

+ (void) remove:(SoundLevelCapture *) capture;

+ (void) updateCapture:(SoundLevelCapture *) capture withNewName:(NSString *) nameStr;


@end
