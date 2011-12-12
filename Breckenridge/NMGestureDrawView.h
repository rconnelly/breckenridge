//
//  PPSSignatureView.h
//  Priority MX POS
//
//  Created by Alex Silverman on 7/14/10.
//  Copyright 2010 Priority Payment Systems, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NMGesture : NSObject
@property (nonatomic, strong) NSMutableArray *points;

@end

@class NMGestureDrawView;


@protocol NMGestureDrawViewDelegate <NSObject>
- (void) didEndDrawGesture:(NMGesture *) gesture;
- (void) didBeginDrawGesture:(NMGesture *) gesture;
- (void) didAddPoint:(CGPoint) point;
- (void) didHide:(NMGestureDrawView *) drawView;
@end


@interface NMGestureDrawView : UIView 
@property (nonatomic, weak) IBOutlet id delegate;
@property (nonatomic, strong) NMGesture *gesture;
- (void) didHide;
- (void)clear;

@end