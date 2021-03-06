//
//  GraphViewController.h
//  Calculator
//
//  Created by Adrián Piñeyro on 15/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface GraphViewController : UIViewController <GraphViewDataSource,UISplitViewControllerDelegate,SplitViewBarButtonItemPresenter>


@property (strong, nonatomic) IBOutlet id program;
@property (weak, nonatomic) IBOutlet UILabel *log;

@end
