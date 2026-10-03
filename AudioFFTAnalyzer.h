//
//  AudioFFTAnalyzer.h
//  Photo Dance Party
//
//  FFT-based audio analysis using AVAudioEngine and Accelerate framework
//  Analyzes music into frequency bands: bass, mid, treble
//

#ifndef AudioFFTAnalyzer_h
#define AudioFFTAnalyzer_h

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioFFTAnalyzer : NSObject

// Initialization
- (instancetype)initWithAudioFile:(AVAudioFile *)audioFile;

// Connect to a real AVAudioPlayer for metering
- (void)setAudioPlayer:(AVAudioPlayer *)audioPlayer;

// Playback control
- (BOOL)startEngine;
- (void)stopEngine;
- (BOOL)isPlaying;

// Audio analysis (call every frame)
- (void)updateFrequencyBands;

// Current power level (dB scale, -160 to 0, matches AVAudioPlayer)
- (float)getCurrentPowerInDB;

// Frequency band levels (0.0 to 1.0)
- (float)getBassLevel;      // 0-250 Hz
- (float)getMidLevel;       // 250-2000 Hz
- (float)getTrebleLevel;    // 2000+ Hz

@end

#endif /* AudioFFTAnalyzer_h */
