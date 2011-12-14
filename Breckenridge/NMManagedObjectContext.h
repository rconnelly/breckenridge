//
//  NMManagedObjectContext.h
//  Breckenridge
//
//  Created by Ryan Connelly on 12/13/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
@class CoreDataManager;
@interface NMManagedObjectContext : NSManagedObjectContext

@property (nonatomic, weak) CoreDataManager *coreDataManager;

@end
