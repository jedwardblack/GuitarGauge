//
//  AudioController.m
//  GuitarGauge
//
//  Created by blackCloud on 7/26/14.
//  Copyright (c) 2014 blackCloud. All rights reserved.
//

#import "AudioController.h"
#import "AQInput.h"

@implementation AudioController

-(BOOL)startAudioController{
    AQInput *newAQInput = [[AQInput alloc] init];
    return ([newAQInput startAQInput]);
}

@end
