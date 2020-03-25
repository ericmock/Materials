
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "LevelsView.h"
#import "LevelsViewController.h"
#include "trackball.h"
#include "random.h"
#include "AppController.h"
#include "Polyhedron.h"
#include "Textures.h"
#include "Polygons.h"
#include "SoundEffect.h"
#include "Constants.h"

@interface LevelsView (private)

- (void)initGLES;
//- (BOOL)createFramebuffer;
//- (void)destroyFramebuffer;

@end

@implementation LevelsView

@synthesize animationInterval, polyhedronArray, textures;
@synthesize sq_centroids, viewController;
@synthesize dragging, level;
@synthesize appController;

+(Class)layerClass {
	return [CAEAGLLayer class];
}

//- (BOOL)createFramebuffer {
//	GLenum err;
//	glGenFramebuffersOES(1, &viewFramebuffer);
//	glGenRenderbuffersOES(1, &viewRenderbuffer);
//#ifdef debug
//	err = glGetError();
//	if(err) {
//		NSLog(@"%x error 1", err);
//	}
//#endif	
//	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
//	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
//#ifdef debug
//	err = glGetError();
//	if(err) {
//		NSLog(@"%x error 2", err);
//	}
//#endif
//	BOOL response = [appController.context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
//	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
//#ifdef debug
//	err = glGetError();
//	if(err) {
//		NSLog(@"%x error 3", err);
//	}
//#endif
//	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
//	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);	
//#ifdef debug
//	err = glGetError();
//	if(err) {
//		NSLog(@"%x error 4", err);
//	}
//#endif
//	glGenRenderbuffersOES(1, &depthRenderbuffer);
//	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
//#ifdef debug
//	err = glGetError();
//	if(err) {
//		NSLog(@"%x error 5", err);
//	}
//#endif
//	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
//	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
//#ifdef debug
//	err = glGetError();
//	if(err) {
//		NSLog(@"%x error 6", err);
//	}
//#endif
//	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
//		if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) == GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_OES) {
//			NSLog(@"GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_OES");
//		}
//		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
//		return NO;
//	}
//	
//	return YES;
//}
//
//- (void)destroyFramebuffer {
//	glDeleteFramebuffersOES(1, &viewFramebuffer);
//	viewFramebuffer = 0;
//	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
//	viewRenderbuffer = 0;
//	
//	if(depthRenderbuffer) {
//		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
//		depthRenderbuffer = 0;
//	}
//}

-(id)initWithFrame:(CGRect)frame {
#ifdef verbose
NSLog(@"into initWithFrame:(CGRect)frame  of %@",[self class]);
#endif

	self = [super initWithFrame:frame];
	if(self != nil) {
		appController  = (AppController *)[[UIApplication sharedApplication] delegate];
		touchAngleArray = [NSMutableArray new];
		touchTimeArray = [NSMutableArray new];
		polyhedronArray = [NSMutableArray new];
		gTrackBallRotation[1] = 1.0;
		worldRotation[1] = 1.0;
		lockedPolyhedronInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"Locked", @"name", INT(0), @"polyID", [NSArray arrayWithObjects:[NSNumber numberWithBool:TRUE],[NSNumber numberWithBool:TRUE],[NSNumber numberWithBool:TRUE],[NSNumber numberWithBool:TRUE],nil], @"completed", INT(0), @"level", nil];
	}
	return self;
}

- (BOOL)initGLES {
#ifdef verbose
NSLog(@"into initGLES  of %@",[self class]);
#endif

	CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;

	eaglLayer.opaque = YES;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
										kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
										nil];

	[appController destroyFramebuffer];
	if(!appController.context || ![EAGLContext setCurrentContext:appController.context] || ![appController createFramebufferWithView:self]) {
		[self release];
		return FALSE;
	}

	textures = [appController getTextures];
	glDisable(GL_LIGHTING);
	glEnableClientState(GL_VERTEX_ARRAY);
	glDisable(GL_POINT_SMOOTH);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_NORMALIZE);
	glEnable(GL_CULL_FACE);

	glEnable(GL_TEXTURE_2D);
	glActiveTexture(GL_TEXTURE0);
	
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f); 
	
	// Set a blending function to use
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	// Enable blending
	glEnable(GL_BLEND);
	
	glClear(GL_COLOR_BUFFER_BIT);
	glEnable(GL_DEPTH_TEST);

	gTrackBallRotation[0] = 5.0;
	gTrackBallRotation[2] = gTrackBallRotation[3] = 0.0;
	gTrackBallRotation[1] = 1.0;
	
	worldRotation[0] = 0.0;
	worldRotation[1] = 1.0;
	worldRotation[2] = 0.0;
	worldRotation[3] = 0.0;

	[self setRotationAngle:gTrackBallRotation[0] X:gTrackBallRotation[1] Y:gTrackBallRotation[2] Z:gTrackBallRotation[3]];
	[self setWorldRotationAngle:0.0 X:1.0 Y:0.0 Z:0.0];
	[self initializeGL];
	return TRUE;
}

- (void)initializeGL {
#ifdef verbose
NSLog(@"into initializeGL  of %@",[self class]);
#endif

//	if (polyhedron) [polyhedron release];
//	polyhedron = [[Polyhedra alloc] initializeWithInformation:[NSArray arrayWithObjects:@"",[NSNumber numberWithInt:0],[NSNumber numberWithBool:YES],nil]];
	
	// set polygon colors with hue based on the number of sides
	{
		for (int kk = 0; kk < num_polygon_types + 1; kk++) {
			UIColor *color = [UIColor colorWithHue:(CGFloat)kk/((CGFloat)(num_polygon_types + 2)) saturation:1.0f brightness:1.0f alpha:1.0f];
			const CGFloat *rgb = CGColorGetComponents(color.CGColor);
			
			red[kk] = rgb[0];
			green[kk] = rgb[1];
			blue[kk] = rgb[2];
		}
	}
		
	animation_start_time = get_time_of_day();
	animating = YES;

//	animationInterval = 1.0 / 60.0;
	bounds = [self bounds];
	dragging = FALSE;
//	free_wheeling = NO;
	
}

- (void)layoutSubviews {
#ifdef verbose
NSLog(@"into layoutSubviews  of %@",[self class]);
#endif

	[EAGLContext setCurrentContext:appController.context];
	// for some reason the frame buffer doesn't always get created
	[appController destroyFramebuffer];
	[appController createFramebufferWithView:self];
	[self drawView];
}

- (void)startAnimation {
#ifdef verbose
NSLog(@"into startAnimation  of %@",[self class]);
#endif

	if (levelsAnimationTimer) [levelsAnimationTimer invalidate];
	levelsAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:1/60.0f target:self selector:@selector(drawView) userInfo:nil repeats:YES];
	animating = YES;
//	omega = 1000.0f;
//	[self drawView];
}

- (void)stopAnimation {
#ifdef verbose
NSLog(@"into stopAnimation  of %@",[self class]);
#endif

	[levelsAnimationTimer invalidate];
	levelsAnimationTimer = nil;
}

//- (void)setWorldRotation:(float)angle {
//#ifdef debug
//NSLog(@"into setWorldRotation:(float)angle  of %@",[self class]);
//#endif
//
//	worldRotation[0] = angle;
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
#ifdef verbose
NSLog(@"into touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event  of %@",[self class]);
#endif

	[touchAngleArray removeAllObjects];
	[touchTimeArray removeAllObjects];
	
	if (free_wheeling || animating) {
		free_wheeling = NO;
		animating = NO;
		[self endSpin];
	}
	
	NSArray *touchArray = [touches allObjects];
	UITouch *t = [touchArray objectAtIndex:0];
	CGPoint touchPos = [t locationInView:t.view];
	
	prevTouchPos = touchPos;
	touchPos.y = bounds.size.height - touchPos.y;
	startTrackball (bounds.size.width/2, touchPos.y, 0, 0, bounds.size.width, bounds.size.height);		
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
#ifdef verbose
NSLog(@"into touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event  of %@",[self class]);
#endif

	dragging = TRUE;
	
	NSArray *touchArray = [touches allObjects];
	
	UITouch *t = [touchArray objectAtIndex:0];
	CGPoint touchPos = [t locationInView:t.view];
	
	touchPos.y = bounds.size.height - touchPos.y;
	rollToTrackball (bounds.size.width/2, touchPos.y, gTrackBallRotation);
	[self setRotationAngle:gTrackBallRotation[0] X:gTrackBallRotation[1] Y:gTrackBallRotation[2] Z:gTrackBallRotation[3]];
	
	double touch_time = get_time_of_day();	
	[touchTimeArray addObject:[NSNumber numberWithDouble:touch_time]];
	[touchAngleArray addObject:[NSNumber numberWithFloat:gTrackBallRotation[0]]];
	
	prevTouchPos = touchPos;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
#ifdef verbose
NSLog(@"into touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event  of %@",[self class]);
#endif

	if (dragging) {
		int count = [touchTimeArray count];
		if (count>3) {
			float dt = (float)([[touchTimeArray objectAtIndex:(count-1)] doubleValue] - [[touchTimeArray objectAtIndex:(count-3)] doubleValue]);;
			omega = ([[touchAngleArray objectAtIndex:(count-1)] floatValue] - [[touchAngleArray objectAtIndex:(count-3)] floatValue])/dt;
		} else if (count>2) {
			float dt = (float)([[touchTimeArray objectAtIndex:(count-1)] doubleValue] - [[touchTimeArray objectAtIndex:(count-2)] doubleValue]);;
			omega = ([[touchAngleArray objectAtIndex:(count-1)] floatValue] - [[touchAngleArray objectAtIndex:(count-2)] floatValue])/dt;
		} else {
			omega = 0.0;
		}
		free_wheeling = YES;
	} else {
		NSArray *touchArray = [touches allObjects];
		UITouch *t = [touchArray objectAtIndex:0];
		CGPoint touchPos = [t locationInView:t.view];
		if (touchPos.x > 280.0 && ((viewController.stage < 7 && appController.unlocked) || (viewController.stage < 2 && appController.upgraded))) {
			going_to_next_level = YES;
		} else if (touchPos.x < 40.0 && viewController.stage > 1) {
			going_to_prev_level = YES;
		} else { // determine what level was tapped and start playing it
			float local_angle = worldRotationAngle;
			if (worldRotationAboutAxisX < 0.0f) {
				local_angle = 360.0 - worldRotationAngle;
			}
			if (local_angle > 62.0f && local_angle < 82.0f) {
				level = 1;
			} else if (local_angle > 134.0f && local_angle < 154.0f) {
				level = 2;
			} else if (local_angle > 206.0f && local_angle < 226.0f) {
				level = 3;
			} else if (local_angle > 278.0f && local_angle < 298.0f) {
				level = 4;
			} else {
				level = 0;
			}
			int base_level = (viewController.stage-1)*5;

			int mode = appController.mode;
			int index;
			BOOL complete;
#ifdef debug || test
			if (TRUE)
#else
			if ((base_level + (int)level - 1)<0)
#endif
			{
				complete = YES;
			} else {
				index = (base_level + (int)level - 1);
				NSDictionary *polyDict = [appController.polyhedronInfoArray objectAtIndex:index];
				complete = [[[polyDict objectForKey:@"completed"] objectAtIndex:mode] boolValue];
			}

			if (complete) {
//#endif
				[polyhedronArray removeAllObjects];
				[viewController.indicatorView startAnimating];
				appController.polyhedraInfo = [appController.polyhedronInfoArray objectAtIndex:(base_level + level)];
				if (!appController.game_view_initialized) {
					[appController initializeGame];
				}
				[appController resetGame];
				[appController performSelector:@selector(startGame) withObject:nil afterDelay:0.5];
			}
		}
	}
	dragging = FALSE;
}

- (uint)getLevel {
#ifdef verbose
NSLog(@"into getLevel  of %@",[self class]);
#endif

	GLfloat level_rotation[4] = {worldRotation[0],worldRotation[1],worldRotation[2],worldRotation[3]};
	
	addToRotationTrackball(gTrackBallRotation, level_rotation);
	if (level_rotation[1] > 0.0f) {
		if (level_rotation[0] > 62.0f && level_rotation[0] < 82.0f) {
			level = 1;
		} else if (level_rotation[0] > 134.0f && level_rotation[0] < 154.0f) {
			level = 2;
		} else if (level_rotation[0] > 206.0f && level_rotation[0] < 226.0f) {
			level = 3;
		} else if (level_rotation[0] > 278.0f && level_rotation[0] < 298.0f) {
			level = 4;
		} else {
			level = 0;
		}
	} else {
		if (level_rotation[0] > 62.0f && level_rotation[0] < 82.0f) {
			level = 4;
		} else if (level_rotation[0] > 134.0f && level_rotation[0] < 154.0f) {
			level = 3;
		} else if (level_rotation[0] > 206.0f && level_rotation[0] < 226.0f) {
			level = 2;
		} else if (level_rotation[0] > 278.0f && level_rotation[0] < 298.0f) {
			level = 1;
		} else {
			level = 0;
		}
	}
	return level;
}

- (void)endSpin {
#ifdef verbose
NSLog(@"into endSpin  of %@",[self class]);
#endif

	addToRotationTrackball(gTrackBallRotation, worldRotation);
	
	gTrackBallRotation[0] = gTrackBallRotation[2] = gTrackBallRotation[3] = 0.0f;
	gTrackBallRotation[1] = 1.0f;
	[self setRotationAngle:gTrackBallRotation[0] X:gTrackBallRotation[1] Y:gTrackBallRotation[2] Z:gTrackBallRotation[3]];
	[self setWorldRotationAngle:worldRotation[0] X:worldRotation[1] Y:worldRotation[2] Z:worldRotation[3]];
}

- (void)setRotationAngle:(float)angle X:(float)xAxis Y:(float)yAxis Z:(float)zAxis  {
//#ifdef debug
//NSLog(@"into setRotationAngle:(float)angle X:(float)xAxis Y:(float)yAxis Z:(float)zAxis   of %@",[self class]);
//#endif

	rotationAboutAxisX = xAxis;
	rotationAboutAxisY = yAxis;
	rotationAboutAxisZ = zAxis;
	rotationAngle = angle;
}

- (void)setWorldRotationAngle:(float)angle X:(float)xAxis Y:(float)yAxis Z:(float)zAxis {
//#ifdef debug
//NSLog(@"into setWorldRotationAngle:(float)angle X:(float)xAxis Y:(float)yAxis Z:(float)zAxis  of %@",[self class]);
//#endif

	worldRotationAboutAxisX = xAxis;
	worldRotationAboutAxisY = yAxis;
	worldRotationAboutAxisZ = zAxis;
	worldRotationAngle = angle;
}

- (void)drawView {
//#ifdef debug
//NSLog(@"into drawView  of %@",[self class]);
//#endif

	[EAGLContext setCurrentContext:appController.context];
#ifdef debug
	GLenum err;
	err = glGetError();
	if(err) {
		NSLog(@"%x error 1", err);
	}
#endif
	if(!appControllerSetup) {
		[appController setupViewWithRect:self.bounds];
		appControllerSetup = YES;
	}
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, appController.viewFramebuffer);
#ifdef debug
	err = glGetError();
	if(err) {
		NSLog(@"%x error 2", err);
	}
#endif
	[self drawScene];
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, appController.viewRenderbuffer);
#ifdef debug
	err = glGetError();
	if(err) {
		NSLog(@"%x error 3", err);
	}
#endif
	[appController.context presentRenderbuffer:GL_RENDERBUFFER_OES];
#ifdef debug
	err = glGetError();
	if(err) {
		NSLog(@"%x error 4", err);
	}
#endif
}

#define kBackgroundSize 4.6f
#define kBackgroundOffsetZ -10.5f
#define kBackgroundOffsetY 0.0
#define kTestSize 0.2f
#define kTestOffsetZ -1.5f

- (void)drawScene {

//#ifdef debug
//NSLog(@"into drawScene  of %@",[self class]);
//#endif

	current_time = get_time_of_day();
	
	float time_since_start = (float)(current_time - animation_start_time);

	//Clear framebuffer
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glLoadIdentity();  	// Setup model view matrix

	// Draw background
	{
		glPushMatrix();
		const GLfloat bgVertices[] = {
			-1.0, -1.0, 0.0,
			1.0, -1.0, 0.0,
			-1.0, 1.0, 0.0,
			1.0, 1.0, 0.0,
		};
		const GLfloat squareTexCoord3[] = {
			0.0f, (512.0 - 480.0)/512.0,
			(512.0 - 320.0)/512.0, (512.0 - 480.0)/512.0,
			0.0f, 1.0f,
			(512.0 - 320.0)/512.0, 1.0f,
		};
		
//		float rd = frandom(0.0, 1.0);
		glColor4f(1.0, 1.0, 1.0, 1.0);

		glBindTexture(GL_TEXTURE_2D, textures[1]);
		glVertexPointer(3, GL_FLOAT, 0, bgVertices);
		glTexCoordPointer(2, GL_FLOAT, 0, squareTexCoord3);
		
		glTranslatef(0.0, 0.0, -10.5);
		float bg_scale = 2.8f;
		glScalef(bg_scale*1.0f, bg_scale*1.5f, 1.0f);
		
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		
		glPopMatrix();

		const GLfloat stage_vertices[] = {
			-0.05, -0.3, 0.0,
			0.05, -0.3, 0.0,
			-0.05, 0.3, 0.0,
			0.05, 0.3, 0.0,
		};

		if ((viewController.stage < 7 && appController.unlocked) || (viewController.stage < 2 && appController.upgraded)) {
			glPushMatrix();
			const GLfloat next_stage_texture[] = {
				0.9f, 0.0f,
				1.0f, 0.0f,
				0.9f, 0.6f,
				1.0f, 0.6f,
			};
			glTranslatef(2.5, 0.0, -10.0);
			glScalef(4.0f, 4.0f, 1.0f);
			glVertexPointer(3, GL_FLOAT, 0, stage_vertices);
			glTexCoordPointer(2, GL_FLOAT, 0, next_stage_texture);
			glColor4f(1.0, 1.0, 1.0, 1.0);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			glPopMatrix();
		}

		if (viewController.stage > 1) {
			glPushMatrix();
			const GLfloat prev_stage_texture[] = {
				0.8f, 0.0f,
				0.9f, 0.0f,
				0.8f, 0.6f,
				0.9f, 0.6f,
			};
			glTranslatef(-2.5, 0.0, -10.0);
			glScalef(4.0f, 4.0f, 1.0f);
			glVertexPointer(3, GL_FLOAT, 0, stage_vertices);
			glTexCoordPointer(2, GL_FLOAT, 0, prev_stage_texture);
			glColor4f(1.0, 1.0, 1.0, 1.0);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			glPopMatrix();
		}
	}
	
	glPushMatrix();		// Push it onto the stack
	glTranslatef(0.0, 0.0, -7.0);

	if (free_wheeling) {		
		if (omega > 2.0) {
			gTrackBallRotation[0] += omega * 0.02;
			gTrackBallRotation[0] = gTrackBallRotation[0] - 3.0f*sinf(5.0 * M_PI*gTrackBallRotation[0]/180.0f);
			omega /= 1.04;
			[self setRotationAngle:gTrackBallRotation[0] X:gTrackBallRotation[1] Y:gTrackBallRotation[2] Z:gTrackBallRotation[3]];
			glRotatef(rotationAngle, rotationAboutAxisX, rotationAboutAxisY, rotationAboutAxisZ);
		} else {
			free_wheeling = NO;
			[self endSpin];
		}
	} 
	else if (animating) {
		float stop_level = 72.0f*(float)(appController.highest_completed[appController.mode]);
		if (fabsf(gTrackBallRotation[0] - stop_level) > 0.1) {
			gTrackBallRotation[0] = 1.0*360.0*expf(-1.5*time_since_start)*cosf(2.0*time_since_start) + stop_level;
			gTrackBallRotation[0] = gTrackBallRotation[0] - 3.0f*sinf(5.0 * M_PI*gTrackBallRotation[0]/180.0f);
			[self setRotationAngle:gTrackBallRotation[0] X:gTrackBallRotation[1] Y:gTrackBallRotation[2] Z:gTrackBallRotation[3]];
			glRotatef (rotationAngle, rotationAboutAxisX, rotationAboutAxisY, rotationAboutAxisZ);
		} else {
			animating = NO;
			[self endSpin];
		}
	} 
	else if (rotationAboutAxisX != 0.0f) {
		glRotatef (rotationAngle, rotationAboutAxisX, rotationAboutAxisY, rotationAboutAxisZ);
	}

	worldRotation[0] = worldRotation[0] - 3.0f*sinf(5.0 * M_PI*worldRotation[0]/180.0f);
	[self setWorldRotationAngle:worldRotation[0] X:worldRotation[1] Y:worldRotation[2] Z:worldRotation[3]];
	glRotatef (worldRotationAngle, worldRotationAboutAxisX, worldRotationAboutAxisY, worldRotationAboutAxisZ);
	glScalef(0.45, 0.45, 0.45);

	static int last_click_angle = 0;
	int click_angle = ((int)roundf(worldRotationAboutAxisX*worldRotationAngle + rotationAboutAxisX*rotationAngle))%360;
	if (abs(click_angle%72) < 10 && abs((click_angle - last_click_angle)%360) > 30 ) {
		[appController.touchSound play];
		last_click_angle = click_angle;
	}
	
	if (going_to_next_level) {
		static GLfloat shift = 0.0f;
		static BOOL new_levels = NO;
		shift -= 0.2;
		glTranslatef(shift, 0.0, 0.0);
		if (shift < -8.0) {
			viewController.stage++;
			viewController.title = [NSString stringWithFormat:@"Stage %d",viewController.stage];
			[polyhedronArray removeAllObjects];
#ifndef debug && test
			int mode = appController.mode;
#endif
			int base_level = (viewController.stage-1)*5;
			if (base_level > 5 && !appController.unlocked && appController.upgraded) base_level = 5;
			if (base_level > 1 && !appController.upgraded && !appController.unlocked) base_level = 1;
			[polyhedronArray removeAllObjects];
			for (int kk = 0; kk < 5; kk++) {
//				if (mode > 3) mode = 3;
#ifdef debug || test
				if (TRUE) {
#else
				if ((base_level == 0 && kk == 0) || [[[[appController.polyhedronInfoArray objectAtIndex:((base_level + kk - 1)<0?0:(base_level + kk - 1))] objectForKey:@"completed"] objectAtIndex:mode] boolValue]) {
#endif
					[polyhedronArray addObject:[[Polyhedra alloc] initializeWithInformation:[appController.polyhedronInfoArray objectAtIndex:(base_level + kk)] withBasis:NO withConnectivity:NO]];
				} else {
					[polyhedronArray addObject:[[Polyhedra alloc] initializeWithInformation:lockedPolyhedronInfo withBasis:NO withConnectivity:NO]];
#ifdef debug || test
				}
#else
				}
#endif
						}
			shift = 8.0;
			new_levels = YES;
		}
		if (shift < 0.0 && new_levels) {new_levels = NO;going_to_next_level = NO;shift=0.0;}
	}
	
	if (going_to_prev_level) {
		static GLfloat shift = 0.0f;
		static BOOL new_levels = NO;
		shift += 0.2;
		glTranslatef(shift, 0.0, 0.0);
		if (shift > 8.0) {
			viewController.stage--;
			viewController.title = [NSString stringWithFormat:@"Stage %d",viewController.stage];
			[polyhedronArray removeAllObjects];
			
#ifndef debug && test
			int mode = appController.mode;
#endif
			int base_level = (viewController.stage-1)*5;
			if (base_level > 5 && !appController.unlocked && appController.upgraded) base_level = 5;
			if (base_level > 1 && !appController.upgraded && !appController.unlocked) base_level = 1;
			[polyhedronArray removeAllObjects];
			for (int kk = 0; kk < 5; kk++) {
//				if (mode > 3) mode = 3;
#ifdef debug || test
				if (TRUE) {
#else
				if ((base_level == 0 && kk == 0) || [[[[appController.polyhedronInfoArray objectAtIndex:((base_level + kk - 1)<0?0:(base_level + kk - 1))] objectForKey:@"completed"] objectAtIndex:mode] boolValue]) {
#endif
//					polyhedron = ;
					[polyhedronArray addObject:[[Polyhedra alloc] initializeWithInformation:[appController.polyhedronInfoArray objectAtIndex:(base_level + kk)] withBasis:NO withConnectivity:NO]];
				} else {
//					polyhedron = ;
					[polyhedronArray addObject:[[Polyhedra alloc] initializeWithInformation:lockedPolyhedronInfo withBasis:NO withConnectivity:NO]];
#ifdef debug || test
				}
#else
				}
#endif
//				[polyhedron release];
			}
			shift = -8.0;
			new_levels = YES;
		}
		if (shift > 0.0 && new_levels) {new_levels = NO;going_to_prev_level = NO;shift=0.0;}
	} 
	
	glCullFace(GL_BACK);
	
	glBindTexture(GL_TEXTURE_2D, textures[num_polygon_types + 4]);
	glDepthRangef(0.0, 1.0 - 0.00001);
	
	const float radius = 4.5f;
	uint counter = 0;
	for (Polyhedra *polyhedron in polyhedronArray) {
		glPushMatrix();
		glTranslatef(0.0, radius * sinf(2*M_PI*((float)counter)/((float)[polyhedronArray count])), radius * cosf(2*M_PI*((float)counter)/((float)[polyhedronArray count])));
		glRotatef(180.0*time_since_start/M_PI,1.0,1.0,1.0);
		if (polyhedron.num_polygons == 7) {
			glScalef(1.25, 1.25, 1.25);
		}
		int type_num = -1;
		GLfloat **texture_coord = polyhedron.scaled_base_texture_coords;
		GLfloat **poly_vertices_ptr = polyhedron.poly_vertices_ptr;
		GLfloat **texture_coord_ptr = polyhedron.texture_coord_ptr;
		
		int *num_faces = polyhedron.face_num2;
		
		for (int kk = 0; kk < (num_polygon_types+1); kk++) {
			int poly_num = 0;

			int num_sides = kk + 3;
			if (kk == 10 || kk == 11 || kk == 12) num_sides = 4;
			else if (kk == 13 || kk == 14 || kk == 15) num_sides = 3;
			
			glVertexPointer(3, GL_FLOAT, 0, poly_vertices_ptr[kk]);
			
			if (num_faces[kk]) type_num++;
			
			glTexCoordPointer(2, GL_FLOAT, 0, texture_coord_ptr[kk]);
			static int offset_x, offset_y;
			
			offset_x = (kk%4);
			offset_y = (3-kk/4);
			
			if (kk == 5) offset_x = 0, offset_y = 2;
			else if (kk == 7) offset_x = 1, offset_y = 2;
			else if (kk == 9) offset_x = 2, offset_y = 2;
			else if (kk == 10) offset_x = 1, offset_y = 0;
			else if (kk == 11) offset_x = 3, offset_y = 2;
			else if (kk == 12) offset_x = 1, offset_y = 1;
			else if (kk == 13) offset_x = 2, offset_y = 1;
			else if (kk == 14) offset_x = 2, offset_y = 0;
			else if (kk == 15) offset_x = 3, offset_y = 1;

			if (polyhedron.num_polygons == 7 && kk == 1) {
				offset_x = 3, offset_y = 0;
			}

			for (int i = 0; i < num_faces[kk]; i ++) {					
				{
					for (int jj = 0; jj < num_sides; jj++) {
						texture_coord_ptr[kk][2*jj+2*num_sides*i+0] = 1.5f*texture_coord[kk][2*jj] + (float)offset_x/4.0f;
						texture_coord_ptr[kk][2*jj+2*num_sides*i+1] = 1.5f*texture_coord[kk][2*jj+1] + (float)offset_y/4.0f;
					}
				} // generate texture coordinates (should really do this outside the main loop)
					
//				GLfloat opaqueness = 1.0f;
				if (polyhedron.num_polygons == 7) {
					glColor4f(0.5, 0.5, 0.5, 1.0);
				} else {
					glColor4f(red[kk], green[kk], blue[kk], 1.0);
				}
				
				glDrawArrays(GL_TRIANGLE_FAN, num_sides*i, num_sides);
					
				poly_num++;
			}		
		}
		counter++;
		glPopMatrix();
	}
	glPopMatrix();
#ifdef verbose
	// Draw test square
	{
	 #define kTestSize 0.2f
	 #define kTestOffsetZ -1.5f
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
	 //		float rd = frandom(0.0, 1.0);
	 glColor4f(1.0, 1.0, 1.0, 1.0);
	 glVertexPointer(3, GL_FLOAT, 0, testVertices);
	 glTexCoordPointer(2, GL_FLOAT, 0, testTexCoord);
	 glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	 }
#endif
}

- (void)dealloc {
#ifdef verbose
NSLog(@"into dealloc  of %@",[self class]);
#endif

//	NSLog(@"dealloc'ing levelsView retain count = %i",[self retainCount]);
//	free(textures);
//	free(texture_coord);
	free(normals);
	free(vertex_coord);
	free(centroid_coord);
	[polyhedronArray release];
	[touchAngleArray release];
	[touchTimeArray release];
	
	[super dealloc];
}

@end
