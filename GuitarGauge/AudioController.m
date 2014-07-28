//
//  AudioController.m
//  GuitarGauge
//
//  Created by blackCloud on 7/26/14.
//  Copyright (c) 2014 blackCloud. All rights reserved.
//

#import "AudioController.h"
#import "AQInput.h"
#import "AVFoundation/AVFoundation.h"

@implementation AudioController

-(BOOL)startAudioController{
    //Starts AVAudioSession
    if (![self startAudioSession]){
        NSLog(@"Cloud not start AVAudioSession.");
    }
    AQInput *newAQInput = [[AQInput alloc] init];
    return ([newAQInput startAQInput]);
}

//Starts AVAudioSession
- (BOOL)startAudioSession{
    //Creates the AVAudioSession
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    
    //Sets AVAudioSession catergoy to AVAudioSessionCategoryRecord
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return NO;
    }
    
    //Sets AVAudioSession mode to AVAudioSessionModeMeasurement
    [audioSession setMode:AVAudioSessionModeMeasurement error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return NO;
    }
    
    //Sets AVAudioSession to "active"
    [audioSession setActive:YES error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return NO;
    }
    
    //Checks if audio input hardware is available
    BOOL audioHWAvailable = audioSession.inputAvailable;
    if (! audioHWAvailable) {
        NSLog(@"Audio input hardware not available");
        return NO;
    }
    self.sampleRate = audioSession.sampleRate;
    return YES;
}

@end
