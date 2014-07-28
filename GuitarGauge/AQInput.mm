//
//  AQInput.m
//  GuitarGauge
//
//  Created by blackCloud on 7/25/14.
//  Copyright (c) 2014 blackCloud. All rights reserved.
//

#include "AQInput.h"

int AQInput::ComputeRecordBufferSize(const AudioStreamBasicDescription *format, float seconds)
{
	int packets, frames, bytes = 0;
		frames = (int)ceil(seconds * format->mSampleRate);
		
		if (format->mBytesPerFrame > 0)
			bytes = frames * format->mBytesPerFrame;
		else {
			UInt32 maxPacketSize;
			if (format->mBytesPerPacket > 0)
				maxPacketSize = format->mBytesPerPacket;	// constant packet size
			else {
				UInt32 propertySize = sizeof(maxPacketSize);
				AudioQueueGetProperty(mQueue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize, &propertySize);
			}
			if (format->mFramesPerPacket > 0)
				packets = frames / format->mFramesPerPacket;
			else
				packets = frames;	// worst-case scenario: 1 frame in a packet
			if (packets == 0)		// sanity check
				packets = 1;
			bytes = packets * maxPacketSize;
		}
	return bytes;
}

// ____________________________________________________________________________________
// AudioQueue callback function, called when an input buffers has been filled.
void AQInput::MyInputBufferHandler(	void *								inUserData,
                                      AudioQueueRef						inAQ,
                                      AudioQueueBufferRef					inBuffer,
                                      const AudioTimeStamp *				inStartTime,
                                      UInt32								inNumPackets,
                                      const AudioStreamPacketDescription*	inPacketDesc)
{
	AQInput *aqr = (AQInput *)inUserData;
		if (inNumPackets > 0) {
			// write packets to file
			AudioFileWritePackets(aqr->mRecordFile, FALSE, inBuffer->mAudioDataByteSize,
                                                inPacketDesc, aqr->mRecordPacket, &inNumPackets, inBuffer->mAudioData);
			aqr->mRecordPacket += inNumPackets;
		}
		
		// if we're not stopping, re-enqueue the buffer so that it gets filled again
		if (aqr->IsRunning())
			AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
}


AQInput::AQInput()
{
	mIsRunning = false;
	mRecordPacket = 0;
}

AQInput::~AQInput()
{
	AudioQueueDispose(mQueue, TRUE);
	AudioFileClose(mRecordFile);
	if (mFileName) CFRelease(mFileName);
}


void AQInput::SetupAudioFormat()
{
	mRecordFormat = {0};
    //mRecordFormat.mSampleRate = (Float64)sampleRate;
    mRecordFormat.mFormatID = kAudioFormatLinearPCM;
    mRecordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    mRecordFormat.mBytesPerPacket = (mRecordFormat.mBitsPerChannel / 8) * mRecordFormat.mChannelsPerFrame;
    mRecordFormat.mFramesPerPacket = 1;
    mRecordFormat.mBytesPerFrame = 2;
    mRecordFormat.mChannelsPerFrame = 1;
    mRecordFormat.mBitsPerChannel = 16;
    mRecordFormat.mReserved = 0;
}

void AQInput::StartRecord(CFStringRef inRecordFile)
{
	int i, bufferByteSize;
	UInt32 size;
	CFURLRef url = nil;
	
	try {
		mFileName = CFStringCreateCopy(kCFAllocatorDefault, inRecordFile);
        
		// specify the recording format
		SetupAudioFormat(kAudioFormatLinearPCM);
		
		// create the queue
		XThrowIfError(AudioQueueNewInput(
                                         &mRecordFormat,
                                         MyInputBufferHandler,
                                         this /* userData */,
                                         NULL /* run loop */, NULL /* run loop mode */,
                                         0 /* flags */, &mQueue), "AudioQueueNewInput failed");
		
		// get the record format back from the queue's audio converter --
		// the file may require a more specific stream description than was necessary to create the encoder.
		mRecordPacket = 0;
        
		size = sizeof(mRecordFormat);
		XThrowIfError(AudioQueueGetProperty(mQueue, kAudioQueueProperty_StreamDescription, &mRecordFormat, &size), "couldn't get queue's format");
        
        // create temp directory with current path + filename
		NSString *recordFile = [NSTemporaryDirectory() stringByAppendingPathComponent: (NSString*)inRecordFile];
        
        // format path
        CFStringRef recordFileEscaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)recordFile, NULL, NULL, kCFStringEncodingUTF8);
        
		url = CFURLCreateWithString(kCFAllocatorDefault, recordFileEscaped, NULL);
		
		// create the audio file
		OSStatus status = AudioFileCreateWithURL(url, kAudioFileCAFType, &mRecordFormat, kAudioFileFlags_EraseFile, &mRecordFile);
		CFRelease(url);
        
        XThrowIfError(status, "AudioFileCreateWithURL failed");
		
		// copy the cookie first to give the file object as much info as we can about the data going in
		// not necessary for pcm, but required for some compressed audio
		CopyEncoderCookieToFile();
		
		// allocate and enqueue buffers
		bufferByteSize = ComputeRecordBufferSize(&mRecordFormat, kBufferDurationSeconds);	// enough bytes for half a second
		for (i = 0; i < kNumberRecordBuffers; ++i) {
			XThrowIfError(AudioQueueAllocateBuffer(mQueue, bufferByteSize, &mBuffers[i]),
                          "AudioQueueAllocateBuffer failed");
			XThrowIfError(AudioQueueEnqueueBuffer(mQueue, mBuffers[i], 0, NULL),
                          "AudioQueueEnqueueBuffer failed");
		}
		// start the queue
		mIsRunning = true;
		XThrowIfError(AudioQueueStart(mQueue, NULL), "AudioQueueStart failed");
	}
	catch (CAXException e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
	}
	catch (...) {
		fprintf(stderr, "An unknown error occurred\n");;
	}	
    
}


