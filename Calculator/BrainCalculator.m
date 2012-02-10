//
//  BrainCalculator.m
//  Calculator
//
//  Created by Adrián Piñeyro on 21/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BrainCalculator.h"

@interface BrainCalculator()
@property (nonatomic,strong) NSMutableArray *operationStack;
@end

@implementation BrainCalculator

@synthesize operationStack = _operationStack;

-(NSMutableArray *) operationStack {
    if(!_operationStack){
        _operationStack = [[NSMutableArray alloc]init];
    }
    return _operationStack;
}

-(void) pushOperand:(double)operand{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.operationStack addObject:operandObject];
    //NSLog(@"push operand!");
    //NSLog(@"%@",[self.operationStack componentsJoinedByString:@","]);
}

-(double) popOperand {
    NSNumber *operandObject = [self.operationStack lastObject];
    if (operandObject)[self.operationStack removeLastObject];
    return [operandObject doubleValue];
}

-(double) performOperation:(NSString *)operation{
    double result = 0;
    
    if ([operation isEqualToString:@"+"]){
        result = [self popOperand] + [self popOperand];
    } else if ([operation isEqualToString:@"*"]){
        result = [self popOperand] * [self popOperand];
    }else if ([operation isEqualToString:@"-"]){
        double subtrahend = [self popOperand];
        result = [self popOperand]- subtrahend;
    }else if ([operation isEqualToString:@"/"]){
        double divisor = [self popOperand];
        if (divisor) result = [self popOperand] / divisor;
    }else if ([operation isEqualToString:@"sin"]){
        result = sin([self popOperand]);
    }else if ([operation isEqualToString:@"cos"]){
        result = cos([self popOperand]);
    }else if ([operation isEqualToString:@"sqrt"]){
        double number = [self popOperand];
        if (number > 0) result = sqrt(number);
    }else if ([operation isEqualToString:@"π"]){
        result = 3.141592;
    }else if ([operation isEqualToString:@"+/-"]){
        double number = [self popOperand];
        result = number * -1;
    }
    
    [self pushOperand:result];
    
    return result;
}

-(void) clearOperationStack{
    [self.operationStack removeAllObjects];
}

@end
