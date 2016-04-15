//
//  ViewController.m
//  TestVOIP
//
//  Created by include tech. on 01/12/15.
//  Copyright © 2015 include tech. All rights reserved.
//

#import "ViewController.h"
#define SERVER @"107.170.46.82"


@interface ViewController ()

@property (nonatomic) NSMutableArray *localConstraints;
@property (nonatomic) UIButton *loginButton;
@property (nonatomic) UILabel *informationLabel;
@property (nonatomic) UITextField *userName;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.loginButton = [[UIButton alloc]init];
    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.loginButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.loginButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.view addSubview:self.loginButton];
    
    self.userName = [[UITextField alloc]init];
    self.userName.text = @"";
    self.userName.backgroundColor = [UIColor colorWithWhite:0.9f alpha:0.5f];
    self.userName.translatesAutoresizingMaskIntoConstraints = NO;
    self.userName.placeholder = @"Enter Username (eg. 'jack')";
    [self.view addSubview:self.userName];
    self.userName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.userName.autocorrectionType = UITextAutocorrectionTypeNo;
    self.userName.textAlignment = NSTextAlignmentCenter;


    self.localConstraints = [[NSMutableArray alloc]init];
    
    [self updateConstraintsForSize:self.view.bounds.size];
    [self.loginButton addTarget:self action:@selector(loginBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateConstraintsForSize:(CGSize)size
{
    [self.view removeConstraints:self.localConstraints];
    [self.localConstraints removeAllObjects];
    
    //-----------------TextField-----------------

    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.userName attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.userName attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:100]];
    
    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.userName attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30]];

    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.userName attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:-100]];

    //--------------------------BUTTON--------------------
    
    NSLayoutConstraint * btnConstraintX = [NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.userName attribute:NSLayoutAttributeCenterX multiplier:1.0F constant:0];
    [self.localConstraints addObject:btnConstraintX];
    
    NSLayoutConstraint * btnConstraintY = [NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.userName attribute:NSLayoutAttributeBottom multiplier:1.0F constant:40];
    [self.localConstraints addObject:btnConstraintY];
    
    NSLayoutConstraint * btnWidthConstraint = [NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:80];
    [self.localConstraints addObject:btnWidthConstraint];

    NSLayoutConstraint * btnHeightConstraint = [NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil
        attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:80];
    [self.localConstraints addObject:btnHeightConstraint];
    
    [self.view addConstraints:self.localConstraints];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [self updateConstraintsForSize:size];
}

-(IBAction)loginBtnTapped:(id)sender
{
    if (self.userName.text.length==0)
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Error"
                                      message:@"Please enter a name to continue."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Okay!"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        //Handel your yes please button action here
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                        
                                    }];
        
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.center = self.view.center;
        [self.view addSubview:spinner];
        [spinner startAnimating];
        [[XCPjsua sharedXCPjsua] startPjsipAndRegisterOnServer:"107.170.46.82" withUserName:"jack" andPassword:"jack" callback:^(BOOL success) {
            if (success)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CallViewController * cv = [[CallViewController alloc]init];
                    self.userName.text = @"";
                    [self presentViewController:cv animated:YES completion:^{
                        [spinner stopAnimating];
                    }];
                });
            }
            else
            {
                NSLog(@"LOGIN UNSUCCESSFUL PLEASE TRY AGAIN AFTER SOME TIME!");
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"Error"
                                              message:@"Something Went Wrong Please try again aftersometime."
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"Okay!"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action)
                                            {
                                                //Handel your yes please button action here
                                                [alert dismissViewControllerAnimated:YES completion:nil];
                                                
                                            }];
                
                [alert addAction:yesButton];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end