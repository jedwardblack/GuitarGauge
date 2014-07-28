//
//  AudioController.h
//  GuitarGauge
//
//  Created by blackCloud on 7/26/14.
//  Copyright (c) 2014 blackCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioController : NSObject

@property (nonatomic) double sampleRate;

-(BOOL)startAudioController;

@end
