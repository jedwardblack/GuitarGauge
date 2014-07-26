//
//  AQInput.m
//  GuitarGauge
//
//  Created by blackCloud on 7/25/14.
//  Copyright (c) 2014 blackCloud. All rights reserved.
//

#import "AQInput.h"
#import "AVFoundation/AVFoundation.h"
#import "AudioToolbox/AudioToolbox.h"
#import "CoreAudio/CoreAudioTypes.h"

@interface AQInput()

@property (nonatomic) double sampleRate;
@property (nonatomic) AudioQueueInputCallback aQIC;

- (BOOL)startAudioSession;

@end

@implementation AQInput

- (BOOL)startAQInput{
    
    BOOL retVal = YES;
    
    //Starts AVAudioSession
    if (![self startAudioSession]){
        retVal = NO;
        NSLog(@"Cloud not start AVAudioSession.");
    }
    
    //TODO: Set these values dynamically.
    //Sets values for AudioStreamBasicDescription.
    AudioStreamBasicDescription aSBD = {0};
    aSBD.mSampleRate = (Float64)self.sampleRate;
    aSBD.mFormatID = kAudioFormatLinearPCM;
    aSBD.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    aSBD.mBytesPerPacket = (aSBD.mBitsPerChannel / 8) * aSBD.mChannelsPerFrame;
    aSBD.mFramesPerPacket = 1;
    aSBD.mBytesPerFrame = 2;
    aSBD.mChannelsPerFrame = 1;
    aSBD.mBitsPerChannel = 16;
    aSBD.mReserved = 0;
    
    //AudioQueueNewInput(aSBD, aQIC , nil, <#CFRunLoopRef inCallbackRunLoop#>, <#CFStringRef inCallbackRunLoopMode#>, <#UInt32 inFlags#>, <#AudioQueueRef *outAQ#>);
    
    return retVal;
    
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
