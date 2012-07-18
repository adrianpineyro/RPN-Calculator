//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Adrián Piñeyro on 21/01/12.
//  Copyright (c) 2012 unpocodesensatez.com.ar. All rights reserved.
//

#import "CalculatorViewController.h"
#import "BrainCalculator.h"
#import "GraphViewController.h"

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

//Lazy initialization
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

//Returns a string with the value of the used varibles. Format: variable = value
-(NSString *)showVariablesUsed:(id)program{
    NSString *variablesList;
    NSSet *variablesUsed;
    NSArray *keys;
    NSString *text;
    
    variablesList = @"";
    
    variablesUsed = [BrainCalculator variablesUsedInProgram:program];
    //Make an array to manually iterate it
    keys = [NSArray  arrayWithArray:[variablesUsed allObjects]];
    
    for (int i=0; i < keys.count; i++) {
        if([self.testVariableValues objectForKey:[keys objectAtIndex:i]]){
            //If the key is in testVariableValues, it is used an it must be show 
            text = [NSString stringWithFormat:@"%@ = %@ \n",[keys objectAtIndex:i],[self.testVariableValues valueForKey:[keys objectAtIndex:i]]]; 
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
        //if the result is an error we delete from the program the last operation which couse the error
        if([result length] > 4 && [[result substringToIndex:5]isEqualToString:@"Error"]) [program removeLastObject]; 
    } else {
        self.display.text = [NSString stringWithFormat:@"%@", result];
    }
    self.log.text = [BrainCalculator descriptionOfProgram:program];
    self.variablesValues.text = [self showVariablesUsed:program];
    
    //Limit to not show the whole description, just the last 60
    if (self.log.text.length > 50)
        self.log.text = [[self.log.text substringToIndex:50] stringByAppendingString:@" ..."];
    
}

- (IBAction)digitPressed:(UIButton *)sender {
    
    NSString *digit = [sender currentTitle];
    
    if (self.userIsInTheMiddleOfEnteringANumber){
        //Only one decimal point allowed
        NSRange range = [self.display.text rangeOfString:@"."];
        if (range.location != NSNotFound && [digit isEqualToString:@"."]) {
            return;
        }
        
        self.display.text = [self.display.text stringByAppendingString:digit]; 
        
    } else {
        //Fill with 0 if user select "." e.g. ".5" -> "0.5"
        if ([digit isEqualToString:@"."]){
            self.display.text = @"0.";
        }else{
            self.display.text = digit;
        }
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }         
    
}

- (IBAction)enterPressed {
      
    if (![[self testVariableValues] objectForKey:(self.display.text)]) {

        NSNumber *number = [NSNumber numberWithDouble:[self.display.text doubleValue]];
        [self.stack addObject:number];

    }
    
    self.userIsInTheMiddleOfEnteringANumber = NO;
    
}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber && ![[sender currentTitle] isEqualToString:@"+/-"]) {
        //So the user doesn't have to press enter if the number is the last number of the operation
        [self enterPressed];
    }
    
    //Special trateament to the "+/-" operation
    if(self.userIsInTheMiddleOfEnteringANumber && [[sender currentTitle] isEqualToString:@"+/-"]){
        //Add the value to the stack
        [self.stack addObject:[NSNumber numberWithDouble:[self.display.text doubleValue]]];
        //Add the operation
        [self.stack addObject:[sender currentTitle]];
        //Get the result
        [self updateView];
        
        //Remove the operation and the number, leaving the display with opposite sign and allow the posibility to continue adding numbers
        [self.stack removeLastObject];
        [self.stack removeLastObject];
        
    }else {
        //Add the operation
        [self.stack addObject:[sender currentTitle]];
        //Show the result
        [self updateView];
    }
}

//Clear the stack and all the labels
- (IBAction)clearPressed {
    
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.log.text = @"";
    self.display.text = @"0";
    self.variablesValues.text = @"";
    [self.stack removeAllObjects];
}

//This is for delete the last number pressed or the last operand/operation sent
- (IBAction)backspacePressed {
    //Delete last digit from the label
    self.display.text = [self.display.text substringToIndex:[self.display.text length]-1];
    
    if( !self.userIsInTheMiddleOfEnteringANumber){
        //Delete from the stack the last objet if the user was not entering a number
        [self.stack removeLastObject];
        [self updateView];
    } else if([self.display.text isEqualToString:@""]){
        //If get empty, show the last result
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

- (IBAction)graphPressed:(id)sender {
    [self performSegueWithIdentifier:@"ShowGraph" sender:self];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
        [segue.destinationViewController setProgram: self.stack];
}


- (void)viewDidUnload {
    [self setLog:nil];
    [self setVariablesValues:nil];
    [super viewDidUnload];
}
@end