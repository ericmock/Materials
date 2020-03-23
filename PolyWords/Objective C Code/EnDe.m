//
//  EnDe.m
//  AlphaHedra
//
//  Created by Eric Mockensturm on 12/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EnDe.h"
#import "Polyhedron.h"
#import "AlphaHedraView.h"
#import "AppController.h"
#import "Polygons.h"
#import "Constants.h"
#import "random.h"

#define ArrayLength(x) (sizeof(x)/sizeof(*(x)))

static char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static char decodingTable[128];

@implementation EnDe

+ (void) initialize {
	if (self == [EnDe class]) {
		memset(decodingTable, 0, ArrayLength(decodingTable));
		for (NSInteger i = 0; i < ArrayLength(encodingTable); i++) {
			decodingTable[(int)encodingTable[i]] = i;
		}
	}
}


+ (NSString*) encodeBase64:(const uint8_t*) input length:(NSInteger) length {
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
	
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
			
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
		
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    encodingTable[(value >> 18) & 0x3F];
        output[index + 1] =                    encodingTable[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? encodingTable[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? encodingTable[(value >> 0)  & 0x3F] : '=';
    }
	
    return [[[NSString alloc] initWithData:data
                                  encoding:NSASCIIStringEncoding] autorelease];
}


+ (NSString*) encodeBase64:(NSData*) rawBytes {
    return [self encodeBase64:(const uint8_t*) rawBytes.bytes length:rawBytes.length];
}


+ (NSData*) decodeBase64:(const char*) string length:(NSInteger) inputLength {
	if ((string == NULL) || (inputLength % 4 != 0)) {
		return nil;
	}
	
	while (inputLength > 0 && string[inputLength - 1] == '=') {
		inputLength--;
	}
	
	NSInteger outputLength = inputLength * 3 / 4;
	NSMutableData* data = [NSMutableData dataWithLength:outputLength];
	uint8_t* output = data.mutableBytes;
	
	NSInteger inputPoint = 0;
	NSInteger outputPoint = 0;
	while (inputPoint < inputLength) {
		char i0 = string[inputPoint++];
		char i1 = string[inputPoint++];
		char i2 = inputPoint < inputLength ? string[inputPoint++] : 'A'; /* 'A' will decode to \0 */
		char i3 = inputPoint < inputLength ? string[inputPoint++] : 'A';
		
		output[outputPoint++] = (decodingTable[(int)i0] << 2) | (decodingTable[(int)i1] >> 4);
		if (outputPoint < outputLength) {
			output[outputPoint++] = ((decodingTable[(int)i1] & 0xf) << 4) | (decodingTable[(int)i2] >> 2);
		}
		if (outputPoint < outputLength) {
			output[outputPoint++] = ((decodingTable[(int)i2] & 0x3) << 6) | decodingTable[(int)i3];
		}
	}
	
	return data;
}

+ (NSData*) decodeBase64:(NSString*) string {
	return [self decodeBase64:[string cStringUsingEncoding:NSASCIIStringEncoding] length:string.length];
}

+ (NSArray *) encodeGameData:(AlphaHedraView *)alphaHedraView {
	float factor = 1;
	float num;
	NSMutableArray *encodedLetters = [NSMutableArray array];
	NSMutableArray *encodedWordsFound = [NSMutableArray array];
	NSMutableArray *encodedWordsAvailable = [NSMutableArray array];
	
	Polyhedra *polyhedron = alphaHedraView.polyhedron;// alphaHedraView.polyhedron;
	AppController *appController = (AppController *)[[UIApplication sharedApplication] delegate];
	
	for (Polygons *poly in polyhedron.polygons) {
		factor = 1;
		NSUInteger letter_num = [appController.alphabetArray indexOfObject:poly.letter];
		while (letter_num/factor > M_PI) {factor *= 2;}
		float letter_num_encoded = cos(letter_num/factor);
		[encodedLetters addObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:letter_num_encoded], [NSNumber numberWithFloat:factor], nil]];
	}
	
	factor = 1;
	num = alphaHedraView.play_time;
	while (num/factor > M_PI) {factor *= 2;}
	float num_encoded = cos(num/factor);
	NSArray *encodedTime = [NSArray arrayWithObjects:[NSNumber numberWithFloat:num_encoded], [NSNumber numberWithFloat:factor], nil];
	
	factor = 1;
	num = (float)(alphaHedraView.score);
	while (num/factor > M_PI) {factor *= 2;}
	num_encoded = cos(num/factor);
	NSArray *encodedScore = [NSArray arrayWithObjects:[NSNumber numberWithFloat:num_encoded], [NSNumber numberWithFloat:factor], nil];
	
	if (alphaHedraView.wordsFound) {
		for (NSString *word in alphaHedraView.wordsFound) {
			char random_string[5];
			random_string[0] = (char)irandom(1, 90);
			random_string[1] = (char)irandom(1, 90);
			random_string[2] = (char)irandom(1, 90);
			random_string[3] = (char)irandom(1, 90);
			random_string[4] = 0;
			NSString *randomString = [NSString stringWithCString:random_string encoding:NSASCIIStringEncoding];
			NSData *wordData = [[word stringByPaddingToLength:12 withString: randomString startingAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding];
			NSString *encodedWord = [EnDe encodeBase64:wordData];
			[encodedWordsFound addObject:encodedWord];
		}
	}
	
	if (alphaHedraView.availableWords) {
		for (NSString *word in alphaHedraView.availableWords) {
			NSData *wordData = [[word stringByPaddingToLength:12 withString: @":;" startingAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding];
			NSString *encodedWord = [EnDe encodeBase64:wordData];
			[encodedWordsAvailable addObject:encodedWord];
		}
	}
	
	return [NSArray arrayWithObjects:appController.polyhedraInfo, encodedTime, encodedScore, encodedLetters, encodedWordsFound, encodedWordsAvailable, nil];
}

+ (NSArray *) decodeGameData: (NSArray *)saveData withTimeHistory:(NSMutableArray *)timeHistory withWordsFound:(NSMutableArray *)decodedWordsFound {
#ifdef verbose
NSLog(@"into  decodeData: (NSArray *)saveData  of %@",[self class]);
#endif
	
	float factor;
	float time_encoded;
	float score_encoded;
	float play_time = 0.0;
	
	NSArray *encodedTimes = [saveData objectAtIndex:1];
	time_encoded = [[encodedTimes objectAtIndex:0] floatValue];
	factor = [[encodedTimes objectAtIndex:1] floatValue];
	play_time = factor * acosf(time_encoded);
	[timeHistory addObject:[NSNumber numberWithFloat:play_time]];
	NSArray *encodedScores = [saveData objectAtIndex:2];
	score_encoded = [[encodedScores objectAtIndex:0] floatValue];
	factor = [[encodedScores objectAtIndex:1] floatValue];
	float score_decoded = factor * acos(score_encoded);
	NSMutableArray *decodedLettersNumbers = [NSMutableArray array];
	NSArray *encodedLetters = [saveData objectAtIndex:3];
	for (NSArray *encodedLetterArray in encodedLetters) {
		float encoded_letter = [[encodedLetterArray objectAtIndex:0] floatValue];
		float factor = [[encodedLetterArray objectAtIndex:1] floatValue];
		int letter_num = (int)roundf(factor * acosf(encoded_letter));
		[decodedLettersNumbers addObject:INT(letter_num)];
	}
	NSArray *encodedWordsFound = [saveData objectAtIndex:4];
	for (NSString *encodedWord in encodedWordsFound) {
		NSData *wordData = [EnDe decodeBase64:encodedWord];
		NSString *string1 = [[NSString alloc] initWithData:wordData encoding:NSUTF8StringEncoding];
		NSCharacterSet *set = [[NSCharacterSet lowercaseLetterCharacterSet] invertedSet];
		NSString *string2 = [string1 stringByTrimmingCharactersInSet:set];
		[string1 release];
		[decodedWordsFound addObject:string2];
	}
	
	return [NSArray arrayWithObjects:INT((int)score_decoded), FLOAT(play_time), decodedLettersNumbers, nil];
}


@end
