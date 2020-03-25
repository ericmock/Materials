
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "AlphaHedraView.h"
#include "trackball.h"
#include "random.h"
#include "AppController.h"
#include "Polyhedron.h"
#include "Textures.h"
#include "Polygons.h"
#include "ButtonView.h"
#include "HighScores.h"
#include "MyActionSheet.h"
#include "Words.h"
#include "PauseDelegate.h"
#include "PostScoreController.h"
#include "PullDataController.h"
#include "PushDataController.h"
#include "StartDataController.h"
//#include "OAIAdManager.h"
#include "UpgradeDelegate.h"
#include "SoundEffect.h"
#include "Constants.h"
#include "AlphaHedraViewController.h"

#define kEditMode 6
#define kPauseMode 5
#define kHintMode 4
#define kButtonMode 3
#define kZoomMode 2
#define kSelectMode 1
#define kRotateMode 0

@interface AlphaHedraView (private)

- (void)initGLES;

@end

@implementation AlphaHedraView

@synthesize animationInterval, dyn_texture_coord_ptr, rot_texture_coord_ptr, scale_texture_coord_ptr, containerView, waitingAlert;
@synthesize dragging, high_score, lookingUpWordsQ, score, fastest_time, timeHistory, scoreHistory, show_get_ready;
@synthesize appController, availableWords, availableWordScores, wordsFound, wordsFoundOpponent, wordsDB, word_score, last_submit_time, tex_scale;
@synthesize polyhedron, paused, wordString, points_avail, points_avail_display, wordScores, wordScoresOpponent, opponent_ready;
@synthesize animation_start_time, finding_words, play_time, dynamicWordsFoundFileHandle, staticWordsFoundFileHandle, level_completed;
@synthesize opponent_score, oldWordsFound, clock;

+ (Class) layerClass {
	return [CAEAGLLayer class];
}

- (id) initWithFrame:(CGRect)f withAppController:(AppController *)d {
#ifdef verbose
NSLog(@"into  initWithFrame:(CGRect)f withAppController:(AppController *)d  of %@",[self class]);
#endif

	self = [super initWithFrame:f];
	if(self != nil) {
		appController = d;
		[self initializeIvarsWithFrame:f];
		[self initGLES];
		[self addSubview:touchedLetterView];
		
#ifndef JEWEL
#ifndef MATH
		float y_pos;
		if (!appController.unlocked) y_pos = -48.0;
		else y_pos = 0.0;

		float thickness = 95.0;
		UILabel *polygonsCheckedView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, y_pos, appController.screen_rect.size.width, thickness)];
		polygonsCheckedView.adjustsFontSizeToFitWidth = YES;
		polygonsCheckedView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
		polygonsCheckedView.font = [UIFont fontWithName:@"Helvetica" size:36];
		polygonsCheckedView.text = @"\nPolygons Checked";
		polygonsCheckedView.textColor = [UIColor whiteColor];
		polygonsCheckedView.textAlignment = UITextAlignmentCenter;
		polygonsCheckedView.hidden = (appController.checking != 2);
		polygonsCheckedView.numberOfLines = 2;
		polygonsCheckedView.shadowColor = [UIColor blackColor];
		polygonsCheckedView.shadowOffset = CGSizeMake(2.0,2.0);
		polygonsCheckedView.tag = 100;
		[self addSubview:polygonsCheckedView];
		[polygonsCheckedView release];
		
		y_pos += thickness;
		thickness = 65.0;
		UILabel *indicatorView;
		indicatorView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, y_pos, appController.screen_rect.size.width, thickness)];
		indicatorView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.1];
		indicatorView.hidden = (appController.checking != 2);
		indicatorView.tag = 101;
		[self addSubview:indicatorView];
		[indicatorView release];
		
		y_pos += thickness;
		thickness = 95.0;
		UILabel *availableWordsView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, y_pos, appController.screen_rect.size.width, thickness)];
		availableWordsView.adjustsFontSizeToFitWidth = YES;
		availableWordsView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
		availableWordsView.font = [UIFont fontWithName:@"Helvetica" size:36];
		availableWordsView.text = @"\nWords Found";
		availableWordsView.textColor = [UIColor whiteColor];
		availableWordsView.textAlignment = UITextAlignmentCenter;
		availableWordsView.hidden = (appController.checking != 2);
		availableWordsView.numberOfLines = 3;
		availableWordsView.shadowColor = [UIColor blackColor];
		availableWordsView.shadowOffset = CGSizeMake(2.0,2.0);
		availableWordsView.tag = 102;
		[self addSubview:availableWordsView];
		[availableWordsView release];

		y_pos += thickness;
		thickness = 65.0;
		indicatorView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, y_pos, appController.screen_rect.size.width, thickness)];
		indicatorView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.1];
		indicatorView.hidden = (appController.checking != 2);
		indicatorView.tag = 103;
		[self addSubview:indicatorView];
		[indicatorView release];

		y_pos += thickness;
		thickness = 95.0;
		UILabel *availablePointsView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, y_pos, appController.screen_rect.size.width, thickness)];
		availablePointsView.adjustsFontSizeToFitWidth = YES;
		availablePointsView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
		availablePointsView.font = [UIFont fontWithName:@"Helvetica" size:36];
		availablePointsView.text = @"\nPoints Found";
		availablePointsView.textColor = [UIColor whiteColor];
		availablePointsView.textAlignment = UITextAlignmentCenter;
		availablePointsView.hidden = (appController.checking != 2);
		availablePointsView.numberOfLines = 3;
		availablePointsView.shadowColor = [UIColor blackColor];
		availablePointsView.shadowOffset = CGSizeMake(2.0,2.0);
		availablePointsView.tag = 104;
		[self addSubview:availablePointsView];
		[availablePointsView release];
		
		y_pos += thickness;
		thickness = 65.0;
		indicatorView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, y_pos, appController.screen_rect.size.width, thickness)];
		indicatorView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.1];
		indicatorView.hidden = (appController.checking != 2);
		indicatorView.tag = 105;
		[self addSubview:indicatorView];
		[indicatorView release];
#endif
#endif

		timeHistory = [[NSMutableArray alloc] init];
//		self.wordsDB = nil;
	}
	return self;
}

- (void) initGLES {
#ifdef verbose
NSLog(@"into initGLES  of %@",[self class]);
#endif

	CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
	
	eaglLayer.opaque = YES;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
									kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
									nil];
	
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_POINT_SMOOTH);
	glEnableClientState(GL_NORMAL_ARRAY);
	glDisable(GL_NORMALIZE);
	glDisable(GL_LIGHTING);
	glEnable(GL_CULL_FACE);

	glClearColor(0.0f, 0.0f, 0.0f, 1.0f); 
	
	glActiveTexture(GL_TEXTURE0);
	glEnable(GL_TEXTURE_2D);
	// Set a blending function to use
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	// Enable blending
	glEnable(GL_BLEND);
	
	glClear(GL_COLOR_BUFFER_BIT);
	glEnable(GL_DEPTH_TEST);
	
	
} //Ported (mostly)

- (void) resetMatchColor {
#ifdef verbose
NSLog(@"into  resetMatchColor  of %@",[self class]);
#endif

	match_red = 1.0;
	match_green = 1.0;
	match_blue = 1.0;
}	//Ported

- (void) updateOpponentInformtion:(NSArray *)information {
	if ([information count] == 2) {
		NSArray *newWords = [information objectAtIndex:0];
		NSArray *newScores = [information objectAtIndex:1];
		for (NSString *word in newWords) {
			[wordsFoundOpponent addObject:word];
			[opponentWordsToDisplay addObject:word];
			show_opponent_word = YES;
		}
		for (NSString *scoreString in newScores) {
			opponent_score += [scoreString intValue];
			[wordScoresOpponent addObject:INT([scoreString intValue])];
		}
	}
	[pullDataController startSend:[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:appController.game_id], INT(appController.mode), nil]];
} //Ported

- (void) pause {
#ifdef verbose
NSLog(@"into  pause  of %@",[self class]);
#endif

	// FIXME:  crashing on the following line after a few pauses
	PauseAlert *pauseAlert = (PauseAlert *)[[PauseAlert alloc] initWithView:self];
	[pauseAlert showInView:self];
	[pauseAlert release];
	[self stopClock];
	[self stopGameAnimation];
} //Ported

- (void) stopClock {
#ifdef verbose
NSLog(@"into  stopClock  of %@",[self class]);
#endif
	self.paused = YES;
	[clock setFireDate:[NSDate distantFuture]];
} //Ported

- (void) pushData {
	NSMutableArray *newWordsFound = [[NSMutableArray alloc] init];
	NSMutableArray *newWordScores = [[NSMutableArray alloc] init];
	int count_old_words_found = [oldWordsFound count];
	int count_words_found = [wordsFound count];
	for (int ii = count_old_words_found; ii < count_words_found; ii++) {
		[newWordsFound addObject:[wordsFound objectAtIndex:ii]];
		[newWordScores addObject:[wordScores objectAtIndex:ii]];
	}
	
	[oldWordsFound removeAllObjects];
	[oldWordsFound addObjectsFromArray:wordsFound];
	NSArray *updatedData = [NSArray arrayWithObjects:newWordsFound, newWordScores, [NSNumber numberWithUnsignedInteger:appController.game_id], INT(appController.mode), nil];
	[pushDataController startSend:updatedData];
	[newWordsFound release];
	[newWordScores release];
}	 //Ported

- (void) startClock {
#ifdef verbose
NSLog(@"into startClock of %@",[self class]);
#endif

	if (clock) {
		[clock invalidate];
		clock = nil;
	}
	prev_time = get_time_of_day();
	clock = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:1 target:self selector:@selector(oneSecondPulse) userInfo:nil repeats:YES];
	self.paused = NO;
	((AlphaHedraViewController *)(appController.alphaHedraViewController)).game_state = kGameContinue;

	[[NSRunLoop currentRunLoop] addTimer:clock forMode:NSDefaultRunLoopMode];
	
	if (appController.mode == kTwoPlayerClientMode || appController.mode == kTwoPlayerServerMode) {
		[pullDataController startSend:[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:appController.game_id],INT(appController.mode),nil]];
	}	
} //Ported

- (void) checkMatch {
#ifdef verbose
NSLog(@"into  checkMatch  of %@",[self class]);
#endif

	if (appController.mode == kStaticTimedMode || appController.mode == kStaticScoredMode || appController.mode == kTwoPlayerClientMode || appController.mode == kTwoPlayerServerMode) {
		if ([wordString length] > 2 && [wordArray containsObject:wordString] && ![wordsFound containsObject:wordString] && ![wordsFoundOpponent containsObject:wordString]) {
			match = YES;
			[self getWordScore];
		}
	} else {
		if ([wordString length] > 2 && [wordArray containsObject:wordString]) {
			match = YES;
			[self getWordScore];
		} else {
			match = NO;
		}
	}
} //Ported

- (void) getWordScore {
#ifdef verbose
NSLog(@"into  getWordScore  of %@",[self class]);
#endif

	int letter_score = 0;
	int base_word_score = 0;
	[submittingPolygonsValuesArray removeAllObjects];
	for (Polygons *poly in touchedPolygonsArray) {
		int letter_num = [alphabetArray indexOfObject:poly.letter];
		int polygon_type = poly.polyType;
		int num_sides = polygon_type + 3;
		if (polygon_type == 10 || polygon_type == 11 || polygon_type == 12) num_sides = 4;
		else if (polygon_type == 13 || polygon_type == 14 || polygon_type == 15) num_sides = 3;
		
		letter_score = -1.0*pow(-1,(float)match)*(12.0 - (float)num_sides)*[[valueArray objectAtIndex:letter_num] intValue] * (match?[wordString length]:1.0);
		base_word_score += letter_score;
		[submittingPolygonsValuesArray addObject:[NSNumber numberWithInt:letter_score]];
	}
	
	word_length = [wordString length];
	word_score = base_word_score;//-1.0*pow(-1,(float)match)*letter_score * (match?[wordString length]:1.0);
	
	if ((appController.mode != kDynamicTimedMode && appController.mode != kDynamicScoredMode) && word_score < 0)
		word_score = 0;
} //Ported

- (void) submitWord {
#ifdef verbose
NSLog(@"into  submitWord  of %@",[self class]);
#endif

	last_submit_time = play_time;
	
	[self getWordScore];
	
#ifdef MATH
	NSArray *polygonsToReplace = [[NSArray alloc] initWithArray:touchedPolygonsArray];
	[touchedPolygonsArray removeAllObjects];
	for (Polygons *poly in polygonsToReplace) {
		poly.animatingQ = YES;
		poly.selected = NO;
	}
	
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(getNewLettersForPolygons:) userInfo:polygonsToReplace repeats:NO];
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(resetSubmitAnimation) userInfo:nil repeats:NO];
	
	[polygonsToReplace release];
	
	[self setAnimation];
	
#else
	// if we in dynamic letter mode, replace the submitted letters
	if (appController.mode == kDynamicTimedMode || appController.mode == kDynamicScoredMode) {
		NSArray *polygonsToReplace = [[NSArray alloc] initWithArray:touchedPolygonsArray];
		[submittingPolygonsArray removeAllObjects];
		for (Polygons *poly in touchedPolygonsArray) {
			[submittingPolygonsArray addObject:poly];
		}
		[self getNewLettersForPolygons:polygonsToReplace];
		
		[polygonsToReplace release];
		
		[self setAnimation];
	} 
	// if not just deselect them
	else {
		[submittingPolygonsArray removeAllObjects];
		for (Polygons *poly in touchedPolygonsArray) {
			[submittingPolygonsArray addObject:poly];
		}
	}
#endif
	score += word_score;
//	score_display = (score < 0)?0:score;
	
	if (match) {
		[appController.swipeSound play]; // ...play the sound.
		NSString *wordStringCopy = [wordString copy];
		[wordsFound addObject:wordStringCopy];
		[wordStringCopy release];
		[wordScores addObject:INT(word_score)];
		if (appController.mode == kTwoPlayerClientMode || appController.mode == kTwoPlayerServerMode)
			[self pushData];
		num_words_found = [wordsFound count];
		match = NO;
		score_animating = YES;
		if (appController.mode == kDynamicTimedMode || appController.mode == kDynamicScoredMode) {
			NSString *wordsFoundString = [NSString stringWithFormat:@"%@,%i,%i,",wordString,word_score,[[polyhedron.polyInfo objectForKey:@"polyID"] intValue]];
			[dynamicWordsFoundFileHandle writeData:[wordsFoundString dataUsingEncoding:NSUTF8StringEncoding]];
		} else if (appController.mode == kStaticTimedMode || appController.mode == kStaticScoredMode) {
			NSString *wordsFoundString = [NSString stringWithFormat:@"%@,%i,%i,",wordString,word_score,[[polyhedron.polyInfo objectForKey:@"polyID"] intValue]];
			[staticWordsFoundFileHandle writeData:[wordsFoundString dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	
	[self resetMatchColor];
	[wordString setString:@""];
	word_score = 0;

} //Ported

- (void) getNewLettersForPolygons:(NSArray *)polygonsToReplace {	
#ifdef verbose
NSLog(@"into  getNewLettersForPolygons:(NSArray *)polygonsToReplace  of %@",[self class]);
#endif

	for (Polygons *poly in polygonsToReplace) [self assignRandomLetterToPolyNumber:poly.number];
} //Ported

- (void) setMatchColor {
#ifdef verbose
NSLog(@"into  setMatchColor  of %@",[self class]);
#endif

	if (match) {
		match_red = 0.0;
		match_green = 1.0;
		match_blue = 0.0;
	} else if ([wordsFound containsObject:wordString]) { 
		match_red = 1.0;
		match_green = 1.0;
		match_blue = 0.0;
	} else if ([wordsFoundOpponent containsObject:wordString]) {
		match_red = 1.0;
		match_green = 0.5;
		match_blue = 0.0;
	} else if (!lookingUpWordsQ && [wordString length] > 2) {
		match_red = 1.0;
		match_green = 0.0;
		match_blue = 0.0;
	} else {
		match_red = 1.0;
		match_green = 1.0;
		match_blue = 1.0;
	}

} //Ported

- (void) setTouchedPolygon:(Polygons *)touchedPoly {
	
#ifdef verbose
NSLog(@"into  setTouchedPolygon:(Polygons *)touchedPoly  of %@",[self class]);
#endif

	// reset the match identifier
	match = NO;
#ifdef MATH
	//  addition stage
//	total = 0;
	//  subtraction stage
	total = base_value;
#endif
	
	if (!touchedPoly) {
		for (Polygons *poly in touchedPolygonsArray) {
			poly.selected = NO;
		}
		[touchedPolygonsArray removeAllObjects];
		
		[wordString setString:@""];
		[self getWordScore];
		return;
	}
	
	touchedPoly.selected = YES;
	
	// check to see if it is already selected
	if ([touchedPolygonsArray containsObject:touchedPoly]) {
		// if it's already selected grab the index number and length of the range to remove from the selected array
		int index = [touchedPolygonsArray indexOfObject:touchedPoly];
		int length = [touchedPolygonsArray count] - index;
		// reset the touched flag of all the previously touched polygons
		for (Polygons *poly in touchedPolygonsArray) {
			poly.selected = NO;
		}
		NSRange range = NSMakeRange(index, length);
		// remove the touched polygon and all those higher on the stack
		[touchedPolygonsArray removeObjectsInRange:range];
		// reset the word string to contain only selected letters
		[wordString setString:@""];
#ifdef MATH
		int counter = 0;
		eq_terms[0] = 0;
		eq_terms[1] = 0;
		eq_terms[2] = 0;
		eq_terms[3] = 0;
		for (Polygons *poly in touchedPolygonsArray) {
			poly.selected = YES;
			if (counter) [wordString appendString:@" + "];
			[wordString appendString:poly.letter];
			eq_terms[counter] = poly.texture + 1;
			counter++;
			//  addition stage
//			total += poly.texture + 1;
			//  subtraction stage
			total -= poly.texture + 1;
		}
		if (counter > 1) [wordString appendString:[NSString stringWithFormat:@" = %i",total]];
#else
		for (Polygons *poly in touchedPolygonsArray) {
			poly.selected = YES;
			[wordString appendString:[poly.letter lowercaseString]];
		}
#endif
	} else {
		// if the polygon wasn't already selected, add it to the array of selected polygons
		// determine how many vertices the touched polygon has in common with the previously touched polygon
		
		//			00  04  08  12
		//			01  05  09  13
		//			02  06  10  14			
		//			03  07  11  15
		
		// generate a rotation matrix that takes the polygon basis to the global basis
		float rot_m[3][3];
		rot_m[0][0] = touchedPoly.tangent_v[0];
		rot_m[0][1] = touchedPoly.tangent_v[1];
		rot_m[0][2] = touchedPoly.tangent_v[2];
		rot_m[1][0] = touchedPoly.binorm_v[0];
		rot_m[1][1] = touchedPoly.binorm_v[1];
		rot_m[1][2] = touchedPoly.binorm_v[2];
		rot_m[2][0] = touchedPoly.normal_v[0];
		rot_m[2][1] = touchedPoly.normal_v[1];
		rot_m[2][2] = touchedPoly.normal_v[2];
		
		// calculate the rotation angle per http://en.wikipedia.org/wiki/Rotation_representation
		touchedPoly.rot_angle = acosf( (rot_m[0][0] + rot_m[1][1] + rot_m[2][2] - 1.0)/2.0 );
		
		// calculate the rotation vector per http://en.wikipedia.org/wiki/Rotation_representation
		float denom = 2.0*sinf(touchedPoly.rot_angle);
		touchedPoly.rot_v[0] = (rot_m[2][1] - rot_m[1][2])/denom;
		touchedPoly.rot_v[1] = (rot_m[0][2] - rot_m[2][0])/denom;
		touchedPoly.rot_v[2] = (rot_m[1][0] - rot_m[0][1])/denom;

		touchedPoly.select_animation_start_time = get_time_of_day();

		uint count = 0;
		for (NSNumber *num in touchedPoly.indices) {
			if ([((Polygons *)[touchedPolygonsArray lastObject]).indices containsObject:num]) count++;
		}
		// if the polygon doesn't share at least two vertices with the previously touched polygon...
		if (count < 2 && [touchedPolygonsArray count] > 0) {
			// ...reset touched flag for all previously touched polygons...
			for (Polygons *poly in touchedPolygonsArray) {
				poly.selected = NO;
			}
			// ...clear the array of selected polygons...
			[touchedPolygonsArray removeAllObjects];
			// ...and set the touched flag and add the touched polygon to the array.
			touchedPoly.selected = YES;
			[touchedPolygonsArray addObject:touchedPoly];
		} else 
			[touchedPolygonsArray addObject:touchedPoly];
		// update the word string
		[wordString setString:@""];
#ifdef MATH
		int counter = 0;
		eq_terms[0] = 0;
		eq_terms[1] = 0;
		eq_terms[2] = 0;
		eq_terms[3] = 0;
		for (Polygons *poly in touchedPolygonsArray) {
			if (counter) [wordString appendString:@" + "];
			[wordString appendString:poly.letter];
			eq_terms[counter] = poly.texture + 1;
			counter++;
			//  addition stage
//			total += poly.texture + 1;
			//  subtraction stage
			total -= poly.texture + 1;
		}
		if (counter > 1) [wordString appendString:[NSString stringWithFormat:@" = %i",total]];
#else
		for (Polygons *poly in touchedPolygonsArray) {
			[wordString appendString:[poly.letter lowercaseString]];
		}
#endif
	}
	
#ifdef MATH
//  addition stage
//	if ([touchedPolygonsArray count] == 4 && total == 24) {
//  subtraction stage
	if (total == 0) {
		base_value = irandom(5, 30);
		match = YES;
		[self submitWord];
		eq_terms[0] = 0;
		eq_terms[1] = 0;
		eq_terms[2] = 0;
		eq_terms[3] = 0;
		total = base_value;
	}
#else
	// if there are three letters selected, use the other thread to grab all the words that start with those three letters
	if ([wordString length] >= 3) {		
		self.lookingUpWordsQ = YES;
		NSString *foundWord = NULL;
		[wordArray removeAllObjects];
		if ([availableWords count]) {
			if ([availableWords containsObject:wordString]) foundWord = wordString;
			lookingUpWordsQ = NO;
		} else {
			foundWord = [wordsDB selectWordsForString:wordString];
		}
		if (foundWord) [wordArray addObject:foundWord];
		[self checkMatch];
	} else {
		word_score = 0;
	}
#endif

	previousTouchedPoly = touchedPoly;
	
	[self setMatchColor];

} //Ported

- (void) showDynamicTimedModeEndAlert {
#ifdef verbose
NSLog(@"into  showDynamicTimedModeEndAlert  of %@",[self class]);
#endif

	NSMutableString *message = [NSMutableString string];
	BOOL next_level_unlocked = NO;
	BOOL this_level_completed = [[[[appController.polyhedronInfoArray objectAtIndex:(appController.level - 1)] objectForKey:@"completed"] objectAtIndex:appController.mode] boolValue];
	if (score >= kScoreToObtainDynamic && !this_level_completed && 
		((appController.unlocked && appController.level < 35) ||
		(appController.upgraded && appController.level < 10) ||
		(appController.level < 5))) next_level_unlocked = YES;

	NSArray *buttons = [NSArray arrayWithObjects: @"Play Again", @"Play Another Level", @"Main Menu", nil];
	NSNumber *type = INT(6);
	if (recordScore && !appController.level_aborted) {
		if (high_score == 0) {
			high_score = score;
			[message appendString:@"You established your high score for this level"];
			if (next_level_unlocked) {
				[message appendString:@" and unlocked the next level.\n\n\n\n\n"];
			} else {
				[message appendString:@".\n\n\n\n\n"];
			}
		} else if (score > high_score) {
			high_score = score;
			[message appendString:@"Congratulations.  You beat your high score"];
			if (next_level_unlocked) {
				[message appendString:@" and unlocked the next level.\n\n\n\n\n"];
			} else {
				[message appendString:@".\n\n\n\n\n"];
			}
		} else {
			[message appendString:@"You failed to beat your high score.\n\n\n\n\n"];
		}
	} else {
		[message appendString:@"\n\n\n\n\n"];
	}
	[self showAlphaHedraViewAlertWithInfo:[NSArray arrayWithObjects:type, message, buttons, nil]];
				
	[self stopClock];
	[self stopGameAnimation];
} //Ported

- (void) showStaticTimedModeEndAlert {
#ifdef verbose
NSLog(@"into  showStaticTimedModeEndAlert  of %@",[self class]);
#endif

	NSMutableString *message = [NSMutableString string];
	NSMutableArray *buttons = [NSMutableArray arrayWithObjects: @"View Word List", @"Play Again", @"Play Another Level", @"Main Menu", nil];
	NSNumber *type;
	BOOL next_level_unlocked = NO;
	BOOL this_level_completed = [[[[appController.polyhedronInfoArray objectAtIndex:(appController.level - 1)] objectForKey:@"completed"] objectAtIndex:appController.mode] boolValue];
	if (score >= kScoreToObtainStatic && !this_level_completed && 
		((appController.unlocked && appController.level < 35) ||
		 (appController.upgraded && appController.level < 10) ||
		 (appController.level < 5))) next_level_unlocked = YES;

	if (recordScore && !appController.level_aborted) {
		if (high_score == 0) {
			high_score = score;
			[message appendString:@"You established your high score for this level"];
			if ([availableWords count]) {
				type = INT(8);
				if (next_level_unlocked) {
					[message appendString:@" and unlocked the next level.\n\n\n\n\n"];
				} else {
					[message appendString:@".\n\n\n\n\n"];
				}
			} else {
				type = INT(3);
				if (next_level_unlocked) {
					[message appendString:@" and unlocked the next level.\n\n\n\n\n"];
					[buttons replaceObjectAtIndex:0 withObject:@"Find Missed Words"];
				} else {
					[message appendString:@".\n\n\n\n\n"];
					[buttons replaceObjectAtIndex:0 withObject:@"Find Missed Words"];
				}
			}
		} else if (score > high_score) {
			high_score = score;
			[message appendString:@"Congratulations.  You beat your high score"];
			if ([availableWords count]) {
				type = INT(8);
				if (next_level_unlocked)
					[message appendString:@" and unlocked the next level.\n\n\n\n\n"];
				else 
					[message appendString:@".\n\n\n\n\n"];
			} else {
				type = INT(3);
				if (next_level_unlocked) {
					[message appendString:@" and unlocked the next level.\n\n\n\n\n"];
					[buttons replaceObjectAtIndex:0 withObject:@"Find Missed Words"];
				} else {
					[message appendString:@".\n\n\n\n\n"];
					[buttons replaceObjectAtIndex:0 withObject:@"Find Missed Words"];
				}
			}
		} else {
			[message appendString:@"You failed to beat your high score.\n\n\n\n\n"];
			if ([availableWords count]) {
				type = INT(8);
			} else {
				type = INT(3);
				[buttons replaceObjectAtIndex:0 withObject:@"Find Missed Words"];
			}
		}
	} else {
		[message appendString:@"\n\n\n\n\n"];
		if ([availableWords count]) 
			type = INT(8);
		else {
			type = INT(3);
			[buttons replaceObjectAtIndex:0 withObject:@"Find Missed Words"];
		}
	}
	[self showAlphaHedraViewAlertWithInfo:[NSArray arrayWithObjects:type, message, buttons, nil]];
	
	[self stopClock];
	[self stopGameAnimation];
} //Ported

- (void) showDynamicScoredModeEndAlert {
#ifdef verbose
NSLog(@"into  showDynamicTimedModeEndAlert  of %@",[self class]);
#endif
	
	NSMutableString *message = [NSMutableString string];
	NSArray *buttons = [NSArray arrayWithObjects: @"Play Again", @"Play Another Level", @"Main Menu", nil];
	NSNumber *type = INT(6);
	BOOL next_level_unlocked = NO;
	BOOL this_level_completed = [[[[appController.polyhedronInfoArray objectAtIndex:(appController.level - 1)] objectForKey:@"completed"] objectAtIndex:appController.mode] boolValue];
	if (play_time <= kTimeToCompleteDynamic && !this_level_completed && 
		((appController.unlocked && appController.level < 35) ||
		 (appController.upgraded && appController.level < 10) ||
		 (appController.level < 5))) next_level_unlocked = YES;

	if (recordScore && !appController.level_aborted) {
		if (fastest_time == MAXFLOAT) {
			fastest_time = play_time;
			[message appendString:@"You established your fastest time for this level"];
			if (next_level_unlocked) {
				[message appendString:@" and unlocked the next level.\n\n\n\n\n"];
			} else {
				[message appendString:@".\n\n\n\n\n"];
			}
		} else if (play_time < fastest_time) {
			fastest_time = play_time;
			[message appendString:@"Congratulations.  You beat your fastest time"];
			if (next_level_unlocked) {
				[message appendString:@" and unlocked the next level.\n\n\n\n\n"];
			} else {
				[message appendString:@".\n\n\n\n\n"];
			}
		} else {
			[message appendString:@"You failed to beat your high score.\n\n\n\n\n"];
		}
	} else {
		[message appendString:@"\n\n\n\n\n"];
	}
	[self showAlphaHedraViewAlertWithInfo:[NSArray arrayWithObjects:type, message, buttons, nil]];
	
	[self stopClock];
	[self stopGameAnimation];
} //Ported

- (void) showStaticScoredModeEndAlert {
#ifdef verbose
NSLog(@"into  showStaticTimedModeEndAlert  of %@",[self class]);
#endif
	
	NSMutableString *message = [NSMutableString string];
	NSMutableArray *buttons = [NSMutableArray arrayWithObjects: @"View Word List", @"Play Again", @"Play Another Level", @"Main Menu", nil];
	NSNumber *type;
	BOOL next_level_unlocked = NO;
	BOOL this_level_completed = [[[[appController.polyhedronInfoArray objectAtIndex:(appController.level - 1)] objectForKey:@"completed"] objectAtIndex:appController.mode] boolValue];
	if (score >= kScoreToObtainStatic && !this_level_completed && 
		((appController.unlocked && appController.level < 35) ||
		 (appController.upgraded && appController.level < 10) ||
		 (appController.level < 5))) next_level_unlocked = YES;

	if (recordScore && !appController.level_aborted) {
		if (fastest_time == MAXFLOAT) {
			fastest_time = play_time;
			[message appendString:@"You established your fastest time for this level"];
			if ([availableWords count]) {
				type = INT(8);
				if (next_level_unlocked) {
					[message appendString:@" and unlocked the next level.\n\n\n\n\n"];
				} else {
					[message appendString:@".\n\n\n\n\n"];
				}
			} else {
				type = INT(3);
				if (next_level_unlocked) {
					[message appendString:@" and unlocked the next level.\n\n\n\n\n"];
					[buttons replaceObjectAtIndex:0 withObject:@"Find Missed Words"];
				} else {
					[message appendString:@".\n\n\n\n\n"];
					[buttons replaceObjectAtIndex:0 withObject:@"Find Missed Words"];
				}
			}
		} else if (fastest_time > play_time) {
			fastest_time = play_time;
			[message appendString:@"Congratulations.  You beat your fastest time"];
			if ([availableWords count]) {
				type = INT(8);
				if (next_level_unlocked)
					[message appendString:@" and unlocked the next level.\n\n\n\n\n"];
				else 
					[message appendString:@".\n\n\n\n\n"];
			} else {
				type = INT(3);
				if (next_level_unlocked) {
					[message appendString:@" and unlocked the next level.\n\n\n\n\n"];
					[buttons replaceObjectAtIndex:0 withObject:@"Find Missed Words"];
				} else {
					[message appendString:@".\n\n\n\n\n"];
					[buttons replaceObjectAtIndex:0 withObject:@"Find Missed Words"];
				}
			}
		} else {
			[message appendString:@"You failed to beat your fastest time.\n\n\n\n\n"];
			if ([availableWords count]) {
				type = INT(8);
			} else {
				type = INT(3);
				[buttons replaceObjectAtIndex:0 withObject:@"Find Missed Words"];
			}
		}
	} else {
		[message appendString:@"\n\n\n\n\n"];
		if ([availableWords count]) 
			type = INT(8);
		else {
			type = INT(3);
			[buttons replaceObjectAtIndex:0 withObject:@"Find Missed Words"];
		}
	}
	[self showAlphaHedraViewAlertWithInfo:[NSArray arrayWithObjects:type, message, buttons, nil]];
	
	[self stopClock];
	[self stopGameAnimation];
} //Ported

- (void) showTwoPlayerModeEndAlert {
#ifdef verbose
NSLog(@"into  showTwoPlayerModeEndAlert  of %@",[self class]);
#endif
	
	NSMutableString *message = [NSMutableString string];
	NSMutableArray *buttons = [NSMutableArray arrayWithObjects: @"View Word List", @"Play Again", @"Main Menu", nil];
	NSNumber *type;
	if (recordScore) {
		if (score > opponent_score) {
			[message appendString:@"Congratulations.  You beat your opponent.\n\n\n\n\n"];
			if ([availableWords count]) {
				type = INT(10);
			} else {
				type = INT(11);
				[buttons replaceObjectAtIndex:0 withObject:@"Find Missed Words"];
			}
		} else if (score < opponent_score) {
			[message appendString:@"Your opponent won that game.\n\n\n\n\n"];
			if ([availableWords count]) {
				type = INT(10);
			} else {
				type = INT(11);
				[buttons replaceObjectAtIndex:0 withObject:@"Find Missed Words"];
			}
		} else {
			[message appendString:@"You tied!\n\n\n\n\n"];
			if ([availableWords count]) {
				type = INT(10);
			} else {
				type = INT(11);
				[buttons replaceObjectAtIndex:0 withObject:@"Find Missed Words"];
			}
		}
	} else {
		[message appendString:@"\n\n\n\n\n"];
		if ([availableWords count]) 
			type = INT(10);
		else {
			type = INT(11);
			[buttons replaceObjectAtIndex:0 withObject:@"Find Missed Words"];
		}
	}
	[self showAlphaHedraViewAlertWithInfo:[NSArray arrayWithObjects:type, message, buttons, nil]];
	
	[self stopClock];
	[self stopGameAnimation];
} //Ported

- (void) abortLevel {
#ifdef verbose
NSLog(@"into  abortLevel  of %@",[self class]);
#endif

	score = 0;
	[timeHistory removeAllObjects];
//	[wordsFound removeAllObjects];
//	[wordsFoundOpponent removeAllObjects];
//	[wordScores removeAllObjects];
//	[wordScoresOpponent removeAllObjects];
	word_score = 0;
//	score_display = 0;
	points_avail = 0;
	points_avail_display = 0;
	[[NSArray array] writeToFile:[appController getDynamicScoredSavePath] atomically:YES];
	appController.level_aborted = YES;
	[self startGameAnimation];
} //Ported

- (void) checkLevelCompleted {
#ifdef verbose
NSLog(@"into  checkLevelCompleted  of %@",[self class]);
#endif

	appController.level_completed = NO;
	BOOL level_unlock = NO;
	int recorded_score = kScoreToObtainDynamic;
	float recorded_time = kTimeToCompleteDynamic;
	if (appController.mode == kDynamicTimedMode) {
		if (floor(play_time) >= kTimeToCompleteDynamic || appController.level_aborted) {
			if (score >= kScoreToObtainDynamic) level_unlock = YES;
			if (!appController.level_aborted) appController.level_completed = YES;
			[appController removeAllStoredData];
			[self showDynamicTimedModeEndAlert];
			recorded_time = kTimeToCompleteDynamic;
			recorded_score = score;
		}
	} 
	else if (appController.mode == kStaticTimedMode) {
		if (floor(play_time) >= kTimeToCompleteStatic || appController.level_aborted) {
			if (score >= kScoreToObtainStatic) level_unlock = YES;
			if (!appController.level_aborted) appController.level_completed = YES;
			[appController removeAllStoredData];
			[self showStaticTimedModeEndAlert];
			recorded_time = kTimeToCompleteStatic;
			recorded_score = score;
		}
	}
	else if (appController.mode == kDynamicScoredMode) {
		if (score >= kScoreToObtainDynamic || appController.level_aborted) {
			if (play_time <= kTimeToCompleteDynamic) level_unlock = YES;
			if (!appController.level_aborted) appController.level_completed = YES;
			[appController removeAllStoredData];
			[self showDynamicScoredModeEndAlert];
			recorded_time = play_time;
			recorded_score = kScoreToObtainDynamic;
		}
	}
	else if (appController.mode == kStaticScoredMode) {
		if (score >= kScoreToObtainStatic || appController.level_aborted) {
			if (play_time <= kTimeToCompleteStatic) level_unlock = YES;
			if (!appController.level_aborted) appController.level_completed = YES;
			[appController removeAllStoredData];
			[self showStaticScoredModeEndAlert];
			recorded_time = play_time;
			recorded_score = kScoreToObtainStatic;
		}
	}
	else if (appController.mode == kTwoPlayerClientMode || appController.mode == kTwoPlayerServerMode) {
		if (floor(play_time) >= kTimeToCompleteStatic || appController.level_aborted) {
			[appController removeAllStoredData];
			[pullDataController.connection cancel];
			[pushDataController.connection cancel];
			[self showTwoPlayerModeEndAlert];
			opponent_ready = NO;
		}
	}
	
	if (recordScore && appController.level_completed) {
		[appController.highScores addScoreForPolyhedronType:[[polyhedron.polyInfo objectForKey:@"polyID"] intValue] forMode:appController.mode forTime:recorded_time withScore:recorded_score];
		recordScore = NO;
		opponent_ready = NO;
		if (appController.send_data_q) {
			PostScoreController *postController = [[PostScoreController alloc] init];
			[postController startSend:[NSArray arrayWithObjects:INT(score),FLOAT(play_time),INT(appController.level),INT(appController.mode),wordsFound,wordScores,wordScores, nil]];
			[postController release];
		}
	}

	if (appController.level_completed) {
		[self stopClock];
		if (level_unlock) {
			NSMutableDictionary *dict = [[appController.polyhedronInfoArray objectAtIndex:(appController.level - 1)] mutableCopy];
			NSMutableArray *array2 = [[dict objectForKey:@"completed"] mutableCopy];
			[array2 replaceObjectAtIndex:appController.mode withObject:[NSNumber numberWithBool:TRUE]];
			[dict setObject:array2 forKey:@"completed"];
			[appController.polyhedronInfoArray replaceObjectAtIndex:(appController.level - 1) withObject:dict];
			[dict release];
			[array2 release];
		}
	}
} //Ported

- (void) oneSecondPulse {
#ifdef verbose
NSLog(@"into oneSecondPulse of %@",[self class]);
#endif

	double time = get_time_of_day();
	float dt = (float)(time - prev_time);
	prev_time = time;
	
	[timeHistory addObject:[NSNumber numberWithFloat:dt]];
	
	play_time = 0.0;
	for (NSNumber *num in timeHistory)  play_time += [num floatValue];
	
	if (appController.mode == kStaticTimedMode || appController.mode == kTwoPlayerServerMode || appController.mode == kTwoPlayerClientMode) {
		time_left = kTimeToCompleteStatic - play_time;
		if (time_left < 0.0) time_left = 0.0;
	}
	else if (appController.mode == kDynamicTimedMode) {
		time_left = kTimeToCompleteDynamic - play_time;
		if (time_left < 0.0) time_left = 0.0;
	}
	else if (appController.mode == kStaticScoredMode || appController.mode == kDynamicScoredMode) time_left = play_time;
	
#ifndef JEWEL	
	if ((play_time - last_submit_time > 60) && (appController.mode == kDynamicTimedMode || appController.mode == kDynamicScoredMode)) {
		last_submit_time = play_time;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Throwing Back" message:@"Consider throwing back letters if you cannot find a word." 
													   delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
		alert.tag = 4;
		[alert show];
		[alert release];
		[self stopClock];
	}
#endif
	[self checkLevelCompleted];
} //Ported

- (void) dismissAlertView:(UIAlertView *)alertView {
#ifdef verbose
NSLog(@"into dismissAlertView:%@ of class %@",alertView,[self class]);
#endif
	static int counter = 0;
	counter++;
	if (counter == 3) {
		[self startClock];
		[alertView dismissWithClickedButtonIndex:2 animated:NO];
		counter = 0;
	}
	else {
		[(UILabel *)[alertView viewWithTag:101] setText:[NSString stringWithFormat:@"%i",3-counter]];
		[self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:1.0];
	}
}

- (NSArray *) wordsFoundWithLength:(int)length {
	NSMutableArray *words = [[[NSMutableArray alloc] init] autorelease];
	for (NSString *word in wordsFound) {
		if ([word length] == length) [words addObject:word];
	}
	return words;
} //Ported

- (void) findAllWords {
#ifdef verbose
NSLog(@"into  findAllWords  of %@",[self class]);
#endif

	[self findWordsToPoints:INT(INT_MAX)];
} //Ported

- (void) findWordsToPoints:(NSNumber *)points {
#ifdef verbose
NSLog(@"into  findWordsToPoints:(NSNumber *)points  of %@",[self class]);
#endif

	self.finding_words = YES;
	reset_counters = YES;
	poly_counter = 0;
	points_avail = 0;
	num_words_avail = 0;
	int to_points = [points intValue];
	
	for (Polygons* poly in polyhedron.polygons) {
		if (poly.active && points_avail < to_points) {
			[self findWordsStartingWithPolygon:poly];
			poly_counter++;
		}
	}

	// don't need the connection anymore and they retain other polygons so we release them
	if ([points intValue] == INT_MAX) {
		for (Polygons* poly in polyhedron.polygons) {
			poly.connections = nil;
		}
	}
	
	if (to_points == INT_MAX) {
		[wordsDB finalizeStatements];
		[wordsDB release];	
		// shouldn't do this until later if finding words first
		// sort by word length
		[self sortAvailableWords];
	} else {
		[availableWords removeAllObjects];
		[availableWordScores removeAllObjects];
	}
	
#ifdef debug
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *fullPath = [documentsDir stringByAppendingPathComponent:@"static_words_available"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL success = [fileManager fileExistsAtPath:fullPath]; 
	if(!success) {
		[fileManager createFileAtPath:fullPath contents:nil attributes:nil];
	}
	NSFileHandle *staticWordsAvailableFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:fullPath];
	[staticWordsAvailableFileHandle seekToEndOfFile];
	int rd = irandom(0, RAND_MAX);
	for (int kk = 0; kk < [availableWords count]; kk++) {
		NSString *wordsFoundString = [NSString stringWithFormat:@"%i,%@,%@,%i\n",rd,[availableWords objectAtIndex:kk],[availableWordScores objectAtIndex:kk],[[polyhedron.polyInfo objectForKey:@"polyID"] intValue]];
		[staticWordsAvailableFileHandle writeData:[wordsFoundString dataUsingEncoding:NSUTF8StringEncoding]];
	}
#endif
	
	self.finding_words = NO;
	[self performSelectorOnMainThread:@selector(stopTransitionAnimation) withObject:nil waitUntilDone:NO];
	if (!appController.level_completed && !appController.level_aborted) {
		[self performSelectorOnMainThread:@selector(startGameAnimation) withObject:nil waitUntilDone:NO];
	} else {
		[self performSelectorOnMainThread:@selector(checkLevelCompleted) withObject:nil waitUntilDone:NO];
	}
}	 //Ported

- (void) sortAvailableWords {
#ifdef verbose
NSLog(@"into sortAvailableWords of %@",[self class]);
#endif

	BOOL cont = YES;
	NSString *tempString;
	NSNumber *tempNum;
	while (cont) {
		cont = NO;
		if ([availableWords count]) {
			for (int ii = 0; ii < [availableWords count] - 1; ii++) {
				int length1 = [[availableWords objectAtIndex:ii] length];
				int length2 = [[availableWords objectAtIndex:(ii+1)] length];
				if (length1 < length2) {
					tempString = [availableWords objectAtIndex:ii];
					tempNum = [availableWordScores objectAtIndex:ii];
					[availableWords replaceObjectAtIndex:ii withObject:[availableWords objectAtIndex:(ii+1)]];
					[availableWords replaceObjectAtIndex:(ii+1) withObject:tempString];
					[availableWordScores replaceObjectAtIndex:ii withObject:[availableWordScores objectAtIndex:(ii+1)]];
					[availableWordScores replaceObjectAtIndex:(ii+1) withObject:tempNum];
					cont = YES;
				}
			}
		}
	}
	
	num_words_avail = [availableWords count];
}	 //Ported

- (void) findWordsStartingWithPolygon:poly {
#ifdef verbose
NSLog(@"into  findWordsStartingWithPolygon:poly  of %@",[self class]);
#endif

	// FIXME:  don't need to return an array with the actual words
	NSArray *localWordArray = [wordsDB findWordsStartingWithPolygon:poly];
	NSArray *chainsFoundArray = [localWordArray objectAtIndex:1];
	for (NSArray *chain in chainsFoundArray) {
		NSMutableString *word = [NSMutableString string];
		for (Polygons *poly in chain) {
			[word appendString:[poly.letter lowercaseString]];
		}
		if (![availableWords containsObject:word]) {
			[availableWords addObject:word];
			num_words_avail = [availableWords count];
			NSNumber *num = [self getScoreForChain:chain];
			points_avail += [num intValue];
			points_avail_display = (points_avail < 100000)?(points_avail):1000;
			[availableWordScores addObject:[self getScoreForChain:chain]];
		}
	}
}	//Ported

- (NSNumber *) getScoreForChain:(NSArray *)chain {
//	NSMutableString *word = [[NSMutableString alloc] init];
	int base_word_score = 0, letter_score = 0;
	for (Polygons *poly in chain) {
		int letter_num = [alphabetArray indexOfObject:poly.letter];
		int polygon_type = poly.polyType;
		int num_sides = polygon_type + 3;
		if (polygon_type == 10 || polygon_type == 11 || polygon_type == 12) num_sides = 4;
		else if (polygon_type == 13 || polygon_type == 14 || polygon_type == 15) num_sides = 3;
		
		letter_score = (12.0 - (float)num_sides)*[[valueArray objectAtIndex:letter_num] intValue] * [chain count];
		base_word_score += letter_score;
	}
	return [NSNumber numberWithInt:base_word_score];
}

- (void) showAlphaHedraViewAlertWithInfo:(NSArray *)alertInfo {
#ifdef verbose
NSLog(@"into  showAlphaHedraViewAlertWithInfo:(NSArray *)alertInfo  of %@",[self class]);
#endif

	if (alertInfo) {
		MyActionSheet *myActionSheet = [[MyActionSheet alloc] initWithController:appController withInformation:alertInfo withCallingObject:self];
		[myActionSheet showInView:self];
		[myActionSheet release];
	}
} //Ported

- (void) selectPolyhedron:(NSDictionary *)polyhedraInfo {
#ifdef verbose
NSLog(@"into  selectPolyhedron:(NSDictionary *)polyhedraInfo  of %@",[self class]);
#endif

	[self initGLES];

	[alphabetArray release];
	[commonLettersArray release];
	[uncommonLettersArray release];
	[valueArray release];

#if LANGUAGE == 1
#if MATH
	alphabetArray = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", nil];
#else
	alphabetArray = [[NSArray alloc] initWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
#endif
	commonLettersArray = [[NSArray alloc] initWithObjects:@"A", @"E", @"I", @"O", @"T", @"N", nil];
	uncommonLettersArray = [[NSArray alloc] initWithObjects:@"J", @"Q", @"X", @"Z", nil];
	//												A		B		C		D		E		F		G		H		I		J		K		L		M		N		O		P		Q		R		S		T		U		V		W		X		Y		Z
	valueArray = [[NSArray alloc] initWithObjects:INT(1), INT(3), INT(2), INT(2), INT(1), INT(2), INT(2), INT(1), INT(1), INT(4), INT(3), INT(2), INT(2), INT(1), INT(1), INT(3), INT(4), INT(1), INT(1), INT(1), INT(2), INT(3), INT(2), INT(4), INT(3), INT(4), nil];
#endif
	
	alphabetCount = [alphabetArray count];

	[touchedPolygonsArray removeAllObjects];
	dragging = NO;
//	paused = NO;
	score_animating = NO;
	recordTimeQ = YES;
	recordScore = YES;
	zoom_factor = 1;
	time_left = kTimeToCompleteStatic;
	[touchAngleArray removeAllObjects];
	[touchTimeArray removeAllObjects];
	free_wheeling = NO;
	touchedLetterView.text = @"";
	[wordString setString:@""];
	match = NO;
	lookingUpWordsQ = NO;
	if (availableWords) {[availableWords release]; availableWords = nil;}
	if (availableWordScores) {[availableWordScores release]; availableWordScores = nil;}
	if (appController.mode == kStaticTimedMode || appController.mode == kStaticScoredMode
		|| appController.mode == kTwoPlayerClientMode || appController.mode == kTwoPlayerServerMode) {
		availableWords = [[NSMutableArray alloc] initWithCapacity:100];
		availableWordScores = [[NSMutableArray alloc] initWithCapacity:100];
	}
	else {
		availableWords = nil;
		availableWordScores = nil;
	}
	
	if (polyhedron) [polyhedron release];
	polyhedron = (Polyhedra *)[[Polyhedra alloc] initializeWithInformation:polyhedraInfo];
	
	for (int kk = 0; kk < num_polygon_types; kk++) {
		free(dyn_texture_coord_ptr[kk]);
		dyn_texture_coord_ptr[kk] = (float *)malloc(sizeof(float)*(polyhedron.face_num[kk]*(kk+3)*2));
		free(rot_texture_coord_ptr[kk]);
		rot_texture_coord_ptr[kk] = (float *)malloc(sizeof(float)*(polyhedron.face_num[kk]*(kk+3)*2));
		free(scale_texture_coord_ptr[kk]);
		scale_texture_coord_ptr[kk] = (float *)malloc(sizeof(float)*(polyhedron.face_num[kk]*(kk+3)*2));
	}

	free(axes_vertex_coord);
	free(axes_cap_vertex_coord);
	const uint num_sides = 6;
	axes_vertex_coord = (GLfloat *)malloc(sizeof(GLfloat)*3*4*num_sides);
	axes_cap_vertex_coord = (GLfloat *)malloc(sizeof(GLfloat)*3*num_sides);

	float cosii, sinii, cosiiplusone, siniiplusone;
	for (int ii = 0; ii < num_sides; ii++) {
		cosii = cosf((float)ii * 2 * M_PI / (float)num_sides);
		sinii = sinf((float)ii * 2 * M_PI / (float)num_sides);
		cosiiplusone = cosf((float)(ii + 1) * 2 * M_PI / (float)num_sides);
		siniiplusone = sinf((float)(ii + 1) * 2 * M_PI / (float)num_sides);
		axes_vertex_coord[12*ii + 0] = -1.0;
		axes_vertex_coord[12*ii + 1] = cosii;
		axes_vertex_coord[12*ii + 2] = sinii;
		axes_vertex_coord[12*ii + 3] = 1.0;
		axes_vertex_coord[12*ii + 4] = cosii;
		axes_vertex_coord[12*ii + 5] = sinii;
		axes_vertex_coord[12*ii + 6] = -1.0;
		axes_vertex_coord[12*ii + 7] = cosiiplusone;
		axes_vertex_coord[12*ii + 8] = siniiplusone;
		axes_vertex_coord[12*ii + 9] = 1.0;
		axes_vertex_coord[12*ii + 10] = cosiiplusone;
		axes_vertex_coord[12*ii + 11] = siniiplusone;
		
		axes_cap_vertex_coord[3*ii + 0] = cosii;
		axes_cap_vertex_coord[3*ii + 1] = sinii;
		axes_cap_vertex_coord[3*ii + 2] = 0.0;
	}

	for (int ii = 0; ii < 4; ii++) {
		red[ii] = 1.0;
		green[ii] = 1.0;
		blue[ii] = 1.0;
	}
	
	select_red = 0.7;
	select_green = 0.7;
	select_blue = 1.0;

	num_colors = 1;
	
	UIColor *color[20];
	color[0] = [UIColor colorWithRed:0.752 green:0.730 blue:0.210 alpha:1.000];
	color[1] = [UIColor colorWithRed:0.777 green:0.685 blue:0.572 alpha:1.000];
	color[2] = [UIColor colorWithRed:0.905 green:0.835 blue:0.690 alpha:1.000];
	color[3] = [UIColor colorWithRed:0.825 green:0.703 blue:0.456 alpha:1.000];
	color[4] = [UIColor colorWithRed:0.637 green:0.075 blue:0.163 alpha:1.000];
	color[5] = [UIColor colorWithRed:0.541 green:0.654 blue:0.406 alpha:1.000];
	color[6] = [UIColor colorWithRed:0.679 green:0.548 blue:0.112 alpha:1.000];
	color[7] = [UIColor colorWithRed:0.592 green:0.512 blue:0.382 alpha:1.000];
	color[8] = [UIColor colorWithRed:0.530 green:0.604 blue:0.214 alpha:1.000];
	color[9] = [UIColor colorWithRed:0.305 green:0.505 blue:0.476 alpha:1.000];
//	color[10] = [UIColor colorWithRed:0.309 green:0.252 blue:0.162 alpha:1.000];
//	color[11] = [UIColor colorWithRed:0.331 green:0.329 blue:0.247 alpha:1.000];
//	color[12] = [UIColor colorWithRed:0.276 green:0.209 blue:0.157 alpha:1.000];
//	color[13] = [UIColor colorWithRed:0.327 green:0.049 blue:0.101 alpha:1.000];
//	color[14] = [UIColor colorWithRed:0.107 green:0.110 blue:0.187 alpha:1.000];
//	color[15] = [UIColor colorWithRed:0.358 green:0.218 blue:0.152 alpha:1.000];
//	color[16] = [UIColor colorWithRed:0.294 green:0.030 blue:0.038 alpha:1.000];
//	color[17] = [UIColor colorWithRed:0.288 green:0.235 blue:0.224 alpha:1.000];
//	color[18] = [UIColor colorWithRed:0.127 green:0.101 blue:0.062 alpha:1.000];
//	color[19] = [UIColor colorWithRed:0.027 green:0.103 blue:0.178 alpha:1.000];
	
	// set polygon colors with hue based on the number of sides
	{
		for (int kk = 0; kk < 20; kk++) {
			const CGFloat *rgb = CGColorGetComponents(color[kk%10].CGColor);

			red[kk] = rgb[0];
			green[kk] = rgb[1];
			blue[kk] = rgb[2];
		}
	}
	
	differentPolygonTypes = 0;
	polyhedron.animatingQ = NO;
	
	polyInfo = polyhedraInfo;

	self.staticWordsFoundFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:[[appController getStaticWordsFoundPath] stringByAppendingFormat:@"_string"]];
	[staticWordsFoundFileHandle seekToEndOfFile];
	self.dynamicWordsFoundFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:[[appController getDynamicWordsFoundPath] stringByAppendingFormat:@"_string"]];
	[dynamicWordsFoundFileHandle seekToEndOfFile];

} // Ported

- (void) assignLetter:(int)letter_num toPolyNumber:(int)ii {
#ifdef verbose
NSLog(@"into  assignLetter:(int)letter_num toPolyNumber:(int)ii  of %@",[self class]);
#endif

	if (((Polygons *)[polyhedron.polygons objectAtIndex:ii]).texture) {
		((Polygons *)[polyhedron.polygons objectAtIndex:ii]).texture = letter_num;
		((Polygons *)[polyhedron.polygons objectAtIndex:ii]).letter = [alphabetArray objectAtIndex:letter_num];
	}
} // Ported

- (void) assignLetterToAllPolygonsWithLetterString:(NSString *)letterString {
	for (int ii = 0; ii < polyhedron.num_polygons; ii++) {
		Polygons *poly = [polyhedron.polygons objectAtIndex:ii];
		NSRange range = NSMakeRange(ii, 1);
		poly.letter = [letterString substringWithRange:range];
		poly.texture = [alphabetArray indexOfObject:poly.letter];
	}
} // Ported

- (void) assignLetterToAllPolygons {
#ifdef verbose
NSLog(@"into  assignLetterToAllPolygons  of %@",[self class]);
#endif
	if (appController.mode != kTwoPlayerClientMode) {
		for (int ii = 0; ii < polyhedron.num_polygons; ii++) {
			[self assignRandomLetterToPolyNumber:ii];
		}
	} else {
		[self assignLetterToAllPolygonsWithLetterString:appController.letterString];
	}
} // Ported

- (void) assignRandomLetterToPolyNumber:(int)ii {
#ifdef verbose
NSLog(@"into  assignRandomLetterToPolyNumber:(int)ii  of %@",[self class]);
#endif

	int rd;
	srandomdev();
	Polygons *poly = [polyhedron.polygons objectAtIndex:ii];
	if (poly.active) {
		rd = irandom(0, [alphabetArray count] - 1);
		if ([uncommonLettersArray containsObject:[alphabetArray objectAtIndex:rd]])
			rd = irandom(0, [alphabetArray count] - 1);
		else if (!([commonLettersArray containsObject:[alphabetArray objectAtIndex:rd]]))
			rd = irandom(0, [alphabetArray count] - 1);
	//	rd=ii+1;// for numbers
		poly.texture = rd%180;
		poly.letter = [alphabetArray objectAtIndex:rd%[alphabetArray count]];
	} else {
		poly.texture = 26;
		poly.letter = @"-";
	}
} //Ported

- (void) layoutSubviews {
#ifdef verbose
NSLog(@"into  layoutSubviews  of %@",[self class]);
#endif

//	if (finding_words)
//		[self drawTransitionView];
//	else
//		[self drawView];
}

- (void) startGameAnimation {
#ifdef verbose
NSLog(@"into  startGameAnimation  of %@",[self class]);
#endif
	NSString *message = @"";
	if (gameAnimationTimer) {
		[gameAnimationTimer invalidate];
		gameAnimationTimer = nil;
	}
	
	int game_state = ((AlphaHedraViewController *)(appController.alphaHedraViewController)).game_state;
	if (points_avail < 3000 && appController.mode == kStaticScoredMode && !appController.level_aborted && game_state != kGameContinue) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reshuffle Letters" message:[NSString stringWithFormat:@"Only %i points are available with these letters.",points_avail] 
													   delegate:self cancelButtonTitle:@"Shuffle" otherButtonTitles:nil];
		alert.tag = 1;
		[alert show];
		[alert release];
	} else if ((game_state == kGameStart || game_state == kGameRestart) && show_get_ready && appController.mode != kTwoPlayerClientMode && appController.mode != kTwoPlayerServerMode) {
		gameAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
		if (appController.mode == kDynamicTimedMode) message = [NSString stringWithFormat:@"Score as many points as you can in %d seconds.  Don't forget you can throw back letters.\n\n\n\n\n\n", kTimeToCompleteDynamic];
		else if (appController.mode == kStaticTimedMode) message = [NSString stringWithFormat:@"Score as many points as you can in %d seconds.\n\n\n\n\n\n", kTimeToCompleteStatic];
		else if (appController.mode == kDynamicScoredMode) message = [NSString stringWithFormat:@"Score %d points as fast as you can.  Don't forget you can throw back letters.\n\n\n\n\n\n", kScoreToObtainDynamic];
		else if (appController.mode == kStaticScoredMode) message = [NSString stringWithFormat:@"Score %d points as fast as you can.\n\n\n\n\n\n", kScoreToObtainStatic];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Get Ready" message:message 
													   delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
		alert.tag = 3;
		CGRect rect;
		if (appController.mode == kDynamicTimedMode || appController.mode == kDynamicScoredMode) {
			rect = CGRectMake(16,100,252,115);
		} else {
			rect = CGRectMake(16,80,252,115);
		}
		UILabel *label1 = [[UILabel alloc] initWithFrame:rect];
		label1.text = @"Remember letters must share an edge to form words.";
		label1.numberOfLines = 3;
		label1.adjustsFontSizeToFitWidth = YES;
		label1.backgroundColor = [UIColor clearColor];
		label1.font = [UIFont boldSystemFontOfSize:20.0];
		label1.textColor = [UIColor whiteColor];
		label1.textAlignment = UITextAlignmentCenter;
		label1.shadowColor = [UIColor blackColor];
		label1.shadowOffset = CGSizeMake(2.0,2.0);
		[alert addSubview:label1];
		
		[alert show];
		[alert release];
		show_get_ready = YES;
	} else if (show_get_ready && opponent_ready) {
		gameAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
		[waitingAlert dismissWithClickedButtonIndex:2 animated:NO];
		message = @"";

		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Get Ready\n\n\n\n\n\n" message:message 
													   delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
		UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(16,50,252,25)];
		label1.text = @"Game will start in";
		label1.adjustsFontSizeToFitWidth = YES;
		label1.backgroundColor = [UIColor clearColor];
		label1.font = [UIFont systemFontOfSize:18.0];
		label1.textColor = [UIColor whiteColor];
		label1.textAlignment = UITextAlignmentCenter;
		label1.shadowColor = [UIColor blackColor];
		label1.shadowOffset = CGSizeMake(2.0,2.0);
		[alert addSubview:label1];
		[label1 release];
		UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(16,175,252,25)];
		label2.text = @"seconds.";
		label2.adjustsFontSizeToFitWidth = YES;
		label2.backgroundColor = [UIColor clearColor];
		label2.font = [UIFont systemFontOfSize:18.0];
		label2.textColor = [UIColor whiteColor];
		label2.textAlignment = UITextAlignmentCenter;
		label2.shadowColor = [UIColor blackColor];
		label2.shadowOffset = CGSizeMake(2.0,2.0);
		[alert addSubview:label2];
		[label2 release];
		UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(16,90,252,75)];
		label3.text = @"3";
		label3.adjustsFontSizeToFitWidth = YES;
		label3.backgroundColor = [UIColor clearColor];
		label3.font = [UIFont systemFontOfSize:72.0];
		label3.textColor = [UIColor whiteColor];
		label3.textAlignment = UITextAlignmentCenter;
		label3.shadowColor = [UIColor blackColor];
		label3.shadowOffset = CGSizeMake(2.0,2.0);
		label3.tag = 101;
		[alert addSubview:label3];
		[label3 release];
		[alert show];
		show_get_ready = YES;
		[self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:1.0];
		alert.tag = 6;
		[alert release];
	}
	else {
		gameAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
		if (!appController.level_completed) [self startClock];
	}
//	[self checkLevelCompleted];
} //Ported

- (void) waitForOpponent {
	if (show_get_ready && !opponent_ready) {
		StartDataController *startDataController = [[StartDataController alloc] init];
		[startDataController startSend:[NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:appController.game_id]]];
		[startDataController release];
		static BOOL alert_showing = NO;
		if (!alert_showing) {
			waitingAlert = [[UIAlertView alloc] initWithTitle:@"Waiting" message:@"Waiting for opponent.\n\n\n\n" 
													 delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
			[waitingAlert show];
			waitingAlert.tag = 2;
		}
		show_get_ready = YES;
		alert_showing = YES;
	}
}	

- (void) stopGameAnimation {
#ifdef verbose
NSLog(@"into  stopGameAnimation  of %@",[self class]);
#endif

	if (score_animating && gameAnimationTimer) {
		[self performSelector:@selector(stopGameAnimation) withObject:nil afterDelay:1.0];
	} else {
		[gameAnimationTimer invalidate];
		gameAnimationTimer = nil;
	}
} //Ported

- (void) startTransitionAnimation {
#ifdef verbose
NSLog(@"into  startTransitionAnimation  of %@",[self class]);
#endif

	if (transitionAnimationTimer) [transitionAnimationTimer invalidate];
	transitionAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval/1.5f target:self selector:@selector(drawTransitionView) userInfo:nil repeats:YES];
	[self setNeedsLayout];
	for (int ii = 100; ii < 106; ii++) [[self viewWithTag:ii] setHidden:NO];
}

- (void) stopTransitionAnimation {
#ifdef verbose
NSLog(@"into  stopTransitionAnimation  of %@",[self class]);
#endif

	[transitionAnimationTimer invalidate];
	transitionAnimationTimer = nil;
	for (int ii = 100; ii < 106; ii++) [[self viewWithTag:ii] setHidden:YES];
}

- (void) endSpin {
#ifdef verbose
NSLog(@"into  endSpin  of %@",[self class]);
#endif

	addToRotationTrackball (gTrackBallRotation, worldRotation);
	gTrackBallRotation [0] = gTrackBallRotation [1] = gTrackBallRotation [2] = gTrackBallRotation [3] = 0.0f;
	[self setRotationAngle:gTrackBallRotation[0] X:gTrackBallRotation[1] Y:gTrackBallRotation[2] Z:gTrackBallRotation[3]];
	[self setWorldRotationAngle:worldRotation[0] X:worldRotation[1] Y:worldRotation[2] Z:worldRotation[3]];
}

- (void) setAnimation {
#ifdef verbose
NSLog(@"into  setAnimation  of %@",[self class]);
#endif

	polyhedron.animation_type = 2;
	polyhedron.animatingQ = YES;
	animation_start_time = get_time_of_day();
}

- (void) checkDrag:(NSTimer *)timer {
#ifdef verbose
NSLog(@"into  checkDrag:(NSTimer *)timer  of %@",[self class]);
#endif

	checked = TRUE;
	if (!dragging || (hypot(curTouchPos.x - initTouchPos.x,curTouchPos.y - initTouchPos.y) < 5)) 
		touch_mode = kSelectMode; // if dragging hasn't started yet, we're selecting
	else touch_mode = kRotateMode;
	if (touch_mode == kSelectMode) {
		int touched_num = [self findTouchedPolygonAtPoint:initTouchPos];
		int poly_count = [polyhedron.polygons count];
		if (prev_touched_num >= 0 && prev_touched_num < poly_count) {
			Polygons *poly = [polyhedron.polygons objectAtIndex:prev_touched_num];
			poly.touched = FALSE;
		}
		if (touched_num >= 0 && prev_touched_num < poly_count) {
			Polygons *poly = [polyhedron.polygons objectAtIndex:touched_num];
			poly.touched = TRUE;
			touchedLetterView.text = [[alphabetArray objectAtIndex:(poly.texture)%[alphabetArray count]] lowercaseString];
			touchedLetterView.hidden = NO;
			prev_touched_num = touched_num;
		}
	}
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
//#ifdef debug
//NSLog(@"into  touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event  of %@",[self class]);
//#endif

	[touchAngleArray removeAllObjects];
	[touchTimeArray removeAllObjects];
	[touchXArray removeAllObjects];
	[touchYArray removeAllObjects];
	
	if (submitting) {
		submitting = NO;
		for (Polygons *poly in touchedPolygonsArray) {
			poly.selected = NO;
		}
		[touchedPolygonsArray removeAllObjects];
	}
	
	if (free_wheeling) {
		free_wheeling = NO;
		[self endSpin];
	}
	
	NSArray *touchArray = [touches allObjects];
	UITouch *t = [touchArray objectAtIndex:0];
	CGPoint touchPos = [t locationInView:t.view];
	initTouchPos = touchPos;
	if ([touchArray count]>1) {
		UITouch *t2 = [touchArray objectAtIndex:1];
		CGPoint touchPos2 = [t2 locationInView:t2.view];
		init_dist = hypot(touchPos2.x - touchPos.x,touchPos2.y - touchPos.y);
	}
	
	dragging = FALSE;
	
	checked = FALSE;
	
	float touch_zone = 405.0f;
	if (!appController.unlocked) touch_zone -= 45.0f;
	if (touchPos.y > touch_zone && (touchPos.x < 90 || touchPos.x > 230)) {
		touch_mode = kButtonMode;
		if (submitting) {
			submitting = 0;
			word_disp = 0.0;
		}
		
		[touchTimeArray addObject:[NSNumber numberWithDouble:get_time_of_day()]];
		[touchXArray addObject:[NSNumber numberWithFloat:touchPos.x]];
		[touchYArray addObject:[NSNumber numberWithFloat:touchPos.y]];
	} else if (touchPos.y < 50) {
		touch_mode = kEditMode;
	} else {
		[self performSelector:@selector(checkDrag:) withObject:nil afterDelay:0.5];
		touch_mode = kRotateMode;
		touchPos.y = bounds.size.height - touchPos.y;
		startTrackball(touchPos.x, touchPos.y, 0, 0, bounds.size.width, bounds.size.height);
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
//#ifdef debug
//NSLog(@"into  touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event  of %@",[self class]);
//#endif

	dragging = TRUE;
	
	NSArray *touchArray = [touches allObjects];
	if ([touchArray count]>1) touch_mode = kZoomMode;
	
	UITouch *t = [touchArray objectAtIndex:0];
	CGPoint touchPos = [t locationInView:t.view];
	curTouchPos = touchPos;
	
	if (touch_mode == kRotateMode) {
		[touchTimeArray addObject:[NSNumber numberWithDouble:get_time_of_day()]];

		touchPos.y = bounds.size.height - touchPos.y;
		rollToTrackball (touchPos.x, touchPos.y, gTrackBallRotation);
		[touchAngleArray addObject:[NSNumber numberWithFloat:gTrackBallRotation[0]]];
		[self setRotationAngle:gTrackBallRotation[0] X:gTrackBallRotation[1] Y:gTrackBallRotation[2] Z:gTrackBallRotation[3]];
	} else if (touch_mode == kSelectMode) {
		int touched_num = [self findTouchedPolygonAtPoint:touchPos];
		if (prev_touched_num >= 0 && prev_touched_num < [polyhedron.polygons count]) {
			Polygons *poly = [polyhedron.polygons objectAtIndex:prev_touched_num];
			poly.touched = FALSE;
		}
		if (touched_num >= 0) {
			Polygons *poly = [polyhedron.polygons objectAtIndex:touched_num];
			poly.touched = TRUE;
			touchedLetterView.text = [[alphabetArray objectAtIndex:(poly.texture)%[alphabetArray count]] lowercaseString];
			touchedLetterView.hidden = NO;
			
			prev_touched_num = touched_num;
		}
	} else if (touch_mode == kZoomMode && [touchArray count]>1) {
		UITouch *t2 = [touchArray objectAtIndex:1];
		CGPoint touchPos2 = [t2 locationInView:t2.view];
		float dist = hypot(touchPos2.x - touchPos.x,touchPos2.y - touchPos.y);
		zoom_factor -= (dist - init_dist)/300;
		if (zoom_factor < 0.5)
			zoom_factor = 0.5;
		if (zoom_factor > 4.0)
			zoom_factor = 4.0;
		init_dist = dist;
//	} else if (touch_mode == kButtonMode) {
//		[touchTimeArray addObject:[NSNumber numberWithDouble:get_time_of_day()]];
//		
//		touchPos.y = bounds.size.height - touchPos.y;
//		if (touchPos.x - initTouchPos.x > 15.0*(touchPos.y - initTouchPos.y)) {
//			submitting = 1;
//			word_disp = touchPos.x;
//		}
//		[touchXArray addObject:[NSNumber numberWithFloat:touchPos.x]];
//		[touchYArray addObject:[NSNumber numberWithFloat:touchPos.y]];
	}
}

void rotateNormalToZAxis(Polygons *firstPoly,GLfloat* modelViewMatrix,GLfloat* rotation_axis) {
	float current_tangent_v[4], current_normal_v[4], current_binorm_v[4];
	matrixMultiply(modelViewMatrix, firstPoly.tangent_v, current_tangent_v);
	matrixMultiply(modelViewMatrix, firstPoly.normal_v, current_normal_v);
	matrixMultiply(modelViewMatrix, firstPoly.binorm_v, current_binorm_v);

	// normalize the vectors in case the modelViewMatrix scaled them
	normalize(current_tangent_v);
	normalize(current_normal_v);
	normalize(current_binorm_v);
	float rot_m[3][3];
	rot_m[0][0] = current_tangent_v[0];
	rot_m[0][1] = current_tangent_v[1];
	rot_m[0][2] = current_tangent_v[2];
	rot_m[1][0] = current_binorm_v[0];
	rot_m[1][1] = current_binorm_v[1];
	rot_m[1][2] = current_binorm_v[2];
	rot_m[2][0] = current_normal_v[0];
	rot_m[2][1] = current_normal_v[1];
	rot_m[2][2] = current_normal_v[2];
	
	// calculate the rotation angle per http://en.wikipedia.org/wiki/Rotation_representation
	rotation_axis[0] = acosf( (rot_m[0][0] + rot_m[1][1] + rot_m[2][2] - 1.0)/2.0 );
	
	// calculate the rotation vector per http://en.wikipedia.org/wiki/Rotation_representation
	float denom = 2.0*sinf(rotation_axis[0]);
	rotation_axis[0] = 180.0/M_PI * rotation_axis[0];
	rotation_axis[1] = (rot_m[2][1] - rot_m[1][2])/denom;
	rotation_axis[2] = (rot_m[0][2] - rot_m[2][0])/denom;
	rotation_axis[3] = (rot_m[1][0] - rot_m[0][1])/denom;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
//#ifdef debug
//NSLog(@"into  touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event  of %@",[self class]);
//#endif

	[NSObject cancelPreviousPerformRequestsWithTarget:self]; // cancel the dragging check
	
	NSArray *touchArray = [touches allObjects];  // get touches into an array
	UITouch *t = [touchArray objectAtIndex:0];  // get the first touch object
	CGPoint touchPos = [t locationInView:t.view];  // get the position of the touch in the view
	
	
	if (dragging && touch_mode == kRotateMode) { // if we're dragging and rotating the polyhedron...
		int count = [touchTimeArray count];
		// ...get information about the drag history to calculate a velocity...
		if (count>3) {
			float dt = (float)([[touchTimeArray objectAtIndex:(count-1)] doubleValue] - [[touchTimeArray objectAtIndex:(count-3)] doubleValue]);
			omega = ([[touchAngleArray objectAtIndex:(count-1)] floatValue] - [[touchAngleArray objectAtIndex:(count-3)] floatValue])/dt;
		} else if (count>2) {
			float dt = (float)([[touchTimeArray objectAtIndex:(count-1)] doubleValue] - [[touchTimeArray objectAtIndex:(count-2)] doubleValue]);
			omega = ([[touchAngleArray objectAtIndex:(count-1)] floatValue] - [[touchAngleArray objectAtIndex:(count-2)] floatValue])/dt;
		} else {
			omega = 0.0;
		}
		// ...and let the polyhedron start free wheeling.
		free_wheeling = YES;
		
	} 
	else if (touch_mode == kButtonMode) {  // if we're in button mode
		if (touchPos.x > 220.0) {  //  if the submit button was touched...
			// ...set the animation start time for all the selected polygons...
			for (Polygons *touchedPoly in touchedPolygonsArray) {
				touchedPoly.select_animation_start_time = get_time_of_day();
			}
			[self submitWord];  // ...submit the word...
			submitting = TRUE;
		} else if (touchPos.x < 90.0 && appController.mode != kTwoPlayerClientMode && appController.mode != kTwoPlayerServerMode) {  //  if the submit button was touched...
			[self pause];  // ...submit the word...
		}
	} 
//	else if (touch_mode == kEditMode) { //  if a selected letter was touched...
//			int poly_to_remove = [self findTouchedPolygonAtPoint:touchPos]; //  ...figure out which selected polygon was touched...
//			if ([touchedPolygonsArray count] > poly_to_remove)  //  ...check to see if it's valid and remove it.
//				[self setTouchedPolygon:[touchedPolygonsArray objectAtIndex:poly_to_remove]];
//	}			
	else if (touch_mode == kHintMode) {  //  if the hidden hint button was pressed
		// Find a random three or four letter word
		BOOL continue_looking = TRUE;
		int counter = 0;
		while (continue_looking && counter < 10) {
			// get a random polygon
			int random_poly_number = irandom(0, [polyhedron.polygons count]-1);
			Polygons *poly = [polyhedron.polygons objectAtIndex:random_poly_number];
			// get the valid chains starting from that polygon
			NSArray *validStuff = [wordsDB getValidChainsStartingWithPolygon:poly];
			// make two copies of the valid chains and words to shuffle them
			NSMutableArray *validChains1 = [[[validStuff objectAtIndex:0] mutableCopy] autorelease];
			NSMutableArray *validWords1 = [[[validStuff objectAtIndex:1] mutableCopy] autorelease];
			NSMutableArray *validChains = [[[validStuff objectAtIndex:0] mutableCopy] autorelease];
			NSMutableArray *validWords = [[[validStuff objectAtIndex:1] mutableCopy] autorelease];

			// shuffle the chains keeping the correspondence between chain array and word array
			while ([validChains1 count]) {
				int rand = irandom(0, [validChains count] - 1);
				[validChains insertObject:[validChains1 lastObject] atIndex:rand];
				[validChains1 removeLastObject];
				[validWords insertObject:[validWords1 lastObject] atIndex:rand];
				[validWords1 removeLastObject];
			}
			
			NSString *s, *newString;
			// while there are elements in the validChains array...
			while ([validChains count]) {
				// ...grab the last chain and the last word...
				NSArray *chain = [validChains lastObject];
				NSArray *words = [validWords lastObject];
				NSMutableString *string = [NSMutableString stringWithCapacity:5];
				for (Polygons *poly in chain) {
					[string appendString:[poly.letter lowercaseString]];
				}
				if ([words containsObject:string]) { // if the possible words list contains the string
					if (![wordsFound containsObject:string]) { // if that word has not already been found
						[wordsFound addObject:string]; // add the word to the list of found words
						[self setTouchedPolygon:nil]; // clear all the touched polygons (why not just [touchedPolygonsArray removeAllObjects])
						for (Polygons *poly in chain) { // 'touch' all the polygons in the chain
							[self setTouchedPolygon:poly];
						}
						continue_looking = NO; // stop looking any further
						// rotate the polyhedron so that the first polygon has a normal in the z-direction
						rotateNormalToZAxis([chain objectAtIndex:0],modelViewMatrix,gTrackBallRotation);
						[self endSpin];
						
						[validChains removeAllObjects]; // remove all valid chains to break loop
					}
				}
				
				if ([validChains count]) { // if there are still objects in the list of valid chains
					uint chain_size = [chain count];
					// make an array containing the first N letters of each of the possible words.
					NSMutableArray *substrings = [NSMutableArray arrayWithCapacity:[words count]];
					for (s in words) {
						if ([s length]>chain_size) {
							[substrings addObject:[s substringToIndex:(chain_size+1)]];
						}
					}
					Polygons *lastPoly = [chain lastObject]; // grab the last polygon in the chain
					for (Polygons *nextPoly in lastPoly.connections) { // loop over all the polygons connected to the last one
						if (![chain containsObject:nextPoly]) { // if the connected polygon is not already in the chain...
							// ...add that polygons letter to the end of the original string
							newString = [[NSString stringWithString:string] stringByAppendingString:[nextPoly.letter lowercaseString]];
							if ([words containsObject:newString]) { // if that appended string is in the list of possible words
								if (![wordsFound containsObject:newString]) { // if the new string is not in the list of words already found
									// touch all the polygons in the chain
									for (Polygons *poly in chain) {
										[self setTouchedPolygon:poly];
									}
								}
							}
							if ([substrings containsObject:newString]) { // if the new string is contained in the substrings...
								// ...add the current chain plus the valid connected polygon to the list of valid chains
								[validChains insertObject:[[NSArray arrayWithArray:chain] arrayByAddingObject:nextPoly] atIndex:0];
								// ...add the words list to the combined list of valid words
								[validWords insertObject:words atIndex:0];
							}
						}
					}
					// get rid of the last chain and last word list
					if ([validChains count])
						[validChains removeLastObject];
					if ([validWords count])
						[validWords removeLastObject];
				}
			}
			counter++;
		}
	}
	else if (!dragging || touch_mode == kSelectMode) {
		
		touch_start_time = get_time_of_day();

		if (prev_touched_num >= 0 && prev_touched_num < [polyhedron.polygons count]) 
			// need to make sure from level to level that index is within bounds
			((Polygons *)[polyhedron.polygons objectAtIndex:prev_touched_num]).touched = FALSE;
		
		int touched_num = [self findTouchedPolygonAtPoint:touchPos];
		
		if (touched_num >= 0) {
			Polygons *poly = [polyhedron.polygons objectAtIndex:touched_num];
			[self setTouchedPolygon:poly];
		} else
			[self setTouchedPolygon:nil];
		
		if (match)
			[appController.wordSound play];
		else 
			[appController.touchSound play];

		touchedLetterView.text = @"";
		touchedLetterView.hidden = YES;
	} 
	dragging = FALSE;
}

- (int) findTouchedPolygonAtPoint:(CGPoint)touchPos {
#ifdef verbose
NSLog(@"into  findTouchedPolygonAtPoint:(CGPoint)touchPos  of %@",[self class]);
#endif

	GLfloat vec[4], vec1[4], vec3[4], transform_matrix[16];//, touch[3] = {0.0, 0.0, -6.0};
	GLint vp[4];
	GLfloat winX, winY;
	
	touchPos.y = appController.screen_rect.size.height - touchPos.y;
	
	uint ii = 0, jj = 0;
	NSMutableArray *closeArray = [NSMutableArray new];
	NSMutableArray *centroidsArray = [NSMutableArray new];
	NSMutableArray *faceNumArrary = [NSMutableArray new];
	
	vec[3] = 1.0;
	
	glGetIntegerv(GL_VIEWPORT, vp);
	matrixMatrixMultiply(appController.projectionMatrix, modelViewMatrix, transform_matrix);
	
	int counter = 0;
	for (int ll = 0; ll < num_polygon_types + 1; ll++) {
		for (ii = 0; ii < polyhedron.face_num2[ll]; ii++) {
			int num_sides = ll + 3;
			if (ll == 10 || ll == 11 || ll == 12) num_sides = 4;
			else if (ll == 13 || ll == 14 || ll == 15) num_sides = 3;
			float minX = MAXFLOAT , maxX = -MAXFLOAT, minY=MAXFLOAT, maxY=-MAXFLOAT;
			for (int kk = 0; kk < num_sides; kk++) {
				for (jj = 0; jj < 3; jj++) {
					vec[jj] = polyhedron.poly_vertices_ptr[ll][num_sides * 3 * ii + 3 * kk + jj];
				}
				
				matrixMultiply(transform_matrix, vec, vec3);
				vec3[0]/=vec3[3];
				vec3[1]/=vec3[3];
				vec3[2]/=vec3[3];
				winX = (GLfloat)vp[0] + (GLfloat)vp[2] * (vec3[0] + 1.0) / 2.0;
				winY = (GLfloat)vp[1] + (GLfloat)vp[3] * (vec3[1] + 1.0) / 2.0;
//				winZ = (vec3[2]	+ 1.0) / 2.0;
				
				if (winX > maxX) maxX = winX;
				if (winX < minX) minX = winX;
				if (winY > maxY) maxY = winY;
				if (winY < minY) minY = winY;
			}
			if (touchPos.x < maxX && touchPos.x > minX && touchPos.y < maxY && touchPos.y > minY) {
				[closeArray addObject:[polyhedron.polygons objectAtIndex:counter]];
				[faceNumArrary addObject:[NSNumber numberWithInt:ii]];
				// I should store the deformed vertex coords here so I don't have to recompute them later
				//				NSLog(@"*******MATCH*******");
			}
			counter++;
		}
	}
	
	GLfloat centroid_z_max = -100;//, temp[4] = {0.0, 0.0, 0.0, 1.0}, vec2[4] = {0.0, 0.0, 0.0, 1.0};
	int touched_num = -1, base_vertex_index = 0;
	counter = 0;
	NSArray *copyOfCloseArray = [NSArray arrayWithArray:closeArray];
//	NSLog(@"copyOfCloseArray = %@",copyOfCloseArray);
	for (Polygons *poly in copyOfCloseArray) {
		int poly_type = poly.polyType;
		int num_sides = poly_type + 3;
		if (poly_type == 10 || poly_type == 11 || poly_type == 12) num_sides = 4;
		else if (poly_type == 13 || poly_type == 14 || poly_type == 15) num_sides = 3;
		// get the deformed coordinates of all the vertices and store them in a 2-D array
		float *deformed_vertex_coords_x = (float *)malloc(sizeof(float)*num_sides);
		float *deformed_vertex_coords_y = (float *)malloc(sizeof(float)*num_sides);
		
		for (int nn = 0; nn < num_sides; nn++) {
			base_vertex_index = num_sides * 3 * [[faceNumArrary objectAtIndex:counter] intValue] + 3 * nn;
			for (int kk = 0; kk < 3; kk++) vec[kk] = polyhedron.poly_vertices_ptr[poly_type][base_vertex_index + kk];
			matrixMultiply(transform_matrix, vec, vec3);
			vec3[0]/=vec3[3];
			vec3[1]/=vec3[3];
			vec3[2]/=vec3[3];
			winX = (GLfloat)vp[0] + (GLfloat)vp[2] * (vec3[0] + 1.0) / 2.0;
			winY = (GLfloat)vp[1] + (GLfloat)vp[3] * (vec3[1] + 1.0) / 2.0;
//			winZ = (vec3[2]	+ 1.0) / 2.0;
			deformed_vertex_coords_x[nn] = winX;
			deformed_vertex_coords_y[nn] = winY;
		}
		
		int inside = pnpoly(num_sides, deformed_vertex_coords_x, deformed_vertex_coords_y, touchPos.x, touchPos.y);
		
		free(deformed_vertex_coords_x);
		free(deformed_vertex_coords_y);
		
		if (!inside)// || !poly.active)
			[closeArray removeObject:poly];
		else {
			NSArray *centroid = poly.centroid;
			vec[0] = [[centroid objectAtIndex:0] floatValue];
			vec[1] = [[centroid objectAtIndex:1] floatValue];
			vec[2] = [[centroid objectAtIndex:2] floatValue];
			vec[3] = 1.0;
			matrixMultiply(modelViewMatrix, vec, vec1);
			[centroidsArray addObject:[NSNumber numberWithFloat:vec1[2]]];
		}				
		
		counter++;
	}
	
	counter = 0;
	for (Polygons *poly in closeArray) {
		float centroid_z = [[centroidsArray objectAtIndex:counter] floatValue];
		if (centroid_z > centroid_z_max) {
			centroid_z_max = centroid_z;
			touched_num = poly.number;
		}
		counter++;
	}
	
	[closeArray release];
	[centroidsArray release];
	[faceNumArrary release];
	
	return touched_num;
}

- (void) setRotationAngle:(float)angle X:(float)xAxis Y:(float)yAxis Z:(float)zAxis  {
//#ifdef debug
//NSLog(@"into  setRotationAngle:(float)angle X:(float)xAxis Y:(float)yAxis Z:(float)zAxis   of %@",[self class]);
//#endif

	rotationAboutAxisX = xAxis;
	rotationAboutAxisY = yAxis;
	rotationAboutAxisZ = zAxis;
	rotationAngle = angle;
}

- (void) setWorldRotationAngle:(float)angle X:(float)xAxis Y:(float)yAxis Z:(float)zAxis {
//#ifdef debug
//NSLog(@"into  setWorldRotationAngle:(float)angle X:(float)xAxis Y:(float)yAxis Z:(float)zAxis  of %@",[self class]);
//#endif

	worldRotationAboutAxisX = xAxis;
	worldRotationAboutAxisY = yAxis;
	worldRotationAboutAxisZ = zAxis;
	worldRotationAngle = angle;
}

- (void) drawView {
//#ifdef debug
//NSLog(@"into  drawView  of %@",[self class]);
//#endif

//	while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE) == kCFRunLoopRunHandledSource);
	
	[EAGLContext setCurrentContext:appController.context];
		
	if(!appControllerSetup) {
		[appController setupViewWithRect:self.bounds];
		appControllerSetup = YES;
	}
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, appController.viewFramebuffer);
	
	[self drawScene];
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, appController.viewRenderbuffer);
	[appController.context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
	//	GLenum err = glGetError();
	//	if(err) NSLog(@"%x error", err);
}

void draw_background(GLuint *textures) {
#define kBackgroundSize 10.0f
#define kBackgroundOffsetZ -20.0f
#define kBackgroundOffsetY 0.0f
#define kBackgroundOffsetX 3.8f
	const GLfloat bgVertices[] = {
		-kBackgroundSize + kBackgroundOffsetX, -kBackgroundSize + kBackgroundOffsetY, kBackgroundOffsetZ,
		kBackgroundSize + kBackgroundOffsetX, -kBackgroundSize + kBackgroundOffsetY, kBackgroundOffsetZ,
		-kBackgroundSize + kBackgroundOffsetX, kBackgroundSize + kBackgroundOffsetY, kBackgroundOffsetZ,
		kBackgroundSize + kBackgroundOffsetX, kBackgroundSize + kBackgroundOffsetY, kBackgroundOffsetZ,
	};
	const GLfloat bgTexCoord[] = {
		0.0f, (512.0f - 480.0f)/512.0f,
		0.5f, (512.0f - 480.0f)/512.0f,
		0.0f, 1.0f,
		0.5f, 1.0f,
	};
	
	glCullFace(GL_BACK);
	glBindTexture(GL_TEXTURE_2D, textures[1]);
//	float rd = frandom(0.0, 1.0);
//	glColor4f(rd, 1.0, 1.0, 1.0);
	glColor4f(1.0, 1.0, 1.0, 1.0);
	glVertexPointer(3, GL_FLOAT, 0, bgVertices);
	glTexCoordPointer(2, GL_FLOAT, 0, bgTexCoord);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

#define kNumOffsetX1 0.62
#define kNumOffsetX2 0.72
#define kNumWidth 0.3f

#define kTimeOffsetX1 (0.67 - 0.03)
#define kTimeOffsetX2 (0.67 + 0.03)
#define kSymbolOffsetX1 (0.75 - 0.03)
#define kSymbolOffsetX2 (0.75 + 0.03)

- (BOOL) drawScoreFor:(NSInteger)player {
	
//#ifdef debug
//NSLog(@"into  drawScore  of %@",[self class]);
//#endif

	static float	ones_offset_points[2] = {0.0}, 
					tens_offset_points[2] = {0.0}, 
					huns_offset_points[2] = {0.0}, 
					thous_offset_points[2] = {0.0}, 
					ten_thous_offset_points[2] = {0.0};

	const GLfloat numVertices[] = {
		-1.0, -1.0, 0.0,
		1.0, -1.0, 0.0,
		-1.0, 1.0, 0.0,
		1.0, 1.0, 0.0,
	};

	static float y_pos = -12.0;
	float x_pos = 15.0, z_pos = -3.0, shift = 1.9;
	if (appController.unlocked) {
		y_pos = -12.0;
	} else {
		y_pos = -9.25;
	}
	
	//Setup model view matrix
	glLoadIdentity();
	
	glBindTexture(GL_TEXTURE_2D, textures[1]);
	glColor4f(1.0, 1.0, 1.0, 1.0);
	glVertexPointer(3, GL_FLOAT, 0, numVertices);
	
	glCullFace(GL_BACK);
	glPushMatrix();

	{
		static GLfloat points_ones_tex[] = {
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
		};
		
		static GLfloat points_tens_tex[] = {
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
		};
		
		static GLfloat points_huns_tex[] = {
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
		};
		
		static GLfloat points_thous_tex[] = {
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
		};
		
		static GLfloat points_ten_thous_tex[] = {
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
		};

		glScalef(0.05, 0.08, 1.0);
		glPushMatrix();
		if (player == 1) {
			float offset = 0;
			if (opponent_score > 1000) offset = 1;
			if (opponent_score > 10000) offset = 2;
			glTranslatef(-26.2 + shift * offset, 0.0, 0.0);
		}
		glTranslatef(x_pos, y_pos, z_pos);
		float score_display_float;
		if (player == 1) score_display_float = (float)((opponent_score < 0)?0:opponent_score);
		else score_display_float = (float)((score < 0)?0:score);
		if (fabsf(ones_offset_points[player] - score_display_float) > 0.001) {
			score_animating = YES;
			ones_offset_points[player] += 0.25*(score_display_float - ones_offset_points[player]);
		} else {
			score_animating = NO;
		}
		
		points_ones_tex[1] = 0.91f - fmodf(ones_offset_points[player],10)/10.0f,
		points_ones_tex[3] = 0.91f - fmodf(ones_offset_points[player],10)/10.0f,
		points_ones_tex[5] = 0.99f - fmodf(ones_offset_points[player],10)/10.0f,
		points_ones_tex[7] = 0.99f - fmodf(ones_offset_points[player],10)/10.0f;
		
		glTexCoordPointer(2, GL_FLOAT, 0, points_ones_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

		glTranslatef(-shift, 0, 0);
		if (fabsf(tens_offset_points[player] - floorf(score_display_float/10.0f)) > 0.001) {
			tens_offset_points[player] += 0.25*(floorf(score_display_float/10.0f) - tens_offset_points[player]);
		}
		
		points_tens_tex[1] = 0.91f - fmodf(tens_offset_points[player],10)/10.0f,
		points_tens_tex[3] = 0.91f - fmodf(tens_offset_points[player],10)/10.0f,
		points_tens_tex[5] = 0.99f - fmodf(tens_offset_points[player],10)/10.0f,
		points_tens_tex[7] = 0.99f - fmodf(tens_offset_points[player],10)/10.0f;
		
		glTexCoordPointer(2, GL_FLOAT, 0, points_tens_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

		glTranslatef(-shift, 0, 0);
		if (fabsf(huns_offset_points[player] - floorf(score_display_float/100.0f)) > 0.001) {
			huns_offset_points[player] += 0.25f*(floorf(score_display_float/100.0f) - huns_offset_points[player]);
		}
		
		points_huns_tex[1] = 0.91f - fmodf(huns_offset_points[player],10)/10.0f,
		points_huns_tex[3] = 0.91f - fmodf(huns_offset_points[player],10)/10.0f,
		points_huns_tex[5] = 0.99f - fmodf(huns_offset_points[player],10)/10.0f,
		points_huns_tex[7] = 0.99f - fmodf(huns_offset_points[player],10)/10.0f;
		
		glTexCoordPointer(2, GL_FLOAT, 0, points_huns_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		
		if (score_display_float >= 1000) {
			glTranslatef(-shift, 0, 0);
			if (fabsf(thous_offset_points[player] - floorf(score_display_float/1000.0f)) > 0.001) {
				thous_offset_points[player] += 0.25*(floorf(score_display_float/1000.0f) - thous_offset_points[player]);
			}
			
			points_thous_tex[1] = 0.91f - fmodf(thous_offset_points[player],10)/10.0f,
			points_thous_tex[3] = 0.91f - fmodf(thous_offset_points[player],10)/10.0f,
			points_thous_tex[5] = 0.99f - fmodf(thous_offset_points[player],10)/10.0f,
			points_thous_tex[7] = 0.99f - fmodf(thous_offset_points[player],10)/10.0f;
			
			glTexCoordPointer(2, GL_FLOAT, 0, points_thous_tex);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		}
		
		if (score_display_float >= 10000) {
			glTranslatef(-shift, 0, 0);
			if (fabsf(ten_thous_offset_points[player] - floorf(score_display_float/10000.0f)) > 0.001) {
				ten_thous_offset_points[player] += 0.25*(floorf(score_display_float/10000.0f) - ten_thous_offset_points[player]);
			}
			
			points_ten_thous_tex[1] = 0.91f - fmodf(ten_thous_offset_points[player],10)/10.0f,
			points_ten_thous_tex[3] = 0.91f - fmodf(ten_thous_offset_points[player],10)/10.0f,
			points_ten_thous_tex[5] = 0.99f - fmodf(ten_thous_offset_points[player],10)/10.0f,
			points_ten_thous_tex[7] = 0.99f - fmodf(ten_thous_offset_points[player],10)/10.0f;
			
			glTexCoordPointer(2, GL_FLOAT, 0, points_ten_thous_tex);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		}
		glPopMatrix();
	}
	glPopMatrix();
	return score_animating;
}

- (void) drawTime {
//#ifdef debug
//NSLog(@"into  drawTime  of %@",[self class]);
//#endif

	static GLfloat symbol_tex[] = {
		kSymbolOffsetX1, 0.61f,
		kSymbolOffsetX2, 0.61f,
		kSymbolOffsetX1, 0.69f,
		kSymbolOffsetX2, 0.69f,
	};

	static GLfloat time_ones_tex[] = {
		kTimeOffsetX1, 0.0,
		kTimeOffsetX2, 0.0,
		kTimeOffsetX1, 0.0,
		kTimeOffsetX2, 0.0,
	};
	
	static GLfloat time_tens_tex[] = {
		kTimeOffsetX1, 0.0,
		kTimeOffsetX2, 0.0,
		kTimeOffsetX1, 0.0,
		kTimeOffsetX2, 0.0,
	};
	
	static GLfloat min_tex[] = {
		kTimeOffsetX1, 0.0,
		kTimeOffsetX2, 0.0,
		kTimeOffsetX1, 0.0,
		kTimeOffsetX2, 0.0,
	};
//	if (appController.mode == kStaticTimedMode || appController.mode == kDynamicTimedMode) {
		static int ones_offset_time = 0;
		static int tens_offset_time = 0, offset_min = 0;
		
		//Setup model view matrix
		glLoadIdentity();
		
		glBindTexture(GL_TEXTURE_2D, textures[1]);
		glColor4f(1.0, 1.0, 1.0, 1.0);
		const GLfloat numVertices[] = {
			-1.0, -1.0, 0.0,
			1.0, -1.0, 0.0,
			-1.0, 1.0, 0.0,
			1.0, 1.0, 0.0,
		};
		glVertexPointer(3, GL_FLOAT, 0, numVertices);
		
		glCullFace(GL_BACK);

	static float y_pos;
	float x_pos = -15.0, z_pos = -3.0, shift = 1.9;
	if (appController.unlocked) {
		if (appController.mode == kTwoPlayerClientMode || appController.mode == kTwoPlayerServerMode) {
			y_pos = -14.0;
		} else {
			y_pos = -12.0;
		}

	} else {
		if (appController.mode == kTwoPlayerClientMode || appController.mode == kTwoPlayerServerMode) {
			y_pos = -11.0;
		} else {
			y_pos = -9.25;
		}
	}
	
	x_pos += 2.0*shift + 0.5;

	glPushMatrix();
	glScalef(0.05, 0.08, 1.0);
	if (appController.mode == kStaticTimedMode || appController.mode == kDynamicTimedMode) {
		if (time_left > kTimeToCompleteStatic/2) {
			glColor4f(2.0 - 2.0*time_left/kTimeToCompleteStatic, 1.0, 0.0, 1.0);
		} else {
			glColor4f(1.0, 2.0*time_left/kTimeToCompleteStatic, 0.0, 1.0);
		}
	} else {
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	}
	{
		int min_left = (int)time_left/60;
		int sec_left = ((int)time_left)%60;
		glPushMatrix();
		glTranslatef(x_pos, y_pos, z_pos);
		if (ones_offset_time != sec_left) {
			ones_offset_time += (sec_left - ones_offset_time);
		}
		
		time_ones_tex[1] = 0.91f - (float)(ones_offset_time%10)/10.0f,
		time_ones_tex[3] = 0.91f - (float)(ones_offset_time%10)/10.0f,
		time_ones_tex[5] = 0.99f - (float)(ones_offset_time%10)/10.0f,
		time_ones_tex[7] = 0.99f - (float)(ones_offset_time%10)/10.0f;
		
		glTexCoordPointer(2, GL_FLOAT, 0, time_ones_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
		
		glPushMatrix();
		x_pos -= shift;
		glTranslatef(x_pos, y_pos, z_pos);
		if (tens_offset_time != (ones_offset_time/10)) {
			tens_offset_time += (ones_offset_time/10 - tens_offset_time);
		}
		
		time_tens_tex[1] = 0.91f - (float)(tens_offset_time%10)/10.0f,
		time_tens_tex[3] = 0.91f - (float)(tens_offset_time%10)/10.0f,
		time_tens_tex[5] = 0.99f - (float)(tens_offset_time%10)/10.0f,
		time_tens_tex[7] = 0.99f - (float)(tens_offset_time%10)/10.0f;
		
		glTexCoordPointer(2, GL_FLOAT, 0, time_tens_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
		
		glPushMatrix();
		x_pos -= shift + 0.5;
		glTranslatef(x_pos, y_pos, z_pos);
		if ((int)offset_min != min_left) {
			offset_min += (min_left - offset_min);
		}
		
		min_tex[1] = 0.91f - (float)(offset_min%10)/10.0f,
		min_tex[3] = 0.91f - (float)(offset_min%10)/10.0f,
		min_tex[5] = 0.99f - (float)(offset_min%10)/10.0f,
		min_tex[7] = 0.99f - (float)(offset_min%10)/10.0f;
		
		glTexCoordPointer(2, GL_FLOAT, 0, min_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();

		glPushMatrix();
		x_pos += (shift + 0.5)/2;
		glTranslatef(x_pos, y_pos, z_pos);
		
		glTexCoordPointer(2, GL_FLOAT, 0, symbol_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
	}
	glPopMatrix();
}

void draw_axes(float *axes_cap_vertex_coord,float *axes_vertex_coord) {
#define axes_radius 0.02
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, axes_cap_vertex_coord);

	glPushMatrix();
	glRotatef(90.0, 0.0, 1.0, 0.0);
	glTranslatef(0.0, 0.0, -3.0);
	glScalef(axes_radius, axes_radius, axes_radius);
	glRotatef(30.0, 0.0, 0.0, 1.0);
	glColor4f(1.0, 0.5, 0.5, 1.0);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 6);
	glPopMatrix();

//		glPushMatrix();
//		glRotatef(-90.0, 0.0, 1.0, 0.0);
//		glTranslatef(0.0, 0.0, -5.0);
//		glScalef(axes_radius, axes_radius, axes_radius);
//		glRotatef(30.0, 0.0, 0.0, 1.0);
//		glColor4f(1.0, 0.0, 0.0, 1.0);
//		glDrawArrays(GL_TRIANGLE_FAN, 0, 6);
//		glPopMatrix();
	
//		glPushMatrix();
//		glRotatef(90.0, 1.0, 0.0, 0.0);
//		glTranslatef(0.0, 0.0, -5.0);
//		glScalef(axes_radius, axes_radius, axes_radius);
//		glColor4f(0.0, 1.0, 0.0, 1.0);
//		glDrawArrays(GL_TRIANGLE_FAN, 0, 6);
//		glPopMatrix();
	
	glPushMatrix();
	glRotatef(-90.0, 1.0, 0.0, 0.0);
	glTranslatef(0.0, 0.0, -3.0);
	glScalef(axes_radius, axes_radius, axes_radius);
	glColor4f(0.5, 1.0, 0.5, 1.0);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 6);
	glPopMatrix();

//		glPushMatrix();
//		glTranslatef(0.0, 0.0, -5.0);
//		glScalef(axes_radius, axes_radius, axes_radius);
//		glRotatef(30.0, 0.0, 0.0, 1.0);
//		glColor4f(0.0, 0.0, 1.0, 1.0);
//		glDrawArrays(GL_TRIANGLE_FAN, 0, 6);
//		glPopMatrix();
//		
//		glPushMatrix();
//		glRotatef(180.0, 0.0, 1.0, 0.0);
//		glTranslatef(0.0, 0.0, -5.0);
//		glScalef(axes_radius, axes_radius, axes_radius);
//		glRotatef(30.0, 0.0, 0.0, 1.0);
//		glColor4f(0.0, 0.0, 1.0, 1.0);
//		glDrawArrays(GL_TRIANGLE_FAN, 0, 6);
//		glPopMatrix();

	glVertexPointer(3, GL_FLOAT, 0, axes_vertex_coord);
	
	glPushMatrix();
	glScalef(1.5, axes_radius, axes_radius);
	glTranslatef(-1.0, 0.0, 0.0);
	glColor4f(1.0, 0.5, 0.5, 1.0);
	for (int i = 0; i < 6; i++) {
		glDrawArrays(GL_TRIANGLE_STRIP, 4*i, 4);
	}
	glPopMatrix();

	glPushMatrix();
	glRotatef(90.0, 0.0, 0.0, 1.0);
	glScalef(1.5, axes_radius, axes_radius);
	glTranslatef(-1.0, 0.0, 0.0);
	glColor4f(0.5, 1.0, 0.5, 1.0);
	for (int i = 0; i < 6; i++) {
		glDrawArrays(GL_TRIANGLE_STRIP, 4*i, 4);
	}
	glPopMatrix();

//		glPushMatrix();
//		glRotatef(90.0, 0.0, 1.0, 0.0);
//		glScalef(5.0, axes_radius, axes_radius);
//		glColor4f(0.5, 0.5, 1.0, 1.0);
//		for (int i = 0; i < 6; i++) {
//			glDrawArrays(GL_TRIANGLE_STRIP, 4*i, 4);
//		}
//		glPopMatrix();
}

void draw_selected_polyhedron_fronts(Polyhedra *polyhedron, GLfloat* blue, GLfloat* green, GLfloat* red, float select_blue, float select_green, float select_red, float* scale, GLuint *textures, NSArray *touchedPolygonsArray) {
	int poly_num = 0;
	int type_num = -1;
	
	GLfloat **texture_coord = polyhedron.scaled_base_texture_coords;
	GLfloat **poly_vertices_ptr = polyhedron.poly_vertices_ptr;
	GLfloat **texture_coord_ptr = polyhedron.texture_coord_ptr;
	
	glCullFace(GL_BACK);
	
	glActiveTexture(GL_TEXTURE0);
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glDepthRangef(0.0, 1.0 - 0.00001);
	
	int *num_faces = polyhedron.face_num2;
	
	for (int kk = 0; kk < num_polygon_types + 1; kk++) {
		int num_sides = kk + 3;
		if (kk == 10 || kk == 11 || kk == 12) num_sides = 4;
		else if (kk == 13 || kk == 14 || kk == 15) num_sides = 3;
		glBindTexture(GL_TEXTURE_2D, textures[kk+3]);
		glVertexPointer(3, GL_FLOAT, 0, poly_vertices_ptr[kk]);
		
		if (num_faces[kk]) type_num++;
		
		for (int i = 0; i < num_faces[kk]; i ++) {
			Polygons *poly = [polyhedron.polygons objectAtIndex:poly_num];
			if ([touchedPolygonsArray containsObject:poly]) {
				
				{
//					glClientActiveTexture(GL_TEXTURE0);
					glTexCoordPointer(2, GL_FLOAT, 0, texture_coord_ptr[kk]);
					static int offset_x, offset_y;
#if MATH
					offset_x = ((poly.texture)%4);
					offset_y = (3-(poly.texture)/4);
					for (int jj = 0; jj < num_sides; jj++) {
						texture_coord_ptr[kk][2*jj+2*num_sides*i+0] = texture_coord[kk][2*jj] + (float)offset_x/4.0f;
						texture_coord_ptr[kk][2*jj+2*num_sides*i+1] = texture_coord[kk][2*jj+1] + (float)offset_y/4.0f;
					}
#else
					offset_x = ((poly.texture)%6);
					offset_y = (5-(poly.texture)/6);
					for (int jj = 0; jj < num_sides; jj++) {
						texture_coord_ptr[kk][2*jj+2*num_sides*i+0] = texture_coord[kk][2*jj] + (float)offset_x/6.0f;
						texture_coord_ptr[kk][2*jj+2*num_sides*i+1] = texture_coord[kk][2*jj+1] + (float)offset_y/6.0f;
					}
#endif
				} // generate texture coordinates (should really do this outside the main loop)
				
				glPushMatrix();
				if (poly.animatingQ) glScalef(scale[type_num], scale[type_num], scale[type_num]);
				
				{
					if (poly.texture >= 0 && poly.active) {
						glColor4f(red[kk]*0.2, green[kk]*0.2, blue[kk]*0.2, 0.2);
					}
				} // determine which secondary color to use
				
				glDrawArrays(GL_TRIANGLE_FAN, num_sides*i, num_sides);
				
				glPopMatrix();
			}
			
			poly_num++;
		}		
	}
}

void draw_polyhedron_fronts(Polyhedra *polyhedron, GLfloat* blue, GLfloat* green, GLfloat* red, float select_blue, float select_green, float select_red, float* scale, GLuint *textures, NSArray *touchedPolygonsArray) {
	int poly_num = 0;
	int type_num = -1;
	
	GLfloat **texture_coord = polyhedron.scaled_base_texture_coords;
	GLfloat **poly_vertices_ptr = polyhedron.poly_vertices_ptr;
	GLfloat **texture_coord_ptr = polyhedron.texture_coord_ptr;
	
	glCullFace(GL_BACK);
		
	glDepthRangef(0.0, 1.0 - 0.00001);
		
	int *num_faces = polyhedron.face_num2;

	for (int kk = 0; kk < num_polygon_types + 1; kk++) {
		int num_sides = kk + 3;
		if (kk == 10 || kk == 11 || kk == 12) num_sides = 4;
		else if (kk == 13 || kk == 14 || kk == 15) num_sides = 3;
		glBindTexture(GL_TEXTURE_2D, textures[kk+3]);
		glVertexPointer(3, GL_FLOAT, 0, poly_vertices_ptr[kk]);
		
		if (num_faces[kk]) type_num++;
		
		for (int i = 0; i < num_faces[kk]; i ++) {
			Polygons *poly = [polyhedron.polygons objectAtIndex:poly_num];
			if (![touchedPolygonsArray containsObject:poly]) {
					
				{
					glTexCoordPointer(2, GL_FLOAT, 0, texture_coord_ptr[kk]);
					static int offset_x, offset_y;
	#if MATH
					offset_x = ((poly.texture)%4);
					offset_y = (3-(poly.texture)/4);
					for (int jj = 0; jj < num_sides; jj++) {
						texture_coord_ptr[kk][2*jj+2*num_sides*i+0] = texture_coord[kk][2*jj] + (float)offset_x/4.0f;
						texture_coord_ptr[kk][2*jj+2*num_sides*i+1] = texture_coord[kk][2*jj+1] + (float)offset_y/4.0f;
					}
	#else
					offset_x = ((poly.texture)%6);
					offset_y = (5-(poly.texture)/6);
					for (int jj = 0; jj < num_sides; jj++) {
						texture_coord_ptr[kk][2*jj+2*num_sides*i+0] = texture_coord[kk][2*jj] + (float)offset_x/6.0f;
						texture_coord_ptr[kk][2*jj+2*num_sides*i+1] = texture_coord[kk][2*jj+1] + (float)offset_y/6.0f;
					}
	#endif
				} // generate texture coordinates (should really do this outside the main loop)
				
				glPushMatrix();
				if (poly.animatingQ) glScalef(scale[type_num], scale[type_num], scale[type_num]);
				
				glColor4f(red[kk], green[kk], blue[kk], 1.0);
				
				glDrawArrays(GL_TRIANGLE_FAN, num_sides*i, num_sides);

				glPopMatrix();
			}

			poly_num++;
		}		
	}
}

void draw_test_rect(GLuint *textures) {
#define kTestSize 0.2f
#define kTestOffsetZ -1.5f
	// Draw test square
	{
		const GLfloat testVertices[] = {
			-kTestSize, -kTestSize, kTestOffsetZ,
			kTestSize, -kTestSize, kTestOffsetZ,
			-kTestSize, kTestSize, kTestOffsetZ,
			kTestSize, kTestSize, kTestOffsetZ,
		};
		const GLfloat testTexCoord[] = {
			0.0f, 0.0f,
			1.0f, 0.0f,
			0.0f, 1.0f,
			1.0f, 1.0f,
		};
		
		glCullFace(GL_BACK);
		glActiveTexture(GL_TEXTURE0);
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glBindTexture(GL_TEXTURE_2D, textures[1]);
		glColor4f(1.0, 1.0, 1.0, 1.0);
		glVertexPointer(3, GL_FLOAT, 0, testVertices);
		glTexCoordPointer(2, GL_FLOAT, 0, testTexCoord);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}	
}	

void draw_opponent_word(GLuint *textures) {
	{
		const GLfloat testVertices[] = {
			-1.0, -1.0, -12,
			1.0, -1.0, -12,
			-1.0, 1.0, -12,
			1.0, 1.0, -12,
		};
		const GLfloat testTexCoord[] = {
			0.0f + 0.0f, 0.0f + 0.0f,
			320.0/512.0 - 0.0f, 0.0f + 0.0f,
			0.0f + 0.0f, 75.0/512.0 - 0.0f,
			320.0/512.0 - 0.0f, 75.0/512.0 - 0.0f,
		};
		
		glScalef(1.0, 75.0/320.0, 1.0);
		glCullFace(GL_BACK);
		glActiveTexture(GL_TEXTURE0);
		glEnable(GL_TEXTURE_2D);
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glBindTexture(GL_TEXTURE_2D, textures[1]);
		glColor4f(1.0, 1.0, 1.0, 1.0);
		glVertexPointer(3, GL_FLOAT, 0, testVertices);
		glTexCoordPointer(2, GL_FLOAT, 0, testTexCoord);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}	
}	

void draw_buttons (GLuint *textures, float match_red, float match_green, float match_blue, BOOL unlocked, int mode) {
	// Draw pause/submit buttons
	
	const GLfloat squareVertices2[] = {
		-1.0f, -1.0f, 0.0f,
		1.0f, -1.0f, 0.0f,
		-1.0f, 1.0f, 0.0f,
		1.0f, 1.0f, 0.0f,
	};
	
	const GLfloat submit_texture_coord[] = {
		0.72f, 0.8f,
		1.0f, 0.8f,
		0.72f, 0.9f,
		1.0f, 0.9f,
	};
	const GLfloat pause_texture_coord[] = {
		0.72f, 0.9f,
		1.0f, 0.9f,
		0.72f, 1.0f,
		1.0f, 1.0f,
	};
	
	glCullFace(GL_BACK);
	
	glBindTexture(GL_TEXTURE_2D, textures[1]);
	
	glPushMatrix();
	glLoadIdentity();
	static float y_pos;
	if (unlocked) y_pos = -2.95f;
	else y_pos = -2.38;
	glTranslatef(1.65f, y_pos, -8.1f);
	glScalef(0.5, 0.225, 1.0);
	glColor4f(match_red, match_green, match_blue, 1.0);
	glVertexPointer(3, GL_FLOAT, 0, squareVertices2);
	glTexCoordPointer(2, GL_FLOAT, 0, submit_texture_coord);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
	
	if (mode != kTwoPlayerClientMode && mode != kTwoPlayerServerMode) {
		glPushMatrix();
		glLoadIdentity();
		glTranslatef(-1.75f, y_pos, -8.1f);
		glScalef(0.5, 0.225, 1.0);
		glColor4f(1.0, 1.0, 1.0, 1.0);
		glVertexPointer(3, GL_FLOAT, 0, squareVertices2);
		glTexCoordPointer(2, GL_FLOAT, 0, pause_texture_coord);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
	}
}	

void draw_polyhedron_backs(Polyhedra *polyhedron, GLfloat* blue, GLfloat* green, GLfloat* red, int differentPolygonTypes, float* scale, GLuint *textures, NSArray *touchedPolygonsArray) {
	int poly_num = 0;

	GLfloat **texture_coord = polyhedron.scaled_base_texture_coords;
	GLfloat **poly_vertices_ptr = polyhedron.poly_vertices_ptr;
	GLfloat **texture_coord_ptr = polyhedron.texture_coord_ptr;

	glCullFace(GL_FRONT);

	for (int kk = 0; kk < num_polygon_types + 1; kk++) {
		int num_sides = kk + 3;
		if (kk == 10 || kk == 11 || kk == 12) num_sides = 4;
		else if (kk == 13 || kk == 14 || kk == 15) num_sides = 3;
		glVertexPointer(3, GL_FLOAT, 0, poly_vertices_ptr[kk]);
		glBindTexture(GL_TEXTURE_2D, textures[kk+3]);

//		if (polyhedron.face_num2[kk]) type_num++;
		
		for (int i = 0; i < polyhedron.face_num2[kk]; i ++) {
			Polygons *poly = [polyhedron.polygons objectAtIndex:poly_num];
			if (![touchedPolygonsArray containsObject:poly]) {
				glClientActiveTexture(GL_TEXTURE0);
				glTexCoordPointer(2, GL_FLOAT, 0, texture_coord_ptr[kk]);
				static int offset_x, offset_y;
	#if MATH
				offset_x = ((poly.texture)%4);
				offset_y = (3-(poly.texture)/4);
				for (int jj = 0; jj < num_sides; jj++) {
					texture_coord_ptr[kk][2*jj+2*num_sides*i+0] = texture_coord[kk][2*jj] + (float)offset_x/4.0f;
					texture_coord_ptr[kk][2*jj+2*num_sides*i+1] = texture_coord[kk][2*jj+1] + (float)offset_y/4.0f;
				}
	#else
				offset_x = ((poly.texture)%6);
				offset_y = (5-(poly.texture)/6);
				for (int jj = 0; jj < num_sides; jj++) {
					texture_coord_ptr[kk][2*jj+2*num_sides*i+0] = texture_coord[kk][2*jj] + (float)offset_x/6.0f;
					texture_coord_ptr[kk][2*jj+2*num_sides*i+1] = texture_coord[kk][2*jj+1] + (float)offset_y/6.0f;
				}
	#endif
				{
					glPushMatrix();
					if (poly.texture >= 0 && poly.active) {
						glColor4f(red[kk]/2, green[kk]/2, blue[kk]/2, 1.0);
					}
					glDrawArrays(GL_TRIANGLE_FAN, num_sides*i, num_sides);
					glPopMatrix();
				}
				
			}
			poly_num++;
		}
	}
}

void draw_flying_polygons(BOOL submitting, GLuint *textures, GLfloat **texture_coord_ptr, GLfloat **texture_coord, AppController *appController, NSMutableArray *touchedPolygonsArray, double time, int letter_num, int letter_count, float *red, float *green, float *blue, float worldRotationAboutAxisX, float worldRotationAboutAxisY, float worldRotationAboutAxisZ, float rotationAboutAxisX, float rotationAboutAxisY, float rotationAboutAxisZ, float worldRotationAngle, float rotationAngle) {
	NSArray *touchedPolygonsArrayCopy = [NSArray arrayWithArray:touchedPolygonsArray];
	for (Polygons *poly in touchedPolygonsArrayCopy) {
		
		float dt = (float)(time - poly.select_animation_start_time);
		letter_num++;
		int polygon_type = [poly polyType];
		
		glPushMatrix();
		glLoadIdentity();
		
		glColor4f(red[polygon_type], green[polygon_type], blue[polygon_type], 1.0);
		float trans, trans2;
		if (dt < 0.2f) {
			trans = 0.5f*(1.0f + atanf(40.0f*(dt - 0.1f))/atanf(40.0f*(- 0.1f)));
			trans2 = 1.0f - expf(40.0*(dt-0.2f));
		} else {
			trans = 0.0;
			trans2 = 0.0;
		}
		
		glTranslatef(((float)(letter_num-1)*0.25f - (float)(letter_count-1)*0.25/2.0)*trans, 0.0f + 1.38f*trans, -8.0f + 4.0f*trans2 + 0.01f*((float)letter_num));
		if (rotationAboutAxisX != 0.0f) glRotatef (rotationAngle*(1.0 - trans), rotationAboutAxisX, rotationAboutAxisY, rotationAboutAxisZ);
		glRotatef(worldRotationAngle*(1.0 - trans), worldRotationAboutAxisX, worldRotationAboutAxisY, worldRotationAboutAxisZ);
		glScalef(1.0f + trans*(0.2f/poly.radius - 1.0f), 1.0f + trans*(0.2f/poly.radius - 1.0f), 1.0);
		if (appController.level == 5)
			glRotatef(135.0f, 0.0, 0.0, 1.0);
		else if (polygon_type == 5) {
			glRotatef(-180.0f/((float)(polygon_type + 3)) * trans, 0.0, 0.0, 1.0);
		} else if (polygon_type == 3)
			glRotatef(-360.0f/((float)(polygon_type + 3)) * trans, 0.0, 0.0, 1.0);
		else if (polygon_type == 2)
			glRotatef(-180.0f/((float)(polygon_type + 3)) * trans, 0.0, 0.0, 1.0);
		else if (polygon_type == 0)
			glRotatef(-180.0f * trans, 0.0, 0.0, 1.0);
		glRotatef(180.0f/M_PI*poly.rot_angle * trans, poly.rot_v[0], poly.rot_v[1], poly.rot_v[2]);
		glTranslatef(- poly.centroid_v[0]*trans, -poly.centroid_v[1]*trans, -poly.centroid_v[2]*trans);
		static int offset_x, offset_y;
		offset_x = ((poly.texture)%6);
		offset_y = (5-(poly.texture)/6);
		int num_sides = polygon_type + 3, i = 0;
		if (polygon_type == 10 || polygon_type == 11 || polygon_type == 12) num_sides = 4;
		else if (polygon_type == 13 || polygon_type == 14 || polygon_type == 15) num_sides = 3;
		
		for (int jj = 0; jj < num_sides; jj++) {
			texture_coord_ptr[polygon_type][2*jj+2*num_sides*i+0] = texture_coord[polygon_type][2*jj] + (float)offset_x/6.0f;
			texture_coord_ptr[polygon_type][2*jj+2*num_sides*i+1] = texture_coord[polygon_type][2*jj+1] + (float)offset_y/6.0f;
		}
		
		glBindTexture(GL_TEXTURE_2D, textures[polygon_type + 3]);
		glTexCoordPointer(2, GL_FLOAT, 0, texture_coord_ptr[polygon_type]);
		glVertexPointer(3, GL_FLOAT, 0, poly.vertices);
		glDrawArrays(GL_TRIANGLE_FAN, 0, num_sides);
		
		glPopMatrix();
		
		if (dt > 0.2f) {
//			submitting = NO;
			poly.selected = NO;
			[touchedPolygonsArray removeAllObjects];
		}
	}
}

void draw_selected_polygons(BOOL submitting, GLuint *textures, GLfloat **texture_coord_ptr, GLfloat **texture_coord, AppController *appController, NSMutableArray *touchedPolygonsArray, double time, int letter_num, int letter_count, float *red, float *green, float *blue, float worldRotationAboutAxisX, float worldRotationAboutAxisY, float worldRotationAboutAxisZ, float rotationAboutAxisX, float rotationAboutAxisY, float rotationAboutAxisZ, float worldRotationAngle, float rotationAngle) {
	for (Polygons *poly in touchedPolygonsArray) {
		float dt = (float)(time - poly.select_animation_start_time);
		letter_num++;
		int polygon_type = [poly polyType];
		
		glPushMatrix();
		glLoadIdentity();
		
		glColor4f(red[polygon_type], green[polygon_type], blue[polygon_type], 1.0);
		float trans, trans2;//, trans3;
		if (dt < 0.5) {
			trans = 0.5f*(1.0f - atanf(6.0f*(dt - 0.25f))/atanf(6.0f*(- 0.25f)));
			trans2 = 1.0f - expf(-24.0*dt);
		} else {
			trans = 1.0;
			trans2 = 1.0;
		}
		
		// this cause the polygon to orbit the polyhedron.
		//	glScalef(1.1f, 1.1f, 1.1f);
		//	glTranslatef(0.0f, 0.0f, -8.0f/1.1f);
		//	if (rotationAboutAxisX != 0.0f)
		//		glRotatef (rotationAngle, rotationAboutAxisX, rotationAboutAxisY, rotationAboutAxisZ);
		//	glRotatef(worldRotationAngle, worldRotationAboutAxisX, worldRotationAboutAxisY, worldRotationAboutAxisZ);
		//	glRotatef(180.0f*dt, 1.0f, 0.0f, 0.0f);
		
		glTranslatef(((float)(letter_num-1)*0.25f - (float)(letter_count-1)*0.25/2.0)*trans, 0.0f + 1.38f*trans, -8.0f + 4.0f*trans2 + 0.01f*((float)letter_num));
		if (rotationAboutAxisX != 0.0f) glRotatef (rotationAngle*(1.0 - trans), rotationAboutAxisX, rotationAboutAxisY, rotationAboutAxisZ);
		glRotatef(worldRotationAngle*(1.0 - trans), worldRotationAboutAxisX, worldRotationAboutAxisY, worldRotationAboutAxisZ);
		glScalef(1.0f + trans*(0.2f/poly.radius - 1.0f), 1.0f + trans*(0.2f/poly.radius - 1.0f), 1.0);
		if (appController.level == 5)
			glRotatef(147.5f, 0.0, 0.0, 1.0);
		else if (appController.level == 27)
			glRotatef(47.0, 0.0, 0.0, 1.0);
		else if (appController.level == 6)
			glRotatef(-135.0f, 0.0, 0.0, 1.0);
		else if (appController.level == 23)
			glRotatef(55.0f, 0.0, 0.0, 1.0);
		else if (appController.level == 24)
			if (polygon_type == 0)
				glRotatef(90.0, 0.0, 0.0, 1.0);
			else
				glRotatef(90.0, 0.0, 0.0, 1.0);
			else if (polygon_type == 5)
				glRotatef(-2.0*360.0f/((float)(polygon_type + 3)) * trans, 0.0, 0.0, 1.0);
			else if (polygon_type == 3)
				glRotatef(-360.0f/((float)(polygon_type + 3)) * trans, 0.0, 0.0, 1.0);
			else if (polygon_type == 2)
				glRotatef(-180.0f/((float)(polygon_type + 3)) * trans, 0.0, 0.0, 1.0);
			else if (polygon_type == 0)
				glRotatef(-180.0f * trans, 0.0, 0.0, 1.0);
			else if (polygon_type == 7)
				glRotatef(-72.0f, 0.0, 0.0, 1.0);
			else if (polygon_type == 9)
				glRotatef(-60.0, 0.0, 0.0, 1.0);
		glRotatef(180.0f/M_PI*poly.rot_angle * trans, poly.rot_v[0], poly.rot_v[1], poly.rot_v[2]);
		glTranslatef(- poly.centroid_v[0]*trans, -poly.centroid_v[1]*trans, -poly.centroid_v[2]*trans);
		static int offset_x, offset_y;
		offset_x = ((poly.texture)%6);
		offset_y = (5-(poly.texture)/6);
		int num_sides = polygon_type + 3, i = 0;
		if (polygon_type == 10 || polygon_type == 11 || polygon_type == 12) num_sides = 4;
		else if (polygon_type == 13 || polygon_type == 14 || polygon_type == 15) num_sides = 3;
		for (int jj = 0; jj < num_sides; jj++) {
			texture_coord_ptr[polygon_type][2*jj+2*num_sides*i+0] = texture_coord[polygon_type][2*jj] + (float)offset_x/6.0f;
			texture_coord_ptr[polygon_type][2*jj+2*num_sides*i+1] = texture_coord[polygon_type][2*jj+1] + (float)offset_y/6.0f;
		}
		
		glBindTexture(GL_TEXTURE_2D, textures[polygon_type + 3]);
		glTexCoordPointer(2, GL_FLOAT, 0, texture_coord_ptr[polygon_type]);
		glVertexPointer(3, GL_FLOAT, 0, poly.vertices);
		glDrawArrays(GL_TRIANGLE_FAN, 0, num_sides);
		
		glPopMatrix();
	}	
}

- (void) drawScene {
	
	//Clear framebuffer
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glEnable(GL_DEPTH_TEST);
	glDepthRangef(0.0, 1.0);

	//Setup model view matrix
	glLoadIdentity();

	glActiveTexture(GL_TEXTURE0);
	glEnable(GL_TEXTURE_2D);

	GLfloat **texture_coord_ptr = polyhedron.texture_coord_ptr;
	GLfloat **texture_coord = polyhedron.scaled_base_texture_coords;

	// Draw background
	draw_background(textures);

	int letter_count = [touchedPolygonsArray count];

	float y_shift = 0.0f;
	if (!appController.unlocked) y_shift = 0.25f;
	
	GLfloat zoom = -zoom_factor*8.0;
	glTranslatef(0.0, y_shift, (zoom < -15?-15:zoom));
	
	if (free_wheeling) {
		if (omega > 1) {
			gTrackBallRotation[0] += omega * 0.02;
			omega /= 1.1;
			[self setRotationAngle:gTrackBallRotation[0] X:gTrackBallRotation[1] Y:gTrackBallRotation[2] Z:gTrackBallRotation[3]];
			glRotatef (rotationAngle, rotationAboutAxisX, rotationAboutAxisY, rotationAboutAxisZ);
		} else {
			free_wheeling = NO;
			[self endSpin];
		}
	} 
	else if (rotationAboutAxisX != 0.0f) {
		glRotatef (rotationAngle, rotationAboutAxisX, rotationAboutAxisY, rotationAboutAxisZ);
	}
	glRotatef (worldRotationAngle, worldRotationAboutAxisX, worldRotationAboutAxisY, worldRotationAboutAxisZ);

	float scale[num_polygon_types] = {1.0};
	
	glGetFloatv (GL_MODELVIEW_MATRIX, modelViewMatrix);
	
	// Draw axes
	if (appController.axesQ)
		draw_axes(axes_cap_vertex_coord,axes_vertex_coord);

	// Draw polygons
	if (letter_count) {
		draw_polyhedron_backs(polyhedron,blue,green,red,differentPolygonTypes,scale,textures,touchedPolygonsArray);
		int letter_num = 0;
		glDisable(GL_CULL_FACE);
		
		double time = get_time_of_day();

		if (submitting) {
			draw_flying_polygons(submitting, textures, texture_coord_ptr, texture_coord, appController, touchedPolygonsArray, time, letter_num, letter_count, red, green, blue, worldRotationAboutAxisX, worldRotationAboutAxisY, worldRotationAboutAxisZ, rotationAboutAxisX, rotationAboutAxisY, rotationAboutAxisZ, worldRotationAngle, rotationAngle);
		} 
		else {
			draw_selected_polygons(submitting, textures, texture_coord_ptr, texture_coord, appController, touchedPolygonsArray, time, letter_num, letter_count, red, green, blue, worldRotationAboutAxisX, worldRotationAboutAxisY, worldRotationAboutAxisZ, rotationAboutAxisX, rotationAboutAxisY, rotationAboutAxisZ, worldRotationAngle, rotationAngle);
		}
		glEnable(GL_CULL_FACE);
	}

	draw_polyhedron_fronts(polyhedron,blue,green,red,select_blue,select_green,select_red,scale,textures,touchedPolygonsArray);
	draw_selected_polyhedron_fronts(polyhedron,blue,green,red,select_blue,select_green,select_red,scale,textures,touchedPolygonsArray);

	[self drawTime];
	
	score_animating = [self drawScoreFor:0];
	
	if (appController.mode == kTwoPlayerClientMode || appController.mode == kTwoPlayerServerMode) {
		[self drawScoreFor:1];
	}

	draw_buttons(textures, match_red, match_green, match_blue, appController.unlocked, appController.mode);
	
//	draw_test_rect(textures);
	
	static int opponent_word_timer = 0;
	if ([opponentWordsToDisplay count] && opponent_word_timer == 0) {
		[Textures loadTextureWithString:[opponentWordsToDisplay objectAtIndex:0] intoLocation:appController.textures[1] withTag:0 inRect:CGRectMake(0.0, 0.0, 320.0, 75.0)];
		show_opponent_word = YES;
	}
	if (show_opponent_word || (opponent_word_timer > 0 && opponent_word_timer < 30)) {
		glTranslatef(0.0, 0.0, 0.5f*(float)opponent_word_timer);
		draw_opponent_word(textures);
		show_opponent_word = NO;
		opponent_word_timer++;
	} else if (opponent_word_timer >= 30) {
		opponent_word_timer = 0;
		[opponentWordsToDisplay removeObjectAtIndex:0];
	}
}

- (void) drawTransitionView {
//#ifdef debug
//NSLog(@"into  drawTransitionView  of %@",[self class]);
//#endif

//	while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE) == kCFRunLoopRunHandledSource);
	
	[EAGLContext setCurrentContext:appController.context];
	
	if(!appControllerSetup) {
		[appController setupViewWithRect:self.bounds];
		appControllerSetup = YES;
	}
	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, appController.viewFramebuffer);
	
	[self drawTransitionScene];
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, appController.viewRenderbuffer);
	[appController.context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
	//	GLenum err = glGetError();
	//	if(err) NSLog(@"%x error", err);
}

- (void) drawTransitionScene {
	
//#ifdef debug
//NSLog(@"into  drawTransitionScene  of %@",[self class]);
//#endif

	static float ones_offset_poly = 0.0, tens_offset_poly = 0.0, huns_offset_poly = 0.0;
	static float ones_offset_words = 0.0, tens_offset_words = 0.0, huns_offset_words = 0.0;
	static float ones_offset_points = 0.0, tens_offset_points = 0.0, huns_offset_points = 0.0, thous_offset_points = 0.0, ten_thous_offset_points = 0.0;
		
	if (reset_counters) {
		ones_offset_poly = 0.0, tens_offset_poly = 0.0, huns_offset_poly = 0.0;
		ones_offset_words = 0.0, tens_offset_words = 0.0, huns_offset_words = 0.0;
		ones_offset_points = 0.0, tens_offset_points = 0.0, huns_offset_points = 0.0, thous_offset_points = 0.0, ten_thous_offset_points = 0.0;
		reset_counters = NO;
	}
	
	//Clear framebuffer
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	//Setup model view matrix
	glLoadIdentity();
	
	#define kTransNumWidth 0.3f

	glBindTexture(GL_TEXTURE_2D, textures[1]);
	glColor4f(1.0, 1.0, 1.0, 1.0);
	#define kNumSize 0.15f
	#define kNumOffsetZ -1.5f
	const GLfloat numVertices[] = {
		-kNumSize, -kNumSize, kNumOffsetZ,
		kNumSize, -kNumSize, kNumOffsetZ,
		-kNumSize, kNumSize, kNumOffsetZ,
		kNumSize, kNumSize, kNumOffsetZ,
	};
	glVertexPointer(3, GL_FLOAT, 0, numVertices);
	
	glCullFace(GL_BACK);
	float x_pos, y_pos;

	if (!appController.unlocked) y_pos = 0.66;
	else y_pos = 0.46;

	float z_pos = -1.0;
	glScalef(1.0, 1.0, 1.0);
	// Draw polygons checked
	{
		static GLfloat poly_ones_tex[] = {
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
		};
		
		static GLfloat poly_tens_tex[] = {
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
		};
		
		static GLfloat poly_huns_tex[] = {
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
		};
		
		glPushMatrix();
		x_pos = 0.35;
		glTranslatef(x_pos, y_pos, z_pos);
		float poly_counter_float = (float)poly_counter;
		if (ones_offset_poly < poly_counter_float) {
			score_animating = YES;
			ones_offset_poly += 0.25*(poly_counter_float - ones_offset_poly);
		} else {
			score_animating = NO;
		}
		
		poly_ones_tex[1] = 0.9f - fmodf(ones_offset_poly,10)/10.0f,
		poly_ones_tex[3] = 0.9f - fmodf(ones_offset_poly,10)/10.0f,
		poly_ones_tex[5] = 1.0f - fmodf(ones_offset_poly,10)/10.0f,
		poly_ones_tex[7] = 1.0f - fmodf(ones_offset_poly,10)/10.0f;

		glTexCoordPointer(2, GL_FLOAT, 0, poly_ones_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();

		glPushMatrix();
		x_pos -= 0.35;
		glTranslatef(x_pos, y_pos, z_pos);
		if (tens_offset_poly < floorf(poly_counter_float/10.0f)) {
			tens_offset_poly += 0.125f*(floorf(poly_counter_float/10.0f) - tens_offset_poly);
		}
		
		poly_tens_tex[1] = 0.9f - fmodf(tens_offset_poly,10)/10.0f,
		poly_tens_tex[3] = 0.9f - fmodf(tens_offset_poly,10)/10.0f,
		poly_tens_tex[5] = 1.0f - fmodf(tens_offset_poly,10)/10.0f,
		poly_tens_tex[7] = 1.0f - fmodf(tens_offset_poly,10)/10.0f;
		
		glTexCoordPointer(2, GL_FLOAT, 0, poly_tens_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
		glPushMatrix();
		x_pos -= 0.35;
		glTranslatef(x_pos, y_pos, z_pos);
		if (huns_offset_poly < floorf(poly_counter_float/100.0f)) {
			huns_offset_poly += 0.125*(floorf(poly_counter_float/100.0f) - huns_offset_poly);
		}
		
		poly_huns_tex[1] = 0.9f - fmodf(huns_offset_poly,10)/10.0f,
		poly_huns_tex[3] = 0.9f - fmodf(huns_offset_poly,10)/10.0f,
		poly_huns_tex[5] = 1.0f - fmodf(huns_offset_poly,10)/10.0f,
		poly_huns_tex[7] = 1.0f - fmodf(huns_offset_poly,10)/10.0f;
		
		glTexCoordPointer(2, GL_FLOAT, 0, poly_huns_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
	}

	y_pos -= 0.67;
	// Draw words found
	{
		static GLfloat words_ones_tex[] = {
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
		};
		
		static GLfloat words_tens_tex[] = {
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
		};
		
		static GLfloat words_huns_tex[] = {
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
		};
		
		glPushMatrix();
		x_pos = 0.35;
		glTranslatef(x_pos, y_pos, z_pos);
		float num_words_avail_float = (float)num_words_avail;
		if (ones_offset_words < num_words_avail_float) {
			score_animating = YES;
			ones_offset_words += 0.5f*(num_words_avail_float - ones_offset_words);
		} else {
			score_animating = NO;
		}
		
		words_ones_tex[1] = 0.9f - fmodf(ones_offset_words,10)/10.0f,
		words_ones_tex[3] = 0.9f - fmodf(ones_offset_words,10)/10.0f,
		words_ones_tex[5] = 1.0f - fmodf(ones_offset_words,10)/10.0f,
		words_ones_tex[7] = 1.0f - fmodf(ones_offset_words,10)/10.0f;

		glTexCoordPointer(2, GL_FLOAT, 0, words_ones_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
		
		glPushMatrix();
		x_pos -= 0.35;
		glTranslatef(x_pos, y_pos, z_pos);
		if (tens_offset_words < floorf(num_words_avail_float/10.0f)) {
			tens_offset_words += 0.25f*(floorf(num_words_avail_float/10.0f) - tens_offset_words);
		}
		
		words_tens_tex[1] = 0.9f - fmodf(tens_offset_words,10)/10.0f,
		words_tens_tex[3] = 0.9f - fmodf(tens_offset_words,10)/10.0f,
		words_tens_tex[5] = 1.0f - fmodf(tens_offset_words,10)/10.0f,
		words_tens_tex[7] = 1.0f - fmodf(tens_offset_words,10)/10.0f;
		
		glTexCoordPointer(2, GL_FLOAT, 0, words_tens_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
		glPushMatrix();
		x_pos -= 0.35;
		glTranslatef(x_pos, y_pos, z_pos);
		if (huns_offset_words < floorf(num_words_avail_float/100.0f)) {
			huns_offset_words += 0.125*(floorf(num_words_avail_float/100.0f) - huns_offset_words);
		}
		
		words_huns_tex[1] = 0.9f - fmodf(huns_offset_words,10)/10.0f,
		words_huns_tex[3] = 0.9f - fmodf(huns_offset_words,10)/10.0f,
		words_huns_tex[5] = 1.0f - fmodf(huns_offset_words,10)/10.0f,
		words_huns_tex[7] = 1.0f - fmodf(huns_offset_words,10)/10.0f;
		
		glTexCoordPointer(2, GL_FLOAT, 0, words_huns_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
	}
	
	y_pos -= 0.67;
	// Draw points found
	{
		static GLfloat points_ones_tex[] = {
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
		};
		
		static GLfloat points_tens_tex[] = {
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
		};
		
		static GLfloat points_huns_tex[] = {
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
		};
		
		static GLfloat points_thous_tex[] = {
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
		};
		
		static GLfloat points_ten_thous_tex[] = {
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
			kTimeOffsetX1, 0.0,
			kTimeOffsetX2, 0.0,
		};

		glPushMatrix();
		x_pos = 0.54;
		glTranslatef(x_pos, y_pos, z_pos);
		glScalef(0.8, 1.0, 1.0);
		float points_avail_display_float = (float)points_avail_display;
		if (ones_offset_points < points_avail_display_float) {
			score_animating = YES;
			ones_offset_points += 0.25*(points_avail_display_float - ones_offset_points);
		} else {
			score_animating = NO;
		}

		points_ones_tex[1] = 0.9f - fmodf(ones_offset_points,10)/10.0f,
		points_ones_tex[3] = 0.9f - fmodf(ones_offset_points,10)/10.0f,
		points_ones_tex[5] = 1.0f - fmodf(ones_offset_points,10)/10.0f,
		points_ones_tex[7] = 1.0f - fmodf(ones_offset_points,10)/10.0f;

		glTexCoordPointer(2, GL_FLOAT, 0, points_ones_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
		
		glPushMatrix();
		x_pos -= 0.27;
		glTranslatef(x_pos, y_pos, z_pos);
		glScalef(0.8, 1.0, 1.0);
		if (tens_offset_points < floorf(points_avail_display_float/10.0f)) {
			tens_offset_points += 0.25*(floorf(points_avail_display_float/10.0f) - tens_offset_points);
		}
		
		points_tens_tex[1] = 0.9f - fmodf(tens_offset_points,10)/10.0f,
		points_tens_tex[3] = 0.9f - fmodf(tens_offset_points,10)/10.0f,
		points_tens_tex[5] = 1.0f - fmodf(tens_offset_points,10)/10.0f,
		points_tens_tex[7] = 1.0f - fmodf(tens_offset_points,10)/10.0f;
		
		glTexCoordPointer(2, GL_FLOAT, 0, points_tens_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();

		glPushMatrix();
		x_pos -= 0.27;
		glTranslatef(x_pos, y_pos, z_pos);
		glScalef(0.8, 1.0, 1.0);
		if (huns_offset_points < floorf(points_avail_display_float/100.0f)) {
			huns_offset_points += 0.25f*(floorf(points_avail_display_float/100.0f) - huns_offset_points);
		}

		points_huns_tex[1] = 0.9f - fmodf(huns_offset_points,10)/10.0f,
		points_huns_tex[3] = 0.9f - fmodf(huns_offset_points,10)/10.0f,
		points_huns_tex[5] = 1.0f - fmodf(huns_offset_points,10)/10.0f,
		points_huns_tex[7] = 1.0f - fmodf(huns_offset_points,10)/10.0f;
		
		glTexCoordPointer(2, GL_FLOAT, 0, points_huns_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();

		glPushMatrix();
		x_pos -= 0.27;
		glTranslatef(x_pos, y_pos, z_pos);
		glScalef(0.8, 1.0, 1.0);
		if (thous_offset_points < floorf(points_avail_display_float/1000.0f)) {
			thous_offset_points += 0.25*(floorf(points_avail_display_float/1000.0f) - thous_offset_points);
		}

		points_thous_tex[1] = 0.9f - fmodf(thous_offset_points,10)/10.0f,
		points_thous_tex[3] = 0.9f - fmodf(thous_offset_points,10)/10.0f,
		points_thous_tex[5] = 1.0f - fmodf(thous_offset_points,10)/10.0f,
		points_thous_tex[7] = 1.0f - fmodf(thous_offset_points,10)/10.0f;
		
		glTexCoordPointer(2, GL_FLOAT, 0, points_thous_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
		
		glPushMatrix();
		x_pos -= 0.27;
		glTranslatef(x_pos, y_pos, z_pos);
		glScalef(0.8, 1.0, 1.0);
		if (ten_thous_offset_points < floorf(points_avail_display_float/10000.0f)) {
			ten_thous_offset_points += 0.25*(floorf(points_avail_display_float/10000.0f) - ten_thous_offset_points);
		}
		
		points_ten_thous_tex[1] = 0.9f - fmodf(ten_thous_offset_points,10)/10.0f,
		points_ten_thous_tex[3] = 0.9f - fmodf(ten_thous_offset_points,10)/10.0f,
		points_ten_thous_tex[5] = 1.0f - fmodf(ten_thous_offset_points,10)/10.0f,
		points_ten_thous_tex[7] = 1.0f - fmodf(ten_thous_offset_points,10)/10.0f;
		
		glTexCoordPointer(2, GL_FLOAT, 0, points_ten_thous_tex);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glPopMatrix();
	}
}

- (void) dealloc {
#ifdef verbose
NSLog(@"into  dealloc  of %@",[self class]);
#endif

	[self stopTransitionAnimation];
	[self stopGameAnimation];
	
	[alphabetArray release];
	alphabetArray = nil;
	[commonLettersArray release];
	commonLettersArray = nil;
	[uncommonLettersArray release];
	uncommonLettersArray = nil;
	[polyhedron release];
	polyhedron = nil;
	[touchAngleArray release];
	touchAngleArray = nil;
	[touchXArray release];
	touchXArray = nil;
	[touchYArray release];
	touchYArray = nil;
	[touchTimeArray release];
	touchTimeArray = nil;
	[previousTouchedPoly release];
	[polyInfo release];
	[valueArray release];
	[timeHistory release];
	[touchedPolygonsArray release];
	[wordArray release];
	[availableWords release];
	[availableWordScores release];
	[wordsFound release];
	[wordsFoundOpponent release];
	[wordScores release];
	[wordScoresOpponent release];
	[wordString release];
	[containerView release];
	[wordsDB release];
	[waitingAlert release];
	[opponentWordsToDisplay release];
	[pullDataController release];
	[pushDataController release];
	
	for (int kk = 0; kk < 10; kk++) {
		free(dyn_texture_coord_ptr[kk]);
		free(rot_texture_coord_ptr[kk]);
		free(scale_texture_coord_ptr[kk]);
	}
	free(dyn_texture_coord_ptr);
	free(rot_texture_coord_ptr);
	free(scale_texture_coord_ptr);
	[super dealloc];
}

- (void) initializeIvarsWithFrame:(CGRect) f {
	dyn_texture_coord_ptr = (float **)malloc(sizeof(float *)*num_polygon_types);
	rot_texture_coord_ptr = (float **)malloc(sizeof(float *)*num_polygon_types);
	scale_texture_coord_ptr = (float **)malloc(sizeof(float *)*num_polygon_types);
	axes_vertex_coord = (GLfloat *)malloc(sizeof(GLfloat));
	axes_cap_vertex_coord = (GLfloat *)malloc(sizeof(GLfloat));
	for (int kk = 0; kk < num_polygon_types; kk++) {
		dyn_texture_coord_ptr[kk] = (float *)malloc(sizeof(float));
		rot_texture_coord_ptr[kk] = (float *)malloc(sizeof(float));
		scale_texture_coord_ptr[kk] = (float *)malloc(sizeof(float));
	}
	
	self.multipleTouchEnabled = YES;
	self.exclusiveTouch = NO;
	self.clipsToBounds = YES;
	
	gTrackBallRotation[0] = gTrackBallRotation[1] = gTrackBallRotation[2] = gTrackBallRotation[3] = 0.0;
	
	self.wordString = [[NSMutableString alloc] initWithCapacity:10];
	wordsFound = [[NSMutableArray alloc] init];
	wordsFoundOpponent = [[NSMutableArray alloc] init];
	opponentWordsToDisplay = [[NSMutableArray alloc] init];
	wordScores = [[NSMutableArray alloc] init];
	wordScoresOpponent = [[NSMutableArray alloc] init];
	oldWordsFound = [[NSMutableArray alloc] init];
	match = NO;
	lookingUpWordsQ = NO;
//	paused = YES;
	show_get_ready = YES;
	
	wordArray = [[NSMutableArray alloc] init];
	pullDataController = [[PullDataController alloc] init];
	pushDataController = [[PushDataController alloc] init];
	
	availableWords = nil;
	availableWordScores = nil;
	
	touchedPolygonsArray = [[NSMutableArray alloc] init];
	submittingPolygonsArray = [[NSMutableArray alloc] init];
	submittingPolygonsValuesArray = [[NSMutableArray alloc] init];
	
	score = 0;
	opponent_score = 0;
	opponent_ready = NO;
	animationInterval = 1.0 / 30.0;
	bounds = [self bounds];
	self.frame = f;
	dragging = FALSE;
	score_animating = NO;
	self.tag = 2;
#ifdef MATH
	base_value = irandom(5, 30);
#endif
	zoom_factor = 1;
	time_left = kTimeToCompleteStatic;
	
	[self resetMatchColor];
	
	last_submit_time = 0.0f;
	
	touchAngleArray = [NSMutableArray new];
	touchXArray = [NSMutableArray new];
	touchYArray = [NSMutableArray new];
	touchTimeArray = [NSMutableArray new];
	free_wheeling = NO;
	submitting = 0;
	submitted = NO;
	
	touchedLetterView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 60.0, appController.screen_rect.size.width, 40.0)];
	touchedLetterView.adjustsFontSizeToFitWidth = YES;
	touchedLetterView.backgroundColor = [UIColor clearColor];
	touchedLetterView.font = [UIFont fontWithName:@"Helvetica" size:36];
	touchedLetterView.text = @"";
	touchedLetterView.textColor = [UIColor whiteColor];
	touchedLetterView.textAlignment = UITextAlignmentLeft;
	touchedLetterView.hidden = YES;

	textures = [appController getTextures];
	gTrackBallRotation[0] = gTrackBallRotation[1] = gTrackBallRotation[2] = gTrackBallRotation[3] = 0.0;
}

#pragma mark AlertView delegates

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
#ifdef verbose
NSLog(@"into  alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex  of %@",[self class]);
#endif
	if (alertView.tag == 1) {
		
		if (points_avail < 3000 && appController.mode == kStaticScoredMode) {
			[appController resetGame];
			[appController startGame];
		} 
	} else if (alertView.tag == 2) {
		if (buttonIndex == 0) {
			[appController resetGame];
			[appController.aNavigationController popToRootViewControllerAnimated:YES];
		}
	} else if (alertView.tag == 3 && !appController.resign_state) {
		[self startClock];
	} else if (alertView.tag == 4) {
		[self startClock];
	} else if (alertView.tag == 5) {
		[self startClock];
	} else if (alertView.tag == 6) {
		[self startClock];
	}

}

@end

//#if LANGUAGE == 2
//alphabetArray = [[NSArray alloc] initWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"Ä", @"Ö", @"Ü", @"ß", nil];
//commonLettersArray = [[NSArray alloc] initWithObjects:@"A", @"E", @"I", @"O", @"T", @"N", nil];
//uncommonLettersArray = [[NSArray alloc] initWithObjects:@"J", @"Q", @"X", @"Z", @"Ä", @"Ö", @"Ü", @"ß", nil];
////												A		B		C		D		E		F		G		H		I		J		K		L		M		N		O		P		Q		R		S		T		U		V		W		X		Y		Z		Ä		Ö		Ü		ß
//valueArray = [[NSArray alloc] initWithObjects:INT(1), INT(3), INT(2), INT(2), INT(1), INT(2), INT(2), INT(1), INT(1), INT(4), INT(3), INT(2), INT(2), INT(1), INT(1), INT(3), INT(4), INT(1), INT(1), INT(1), INT(2), INT(3), INT(2), INT(4), INT(3), INT(4), INT(4), INT(4), INT(4), INT(4), nil];
//#endif
//#if LANGUAGE == 3
//alphabetArray = [[NSArray alloc] initWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"À", @"Â", @"Ç", @"È", @"É", @"Ê", @"Ë", @"Î", @"Ï", @"Ô", @"Û", @"Ù", @"Ü", nil];
//commonLettersArray = [[NSArray alloc] initWithObjects:@"A", @"E", @"I", @"O", @"T", @"N", @"R", @"L", nil];
//uncommonLettersArray = [[NSArray alloc] initWithObjects:@"J", @"Q", @"X", @"Z", @"K", @"À", @"Â", @"Ç", @"È", @"Ê", @"Ë", @"Î", @"Ï", @"Ô", @"Û", @"Ù", @"Ü", nil];
////												A		B		C		D		E		F		G		H		I		J		K		L		M		N		O		P		Q		R		S		T		U		V		W		X		Y		Z
//valueArray = [[NSArray alloc] initWithObjects:INT(1), INT(3), INT(2), INT(2), INT(1), INT(2), INT(2), INT(1), INT(1), INT(4), INT(3), INT(2), INT(2), INT(1), INT(1), INT(3), INT(4), INT(1), INT(1), INT(1), INT(2), INT(3), INT(2), INT(4), INT(3), INT(4), nil];
//#endif	

