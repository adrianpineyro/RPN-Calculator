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

#define DEFAULT_SCALE 4

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

- (void)setMidPoint:(CGPoint)midPoint
{
    if (midPoint.x != _midPoint.x || midPoint.y != _midPoint.y) {
        _midPoint = midPoint;
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

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        
        CGPoint translation = [gesture translationInView:self]; 

        self.midPoint = CGPointMake(translation.x+self.midPoint.x,translation.y+self.midPoint.y);
    }
    [gesture setTranslation:CGPointZero inView:self];
    
}

- (void)tap:(UITapGestureRecognizer *)gesture
{
    self.midPoint = [gesture locationInView:self];
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

    // Getting the program from the datasource (Usually GraphViewController)
    NSMutableArray *program = [self.datasource getProgram];

    // Move starting point outside the graph
    CGContextMoveToPoint(context,-1,-1);
    
    for (float i = 0; i <= self.bounds.size.width; i+= 1.0/self.contentScaleFactor)
    {
        double xValue = (i - self.midPoint.x)/self.scale;
               
        double yValue = 0;
        NSDictionary* variableValues = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:xValue] forKey:@"x"];
        id result = [BrainCalculator runProgram:program usingVariableValues:variableValues];
        
        if([result isKindOfClass:[NSNumber class]])
        {
            yValue = self.midPoint.y - ([result doubleValue] * self.scale);
            if([self.datasource needAccuracy]){
                CGPoint actualPoint;
                actualPoint.x=i;
                actualPoint.y=yValue;
                
                CGFloat radius = 0.1;
                [self drawCirclesAtPoint:(CGPoint)actualPoint withRadius:(CGFloat)radius inContext:(CGContextRef)context];
                
            }else{
                CGContextAddLineToPoint(context,i,yValue);
            }
        }
    }
    
    CGContextStrokePath(context);
    
}

@end
