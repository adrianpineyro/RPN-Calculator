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
@property (nonatomic,strong) BrainCalculator *brain; 
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize log = _log;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;

-(BrainCalculator *) brain{
    if(!_brain) _brain = [[BrainCalculator alloc] init];
    return _brain;
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
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
   
    //si ya había un = entonces entonces borramos el log
    NSRange range = [self.log.text rangeOfString:@" ="];
    if (range.location != NSNotFound){
         self.log.text = [self.log.text stringByReplacingCharactersInRange:range withString:@" "];
    }

    //agregamos al log el numero con un espacio al final
    self.log.text = [self.log.text stringByAppendingString:[NSString stringWithFormat:@" %g ", [self.display.text doubleValue]]];
    
   }


- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber && ![[sender currentTitle] isEqualToString:@"+/-"]) {
        //le ahorro un enter al usuario
        [self enterPressed];
    } 
    if(self.userIsInTheMiddleOfEnteringANumber && [[sender currentTitle] isEqualToString:@"+/-"]){
        [self.brain pushOperand:[self.display.text doubleValue]];
    }
    //limitamos a las últimas operaciones a mostrar en el log
    if (self.log.text.length > 20)
        self.log.text = [self.log.text substringFromIndex:10];
    
    //enviamos la operación
    double result = [self.brain performOperation:[sender currentTitle]
      ];
    
    //mostramos el resultado
    self.display.text = [NSString stringWithFormat:@"%g",result];
    //self.log.text = [self.log.text stringByAppendingString:[NSString stringWithFormat:@" %g",result]]; 
    
    // si ya había un = entonces ese se reemplaza por un espacio
    NSRange range = [self.log.text rangeOfString:@" ="];
    if (range.location != NSNotFound) 
        self.log.text = [self.log.text stringByReplacingCharactersInRange:range withString:@" "];
    
    //agregamos al log la operación anteponiendo un espacio
    self.log.text = [self.log.text stringByAppendingString: [NSString stringWithFormat:@" %@ =", [sender currentTitle]]];
}

- (IBAction)clearPressed {

    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.log.text = @"";
    self.display.text = @"0";
    [self.brain clearOperationStack];
}

- (IBAction)backspacePressed {
    self.display.text = [self.display.text substringToIndex:[self.display.text length]-1];
    //Si borro todo pongo 0 e indico que no hay ningún numero que se este ingresando para que luego se borre el 0
    if([self.display.text isEqualToString:@""]){
        self.display.text = @"0";
        self.userIsInTheMiddleOfEnteringANumber = NO; 
    }
}


- (void)viewDidUnload {
    [self setLog:nil];
    [super viewDidUnload];
}
@end