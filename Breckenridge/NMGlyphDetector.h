//
//  NMGlyphDetector.h
//  Breckenridge
//
//  Created by Marat Sharifullin on 12/22/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NMGlyphSearchViewController;
@protocol NMGlyphDelegate <NSObject>

@optional
//- (void)glyphDetected:(WTMGlyph *)glyph withScore:(float)score;
- (void)glyphResults:(NSArray *)results;
- (void)firstResults:(char*)results size:(int)size;

@end


@interface NMGlyphDetector : NSObject
{
}
@property (nonatomic, assign) NMGlyphSearchViewController * delegate;
@property (nonatomic, strong) NSMutableArray *points;

//+ (id)detector;
//+ (id)defaultDetector;
+ (id)sharedInstance;
- (id)init;

- (void)addPoint:(CGPoint)point;
- (void)detectGlyph;
- (void)reset;

- (void)addPoints;

@end
