//
//  BrainCalculator.m
//  Calculator
//
//  Created by Adrián Piñeyro on 21/01/12.
//  Copyright (c) 2012 unpocodesensatez.com.ar. All rights reserved.
//

#import "BrainCalculator.h"

@interface BrainCalculator()
@property (nonatomic,strong) NSMutableArray *programStack;
@end

@implementation BrainCalculator

@synthesize programStack = _programStack;

//Lazy inizialitation
-(NSMutableArray *) programStack
{
    if(!_programStack){
        _programStack = [[NSMutableArray alloc]init];
    }
    return _programStack;
}

//Add an operand to the programStack
-(void) pushOperand:(double)operand
{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:operandObject];
}

//Add the operation to the programStack and call class method runProgram to get the result (Only for backward compatibility)
-(double) performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[BrainCalculator runProgram:self.program] doubleValue];
}

//My program is actually the programStack, return a non-mutable copy
-(id)program
{
    return [self.programStack copy];
}


+ (BOOL)isOperation:(NSString *)operation
{
    NSOrderedSet *operationList;
    operationList = [NSSet setWithObjects:@"+",@"*",@"-",@"/",@"sin",@"cos",@"sqrt",@"π",@"+/-", nil];
    
    if ([operationList containsObject:operation]) return YES;
    return NO;
}

+ (BOOL)isTwoOperandOperation:(NSString *)operation
{
    NSOrderedSet *operationList;
    operationList = [NSSet setWithObjects:@"+",@"*",@"-",@"/", nil];
    
    if ([operationList containsObject:operation]) return YES;
    return NO;
}

//Delete begining "(" and final ")" of a string
+(NSString *) removeBorderParentheses:(NSString *)operation{
    
    if ([operation hasPrefix:@"("] && [operation hasSuffix:@")"]) {
        NSRange range;
        range.location = 1;
        range.length = operation.length-2;
        
        operation = [operation substringWithRange:range];
    }
    
    return operation;
}

//Return a description of the operation on the top of the stack, it call its self if find more operation on the top of the stack
+(NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
{
    
    id topOfStack = [stack lastObject];
    NSString *description;
    
    description = @"0";
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSString class]]) {
        if ([self isOperation:topOfStack]) {
            //Is an operation
            if ([self isTwoOperandOperation:topOfStack]) {
                //Is a two operand operation
                id lastOperand =  [self descriptionOfTopOfStack:stack];
                description =  [NSString stringWithFormat:@"(%@ %@ %@)",[self descriptionOfTopOfStack:stack], topOfStack,lastOperand];
            } else {
                //Is an one operand operation
                if ([topOfStack isEqualToString:@"π"]){
                    description =  [NSString stringWithFormat:@" %@ ",topOfStack];
                    //Show +/- in a proper form for a description e.g: (+/-)1 -> (-1)1
                }else if([topOfStack isEqualToString:@"+/-"]){
                    id lastOperand =  [self descriptionOfTopOfStack:stack];
                    description =  [NSString stringWithFormat:@" (-1)%@ ",lastOperand];
                }else{
                    //If the next of top of stack is an operetion, I have to remove parentheses, e.g. sqrt((2+2)) -> sqrt (2+2)
                    if ([self isTwoOperandOperation:[stack lastObject]]) {
                        description =  [NSString stringWithFormat:@" %@ %@ ",topOfStack,[self descriptionOfTopOfStack:stack]];
                    }else{
                        description =  [NSString stringWithFormat:@" %@ (%@) ",topOfStack,[self descriptionOfTopOfStack:stack]];
                    }
                }
            }
        } else {
            //If it is a string but no an operation, then it must be a variable
            description =  [NSString stringWithFormat:@"%@",topOfStack];
        }
    } else if ([topOfStack isKindOfClass:[NSNumber class]]) {
        //Is a number
        description =  [NSString stringWithFormat:@"%@",topOfStack];
    }
    
    return description;
    
}

//Return a description of the given program
+(NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    NSString *description;
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    description = [self descriptionOfTopOfStack:stack];
    //Remove parentheses. e.g. (2+2) -> 2+2
    description = [self removeBorderParentheses:description];
    
    //Add the rest of the stack to the description, until finish, separted by commas
    while(stack.count > 0){
        description = [description stringByAppendingString:[NSString stringWithFormat:@", %@",[self removeBorderParentheses:[self descriptionOfTopOfStack:stack]]]];
    }
    
    return description;
}

//Its returns a NSNumber (if no error) with the result of the operation on the top of the programStack, it calls its self if it find more operation
//If an error occurred (mathematical operations), return a NSString with a description of the error
+(id) popOperandOffStack:(NSMutableArray *)stack
{
    id result;
    
    id topOfStack = [stack lastObject];
    if (topOfStack){
        [stack removeLastObject];
    } else {
        return @"Error: Insufficient operarands";
    }
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        return topOfStack;
    } else if ([topOfStack isKindOfClass:[NSString class]]){
        NSString *operation = topOfStack;
        
        if ([operation isEqualToString:@"+"]){
            result = [NSNumber numberWithDouble:[[self popOperandOffStack:stack] doubleValue] + [[self popOperandOffStack:stack] doubleValue]];
        } else if ([operation isEqualToString:@"*"]){
            result = [NSNumber numberWithDouble:[[self popOperandOffStack:stack] doubleValue] * [[self popOperandOffStack:stack] doubleValue]];
        }else if ([operation isEqualToString:@"-"]){
            double subtrahend = [[self popOperandOffStack:stack] doubleValue];
            result = [NSNumber numberWithDouble:[[self popOperandOffStack:stack] doubleValue] - subtrahend];
        }else if ([operation isEqualToString:@"/"]){
            double divisor = [[self popOperandOffStack:stack] doubleValue];
            if (divisor){
                result = [NSNumber numberWithDouble:[[self popOperandOffStack:stack] doubleValue] / divisor];
            } else {
                result = @"Error: Division by 0";
            }
        }else if ([operation isEqualToString:@"sin"]){
            result = [NSNumber numberWithDouble:sin([[self popOperandOffStack:stack] doubleValue])];
        }else if ([operation isEqualToString:@"cos"]){
            result = [NSNumber numberWithDouble:cos([[self popOperandOffStack:stack] doubleValue])];
        }else if ([operation isEqualToString:@"sqrt"]){
            double number = [[self popOperandOffStack:stack] doubleValue];
            if (number > 0){
                result = [NSNumber numberWithDouble: sqrt(number)];
            } else {
                result = @"Error: Negative Sqrt";
            }
        }else if ([operation isEqualToString:@"π"]){
            result = [NSNumber numberWithDouble: 3.141592];
        }else if ([operation isEqualToString:@"+/-"]){
            double number = [[self popOperandOffStack:stack] doubleValue];
            result = [NSNumber numberWithDouble: number * -1];
        }
        
    }
    
    return result;
}

//Get a mutable copy of the programStack a get the result
+(id)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

//Get a mutable copy of the programStack a get the result, it receive variables: replace string with value
+(id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
{
    NSMutableArray *stack;
    NSNumber *variableValue;
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    for (int i = 0; i < stack.count ; i++) {
        if ([[stack objectAtIndex:i] isKindOfClass:[NSString class]]) {
            
            //If it is a string, look up on the diccionary
            variableValue = [variableValues objectForKey:[stack objectAtIndex:i]];
            //if find, replace string with the value
            if (variableValue) [stack replaceObjectAtIndex:i withObject:variableValue];
            
        }
    }
    
    return [self popOperandOffStack:stack];
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableArray *stack;
    NSMutableSet *variableKeys;
    
    variableKeys = [NSMutableSet set];
    
    //Get a copy, if this is an array
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    for (int i = 0; i < stack.count; i++) {
        if ([[stack objectAtIndex:i] isKindOfClass:[NSString class]]) {
            
            NSString *variable;
            
            variable = [stack objectAtIndex:i];
            //If it is a string but no an operation, then it must be a variable
            if (![self isOperation:variable]) [variableKeys addObject:variable];
        }
    }
    
    if(!variableKeys) return nil;
    return [variableKeys copy];
}

//Remove all the objects from the programStack
-(void) clearOperationStack
{
    [self.programStack removeAllObjects];
}

@end