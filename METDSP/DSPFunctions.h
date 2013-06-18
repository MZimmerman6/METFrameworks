//
//  DSPFunctions.h
//  RealTimeVisuals
//
//  Created by Matthew Zimmerman on 6/5/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSPFunctions : NSObject

+(void) magSpectum:(float*)fft FFT:(float*)FFT fftLength:(int)fftLength useDB:(BOOL)useDB;
//void magSpectrum(float fft[], float FFT[], int fftLength, int useDB);

+(float) centroid:(float*)spectrum frequencies:(float*)freq frameSize:(int)frameSize sampleRate:(int)fs;
//float centroid(float spectrum[], float freq[], int frameSize, int fs);

+(float) intensity:(float*)spectrum windowLength:(int)winLength;
//float intensity(float spectrum[], int winLength);

+(void) hanningWindow:(float*)hann windowLength:(int)winLength;
//void hannWindow(float hann[], int winLength);

+(float) rolloff:(float*)spectrum windowLength:(int)winLength sampleRate:(int)fs;
//float rolloff(float spectrum[], int winLength, int fs);

+(float) bandwidth:(float*)spectrum 
       frequencies:(float*)freq 
          centroid:(float)centroid 
      windowLength:(int)winLength 
        sampleRate:(int)fs;
//float bandwidth(float spectrum[], float freq[], float centroid, int winLength, int fs);

+(void) getFreq:(float*)freq frameSize:(int)frameSize sampleRate:(int)fs;
//void getFreq(float freq[], int frameSize, int fs);

+(int) LPC:(float*)corrData audioLength:(int)audioLength order:(int)order coefficients:(float*)lpCE;
//int LPC(float *corrData, int audioLength, int order, float *lpCE);

+(void) autoCorr:(float*)corrData fftSize:(int)fftSize;
//void autoCorr(float *corrData, int fftSize);

+(void)freqResp:(float*)lpCE 
       response:(float*)resp 
        fftSize:(int)fftSize 
        numRows:(int)numRows 
        numCols:(int)numCols 
          useDB:(BOOL)useDB;
//void freqResp(float *lpCE, float *resp, int fftSize, int numRows, int numCols, int useDB);

+(float)flux:(float*)spectrum spectrumPrevious:(float*)spectrumPrev windowLength:(int)winLength;
//float flux(float spectrum[], float spectrumPrev[], int winLength);

+(void) iirFilter:(float*)input 
           output:(float*)output 
   sequenceLength:(int)seqLen 
             gain:(float)gain 
   numeratorCoeff:(float*)numCoeffs 
 denominatorCoeff:(float*)denomCoeffs 
   numeratorOrder:(int)numOrder 
 denominatorOrder:(int)denomOrder;
//void iirFilter(float *input, float *output, int seqLen, float gain, float *numCoeffs, float *denomCoeffs, int numOrder, int denomOrder);


// Not implementing right now, becuase not particularly necessary
//+(float*)rir:(int)fs 
//       refCo:(float)refCo 
// micLocation:(float*)mic 
//roomDimensions:(float*)room 
//sourceLocation:(float*)src 
//   rirLength:(int*)rirLen;
//float* rir(int fs, float refCo, float mic[], float room[], float src[], int rirLen[]);

+(int) nextPowerOf2:(int)number;
//int nextPowerOf2(int number);

@end
