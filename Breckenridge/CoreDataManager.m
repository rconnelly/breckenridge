//
//  CoreDataManager.m
//  Breckenridge
//
//  Created by Ryan Connelly on 12/13/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CoreDataManager.h"

static CoreDataManager *coreDataManager;

@implementation CoreDataManager
@synthesize observedObjectContexts;
@synthesize persistentStoreCoordinator;

+ (void) initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coreDataManager = [[CoreDataManager alloc] init];
    });
}

- (id) init
{
    self = [super init];
    if(self)
    {
        observedObjectContexts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSPersistentStoreCoordinator *)newPersistentStoreCoordinator
{	
    
    if(persistentStoreCoordinator)
        return persistentStoreCoordinator;
    
    NSString *path = [NSString stringWithFormat:@"%@/Library/Caches/Breckenridge.sqlite", NSHomeDirectory()];
    NSURL *storeUrl = [NSURL fileURLWithPath:path];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self newManagedObjectModel]];
    
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                              URL:storeUrl
                                                                                            error:&error];
    if(error)
    {
       // DebugLog(@"Could not retreive store meta data %@, %@", error, [error userInfo]);
    }
    
    NSManagedObjectModel *destinationModel = [persistentStoreCoordinator managedObjectModel];
    BOOL pscCompatibile = [destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata];
    NSLog(@"Migration needed? %d", !pscCompatibile);
    
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        //DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator;
}


+ (CoreDataManager *) sharedInstance
{
    return coreDataManager;
}

- (NSManagedObjectModel *) newManagedObjectModel
{
    return [NSManagedObjectModel mergedModelFromBundles:nil];
}

- (NSManagedObjectContext *) newManagedObjectContext
{
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    NSManagedObjectContext *managedObjectContext = nil;
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }

    [observedObjectContexts addObject:managedObjectContext];
    return managedObjectContext;
}

@end
