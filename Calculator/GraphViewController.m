//
//  GraphViewController.m
//  Calculator
//
//  Created by Adrián Piñeyro on 15/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "BrainCalculator.h"

@interface GraphViewController()
@property (weak, nonatomic) IBOutlet GraphView *graphView;
@property (nonatomic) BOOL accuracy;
@end

@implementation GraphViewController

@synthesize graphView = _graphView;
@synthesize program = _program;
@synthesize log =_log;
@synthesize accuracy = _accuracy;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)setProgram:(id)program{
    _program = program;
    [self.graphView setNeedsDisplay];
}

-(void)setAccuracy:(BOOL)accuracy{
    if (_accuracy != accuracy) {
        _accuracy = accuracy;
        [self.graphView setNeedsDisplay];
    }
}
- (void)setGraphView:(GraphView *)graphView
{
    
    _graphView=graphView;
    self.graphView.datasource = self;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tap:)];
    tapRecognizer.numberOfTapsRequired=3;
    
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];   
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];   
    [self.graphView addGestureRecognizer: tapRecognizer];

}

- (IBAction)accuracySwitchChange:(UISwitch *)sender
{
    if(sender.on)
    {
        self.accuracy = YES;
    } else {
        self.accuracy = NO;
    }
}

-(NSMutableArray *) getProgram
{
    self.log.text = [BrainCalculator descriptionOfProgram:self.program];
    return self.program;
    
}

-(BOOL)needAccuracy
{
   return self.accuracy;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


@end
