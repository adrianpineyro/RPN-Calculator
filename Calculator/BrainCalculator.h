//
//  BrainCalculator.h
//  Calculator
//
//  Created by Adrián Piñeyro on 21/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrainCalculator : NSObject

-(double) performOperation:(NSString *)operation;
-(void) pushOperand:(double)operand;
-(void) clearOperationStack;
@end
