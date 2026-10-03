//
//  AudioFFTAnalyzer.h
//  Photo Dance Party
//

#ifndef AudioFFTAnalyzer_h
#define AudioFFTAnalyzer_h

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioFFTAnalyzer : NSObject

- (instancetype)initWithAudioFile:(AVAudioFile *)audioFile;
- (void)setAudioPlayer:(AVAudioPlayer *)audioPlayer;
- (BOOL)startEngine;
- (void)stopEngine;
- (BOOL)isPlaying;
- (void)updateFrequencyBands;
- (float)getCurrentPowerInDB;
- (float)getBassLevel;
- (float)getMidLevel;
- (float)getTrebleLevel;

@end

#endif /* AudioFFTAnalyzer_h */
