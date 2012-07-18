//
//  GraphViewController.h
//  Calculator
//
//  Created by Adrián Piñeyro on 15/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"

@interface GraphViewController : UIViewController <GraphViewDataSource>

@property (weak, nonatomic) IBOutlet GraphView *graphView;
@property (strong, nonatomic) IBOutlet id program;

@end
