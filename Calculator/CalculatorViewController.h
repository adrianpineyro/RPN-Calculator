//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Adrián Piñeyro on 21/01/12.
//  Copyright (c) 2012 unpocodesensatez.com.ar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface CalculatorViewController : UIViewController;

@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *log;
@property (weak, nonatomic) IBOutlet UILabel *variablesValues;

@end
