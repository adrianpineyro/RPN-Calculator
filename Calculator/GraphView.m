//
//  GraphView.m
//  Calculator
//
//  Created by Adrián Piñeyro on 15/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView

@synthesize midPoint = _midPoint;

-(void) setup {
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

- (void)drawRect:(CGRect)rect
{
     
    
    CGFloat scale;
    
    scale = 0.90;
    
    // Drawing code
    CGRect baseRect = self.bounds;
    baseRect.origin.x += 0;
    baseRect.origin.y += 0;
    
    // BoundaryRect
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextAddRect(context, baseRect);
    // CGContextFillPath(context);    
    CGContextStrokePath(context); 
    
    [AxesDrawer drawAxesInRect:baseRect originAtPoint:self.midPoint scale:scale];

    
    //[self drawCirclesAtPoint:self.midPoint withRadius:10*M_PI inContext:context];

    
}

@end
