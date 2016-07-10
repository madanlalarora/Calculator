//
//  ViewController.m
//  Calculator
//
//  Created by Madanlal on 10/07/16.
//  Copyright © 2016 Madanlal Arora. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    NSMutableArray *dataStack;
    NSString *currentNum;
    BOOL hasUsedDecimal;
    BOOL hasGeneratedResult;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self customiseUI];
    
    dataStack = [[NSMutableArray alloc] init];
    
    currentNum = @"";
    hasUsedDecimal = NO;
    hasGeneratedResult = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma other methods
- (void)logStack {
    NSString *labelText = @"";
    for (NSString *a in dataStack) {
        labelText = [labelText stringByAppendingString:a];
    }
    
    if ([labelText isEqualToString:@""]) {
        labelText = @"0";
    }
    
    self.label.text = labelText;
}

- (BOOL)isTopNumberic {
    BOOL isTopNumeric = NO;
    
    NSString *regEx = @"^[0-9]*$";
    NSPredicate *regPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    if ([regPred evaluateWithObject:[dataStack lastObject]]) {
        isTopNumeric = YES;
    }
    
    return isTopNumeric;
}

- (BOOL)isNumeric:(NSString *)string {
    BOOL isNumeric = NO;
    
    NSString *regEx = @"^[0-9.]*$";
    NSPredicate *regPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    if ([regPred evaluateWithObject:string]) {
        isNumeric = YES;
    }
    
    return isNumeric;
}

- (BOOL)isEmpty {
    BOOL isEmpty = YES;
    
    if ([dataStack count] > 0) {
        isEmpty = NO;
    }
    
    return isEmpty;
}

#pragma IBActions
- (IBAction)numberButtonPress:(id)sender {
    UIButton *temp = (UIButton *)sender;
    if ([currentNum isEqualToString:@""]) {
        currentNum = [NSString stringWithFormat:@"%d", (int)temp.tag];
    } else {
        if (hasGeneratedResult) {
            hasGeneratedResult = NO;
            currentNum = [NSString stringWithFormat:@"%d", (int)temp.tag];
        } else {
            currentNum = [currentNum stringByAppendingString:[NSString stringWithFormat:@"%d", (int)temp.tag]];
        }
    }
    self.label.text = currentNum;
}

- (IBAction)operationButtonPress:(id)sender {
    UIButton *temp = (UIButton *)sender;
    
    if ([temp.titleLabel.text isEqualToString:@"="]) {
        if (![self isEmpty]) {
            if (![currentNum isEqualToString:@""]) {
                [dataStack addObject:currentNum];
                currentNum = @"";
                hasUsedDecimal = NO;
            }
            
            if ([self isTopNumberic]) {
                NSDictionary *precendece = @{@"^" : @6,
                                             @"%" : @5,
                                             @"/" : @4,
                                             @"*" : @3,
                                             @"+" : @2,
                                             @"-" : @1};
                
                NSMutableArray *opStack = [[NSMutableArray alloc] init];
                NSMutableArray *infixToPostfix = [[NSMutableArray alloc] init];
                
                for (NSString *a in dataStack) {
                    if ([self isNumeric:a]) {
                        [infixToPostfix addObject:a];
                    } else {
                        while ([opStack count] > 0 && [[precendece objectForKey:[opStack lastObject]] intValue] >= [[precendece objectForKey:a] intValue]) {
                            [infixToPostfix addObject:[opStack lastObject]];
                            [opStack removeLastObject];
                        }
                        [opStack addObject:a];
                    }
                }
                
                while ([opStack count] > 0) {
                    [infixToPostfix addObject:[opStack lastObject]];
                    [opStack removeLastObject];
                }
                
                NSMutableArray *operandStack = [[NSMutableArray alloc] init];
                for (NSString *a in infixToPostfix) {
                    if ([self isNumeric:a]) {
                        [operandStack addObject:a];
                    } else {
                        NSString *op2 = [operandStack lastObject];
                        [operandStack removeLastObject];
                        NSString *op1 = [operandStack lastObject];
                        [operandStack removeLastObject];
                        NSNumber *result = [self doMath:a forOp1:[op1 floatValue] andOp2:[op2 floatValue]];
                        [operandStack addObject:result];
                    }
                }
                
                self.label.text = [NSString stringWithFormat:@"%@", [operandStack lastObject]];
                currentNum = self.label.text;
                hasGeneratedResult = YES;
                [dataStack removeAllObjects];
                [dataStack addObject:currentNum];
            }
        }
    } else {
        if ([self isTopNumberic] || ![currentNum isEqualToString:@""]) {
            if (hasGeneratedResult) {
                hasGeneratedResult = NO;
            } else {
                [dataStack addObject:currentNum];
            }
            
            [dataStack addObject:temp.titleLabel.text];
            currentNum = @"";
            hasUsedDecimal = NO;
            hasGeneratedResult = NO;
        }
        
        [self logStack];
    }
}

- (NSNumber *)doMath:(NSString *)operator forOp1:(float)op1 andOp2:(float)op2 {
    NSNumber *result;

    if ([operator isEqualToString:@"^"]) {
        result = [NSNumber numberWithFloat:powf(op1, op2)];
    } else if ([operator isEqualToString:@"%"]) {
        result = [NSNumber numberWithFloat:fmodf(op1, op2)];
    } else if ([operator isEqualToString:@"/"]) {
        result = [NSNumber numberWithFloat:op1/op2];
    } else if ([operator isEqualToString:@"*"]) {
        result = [NSNumber numberWithFloat:op1*op2];
    } else if ([operator isEqualToString:@"+"]) {
        result = [NSNumber numberWithFloat:op1+op2];
    } else if ([operator isEqualToString:@"-"]) {
        result = [NSNumber numberWithFloat:op1-op2];
    }
    
    return result;
}

- (IBAction)dotButtonPress:(id)sender {
    if ([currentNum isEqualToString:@""]) {
        currentNum = @"0.";
    } else {
        if (!hasUsedDecimal)
            currentNum = [currentNum stringByAppendingString:@"."];
    }
    
    hasUsedDecimal = YES;
    
    self.label.text = currentNum;
}

- (IBAction)ceClButtonPress:(id)sender {
    UIButton *temp = (UIButton *)sender;
    if ([[temp.titleLabel.text lowercaseString] isEqualToString:@"cl"]) {
        [dataStack removeAllObjects];
    } else {
        [dataStack removeLastObject];
    }
    
    currentNum = @"";
    hasUsedDecimal = NO;
    hasGeneratedResult = NO;
    
    [self logStack];
}

#pragma UI methods
- (void)customiseUI {
    for (id a in self.view.subviews) {
        if ([a isKindOfClass:[UIButton class]]) {
            UIButton *temp = (UIButton *)a;
            temp.layer.borderColor = [UIColor grayColor].CGColor;
            temp.layer.borderWidth = 0.5;
            [temp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            temp.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:20.0];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
