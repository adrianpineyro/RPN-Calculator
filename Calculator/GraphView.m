//
//  GraphView.m
//  Calculator
//
//  Created by Adrián Piñeyro on 15/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"
#import "BrainCalculator.h"

@implementation GraphView

@synthesize midPoint = _midPoint;
@synthesize scale = _scale;
@synthesize datasource = _datasource;

#define DEFAULT_SCALE 0.9

//Lazy initialization


- (CGFloat) scale
{
    if (! _scale) {
        _scale=DEFAULT_SCALE;
    }
    return _scale;
}

- (void)setScale:(CGFloat)scale
{
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay];
    }
}

-(void)setup {
    self.contentMode = UIViewContentModeRedraw;
    self.midPoint = CGPointMake((self.bounds.origin.x + self.bounds.size.width/2),
                                (self.bounds.origin.y + self.bounds.size.height/2));
}

-(void)awakeFromNib{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];  
    }
    return self;
}

-(void)drawCirclesAtPoint:(CGPoint)p 
               withRadius:(CGFloat)radius 
                inContext:(CGContextRef)context{
    
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    
    CGContextAddArc(context, p.x, p.y, radius, 0, 2*M_PI, YES);
    
    CGContextStrokePath(context);   
    UIGraphicsPopContext();
    
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale;
        gesture.scale = 1;
    }
    
}

- (void)drawRect:(CGRect)rect
{
        
    // Drawing code
    CGRect baseRect = self.bounds;
    baseRect.origin.x = 0;
    baseRect.origin.y = 0;
    
    // BoundaryRect
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextAddRect(context, baseRect);
    
    [AxesDrawer drawAxesInRect:baseRect originAtPoint:self.midPoint scale:self.scale];
    
    CGContextBeginPath (context);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);

    NSMutableArray *program = [self.datasource getProgram];
        
    //NSNumber *number = [NSNumber numberWithDouble:16];
    //[program addObject:number];
    //[program addObject:@"x"];
    //[program addObject:@"sin"];
    //NSLog(@"%@",program);

    CGContextMoveToPoint(context,-1,-1);

    
    for (float i = -self.bounds.size.width; i < self.bounds.size.width; i+=0.25)
    {
        NSDictionary* variableValues = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:i] forKey:@"x"];
        id result = [BrainCalculator runProgram:program usingVariableValues:variableValues];
        double yValue = 0;
        
        if([result isKindOfClass:[NSNumber class]])
        {
            yValue = [result doubleValue];
            CGContextAddLineToPoint(context, self.midPoint.x + i * self.scale, self.midPoint.y - yValue * self.scale);

        }
    }
    
    CGContextStrokePath(context);
    
}

@end
