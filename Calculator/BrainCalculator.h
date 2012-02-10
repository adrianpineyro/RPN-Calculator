//
//  BrainCalculator.h
//  Calculator
//
//  Created by Adrián Piñeyro on 21/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrainCalculator : NSObject

- (double) performOperation:(NSString *)operation;
- (void) pushOperand:(double)operand;
- (void) clearOperationStack;

@property (readonly) id program;
+ (id) runProgram:(id)program;
+ (NSString *) descriptionOfProgram:(id)program;
+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;
@end
