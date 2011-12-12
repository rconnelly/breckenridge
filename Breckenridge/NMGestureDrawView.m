
#import "NMGestureDrawView.h"
#import <QuartzCore/QuartzCore.h>

#define kMaxPoints 10000
#define kLineWidth 2


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
    //åself.backgroundColor = [UIColor clearColor];
    self.gesture = [[NMGesture alloc] init];
	
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = 8.0f;
    
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
    [self.gesture.points addObject:[NSValue valueWithCGPoint:p]];
    [self setNeedsDisplay];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint p = [touch locationInView:self];
    [self.gesture.points addObject:[NSValue valueWithCGPoint:p]];

    if ([delegate respondsToSelector:@selector(didAddPoint:)])
    {
        [delegate didAddPoint:p];
    }
    
    [self setNeedsDisplay];
    //[self setNeedsDisplayInRect:CGRectMake(p.x - kLineWidth/2, p.y - kLineWidth/2, kLineWidth, kLineWidth)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([delegate respondsToSelector:@selector(didEndDrawGesture:)])
    {
        [delegate didEndDrawGesture:self.gesture];
    }
    
    //[self performBlock:^{
        [self clear];
    //} afterDelay:.1];
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
        [self.gesture.points addObject:[NSValue valueWithCGPoint:point]];
        [self setNeedsDisplay];
        //[self setNeedsDisplayInRect:CGRectMake(point.x - kLineWidth/2, point.y - kLineWidth/2, kLineWidth, kLineWidth)];
    }
}

- (void) didHide
{
    if ([delegate respondsToSelector:@selector(didHide:)])
    {
        [delegate didHide:self];
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
    [self.gesture.points enumerateObjectsUsingBlock:^(NSValue *p, NSUInteger index, BOOL *stop) {
        if(index == 0)
        {
			CGContextFillEllipseInRect(ctx, CGRectMake(p.CGPointValue.x-kLineWidth/2, p.CGPointValue.y-kLineWidth/2,
                                                       kLineWidth, kLineWidth));
            lastPoint = p.CGPointValue;
        }
        else
        {
            CGContextMoveToPoint(ctx, lastPoint.x, lastPoint.y);
            CGContextAddLineToPoint(ctx, p.CGPointValue.x, p.CGPointValue.y);
            lastPoint = p.CGPointValue;
        }
    }];
    
    CGContextStrokePath(ctx);
}

@end