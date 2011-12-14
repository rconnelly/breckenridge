//
//  Item.h
//  Breckenridge
//
//  Created by Ryan Connelly on 12/13/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * lastmoddate;
@property (nonatomic, retain) NSDate * createddate;

@end
