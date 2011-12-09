
#import "NMGestureDrawView.h"
#import <QuartzCore/QuartzCore.h>

#define kMaxPoints 10000
#define kLineWidth 2`

@implementation NMPoint
@synthesize dataPoint;

- (id) initWithPoint:(CGPoint)p
{
    self = [super init];
    if(self)
    {
        dataPoint = p;
    }
    return self;
}

@end

@implementation NMGesture

@synthesize points;

- (id) init
{
	self = [super init];
	self.points = [NSMutableArray array];
	return self;
}

@end


@implementation NMGestureDrawView

@synthesize delegate, gesture;

- (id)initWithCoder:(NSCoder *)aCoder
{
	self = [super initWithCoder:aCoder];
    self.backgroundColor = [UIColor clearColor];
    self.gesture = [[NMGesture alloc] init];
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	
    if ([delegate respondsToSelector:@selector(didBeginDrawGesture:)])
    {
        [delegate didBeginDrawGesture:self.gesture];
    }
    
    CGPoint p = [touch locationInView:self];
    [self.gesture.points addObject:[[NMPoint alloc] initWithPoint:p]];
    [self setNeedsDisplay];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint p = [touch locationInView:self];
    [self.gesture.points addObject:[[NMPoint alloc] initWithPoint:p]];
    
    [self setNeedsDisplay];
    //[self setNeedsDisplayInRect:CGRectMake(p.x - kLineWidth/2, p.y - kLineWidth/2, kLineWidth, kLineWidth)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([delegate respondsToSelector:@selector(didEndDrawGesture:)])
    {
        [delegate didEndDrawGesture:self.gesture];
    }
    
    [self performBlock:^{
        [self clear];
    } afterDelay:.3];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)clear
{
    [self.gesture.points removeAllObjects];
    [self setNeedsDisplay];
}


- (void)addPoint:(CGPoint)point
{
    if ([self.gesture.points count] < kMaxPoints) {
        [self.gesture.points addObject:[[NMPoint alloc] initWithPoint:point]];
        [self setNeedsDisplay];
        //[self setNeedsDisplayInRect:CGRectMake(point.x - kLineWidth/2, point.y - kLineWidth/2, kLineWidth, kLineWidth)];
    }
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
    UIColor *whiteColor = [UIColor whiteColor];
    [whiteColor setFill];
    [whiteColor setStroke];
    
    CGContextSetLineWidth(ctx, kLineWidth);
    CGContextSetAllowsAntialiasing(ctx, YES);
//    CGContextBeginPath(ctx);
    __block CGPoint lastPoint;
    [self.gesture.points enumerateObjectsUsingBlock:^(NMPoint *p, NSUInteger index, BOOL *stop) {
        if(index == 0)
        {
			CGContextFillEllipseInRect(ctx, CGRectMake(p.dataPoint.x-kLineWidth/2, p.dataPoint.y-kLineWidth/2,
                                                       kLineWidth, kLineWidth));
            lastPoint = p.dataPoint;
        }
        else
        {
            CGContextMoveToPoint(ctx, lastPoint.x, lastPoint.y);
            CGContextAddLineToPoint(ctx, p.dataPoint.x, p.dataPoint.y);
            lastPoint = p.dataPoint;
        }
    }];
    
    CGContextStrokePath(ctx);
}

@end