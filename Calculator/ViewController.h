//
//  ViewController.h
//  Calculator
//
//  Created by Madanlal on 10/07/16.
//  Copyright © 2016 Madanlal Arora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Math.h"

@interface ViewController : UIViewController


- (IBAction)numberButtonPress:(id)sender;
- (IBAction)operationButtonPress:(id)sender;
- (IBAction)dotButtonPress:(id)sender;
- (IBAction)ceClButtonPress:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

