//
//  ViewController.m
//  GuitarGauge
//
//  Created by blackCloud on 7/25/14.
//  Copyright (c) 2014 blackCloud. All rights reserved.
//

#import "ViewController.h"
#import "AudioController.h"

@interface ViewController ()
            

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    AudioController *newAudioController = [[AudioController alloc] init];
    if (![newAudioController startAudioController]) {
        NSLog(@"Could not start AudioController.");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
