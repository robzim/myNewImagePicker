//
//  AudioFFTAnalyzer.m
//  Photo Dance Party
//  Real audio power metering with simulated frequency bands
//

#import "AudioFFTAnalyzer.h"

@interface AudioFFTAnalyzer ()
@property (nonatomic, weak) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) float bassPower;
@property (nonatomic, assign) float midPower;
@property (nonatomic, assign) float treblePower;
@property (nonatomic, assign) float overallPowerDB;
@property (nonatomic, assign) float lastPower;  // For smoothing
@property (nonatomic, assign) BOOL isProcessing;  // Guard against recursion
@end

@implementation AudioFFTAnalyzer

@synthesize audioPlayer = _audioPlayer;

- (instancetype)initWithAudioFile:(AVAudioFile *)audioFile {
    self = [super init];
    if (self) {
        // Note: audioFile parameter kept for API compatibility
        // In this implementation, AudioFFTAnalyzer receives AVAudioPlayer reference
        self.bassPower = 0.0f;
        self.midPower = 0.0f;
        self.treblePower = 0.0f;
        self.overallPowerDB = -160.0f;
        self.lastPower = -160.0f;

        NSLog(@"✓ AudioFFTAnalyzer initialized (real power metering mode)");
    }
    return self;
}

// Set the audio player to meter from (called by GameScene)
- (void)setAudioPlayer:(AVAudioPlayer *)audioPlayer {
    _audioPlayer = audioPlayer;
    if (audioPlayer) {
        [audioPlayer updateMeters];
        NSLog(@"✓ AudioFFTAnalyzer connected to AVAudioPlayer");
    }
}

- (BOOL)startEngine {
    NSLog(@"✓ Audio analysis ready (metering from AVAudioPlayer)");
    return YES;
}

- (void)stopEngine {
    self.audioPlayer = nil;
    NSLog(@"🔲 Audio analysis stopped");
}

- (BOOL)isPlaying {
    AVAudioPlayer *strongPlayer = self.audioPlayer;
    return strongPlayer && strongPlayer.isPlaying;
}

- (void)updateFrequencyBands {
    // Guard against recursion
    if (self.isProcessing) {
        return;
    }
    self.isProcessing = YES;

    // Capture weak reference to strong local to prevent mid-method deallocation
    AVAudioPlayer *strongPlayer = self.audioPlayer;
    if (!strongPlayer || !strongPlayer.isPlaying) {
        self.isProcessing = NO;
        return;
    }

    // Update metering data
    [strongPlayer updateMeters];

    // Get real power from the audio player (guard against zero-channel players)
    if (strongPlayer.numberOfChannels == 0) {
        self.isProcessing = NO;
        return;
    }
    float peakPower = [strongPlayer peakPowerForChannel:0];
    float averagePower = [strongPlayer averagePowerForChannel:0];

    // Use average power for stability (range: -160 to 0 dB)
    self.overallPowerDB = averagePower;

    // Smooth the power transition for more natural animation
    float smoothedPower = self.lastPower * 0.7f + self.overallPowerDB * 0.3f;
    self.lastPower = smoothedPower;

    // Generate frequency bands based on real power envelope
    // This creates a pseudo-spectrum based on actual audio power
    [self generateFrequencyBandsFromPower:smoothedPower];

    self.isProcessing = NO;
}

- (void)generateFrequencyBandsFromPower:(float)currentPower {
    // Normalize power to 0-1 range (-160 to 0 dB range)
    float normalizedPower = (currentPower + 160.0f) / 160.0f;
    normalizedPower = fminf(1.0f, fmaxf(0.0f, normalizedPower));

    // Generate frequency bands with different sensitivities to power changes
    // Bass responds strongly to overall power
    self.bassPower = normalizedPower * 0.8f + (sinf(currentPower * 0.01f) * 0.1f);
    self.bassPower = fminf(1.0f, fmaxf(0.0f, self.bassPower));

    // Mid responds moderately
    self.midPower = normalizedPower * 0.6f + (sinf(currentPower * 0.015f) * 0.15f);
    self.midPower = fminf(1.0f, fmaxf(0.0f, self.midPower));

    // Treble is more sensitive to fast changes
    self.treblePower = normalizedPower * 0.4f + (sinf(currentPower * 0.02f) * 0.2f);
    self.treblePower = fminf(1.0f, fmaxf(0.0f, self.treblePower));
}

- (float)getCurrentPowerInDB {
    return self.overallPowerDB;
}

- (float)getBassLevel {
    return self.bassPower;
}

- (float)getMidLevel {
    return self.midPower;
}

- (float)getTrebleLevel {
    return self.treblePower;
}

@end
