//
//  AQInput.h
//  GuitarGauge
//
//  Created by blackCloud on 7/25/14.
//  Copyright (c) 2014 blackCloud. All rights reserved.
//

#include <Foundation/Foundation.h>
#include "AudioToolbox/AudioToolbox.h"
#include "CoreAudio/CoreAudioTypes.h"

#define kNumberRecordBuffers	3

class AQInput
{
public:
    AQInput();
    ~AQInput();
    Boolean			IsRunning() const			{ return mIsRunning; }
    Boolean         startAQInput;
    UInt64			startTime;
    
private:
    CFStringRef					mFileName;
    AudioQueueRef				mQueue;
    AudioQueueBufferRef			mBuffers[kNumberRecordBuffers];
    AudioFileID					mRecordFile;
    SInt64						mRecordPacket; // current packet number in record file
    AudioStreamBasicDescription	mRecordFormat;
    Boolean						mIsRunning;
    
    void			SetupAudioFormat();
    int				ComputeRecordBufferSize(const AudioStreamBasicDescription *format, float seconds);
    
    static void MyInputBufferHandler(	void *								inUserData,
                                     AudioQueueRef						inAQ,
                                     AudioQueueBufferRef					inBuffer,
                                     const AudioTimeStamp *				inStartTime,
                                     UInt32								inNumPackets,
                                     const AudioStreamPacketDescription*	inPacketDesc);
};
