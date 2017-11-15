//
//  DHLatestFeaturesViewController.m
//  TMTimer
//
//  Created by Derrick Ho on 11/15/17.
//  Copyright © 2017 ryukkusakku. All rights reserved.
//

#import "DHLatestFeaturesViewController.h"

@interface DHLatestFeaturesViewController ()

@end

@implementation DHLatestFeaturesViewController

- (IBAction)tappedCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:^{}];
}

- (IBAction)tappedGiveRating:(id)sender {
    [self dismissViewControllerAnimated:true completion:^{}];

    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/toastmaster-timer/id837916943?mt=8&action=write-review"];
    [[UIApplication sharedApplication] openURL:url
                                       options:@{}
                             completionHandler:^(BOOL success) {}];
}

@end
