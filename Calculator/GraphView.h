//
//  GraphView.h
//  Calculator
//
//  Created by Adrián Piñeyro on 15/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GraphViewDataSource
- (NSMutableArray *) getProgram;
- (BOOL) needAccuracy;
@end

@interface GraphView : UIView 

@property (nonatomic) CGPoint midPoint;

@property (nonatomic) CGFloat scale;
@property (strong,nonatomic) id <GraphViewDataSource> datasource;

-(void)recalculateMidPointAfterRotation;

@end