//
//  BrainCalculator.m
//  Calculator
//
//  Created by Adrián Piñeyro on 21/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BrainCalculator.h"

@interface BrainCalculator()
@property (nonatomic,strong) NSMutableArray *programStack;
@end

@implementation BrainCalculator

@synthesize programStack = _programStack;

-(NSMutableArray *) programStack
{
    if(!_programStack){
        _programStack = [[NSMutableArray alloc]init];
    }
    return _programStack;
}

-(void) pushOperand:(double)operand
{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:operandObject];
    //NSLog(@"push operand!");
    //NSLog(@"%@",[self.operationStack componentsJoinedByString:@","]);
}

-(double) performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[BrainCalculator runProgram:self.program] doubleValue];
}

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

+(NSString *) removeBorderParentheses:(NSString *)operation{
    
    if ([operation hasPrefix:@"("] && [operation hasSuffix:@")"]) {
        NSRange range;
        range.location = 1;
        range.length = operation.length-2;
        
        operation = [operation substringWithRange:range];
    }
    
    return operation;
}

+(NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
{
    
    id topOfStack = [stack lastObject];
    NSString *description;
    
    description = @"0";
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSString class]]) {
        if ([self isOperation:topOfStack]) {
            // Es una operacioón
            if ([self isTwoOperandOperation:topOfStack]) {
                //Es una operación de dos operadores
                id lastOperand =  [self descriptionOfTopOfStack:stack];
                description =  [NSString stringWithFormat:@"(%@ %@ %@)",[self descriptionOfTopOfStack:stack], topOfStack,lastOperand];
            } else {
                //Es una operación de un operador
                if ([topOfStack isEqualToString:@"π"]){
                    description =  [NSString stringWithFormat:@" %@ ",topOfStack];
                    //Salvado de operación inversión
                }else if([topOfStack isEqualToString:@"+/-"]){
                    id lastOperand =  [self descriptionOfTopOfStack:stack];
                    description =  [NSString stringWithFormat:@" (-1)%@ ",lastOperand];
                }else{
                    //Si lo anterior ya era una operación de dos operadores entonces no lleva parentesis, ej.: sqrt((2+2)) -> sqrt (2+2)
                    if ([self isTwoOperandOperation:[stack lastObject]]) {
                        description =  [NSString stringWithFormat:@" %@ %@ ",topOfStack,[self descriptionOfTopOfStack:stack]];
                    }else{
                        description =  [NSString stringWithFormat:@" %@ (%@) ",topOfStack,[self descriptionOfTopOfStack:stack]];
                    }
                }
            }
        } else {
            //Si es un string y no es una operación, entonces es una variable
            description =  [NSString stringWithFormat:@"%@",topOfStack];
        }
    } else if ([topOfStack isKindOfClass:[NSNumber class]]) {
        //Es un número
        description =  [NSString stringWithFormat:@"%@",topOfStack];
    }
    
    return description;
    
}

+(NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    NSString *description;
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    description = [self descriptionOfTopOfStack:stack];
    //Eliminamos parentesis externos. Ej.: (2+2) -> 2+2
    description = [self removeBorderParentheses:description];
    
    //Agremos el resto de las operaciones en el stack separadas por coma
    while(stack.count > 0){
        description = [description stringByAppendingString:[NSString stringWithFormat:@", %@",[self removeBorderParentheses:[self descriptionOfTopOfStack:stack]]]];
    }
    
    return description;
}

//Devuelve el resultado de la operacion en el tope del stack, se llama recursivamente si se encuentra con más operaciones para resolver el tope
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

+(id)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

+(id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
{
    NSMutableArray *stack;
    NSNumber *variableValue;
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    for (int i = 0; i < stack.count ; i++) {
        if ([[stack objectAtIndex:i] isKindOfClass:[NSString class]]) {
            
            //Si es un string lo busco en el diccionario
            variableValue = [variableValues objectForKey:[stack objectAtIndex:i]];
            //De encontrarlo, reemplazo el string por su valor
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
    
    //Obtenemos una copia si es valido
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    for (int i = 0; i < stack.count; i++) {
        if ([[stack objectAtIndex:i] isKindOfClass:[NSString class]]) {
            
            NSString *variable;
            
            variable = [stack objectAtIndex:i];
            
            //Si es un string y no es una operación, entonces es una variable
            if (![self isOperation:variable]) [variableKeys addObject:variable];
            
        }
    }
    
    //if(!variableKeys) return nil;
    return [variableKeys copy];
}

-(void) clearOperationStack
{
    [self.programStack removeAllObjects];
}

@end