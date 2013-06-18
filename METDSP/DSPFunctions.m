//
//  DSPFunctions.m
//  RealTimeVisuals
//
//  Created by Matthew Zimmerman on 6/5/12.
//  Copyright (c) 2012 Drexel University. All rights reserved.
//
//  Replicated many of the functions from the 
//

#import "DSPFunctions.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>

struct timeval tv1;
time_t startTime1, endTime1;
double timeDiff1;

char out1[200];

//RIR parameters
#define N 3										// related to the number of virtual sources
#define NN (N * 2 + 1)							// number of virtual sources

#define SWAP(a,b)tempr=(a);(a)=(b);(b)=tempr;
#define DISP(lit) AS3_Trace(AS3_String(lit));	//macro function for printing data for debugging
#define START_TIME {		\
gettimeofday(&tv1, NULL);\
startTime = tv1.tv_usec;	\
}
#define END_TIME {			\
gettimeofday(&tv1, NULL);\
endTime = tv1.tv_usec;	\
}
#define TIME_DIFF(funcName) {	\
sprintf(out1, "it took %i msecs to execute %s \n", ((endTime1 - startTime1)/1000), funcName);\
DISP(out1);\
}

@implementation DSPFunctions


/*	
 ****************************************************
 *  Function: getFreq()
 *  Calculates the frequency associated with each bin of the discrete fourier transform.
 *
 *  Function Type:  Static Functoin
 *
 *  Parameters:
 *                  *freq - Pointer to an array. The array will be filled with the frequency values.
 *                  fftSize - The number of points in the discrete fourier transform.
 *                  fs - The sample rate of the input signal.
 *
 ****************************************************
 */
+(void) getFreq:(float *)freq frameSize:(int)frameSize sampleRate:(int)fs {
    
    //Create frequency array
	int n;
	float fnyq = fs/2;								//Nyquist freq
	float deltaF =  fnyq/(frameSize/2);				//Distance between the center frequency of each bin
	for (n = 0; n < (frameSize/2) + 1; n++){
		freq[n] = deltaF*n;
	}
    
}


/*
 ***********************************************************
 *  Function:       freqResp()
 *  Calculates the frequency response from an ALL POLE transfer function
 *
 *  Function Type:  Static Functoin
 *
 *  Parameters:
 *                  lpCE - a pointer to an array holding the linear predictioin coefficients
 *                  resp - a pointer holding an array of bin frequencies
 *                  fftSize - the size (frameSize) of the FFT
 *                  numRows - the number of rows in the lpCE array
 *                  numCols - the number of cols inthe lpCE array
 *                  fs - the sampling frequency
 *                  useDB - a flag that indicates to return in decibels (1) or not (0)
 *
 *  Returns:
 *                  None, values are passed by reference
 *
 *  See Also:
 *  <LPC>
 ************************************************************
 */
+(void) freqResp:(float *)lpCE 
        response:(float *)resp 
         fftSize:(int)fftSize 
         numRows:(int)numRows 
         numCols:(int)numCols 
           useDB:(BOOL)useDB {
    
    float gain = *(lpCE + numCols);						//assign the gain value for access
	float freqInc = M_PI/(fftSize/2 + 1);
	float rePart, imPart, denom;
	int i, c;
	
	for(i =0; i < (fftSize/2 + 1); i++) { 
        resp[i] = 0; 
    }
	
	for(i = 0; i < (fftSize/2 + 1); i++) {
		rePart = 0;
		imPart = 0;
		
		for(c = 1; c < numCols; c++) {
			rePart += (*(lpCE + c))*cos((float)(-c*i)*freqInc);
			imPart += (*(lpCE + c))*sin((float)(-c*i)*freqInc);
		}
		
		denom = sqrt(pow((1 + rePart),2) + pow((imPart), 2));
		resp[i] += gain/denom;									//!!!important! notice the += sign to accumulate values from each coefficient
		if(useDB) {
			resp[i] = 20*log10(fabs(resp[i]));
		}
	}
    
}


/*
 ***********************************************************************
 *	Function:  hanningWindow()
 *
 *  Function Type:  Static Functoin
 *
 *	Parameters:		hann - A float array that will contain the Hann coefficients.
 *					winLength - The number of coefficients to be calculated
 *
 *	Returns:		Replaces the values in hann[] with the windowed values
 *
 ************************************************************************
 */
+(void)hanningWindow:(float *)hann windowLength:(int)winLength {
    int n;
	for (n = 0; n < winLength; n++){
		hann[n] = 0.5*(1 - cos(M_PI*2*(n)/(winLength - 1)));
		hann[n] = sqrt(hann[n]);
	}
}


/*
 ****************************************************
 Function: magSpec()
 Calculates the magnitude spectrum from the complex Fourier transform.
 
 Parameters:
 
 *fft - A pointer to an fft array obtained using realFFT and unpacked.
 *FFT - A pointer to an array, allocated outside, that will hold the magnitude.
 fftLength - An int specifying the length of the FFT.
 useDB - A boolean var indicating to return decibels.
 
 Returns:
 None, arrays are passed by reference
 
 See Also:
 <FFT>, <realFFT>, <unpackFrequency>
 
 ***************************************************
 */
+(void) magSpectum:(float *)fft FFT:(float *)FFT fftLength:(int)fftLength useDB:(BOOL)useDB {
    unsigned int i,j = 0;
    
	if(useDB) { 
		for(i = 0; i <= fftLength; i = i + 2){
			FFT[j] = 20*log10(fabs(sqrt(pow(fft[i], 2) + pow(fft[i + 1], 2)))); 
			j++;
		}
	}else{
		for(i = 0; i <= fftLength; i = i + 2){
			FFT[j] = sqrt(pow(fft[i], 2) + pow(fft[i + 1], 2));		
			j++;
		}
	}	
}

/*
 ***********************************************************************
 *	Function:  +(int) nextPowerOf2:(int)number
 *
 *	Parameters:		number - The number to find the next highest power of two for.
 *
 *	Returns:		An integer which is the next highest power of two above the argument.
 *
 ************************************************************************
 */
+(int)nextPowerOf2:(int)number {
    float power = 1;
    while (pow(2,power)< number) {
        power++; // if 2^power is less than the input, increase the power by 1
    }
    return pow(2,power); // return 2^power
}

/*
 **************************************************************************
 
 Function: autoCorr()
 
 Computes the autocorrelation of a given sequence, which is just 
 its cross correlation with itself. The algorithm works by performing a frequency
 domain multiplication with the complex conjugate of the signal. Computing the 
 IFFT of the result yields the autocorrelation starting at the zeroth lag.
 
 Parameters:
 
 corrData - A pointer to the array containing the Fourier transform of the signal
 fftSize  - The size	of FFT used in computing the transform
 
 Notes:
 
 Only half of the autocorrelation is returned since it is symmetric.
 
 ****************************************************************
 */
+(void) autoCorr:(float *)corrData fftSize:(int)fftSize {
    int i;			
    
    // Now multiply the FFT by its conjugate....
    float RE, IM;
    for(i = 0; i < (fftSize); i = i+2) {
        RE = corrData[i];
        IM = corrData[i+1];
        corrData[i] = RE * RE - (IM * -IM);
        corrData[i+1] = 0;
    }	  
    
}


/*
 *********************************************************
 Function: iirFilter() 
 Performs filtering with a provided transfer function based on a direct form II -transpose structure
 
 Parameters:
 input - the input sequence that will be used to filter the audio signal
 ouput - the output sequence where the audio will be stored
 seqLen - the length of the input and output sequence (they must be the same)
 gain - the gain of the filter if any
 numCoeffs - an array specifying the numerator coefficients
 denomCoeffs - an array specifying the denominator coefficients
 numOrder - the number of numCoefficients
 denomOrder - the number of denomCoefficients
 
 Format:
 - denomCoeffs: (1 a1  a2  a3 ...... aM), order of denom = M
 - numCoeffs: (1  b1  b2 ....... bN), order of num = N 
 - for proper tf, should have M >= N
 
 Returns:
 None, arrays are passed by reference
 
 *******************************************************
 */
+(void)iirFilter:(float *)input 
          output:(float *)output 
  sequenceLength:(int)seqLen 
            gain:(float)gain 
  numeratorCoeff:(float *)numCoeffs 
denominatorCoeff:(float *)denomCoeffs 
  numeratorOrder:(int)numOrder 
denominatorOrder:(int)denomOrder {
    
    int i, n, d, e;
    float v[denomOrder];						//filter memory for delays
    for(i = 0; i < denomOrder; i++) v[i] = 0;	//init to zeros...
    
    //peform the filtering..........
    for(i = 0; i < seqLen; i++){
        
        //calculate v[n] = input[n] - a1*v[n-1] - a2*v[n-2] - ...... - aM*v[n-M]
        v[0] = input[i];
        for(d = 1; d < denomOrder; d++){
            v[0] -= denomCoeffs[d]*v[d];
        }
        
        //now calculate y[n] = b0*v[n] + b1*v[n-1] + .......+ bN*v[n-N]
        output[i] = 0;
        for(n = 0; n < numOrder; n++){
            output[i] += numCoeffs[n]*v[n];
        }
        output[i] *= gain;
        
        //now, need to shift memory in v[n] = v[n-1], v[n-1] = v[n-2] ......
        for(e = denomOrder - 1; e > 0; e--){
            v[e] = v[e-1];
        }
    }
}


/*
 ********************************************************************
 Function: LPC()
 Performs linear predictive analysis on an audio segment for a desired order. The algorithm 
 works by computing the autocorrelation of the sequency followed by the Levinson Recursion to 
 computed the prediction coefficients.
 
 Parameters:
 audioSeg - a pointer to an array containing the frame of audio of interest
 audioLength - the length of audioSeg ...MUST BE A POWER OF 2!!!!!
 order - the desired order of LP analysis
 lpCE - a pointer for a two dimensional array containing gain and coefficients (Coefficients 
 in first row, gain in second)
 
 Returns:
 Returns an integer indicating whether or not an error ocurred in 
 the algorithm (1 = error, 0 = no error)
 *********************************************************************
 */

+(int)LPC:(float *)corrData audioLength:(int)audioLength order:(int)order coefficients:(float *)lpCE {
    int error = 0;
	if (order < 0)	error = 1;					//can't have negative order prediction coefficients
	else if (order > audioLength) error = 1;	//can't have more prediction coefficients than samples
	else {
        
		//*********************************** LEVINSON RECURSION FOLLOWS *********************************		
		//STEP 1: initialize the variables
		float lpcTemp[order];					//this array stores the partial correlaton coefficients
		float temp[order];						//temporary data for the recursion
		float temp0;
		float A = 0;							//this is the gain computed from the predicition error
		float E, ki, sum;						//zeroth order predictor, weighting factor, sum storage
		int i, j;
		
		for(i = 0; i < order; i++) { lpcTemp[i] = 0.0; temp[i] = 0.0; } //init arrays to zeros
		
		E = corrData[0];						//for the zeroth order predictor
		ki = 0;
		
		for(i = 0; i < order; i++) {
			temp0 = corrData[i+1];
			
			for(j = 0; j < i; j++) { 
                temp0 -= lpcTemp[j]*corrData[i - j]; 
            }
            
			if(fabs(temp0) >= E){ 
                break; 
            }
			
			lpcTemp[i] = ki = temp0/E;
			E -= temp0*ki;
			
			//copy the data over so we can overwrite it when needed
			for(j=0; j < i; j++){ 
                temp[j] = lpcTemp[j]; 
            }
			
			for(j=0; j < i; j++){ 
                lpcTemp[j] -= ki*temp[i-j-1]; 
            }
		}
        
		//STEP 6: compute the gain associated with the prediction error
		sum = 0;											//assign the pth order coefficients to an output vector and compute the gain A
		for(i = 0; i < order; i++){ sum += lpcTemp[i]*corrData[i + 1]; }
		A = corrData[0] - sum;
		A = sqrt(A);
		
		//ready the lpCE array for the getHarmonics function
		*(lpCE + order + 1) = A;
		*lpCE = 1;
		
		//assign to output array
		for(i = 0; i < order; i++){ *(lpCE + i + 1) = -lpcTemp[i]; }
	}
	return error;
}


/*
 ********************************************************************
 Group: Spectral Features
 
 Function: bandwidth()
 
 Computes the centroid on a frame-by-frame basis for a vector of sample data
 
 Parameters:
 x[] - array of FFT magnitude values
 fs - sample frequency	
 winLength - window length
 
 Returns:
 Returns a float that is the spectral bandwidth of the given audio frame
 
 ********************************************************************
 */
+(float) bandwidth:(float *)spectrum 
       frequencies:(float *)freq 
          centroid:(float)centroid 
      windowLength:(int)winLength 
        sampleRate:(int)fs {
    
    float *diff = (float *) malloc(sizeof(float)*(floor(winLength/2) + 1));
	int i;
	float band = 0;
	
	//Create frequency array
	float fnyq = fs/2;									//Nyquist freq
	float deltaF =  fnyq/(winLength/2);				//Distance between the center frequency of each bin
	for (i = 0; i < floor(winLength/2) + 1; i++){
		freq[i] = deltaF*(i);
	}
	//Find the distance of each frequency from the centroid
	for (i = 0; i < floor(winLength/2)+1; i++){
		diff[i] = fabs(centroid - freq[i]);	
		
	}
	
	//Weight the differences by the magnitude
	for (i = 0; i < floor(winLength/2)+1; i++){
		band = band + diff[i]*spectrum[i]/(winLength/2);
	}
	
	free(diff);
	return band;
    
}

/*
 ********************************************************************
 
 Function: centroid()
 
 Calculates the spectral centroid 
 
 Parameters:
 spectrum[] - the MAGNITUDE spectrum of the data to compute the centroid of
 fs - the sample frequency
 winLength - the number of points of the FFT taken to compute the associated spectrum
 
 Returns:
 Returns a float that is the centroid for the given frame
 
 ********************************************************************
 */
+(float)centroid:(float *)spectrum frequencies:(float *)freq frameSize:(int)frameSize sampleRate:(int)fs {
    int i;
	float centVal;
	float sumNum = 0;
	float sumDen = 0;
    
	//Calculate Centroid - sum of the frequencies weighted by the magnitude spectrum dided by 
	//the sum of the magnitude spectrum
    
	for (i = 0; i < (frameSize/2) + 1; i++){
		sumNum = spectrum[i]*freq[i] + sumNum;
		sumDen = spectrum[i] + sumDen;
	}
	
	centVal = sumNum/sumDen;
    
	return centVal;
}

/*
 ********************************************************************
 Function: flux()
 
 Calculates the spectral flux.
 
 Parameters:
 
 spectrum - Pointer to the current spectrum
 spectrumPrev - Pointer to the spectrum from the previous frame
 winLength - The length of the DFT
 ********************************************************************
 */
+(float) flux:(float *)spectrum spectrumPrevious:(float *)spectrumPrev windowLength:(int)winLength {
    
    int i;
	
	//Calculate Flux
	float fluxVal = 0;
	for (i = 0; i < (winLength/2) + 1; i++){
		fluxVal = pow((spectrum[i] - spectrumPrev[i]),2) + fluxVal;
	}
	
	return fluxVal;
}

/*
 ********************************************************************
 Function: intensity()
 
 Calculates the spectral energy
 
 Parameters:
 spectrum[] - the MAGNITUDE spectrum of the data to 
 winLength - the window length
 
 Returns:
 Returns a float that is the energy for the given frame
 
 ********************************************************************
 */
+(float) intensity:(float *)spectrum windowLength:(int)winLength {
    
    //Find the total energy of the magnitude spectrum
	float totalEnergy = 0;
	int n;
	for (n = 0; n < (winLength/2) + 1; n++){
		totalEnergy = totalEnergy + spectrum[n];
	}
    
	return totalEnergy;
    
}

/*
 ********************************************************************
 Function: rolloff()
 
 Calculates the spectral centroid 
 
 Parameters:
 spectrum[] - the MAGNITUDE spectrum of the data to compute the centroid of
 fs - the sample frequency
 winLength - the window lenghth specified earlier
 
 Returns:
 Returns a float that is the centroid for the given frame
 
 ********************************************************************
 */
+(float) rolloff:(float *)spectrum windowLength:(int)winLength sampleRate:(int)fs {
    float rollPercent = 0.85;
	float *freq = (float *) malloc(sizeof(float)*((winLength/2) + 1));	
	
	//Create frequency array
	float fnyq = fs/2;								//Nyquist freq
	float deltaF =  fnyq/(winLength/2);			//Distance between the center frequency of each bin
	int n;
	for (n = 0; n < (winLength/2) + 1; n++){
		freq[n] = deltaF*(n);
	}
	
	/*
     * Calculate Rolloff
     */
	
	//Find the total energy of the magnitude spectrum
	float totalEnergy = 0;
	for (n = 0; n < (winLength/2) + 1; n++){
		totalEnergy = totalEnergy + spectrum[n];
	}
	
	//Find the index of the rollof frequency
	float currentEnergy = 0;
	int k = 0;
	while(currentEnergy <= totalEnergy*rollPercent && k <= winLength/2){
		currentEnergy = currentEnergy + spectrum[k];
		k++;
        
	}
    
	//Output the rollof frequency	
	float rollFreq = freq[k-1];
	free(freq);
	return rollFreq;
}
@end
