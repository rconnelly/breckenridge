//
//  NMGlyphDetector.h
//  Breckenridge
//
//  Created by Marat Sharifullin on 12/22/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NMGlyphDelegate <NSObject>

@optional
//- (void)glyphDetected:(WTMGlyph *)glyph withScore:(float)score;
- (void)glyphResults:(NSArray *)results;
- (void)firstResult:(char)result;

@end


@interface NMGlyphDetector : NSObject {
    CGPoint minBn;
    CGPoint maxBn;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, strong) NSMutableArray *points;

+ (id)detector;
+ (id)defaultDetector;
- (id)init;

- (void)addPoint:(CGPoint)point;
- (void)detectGlyph;
- (void)reset;

- (void)calcBnBoxWithAddPoints;

- (float*)createSquare:(int)gridSize;

- (char)predict:(float*)grid gridSize:(int)gridSize;

@end
