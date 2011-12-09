//
//  PPSSignatureView.h
//  Priority MX POS
//
//  Created by Alex Silverman on 7/14/10.
//  Copyright 2010 Priority Payment Systems, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NMPoint : NSObject
@property (nonatomic)CGPoint dataPoint;

- (id) initWithPoint:(CGPoint)p;

@end

@interface NMGesture : NSObject
@property (nonatomic, strong) NSMutableArray *points;

@end


@protocol NMGestureDrawViewDelegate <NSObject>
- (void) didEndDrawGesture:(NMGesture *) gesture;
- (void) didBeginDrawGesture:(NMGesture *) gesture;
@end


@interface NMGestureDrawView : UIView 
@property (nonatomic, weak) IBOutlet id delegate;
@property (nonatomic, strong) NMGesture *gesture;

- (void)clear;

@end