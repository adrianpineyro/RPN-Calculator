//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Adrián Piñeyro on 21/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "BrainCalculator.h"

@interface CalculatorViewController()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic,strong) NSDictionary *testVariableValues;
@property (nonatomic,strong) NSMutableArray *stack;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize log = _log;
@synthesize variablesValues = _variablesValues;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize testVariableValues = _testVariableValues;
@synthesize stack = _stack;

-(NSMutableArray *) stack{
    if(!_stack) _stack = [[NSMutableArray alloc] init];
    return _stack;
}

-(NSDictionary *) testVariableValues{    
    NSNumber *value1 = [NSNumber numberWithDouble:1];
    NSNumber *value2 = [NSNumber numberWithDouble:2];
    NSNumber *value3 = [NSNumber numberWithDouble:3];
    
    if(!_testVariableValues) _testVariableValues = [[NSDictionary alloc] initWithObjectsAndKeys:value1,@"x",value2,@"y",value3,@"foo", nil];
    return _testVariableValues;
}

-(NSString *)showVariablesUsed:(id)program{
    NSString *variablesList;
    NSSet *variablesUsed;
    NSArray *keys;
    NSString *text;
    
    variablesList = @"";
    
    variablesUsed = [BrainCalculator variablesUsedInProgram:program];
    keys = [NSArray  arrayWithArray:[variablesUsed allObjects]];
    
    for (int i=0; i < keys.count; i++) {
        if([self.testVariableValues objectForKey:[keys objectAtIndex:i]]){
            text = [NSString stringWithFormat:@"%@ = %@ ",[keys objectAtIndex:i],[self.testVariableValues valueForKey:[keys objectAtIndex:i]]]; 
            variablesList = [variablesList stringByAppendingString:text];
        }
    }
    
    return variablesList;
}

-(void)updateView
{    
    id program;
    id result;
    program = self.stack;
    
    result = [BrainCalculator runProgram:program usingVariableValues:self.testVariableValues];
    
    if ([result isKindOfClass:[NSString class]]){
        self.display.text = result;
    } else{
        self.display.text = [NSString stringWithFormat:@"%@", result];
    }
    self.log.text = [BrainCalculator descriptionOfProgram:program];
    self.variablesValues.text = [self showVariablesUsed:program];
    
    //Limitamos a las últimas operaciones a mostrar en el log
    if (self.log.text.length > 40)
        self.log.text = [[self.log.text substringToIndex:40] stringByAppendingString:@" ..."];
    
}

- (IBAction)digitPressed:(UIButton *)sender {
    
    NSString *digit = [sender currentTitle];
    
    if (self.userIsInTheMiddleOfEnteringANumber){
        // No permite ingresar más de un punto
        NSRange range = [self.display.text rangeOfString:@"."];
        if (range.location != NSNotFound && [digit isEqualToString:@"."]) {
            return;
        }
        
        self.display.text = [self.display.text stringByAppendingString:digit]; 
        
    } else {
        //pongo un cero delante si puso .0
        if ([digit isEqualToString:@"."]){
            self.display.text = @"0.";
        }else{
            self.display.text = digit;
        }
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }         
    
}

- (IBAction)enterPressed {
    NSNumber *number = [NSNumber numberWithDouble:[self.display.text doubleValue]];
    
    [self.stack addObject:number];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    
}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber && ![[sender currentTitle] isEqualToString:@"+/-"]) {
        //Le ahorro un enter al usuario
        [self enterPressed];
    }
    
    if(self.userIsInTheMiddleOfEnteringANumber && [[sender currentTitle] isEqualToString:@"+/-"]){
        //Agregamos el valor de numero al stack
        [self.stack addObject:[NSNumber numberWithDouble:[self.display.text doubleValue]]];
        //Agreamos la operación
        [self.stack addObject:[sender currentTitle]];
        //La ejecutamos
        [self updateView];
        
        //Removemos la operación y el objeto, quedando así solamente display con signo opuesto y la posibilidad de seguir ingresando numeros
        [self.stack removeLastObject];
        [self.stack removeLastObject];
        
    }else {
        [self.stack addObject:[sender currentTitle]];
        [self updateView];
    }
}

- (IBAction)clearPressed {
    
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.log.text = @"";
    self.display.text = @"0";
    self.variablesValues.text = @"";
    [self.stack removeAllObjects];
}

- (IBAction)backspacePressed {
    //Eliminamos el último caracter
    self.display.text = [self.display.text substringToIndex:[self.display.text length]-1];
    
    //Borramos del stack el último valor del stack si no está ingresando el numero
    if( !self.userIsInTheMiddleOfEnteringANumber){
        [self.stack removeLastObject];
        [self updateView];
        //Si borro todo pongo el último resultado 
    } else if([self.display.text isEqualToString:@""]){
        [self updateView];
        self.userIsInTheMiddleOfEnteringANumber = NO; 
    }
    
}
- (IBAction)variablePressed:(id)sender {
    
    self.display.text = [sender currentTitle];
    [self.stack addObject:[sender currentTitle]];
    
}
- (IBAction)testPressed:(id)sender {
    
    NSNumber *value1;
    NSNumber *value2;
    NSNumber *value3;
    
    if ([[sender currentTitle] isEqualToString:@"test1"]) {       
        
        self.testVariableValues = nil;
        
    } else if ([[sender currentTitle] isEqualToString:@"test2"]) {
        value1 = [NSNumber numberWithDouble:0];
        value2 = [NSNumber numberWithDouble:0];
        value3 = [NSNumber numberWithDouble:0];        
        
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:value1,@"x",value2,@"y",value3,@"foo", nil];
    } else if ([[sender currentTitle] isEqualToString:@"test3"]) {
        value1 = [NSNumber numberWithDouble:-1];
        value2 = [NSNumber numberWithDouble:-2];
        value3 = [NSNumber numberWithDouble:-3];        
        
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:value1,@"x",value2,@"y",value3,@"foo", nil];
    }
    
    [self updateView];
    
}

- (void)viewDidUnload {
    [self setLog:nil];
    [self setVariablesValues:nil];
    [super viewDidUnload];
}
@end