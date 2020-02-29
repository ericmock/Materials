//
//  LongScoreView.swift
//  AlphaHedra
//
//  Copyright 2020 Small Feats Software. All rights reserved.
//

import UIKit

//@protocol ScoreViewDelegate;
let kScoreToObtain = 1000
let kTimeToComplete:Float = 2.0

class LongScoreView : UIView {
//	var appController:AppController
	var score:Int = 0
	var wordScore:Int = 0
	var fastestTime:Float = 0
	var word:String = ""
	var scoreHistory = []
	var timeHistory = []
	var scoreRange:Int = 0
	
	override init(frame:CGRect) {
		super.init()
		self.backgroundColor = .white
		self.bounds = frame
		
		scoreRange = kScoreToObtain
		
		self.setNeedsDisplay()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func reset() {
		scoreHistory.removeAll()
		timeHistory.removeAll()
		score = 0
		wordScore = 0
		word = ""
		self.setNeedsDisplay()
	}
	
	func setFastestTime(toTime time: Float) {
		fastestTime = time == 0 ? time : kTimeToComplete
		self.setNeedsDisplay()
	}
	
	func updateScore(withScore score:Int) {
		self.score = score
		self.setNeedsDisplay()
	}
	
	func updateWordScore(withScore score:Int) {
		wordScore = score
		self.setNeedsDisplay()
	}
	
	func updateWord(withWord word:String) {
		self.word = word
		self.setNeedsDisplay()
	}
	
	func updateGraphWithScore() {
	}
}
/*
- (void) updateGraphWithScore:(int) score deltaTime:(double) dt {
	if (score > scoreRange && appController.mode != kExploreMode) {
		scoreRange = 100 * (int)((float)score/100) + 100;
//		float old_width = self.contentSize.width;
//		self.contentSize = CGSizeMake(old_width,0.2 * scoreRange);
//		NSLog(@"contentSize.height = %2.0f",self.contentSize.height);
	}
	[scoreHistory addObject:[NSNumber numberWithInt:score]];
	[timeHistory addObject:[NSNumber numberWithDouble:dt]];
	[self setNeedsDisplay];
}

- (void) drawRect:(CGRect)clip {
//	NSLog(@"start scoreView:drawRect");
	CGContextRef context = UIGraphicsGetCurrentContext();
	float score, time = 0.0, final_time;
	
	float diff = 0.0, red = 1.0, green = 1.0;
	double total_time = 0.0;
	for (NSNumber *num in timeHistory)  total_time += [num doubleValue];
	
//	if (_fastestTime > total_time) final_time = _fastestTime;
//	else final_time = total_time;

	final_time = _fastestTime;
	
//	int final_min = (int)final_time/60;
//	int final_sec = (int)(final_time - 60 * final_min);
//	int fastest_min = (int)_fastestTime/60;
//	int fastest_sec = (int)(_fastestTime - 60 * fastest_min);

	float ave = kScoreToObtain*(total_time/_fastestTime - 0.0);
	if (ave != 0.0) diff = [[scoreHistory lastObject] floatValue]/ave - 1;
	
	if (diff > 0) {
		red = fmax(1.0-diff,0.0);
		green = 1.0;
	} else {
		red = 1.0;
		green = fmax(1.0+diff,0.0);
	}
	CGContextSetRGBFillColor(context, red, green, 0.0, 1.0);
	CGContextSetRGBStrokeColor(context, red, green, 0.0, 1.0);
	CGContextFillRect(context, CGRectMake(160.0, 0.0, self.bounds.size.width, self.bounds.size.height));
//	CGContextFillRect(context, self.frame);
//	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
//	[[NSString stringWithFormat:@"Score: %i",_score] drawAtPoint:CGPointMake(0.0, 0.0) withFont:[UIFont fontWithName:@"Times New Roman" size:20]];
//	[[NSString stringWithFormat:@"Word score: %i",_wordScore] drawAtPoint:CGPointMake(0.0, 18.0) withFont:[UIFont fontWithName:@"Times New Roman" size:20]];
//	[[NSString stringWithFormat:@"Word: %@",word] drawAtPoint:CGPointMake(0.0, 36.0) withFont:[UIFont fontWithName:@"Times New Roman" size:20]];
	
//	if (final_time) {
//		CGContextRotateCTM(context, -M_PI/2);
//		[[NSString stringWithFormat:@"%02d:%02d",final_min,final_sec] drawAtPoint:CGPointMake(-self.bounds.size.height+10, self.bounds.size.width-20) withFont:[UIFont fontWithName:@"Times New Roman" size:20]];
//		CGContextRotateCTM(context, M_PI/2);
//	}

	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
	// Draw pace line
	CGContextMoveToPoint(context, 160.0, self.bounds.size.height);
//	NSLog(@"coord: %2.3f, height: %2.3f, scoreRange: %d",self.bounds.size.height*(1-kScoreToObtain/(float)scoreRange),self.bounds.size.height,scoreRange);
//	NSLog(@"width: %2.3f, height: %2.3f",self.bounds.size.width,self.bounds.size.height);
	CGContextAddLineToPoint(context, self.bounds.size.width*(1.0 + _fastestTime/final_time), self.bounds.size.height*(1-kScoreToObtain/(float)scoreRange));
//	CGContextAddLineToPoint(context, 0.5*self.bounds.size.width*(1.0 + _fastestTime/final_time), self.contentSize.height*(1 - self.frame.size.height/self.contentSize.height));
	
//	CGContextSetLineWidth(context, 4.0);
//	CGContextMoveToPoint(context, 0, 0);
//	CGContextAddLineToPoint(context, 320, 60);
	// Draw fastest time line
//	CGContextMoveToPoint(context, 0.5*self.bounds.size.width*(1.0 + _fastestTime/final_time),0);
//	CGContextAddLineToPoint(context, 0.5*self.bounds.size.width*(1.0 + _fastestTime/final_time),self.frame.size.height);
	// Draw separator line
	CGContextMoveToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, 0, self.bounds.size.height);
	CGContextMoveToPoint(context, 0.0, self.bounds.size.height);
	for (int ii=0;ii < [scoreHistory count]; ii++) {
		score = [[scoreHistory objectAtIndex:ii] floatValue];
		time += [[timeHistory objectAtIndex:ii] floatValue];
//		NSLog(@"scoreView: time = %2.3f",time);
		CGContextAddLineToPoint(context, 160.0 + self.bounds.size.width*(time/final_time), self.bounds.size.height*(1.0 - score/scoreRange));
//		CGContextAddLineToPoint(context, self.frame.size.width*(time/final_time), self.contentSize.height*(1.0 - score/scoreRange));
	}
	CGContextStrokePath(context);
//	NSLog(@"end scoreView:drawRect");
}

- (void)dealloc {
    [super dealloc];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	[self setNeedsDisplay];
	return;
}
	
- (void)scrollViewWillBeginDragging:(UIScrollView *)sender {
	[self setNeedsDisplay];
	return;
}

@end
*/
