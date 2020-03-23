//
//  AlphaHedraViewController.m
//  AlphaHedra
//
//  Created by Eric Mockensturm on 7/28/09.
//  Copyright 2009 Small Feats Software. All rights reserved.
//

#import "AlphaHedraViewController.h"
#import "AlphaHedraView.h"
#import "MenuView.h"
#import "HighScores.h"
//#import "OAIAdManager.h"
#import "trackball.h"
#import "Constants.h"
#import "Textures.h"
#include "random.h"
#include "Polygons.h"
#include "PostGameDataController.h"
#include "GetGameDataController.h"
#import <OpenGLES/EAGLDrawable.h>

@implementation AlphaHedraViewController

@synthesize polyhedraInfo, game_state;

- (id) init {
#ifdef verbose
NSLog(@"into  init  of %@",[self class]);
#endif

	if ((self = [super init])) {
		appController = (AppController *)[[UIApplication sharedApplication] delegate];
		alphaHedraView = (AlphaHedraView *)(appController.alphaHedraView);
		self.view = alphaHedraView;
	}
	return self;
}

- (void) loadView {
#ifdef verbose
NSLog(@"into  loadView  of %@",[self class]);
#endif

	[super loadView];
}

- (void) viewDidLoad {
#ifdef verbose
NSLog(@"into  viewDidLoad  of %@",[self class]);
#endif

	[super viewDidLoad];
}

- (void) didReceiveMemoryWarning {
#ifdef verbose
NSLog(@"into  didReceiveMemoryWarning  of %@",[self class]);
#endif

	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	NSLog(@"AlphaHedraView got a memory warning.");
	// Release any cached data, images, etc that aren't in use.
}

- (void) viewDidAppear:(BOOL)a {
#ifdef verbose
NSLog(@"into  viewDidAppear:(BOOL)a  of %@",[self class]);
#endif

	[EAGLContext setCurrentContext:appController.context];
	[appController destroyFramebuffer];
	[appController createFramebufferWithView:self.view];
	
	[self.view setNeedsLayout];
	[self.view setNeedsDisplay];
	
	[super viewDidAppear:a];
}

- (void) viewDidDisappear:(BOOL)a {
#ifdef verbose
NSLog(@"into  viewDidDisappear:(BOOL)a  of %@",[self class]);
#endif

	for (UIView *theView in [self.view subviews]) {
		theView.hidden = YES;
	}
	
	[super viewDidDisappear:a];
}

- (void) viewWillAppear:(BOOL)a {
#ifdef verbose
NSLog(@"into  viewWillAppear:(BOOL)a  of %@",[self class]);
#endif

//	[self.view addSubview:appController.adManager.view];
//	appController.adManager.delegate = appController;
//	[appController.adManager requestRefreshAd];
//	[appController.adManager updateView];
	
	[self startGame];
	[alphaHedraView stopClock];
	[self loadTextures];

	if (appController.mode == kTwoPlayerServerMode) {
	}
	
	[appController setupAccelerometerWithFrequency:0.1f];
	
	[super viewWillAppear:a];
}

- (void) viewWillDisappear:(BOOL)a {
	// stop the game animation loop
	[alphaHedraView stopGameAnimation];

	//Clear framebuffer
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	[EAGLContext setCurrentContext:appController.context];
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, appController.viewRenderbuffer);
	[appController.context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
}	

#ifdef JEWEL

- (void) startJewelGame {
#ifdef verbose
NSLog(@"into  startJewelGame  of %@",[self class]);
#endif

	[alphaHedraView selectPolyhedron:appController.polyhedraInfo];
	[alphaHedraView assignColorToAllPolygons];
	[alphaHedraView checkAllPolygons];
//	alphaHedraView.paused = NO;
	[appController loadTextures];
	alphaHedraView.tex_scale = 0.75;
	
	alphaHedraView.animation_start_time = get_time_of_day();
	[alphaHedraView startJewelGameAnimation];
}

#endif

#ifdef MATH

- (void) startMathGame {
#ifdef verbose
NSLog(@"into  startMathGame  of %@",[self class]);
#endif

	[alphaHedraView selectPolyhedron:appController.polyhedraInfo];
	[alphaHedraView assignLetterToAllPolygons];
//	alphaHedraView.paused = NO;
	[appController loadTextures];
	
	alphaHedraView.animation_start_time = get_time_of_day();
	[alphaHedraView startMathGameAnimation];
}

#endif

- (void) startFindingWords {
#ifdef verbose
NSLog(@"into  startFindingWords  of %@",[self class]);
#endif

	if (!wordThread) {
		wordThread = [[NSThread alloc] initWithTarget:self selector:@selector(createThreadWithRunLoop) object:nil];
		wordThread.name = @"wordThread";
		[wordThread start];
	}
			
	[alphaHedraView performSelector:@selector(findAllWords) onThread:wordThread withObject:nil waitUntilDone:NO];
	[alphaHedraView startTransitionAnimation];
}

- (void) startFindingWordsToPoints:(int)points {
#ifdef verbose
NSLog(@"into  startFindingWordsToPoints:(int)points  of %@",[self class]);
#endif

	if (!wordThread) {
		wordThread = [[NSThread alloc] initWithTarget:self selector:@selector(createThreadWithRunLoop) object:nil];
		wordThread.name = @"wordThread";
		[wordThread start];
	}
	
	[alphaHedraView performSelector:@selector(findWordsToPoints:) onThread:wordThread withObject:INT(points) waitUntilDone:NO];
}

- (void) loadTextures {
	
#ifdef verbose
NSLog(@"into  loadTextures  of %@",[self class]);
#endif

	int local_bg_texture = 0;
	NSArray *backgroundTextureArray = [Textures getBackgroundTextures];
	if (!appController.bg_texture) {
		local_bg_texture = irandom(0, [backgroundTextureArray count] + 2);
	} else {
		local_bg_texture = appController.bg_texture;
	}
	
	for (int ii = 0; ii < num_polygon_types + 1; ii++) {
		float _font_size = 40.0f;
		int sides = 3 + ii;
		BOOL text_outline = YES;
		// if there are this type of polygon and the texture doesn't already exist load it...
		// need to do a further check to see if the texture is of the correct size
		if (alphaHedraView.polyhedron.face_num[ii]) {
			if (!appController.texture_exists[ii+3]) {
				int tex_size = 1024;
				if (appController.level == 27) {
	//				if (ii > 4) _font_size += 10.0f;
					_font_size *= (float)tex_size/512;
					_font_size -= 3.0f;
					sides = 203;
				} else if (appController.level == 24) {
					_font_size *= (float)tex_size/512;
					if (ii == 13) sides = 103;
					else sides = 105;
				} else if (appController.level == 23) {
					_font_size *= (float)tex_size/512;
					sides = 304;
				} else if (appController.level == 17) {
					if (ii == 7) {text_outline = YES;tex_size = 1024;_font_size += 10.0f;}
					else tex_size = 512;
					_font_size *= (float)tex_size/512;
				} else if (appController.level == 9) {
					tex_size = 512;
					_font_size *= (float)tex_size/512;
				} else if (appController.level == 7) {
					if (ii == 0) {text_outline = YES;tex_size = 512;_font_size -= 10.0f;}
					else tex_size = 1024;
					_font_size *= (float)tex_size/512;
				} else if (appController.level == 6) {
					tex_size = 1024;
					_font_size *= (float)tex_size/512;
					sides = 104;
				} else if (appController.level == 5) {
					tex_size = 1024;
					_font_size *= (float)tex_size/512;
					sides = 204;
				} else if (appController.level == 4) {
					tex_size = 512;
					if (ii > 4) _font_size += 10.0f;
					_font_size *= (float)tex_size/512;
				} else if (appController.level == 3) {
					if (ii == 0 || ii == 1) tex_size = 512;
					else tex_size = 512;
					if (ii > 4) _font_size += 10.0f;
					_font_size *= (float)tex_size/512;
				} else if (appController.level == 2) {
					if (ii == 5) tex_size = 1024;
					else tex_size = 512;
					if (ii > 4) _font_size += 10.0f;
					_font_size *= (float)tex_size/512;
				} else if (appController.level == 1) {
						tex_size = 512;
					if (ii > 4) _font_size += 10.0f;
					_font_size *= (float)tex_size/512;
				} else {
					if (ii > 4) _font_size += 10.0f;
					_font_size *= (float)tex_size/512;
				}
				[Textures generateGLAlphabetTexture:appController.alphabetArray intoLocation:appController.textures[3+ii] withTag:2 ofSize:tex_size withFont:[UIFont fontWithName:[appController.fontsArray objectAtIndex:appController.font_selected] size:_font_size] withOutline:text_outline withSides:sides withBGTexture:local_bg_texture];
//				[Textures loadTextureWithString:@"wwwwwwww" intoLocation:appController.textures[3+ii] withTag:0 inRect:CGRectMake(0,0,320,75)];
				appController.texture_exists[3+ii] = YES;
			}
		} else { // if we don't need the texture delete it
			glDeleteTextures(1, &appController.textures[ii+3]);
			appController.texture_exists[ii+3] = NO;
		}
	}
}	

- (void) startGame {
#ifdef verbose
NSLog(@"into  startGame  of %@",[self class]);
#endif

	if (game_state == kGameStart || game_state == kGameRestart) {
		alphaHedraView.wordsDB = [[Words alloc] initializeWithDB:[appController getWordDBPath] delegate:((AlphaHedraView *)self.view)];
		if (game_state != kGameRestart) {
			[alphaHedraView selectPolyhedron:appController.polyhedraInfo];
			[alphaHedraView assignLetterToAllPolygons];
		}
				
//		alphaHedraView.paused = NO;
//		game_state = kGameContinue;
				
		if (appController.checking == 1 && (appController.mode == kStaticTimedMode || appController.mode == kStaticScoredMode)) {
#if TARGET_IPHONE_SIMULATOR
			[alphaHedraView findAllWords];
#else			
			[self startFindingWords];
#endif
		} else if (appController.mode == kStaticScoredMode) {
			[self startFindingWordsToPoints:3000];
		} else if (appController.mode == kTwoPlayerClientMode) {
			alphaHedraView.show_get_ready = YES;
			[alphaHedraView stopTransitionAnimation];
			[alphaHedraView waitForOpponent];
		} else if (appController.mode == kTwoPlayerServerMode) {
			NSArray *polygonsArray = alphaHedraView.polyhedron.polygons;
			NSMutableString *polygonLetters = [NSMutableString stringWithCapacity:[polygonsArray count]];
			for (Polygons *poly in polygonsArray) {
				[polygonLetters appendString:poly.letter];
			}
			
			PostGameDataController *postController = [[PostGameDataController alloc] init];
			[postController startSend:[NSArray arrayWithObjects:polygonLetters, appController.polyhedraInfo, INT(appController.mode), INT(irandom(0, INT_MAX)), nil]];
			[postController release];
			
			UIAlertView *serverAlert = [[UIAlertView alloc] initWithTitle:@"Two Player Game" message:[NSString stringWithFormat:@"Tell your opponent to enter the game id:\n%u",appController.game_id] delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
			serverAlert.delegate = self;
			[serverAlert show];
			serverAlert.tag = 70;
			[serverAlert release];
		} else {
			alphaHedraView.show_get_ready = YES;
			[alphaHedraView stopTransitionAnimation];
			[alphaHedraView startGameAnimation];
		}
	}
	
	[appController.aNavigationController setNavigationBarHidden:YES animated:NO];
	
	((HighScores *)appController.highScores).mode = appController.mode;
	alphaHedraView.high_score = [[appController.highScores getHighScoreForPolyhedron:[[appController.polyhedraInfo objectForKey:@"polyID"] intValue] ] intValue];
	alphaHedraView.fastest_time = [[appController.highScores getFastestTimeForPolyhedron:[[appController.polyhedraInfo objectForKey:@"polyID"] intValue] ] floatValue];
	
	alphaHedraView.animation_start_time = get_time_of_day();
	
	if (game_state == kGameContinue) {
		[alphaHedraView checkLevelCompleted];
//		[alphaHedraView startGameAnimation];
	}	
}

- (void) createThreadWithRunLoop {
#ifdef verbose
NSLog(@"into  createThreadWithRunLoop  of %@",[self class]);
#endif

	pool = [NSAutoreleasePool new];
	NSRunLoop *theRL = [NSRunLoop currentRunLoop];
	[NSThread setThreadPriority:1.0];
//	NSLog(@"thread = %@", [NSThread currentThread].name);
	[NSTimer scheduledTimerWithTimeInterval:100.0 target:self selector:@selector(drainThreadPool) userInfo:nil repeats:YES];
	[theRL run];
	[pool drain];
}

- (void) drainThreadPool {//:(NSTimer *)theTimer {
#ifdef verbose
NSLog(@"into  drainThreadPool {//:(NSTimer *)theTimer  of %@",[self class]);
#endif

//	NSLog(@"thread = %@", [NSThread currentThread].name);
	[pool drain];
}

- (void) dealloc {
#ifdef verbose
NSLog(@"into  dealloc  of %@",[self class]);
#endif

	[appController release];
	[buttonTitle release];
	[touchedLetterView release];
	[polyhedraInfo release];
	[wordThread release];
	[pool release];
	[alphaHedraView release];
	[super dealloc];
}

#pragma mark UIAlertView delegates

- (void) alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (!appController.connection_failed) {
		[alphaHedraView waitForOpponent];
	}
	else {
		[appController.aNavigationController popToRootViewControllerAnimated:YES];
	}
}

@end
