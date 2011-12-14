//
//  CoreDataManager.h
//  Breckenridge
//
//  Created by Ryan Connelly on 12/13/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataManager : NSObject

@property (nonatomic, strong) NSMutableArray *observedObjectContexts;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSManagedObjectModel *) newManagedObjectModel;
- (NSManagedObjectContext *) newManagedObjectContext;
+ (CoreDataManager *) sharedInstance;
@end
