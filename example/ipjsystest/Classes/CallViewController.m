//
//  CallViewController.m
//  TestVOIP
//
//  Created by include tech. on 01/12/15.
//  Copyright © 2015 include tech. All rights reserved.
//

#import "CallViewController.h"

typedef enum : NSUInteger
{
    kCallState_Disconnected = 0,
    kCallState_Calling,
    kCallState_Incoming,
    kCallState_Conneced,
    kCallState_Disconnecting
} CallState;

@interface CallViewController ()
{
    CallState callState;
    NSNumber * callID;
    NSString * incomingCallFrom;
    NSMutableDictionary * callDetails;

}
@property (nonatomic) UILabel *informationLabel;
@property (nonatomic) UITextField *callingTo;
@property (nonatomic) UIButton *makeCall;
@property (nonatomic) NSMutableArray * localConstraints;
@property (nonatomic) UIButton *logOut;

@end

@implementation CallViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.localConstraints = [[NSMutableArray alloc]init];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    callState =  kCallState_Disconnected;
    
    self.informationLabel = [[UILabel alloc]init];
    self.informationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.informationLabel.numberOfLines = 0;
    [self.view addSubview:self.informationLabel];
    
    self.callingTo = [[UITextField alloc]init];
    self.callingTo.translatesAutoresizingMaskIntoConstraints = NO;
    self.callingTo.backgroundColor = [UIColor colorWithWhite:0.9f alpha:0.5f];
    self.callingTo.placeholder = @"Enter Name";
    [self.view addSubview:self.callingTo];
    self.callingTo.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.callingTo.autocorrectionType = UITextAutocorrectionTypeNo;
    self.callingTo.textAlignment = NSTextAlignmentCenter;

    self.makeCall = [[UIButton alloc]init];
    self.makeCall.translatesAutoresizingMaskIntoConstraints = NO;
    [self.makeCall setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.makeCall setTitle:@"Login" forState:UIControlStateNormal];
    [self.view addSubview:self.makeCall];
    
    self.logOut = [[UIButton alloc]init];
    self.logOut.translatesAutoresizingMaskIntoConstraints = NO;
    [self.logOut setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.logOut setTitle:@"Log Out" forState:UIControlStateNormal];
    [self.view addSubview:self.logOut];
    [self.logOut addTarget:self action:@selector(logOut:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupConstraints];
    [self updateUI];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"calling" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        callState = kCallState_Calling;
        [self updateUI];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"incoming" object:nil queue:[NSOperationQueue mainQueue]  usingBlock:^(NSNotification * _Nonnull note) {
        
        callDetails = [[NSMutableDictionary alloc]initWithDictionary:note.object];
        callID = [callDetails objectForKey:@"callerID"];
        incomingCallFrom = [callDetails objectForKey:@"callerName"];
        
        [self showIncomingCallAlert];
        callState = kCallState_Incoming;
        [self updateUI];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"connected" object:nil queue:[NSOperationQueue mainQueue]  usingBlock:^(NSNotification * _Nonnull note) {
        
        callState = kCallState_Conneced;
        [self updateUI];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"confirmed" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        callState = kCallState_Conneced;
        [self updateUI];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"disconnected" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        callState = kCallState_Disconnected;
        [self updateUI];
    }];
    
    [self setupConstraints];
    // Do any additional setup after loading the view.
}


-(void)setupConstraints
{
    [self.view removeConstraints:self.localConstraints];
    [self.localConstraints removeAllObjects];
    
    //-------------label
    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.informationLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:20]];
    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.informationLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:50]];
    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.informationLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-20]];
    //------------textfield
    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.callingTo attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.informationLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:20]];
    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.callingTo attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.callingTo attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40]];
    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.callingTo attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:-100]];
    //---------------- call button
    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.makeCall attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:80]];
    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.makeCall attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:80]];
    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.makeCall attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.callingTo attribute:NSLayoutAttributeCenterX multiplier:1 constant:-60]];
    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.makeCall attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.callingTo attribute:NSLayoutAttributeCenterY multiplier:1 constant:50]];
    //---------------- logout button
    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.logOut attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.makeCall attribute:NSLayoutAttributeRight multiplier:1 constant:30]];
    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.logOut attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.callingTo attribute:NSLayoutAttributeCenterY multiplier:1 constant:50]];
    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.logOut attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:80]];
    [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.logOut attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:80]];
    
    
    [self.view addConstraints:self.localConstraints];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showIncomingCallAlert
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Incoming Call"
                                  message:incomingCallFrom
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* acceptButton = [UIAlertAction
                                actionWithTitle:@"Accept"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    //Handel your yes please button action here
                                    NSLog(@"Call Answered");
                                    [[XCPjsua sharedXCPjsua]callAnswer:callID.integerValue];
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                    
                                }];
    
    UIAlertAction* rejectButton = [UIAlertAction
                                actionWithTitle:@"Reject"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    //Handel your yes please button action here
                                    NSLog(@"Call Rejected");
                                    [[XCPjsua sharedXCPjsua]callDecline];
                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                    
                                }];
    
    [alert addAction:acceptButton];
    [alert addAction:rejectButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateUI
{
    [self.makeCall removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
    
        self.makeCall.enabled = YES;
        self.informationLabel.text = @"";
    
        switch (callState) {
            case kCallState_Disconnected:
            {
                [self.makeCall setTitle:@"Call" forState:UIControlStateNormal];
                [self.makeCall addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
                self.callingTo.enabled = YES;
                self.callingTo.text = @"";
                self.informationLabel.text = @"Enter The name of the person you want to call:";
            }
                break;
            case kCallState_Calling:
            {
                [self.makeCall setTitle:@"End" forState:UIControlStateNormal];
                [self.makeCall addTarget:self action:@selector(endCallAction:) forControlEvents:UIControlEventTouchUpInside];
                self.callingTo.enabled = NO;
                self.informationLabel.text = @"Calling...";
                
            }
                break;
                
            case kCallState_Incoming:
            {
                [self.makeCall setTitle:@"End" forState:UIControlStateNormal];
                [self.makeCall addTarget:self action:@selector(endCallAction:) forControlEvents:UIControlEventTouchUpInside];
                self.callingTo.enabled = NO;
                self.callingTo.text = @"";
                self.informationLabel.text = @"Incoming Call";
            }
                break;
                
            case kCallState_Conneced:
            {
                [self.makeCall setTitle:@"End" forState:UIControlStateNormal];
                [self.makeCall addTarget:self action:@selector(endCallAction:) forControlEvents:UIControlEventTouchUpInside];
                self.callingTo.enabled = NO;
                self.informationLabel.text = @"Call in Progress";
            }
                break;
                
            case kCallState_Disconnecting:
            {
                [self.makeCall setTitle:@"Call" forState:UIControlStateNormal];
                self.makeCall.enabled = NO;
                [self.makeCall addTarget:self action:@selector(callAction:) forControlEvents:UIControlEventTouchUpInside];
                self.callingTo.enabled = NO;
                self.callingTo.text = @"";
                self.informationLabel.text = @"Disconnecting...";
            }
                break;
            
            default:
                break;
        }
        
    
}

- (IBAction)callAction:(UIButton *)sender
{
    callState = kCallState_Calling;
    NSString * callerString = [NSString stringWithFormat:@"sip:%@@107.170.46.82:5060;transport=TCP",self.callingTo.text.lowercaseString];
        [[XCPjsua sharedXCPjsua]makeCallTo:[callerString UTF8String]];
    [self updateUI];
}

- (void)endCallAction:(id)sender
{
    callState = kCallState_Disconnecting;
    [[XCPjsua sharedXCPjsua] endCall];
    [self updateUI];
}

-(IBAction)logOut:(id)sender
{
    [[XCPjsua sharedXCPjsua]destroy];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
