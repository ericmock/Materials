//
//  Textures.m
//  GLGravity
//
//  Created by Eric Mockensturm on 6/19/09.
//  Copyright 2009 Small Feats Software. All rights reserved.
//

#import "Textures.h"
#import "random.h"

@implementation Textures

CGImageRef convertToGreyscale(UIImage *i, float *lightness) {

    int m_width = i.size.width;
    int m_height = i.size.height;
	
    uint32_t *rgbImage = (uint32_t *) malloc(m_width * m_height * sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImage, m_width, m_height, 8, m_width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetShouldAntialias(context, NO);
    CGContextDrawImage(context, CGRectMake(0, 0, m_width, m_height), [i CGImage]);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
	
    // now convert to grayscale
    uint8_t *m_imageData = (uint8_t *) malloc(m_width * m_height);
	uint32_t total_sum = 0, total_count = 0;
    for(int y = 0; y < m_height; y++) {
        for(int x = 0; x < m_width; x++) {
			uint32_t rgbPixel=rgbImage[y*m_width+x];
			uint32_t sum=0,count=0;
			sum += (rgbPixel>>24)&255;
			sum += (rgbPixel>>16)&255;
			sum += (rgbPixel>>8)&255;
			count+=3;
			total_sum += sum;
			total_count += count;
			m_imageData[y*m_width+x]=sum/count;
        }
    }
    free(rgbImage);
	
	lightness[0] = (float)total_sum/(float)total_count/255.0f;

	CGColorSpaceRef color_space = CGColorSpaceCreateDeviceGray();
	context = CGBitmapContextCreate(m_imageData,m_width,m_height,8,m_width,color_space,kCGImageAlphaNone);
    CGImageRef image = CGBitmapContextCreateImage(context);
	free(m_imageData);
    CGContextRelease(context);
    CGColorSpaceRelease(color_space);
	return image;
}

+ (NSArray *) getBackgroundTextures {
	NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg" inDirectory:@"BackgroundTextures"];
	return array;
} //Ported

+ (void) generateTextureIntoLocation:(GLuint)location {
	NSInteger texWidth = 256;
	NSInteger texHeight = 256;
	
	GLubyte *textureData = (GLubyte *)malloc(texWidth * texHeight * 4);
	CGContextRef textureContext;
	textureContext = CGBitmapContextCreate(textureData,texWidth,texHeight,8,texWidth * 4,CGColorSpaceCreateDeviceRGB(),kCGImageAlphaPremultipliedFirst);
	
	GLubyte rannum;
	for (int ii=0;ii < texWidth*texHeight*4; ii+=4) {
		rannum = (GLubyte)(127+random()/2/(RAND_MAX/255));
		textureData[ii+0]=rannum;
		textureData[ii+1]=rannum/2;
		textureData[ii+2]=rannum/2;
		textureData[ii+3]=255;
	}
	
	CGContextRelease(textureContext);
	
	glBindTexture(GL_TEXTURE_2D, location);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
}

void draw_numbers(CGContextRef textureContext,UIFont *numberFont,NSInteger size,NSInteger texWidth,GLfloat position,GLfloat *background_color,GLfloat *font_fill_color,GLfloat *font_stroke_color) {
	// draw numbers
	CGFloat max_width = 0.0;
	for (int ii = 0; ii < 10; ii++) {
		CGSize string_size = [[NSString stringWithFormat:@"%i",ii] sizeWithFont:numberFont constrainedToSize:CGSizeMake((float)size/10.0f,(float)size/10.0f) lineBreakMode:UILineBreakModeWordWrap];
		if (string_size.width > max_width) max_width = string_size.width;
	}
	CGContextSetGrayFillColor(textureContext, background_color[0], background_color[1]);
	max_width *= 2;
	CGContextFillRect(textureContext, CGRectMake(position*((GLfloat)texWidth) - (max_width)/2, 0.0, max_width, size));
	CGContextSetGrayFillColor(textureContext, font_fill_color[0], font_fill_color[1]);
	CGContextSetGrayStrokeColor(textureContext, font_stroke_color[0], font_stroke_color[1]);
	CGContextSetTextDrawingMode(textureContext, kCGTextFillStroke);
	for (int ii = 0; ii < 10; ii++) {
		CGSize string_size = [[NSString stringWithFormat:@"%i",ii] sizeWithFont:numberFont constrainedToSize:CGSizeMake((float)size/10.0f,(float)size/10.0f) lineBreakMode:UILineBreakModeWordWrap];
		[[NSString stringWithFormat:@"%i",ii] drawInRect:CGRectMake(position*((GLfloat)texWidth) - (string_size.width)/2, (float)size/10.0f*(float)(ii%10) + ((float)size/10.0f - string_size.height)/2, string_size.width, string_size.height) withFont:numberFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	}
}

void draw_symbols(CGContextRef textureContext,UIFont *numberFont,NSInteger size,NSInteger texWidth,GLfloat position,GLfloat *background_color,GLfloat *font_fill_color,GLfloat *font_stroke_color) {
	// draw numbers
	CGFloat max_width = 0.0;
	NSArray *symbolsArray = [NSArray arrayWithObjects:@"",@"",@"",@":",@";",@"+",@"-",@"x",@"/",@"*",nil];
	for (int ii = 0; ii < 10; ii++) {
		CGSize string_size = [[symbolsArray objectAtIndex:ii] sizeWithFont:numberFont constrainedToSize:CGSizeMake((float)size/10.0f,(float)size/10.0f) lineBreakMode:UILineBreakModeWordWrap];
		if (string_size.width > max_width) max_width = string_size.width;
	}
	CGContextSetGrayFillColor(textureContext, background_color[0], background_color[1]);
	max_width *= 2;
	CGContextFillRect(textureContext, CGRectMake(position*((GLfloat)texWidth) - (max_width)/2, 0.0, max_width, size));
	CGContextSetGrayFillColor(textureContext, font_fill_color[0], font_fill_color[1]);
	CGContextSetGrayStrokeColor(textureContext, font_stroke_color[0], font_stroke_color[1]);
	CGContextSetTextDrawingMode(textureContext, kCGTextFillStroke);
	for (int ii = 0; ii < 10; ii++) {
		CGSize string_size = [[symbolsArray objectAtIndex:ii] sizeWithFont:numberFont constrainedToSize:CGSizeMake((float)size/10.0f,(float)size/10.0f) lineBreakMode:UILineBreakModeWordWrap];
		[[symbolsArray objectAtIndex:ii] drawInRect:CGRectMake(position*((GLfloat)texWidth) - (string_size.width)/2, (float)size/10.0f*(float)(ii%10) + ((float)size/10.0f - string_size.height)/2, string_size.width, string_size.height) withFont:numberFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	}
}

void draw_labels(CGContextRef textureContext,int size,UIFont *numberFont) {
	CGContextSetGrayFillColor(textureContext, 1.0, 1.0);
	CGSize string_size = [@"Pause" sizeWithFont:numberFont constrainedToSize:CGSizeMake((float)size/3.0f,(float)size/3.0f) lineBreakMode:UILineBreakModeWordWrap];
	[@"Pause" drawInRect:CGRectMake(440.0 - (string_size.width)/2, (float)size/10.0f*(float)(0%10) + ((float)size/10.0f - string_size.height)/2, string_size.width, string_size.height) withFont:numberFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	string_size = [@"Submit" sizeWithFont:numberFont constrainedToSize:CGSizeMake((float)size/3.0f,(float)size/3.0f) lineBreakMode:UILineBreakModeWordWrap];
	[@"Submit" drawInRect:CGRectMake(440.0 - (string_size.width)/2, (float)size/10.0f*(float)(1%10) + ((float)size/10.0f - string_size.height)/2, string_size.width, string_size.height) withFont:numberFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	string_size = [@"Find" sizeWithFont:numberFont constrainedToSize:CGSizeMake((float)size/3.0f,(float)size/3.0f) lineBreakMode:UILineBreakModeWordWrap];
	[@"Find" drawInRect:CGRectMake(440.0 - (string_size.width)/2, (float)size/10.0f*(float)(2%10) + ((float)size/10.0f - string_size.height)/2, string_size.width, string_size.height) withFont:numberFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];

	CGContextSaveGState(textureContext);
	CGFloat trans_x = -512.0, trans_y = 512.0 - 0.1*512.0;
	CGContextRotateCTM(textureContext, -1.571);
	CGContextTranslateCTM(textureContext, trans_x, trans_y);
	CGRect drawRect = CGRectMake(0.0, 0.0, 0.6*512.0, 0.1*512.0);
	NSString *string = @"Next Stage";
	UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	[color set];
	[string drawInRect:drawRect withFont:numberFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	CGContextRestoreGState(textureContext);
	
	CGContextSaveGState(textureContext);
	trans_x = 512.0 - 0.6*512.0, trans_y = -512.0 + 0.1*512.0;
	CGContextRotateCTM(textureContext, 1.571);
	CGContextTranslateCTM(textureContext, trans_x, trans_y);
	drawRect = CGRectMake(0.0, 0.0, 0.6*512.0, 0.1*512.0);
	string = @"Previous Stage";
	color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	[color set];
	[string drawInRect:drawRect withFont:numberFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	CGContextRestoreGState(textureContext);
}

+ (void) loadBackdropTextureImage:(NSString *)imageName intoLocation:(GLuint)location withTag:(uint)tag flipped:(BOOL) flipped size:(int) size {
	
    CGImageRef textureImage = [UIImage imageNamed:imageName].CGImage;

    NSInteger texImageWidth = CGImageGetWidth(textureImage);//*size/128;
    NSInteger texImageHeight = CGImageGetHeight(textureImage);//*size/128;

	NSInteger texWidth = size;//128/2;//(texShapeWidth > texLetterWidth)?(texShapeWidth):(texLetterWidth);
	NSInteger texHeight = size;//128/2;//(texShapeHeight > texLetterHeight)?(texShapeHeight):(texLetterHeight);

	GLubyte *textureData = (GLubyte *)calloc(texWidth, texHeight * 4);
	CGContextRef textureContext = CGBitmapContextCreate(textureData,texWidth,texHeight,CGImageGetBitsPerComponent(textureImage),texWidth * 4,CGImageGetColorSpace(textureImage),kCGImageAlphaPremultipliedLast);
//	CGContextSetGrayFillColor(textureContext, 0.7, 1.0);
//	CGContextFillRect(textureContext, CGRectMake(0.0, 0.0, 368.0, (float)texHeight));
//	for (int ii=0;ii<texHeight;ii+=1) {
//		for (int kk=0;kk<4*texWidth;kk+=4) {
//			if (kk < 4*368 && sinf((float)(ii)/(2.0f))*sinf((float)(kk/4)/(2.0f)) > 0.1f) {
//				float ran = frandom(0.75, 1.0);
//				for (int jj=0;jj<3;jj+=1) {
//					textureData[4*texWidth*ii + kk + jj] = ran*textureData[4*texWidth*ii + kk + jj];//(GLubyte)((0.5 + 0.5*c * c) * textureData[4*texWidth*ii + kk + jj]);
//				}
//			}
//		}
//	}
	CGContextSetGrayFillColor(textureContext, 1.0, 0.0);
	CGContextFillRect(textureContext, CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight));
	
	if (flipped) {
		CGContextTranslateCTM(textureContext, 0.0, texHeight);
		CGContextScaleCTM(textureContext, 1.0, -1.0); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
	}

	// draw the image
	CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)texImageWidth, (float)texImageHeight), textureImage);
	
	if (flipped) {
		CGContextScaleCTM(textureContext, 1.0, -1.0);
		CGContextTranslateCTM(textureContext, 0.0, -texHeight);
	}

	// draw a gradient over the picture
/*	CGContextSaveGState(textureContext);
    CGContextBeginPath (textureContext);
    CGContextAddRect(textureContext, CGRectMake(0.0, 0.0, (float)texImageWidth, (float)texImageHeight));
    CGContextClosePath (textureContext);
    CGContextClip (textureContext);
	
	CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
	CGFloat locations[2] = { 0.0, 1.0}, colors[8] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0 };
	size_t size_of_locations = sizeof(locations)/2;
	CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, colors, locations, size_of_locations);
	CGPoint myStartPoint, myEndPoint;
	myStartPoint.x = 0.0;
	myStartPoint.y = 0.0;
	myEndPoint.x = 0.0;
	myEndPoint.y = (float)texImageHeight;
	CGContextDrawLinearGradient(textureContext, myGradient, myStartPoint, myEndPoint, 0);
	CGColorSpaceRelease(myColorspace);
	CGGradientRelease(myGradient);
	CGContextRestoreGState(textureContext);
*/

	UIGraphicsPushContext(textureContext);
	GLfloat background_color[2] = {0.0,1.0};
	GLfloat font_fill_color[2] = {1.0,1.0};
	GLfloat font_stroke_color[2] = {1.0,1.0};
	background_color[0] = 1.0, background_color[1] = 0.0;
	draw_numbers(textureContext,[UIFont fontWithName:@"Helvetica-Bold" size:40],size,texWidth,0.67,background_color,font_fill_color,font_stroke_color);
	draw_symbols(textureContext,[UIFont fontWithName:@"Helvetica-Bold" size:40],size,texWidth,0.75,background_color,font_fill_color,font_stroke_color);
	draw_labels(textureContext,size,[UIFont fontWithName:@"Helvetica-Bold" size:40]);
	UIGraphicsPopContext();

	CGContextRelease(textureContext);
	
	glBindTexture(GL_TEXTURE_2D, location);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glEnable(GL_TEXTURE_2D);
}

/*+ (void) loadTextureWithNumber:(NSNumber *)number intoLocation:(GLuint)location withTag:(uint)tag {
    CGImageRef textureLetter = [UIImage imageNamed:@"A.png"].CGImage;
		
	NSInteger texWidth = 64;//(texShapeWidth > texLetterWidth)?(texShapeWidth):(texLetterWidth);
	NSInteger texHeight = 64;//(texShapeHeight > texLetterHeight)?(texShapeHeight):(texLetterHeight);
	
	GLubyte *textureData = (GLubyte *)malloc(texWidth * texHeight * 4);
	CGContextRef textureContext = CGBitmapContextCreate(textureData,texWidth,texHeight,CGImageGetBitsPerComponent(textureLetter),texWidth * 4,CGImageGetColorSpace(textureLetter),kCGImageAlphaPremultipliedLast);
	CGContextSetGrayFillColor(textureContext, 1.0, 1.0);
	CGContextFillRect(textureContext, CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight));
	CGContextTranslateCTM(textureContext, 0.0, texHeight);
	CGContextScaleCTM(textureContext, 1.0, -1.0); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
//	CGContextDrawImage(textureContext, CGRectMake((float)(texWidth - texLetterWidth)/2, (float)(texHeight - texLetterHeight)/2, (float)texLetterWidth, (float)texLetterHeight), textureLetter);
	UIGraphicsPushContext(textureContext);
	CGContextSetRGBFillColor(textureContext, 0.0, 0.0, 0.0, 1.0);
	CGContextScaleCTM(textureContext, 1.0, -1.0);
	CGContextTranslateCTM(textureContext, 0.0, -texHeight);
	NSString *string = [NSString stringWithFormat:@"%d",tag];
	[string drawInRect:CGRectMake(0, 20, texWidth, texHeight-20) withFont:[UIFont fontWithName:@"Helvetica" size:14] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	UIGraphicsPopContext();
	
	for (int ii=0;ii<texHeight;ii+=1) {
		for (int kk=0;kk<4*texWidth;kk+=4) {
			for (int jj=0;jj<4;jj+=1) {
				float c = cosf((float)ii/3);
				textureData[4*texWidth*ii + kk + jj] = (GLubyte)((0.5 + 0.5*c * c) * textureData[4*texWidth*ii + kk + jj]);
			}
		}
	}
	CGContextRelease(textureContext);
	
	glBindTexture(GL_TEXTURE_2D, location);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glEnable(GL_TEXTURE_2D);
}*/

+ (void) loadTextureWithString:(NSString *)string intoLocation:(GLuint)location withTag:(uint)tag inRect:(CGRect)rect {
	
	NSInteger texWidth = rect.size.width;
	NSInteger texHeight = rect.size.height;
	
	GLubyte *textureData = (GLubyte *)calloc(texWidth * texHeight, 4);
	CGColorSpaceRef color_space = CGColorSpaceCreateDeviceRGB();
	CGContextRef textureContext = CGBitmapContextCreate(textureData,texWidth,texHeight,8,texWidth * 4,color_space,kCGImageAlphaNoneSkipLast);
	
	CGContextSetGrayFillColor(textureContext, 0.0, 0.0);
	CGContextFillRect(textureContext, CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight));

	float font_size2 = 60;
	float font_size1;
	CGSize string_size = [string sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:font_size2] minFontSize:30 actualFontSize:&font_size1 forWidth:rect.size.width/2 lineBreakMode:UILineBreakModeWordWrap];
	UIGraphicsPushContext(textureContext);
	CGContextSetGrayFillColor(textureContext, 1.0, 0.75);

	[string drawInRect:CGRectMake((texWidth - string_size.width)/2, (texHeight - string_size.height)/2, string_size.width, string_size.height) withFont:[UIFont fontWithName:@"Helvetica-Bold" size:font_size1] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	
	if (tag == 1) {
		for (int ii=0;ii<texHeight;ii+=1) {
			for (int kk=0;kk<4*texWidth;kk+=4) {
				if (sinf((float)(ii - 64)/4)*sinf((float)(kk/4 - 64)/4) > 1/8) {
					for (int jj=0;jj<4;jj+=1) {
//						float c = cosf((float)ii/3);
						textureData[4*texWidth*ii + kk + jj] = 0.75*textureData[4*texWidth*ii + kk + jj];//(GLubyte)((0.5 + 0.5*c * c) * textureData[4*texWidth*ii + kk + jj]);
					}
				}
			}
		}
	} else if (tag == 2) {
		for (int ii=0;ii<texHeight;ii+=1) {
			for (int kk=0;kk<4*texWidth;kk+=4) {
				if (cosf((float)(ii - 64)/4)*cosf((float)(kk/4 - 64)/4) > 1/8) {
					for (int jj=0;jj<4;jj+=1) {
//						float c = sinf((float)ii/3);
						textureData[4*texWidth*ii + kk + jj] = 0.75*textureData[4*texWidth*ii + kk + jj];//(GLubyte)((0.5 + 0.5*c * c) * textureData[4*texWidth*ii + kk + jj]);
					}
				}
			}
		}
	}
	
	CGContextRelease(textureContext);
	
	glBindTexture(GL_TEXTURE_2D, location);
	glTexSubImage2D(GL_TEXTURE_2D,0,rect.origin.x,rect.origin.y,rect.size.width,rect.size.height,GL_RGBA,GL_UNSIGNED_BYTE,textureData);
	free(textureData);
	CGColorSpaceRelease(color_space);
	
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glEnable(GL_TEXTURE_2D);
}

+ (void) generateGLAlphabetTexture:(NSArray *)alphabet intoLocation:(GLuint)location withTag:(uint)tag ofSize:(uint)size withFont:(UIFont *)font withSides:(uint)sides {
	[self generateGLAlphabetTexture:alphabet intoLocation:location withTag:tag ofSize:size withFont:font withOutline:YES withSides:sides withBGTexture:0];
}

+ (void) generateGLAlphabetTexture:(NSArray *)alphabet intoLocation:(GLuint)location withTag:(uint)tag ofSize:(uint)size withFont:(UIFont *)font withSides:(uint)sides withBGTexture:(int)texture_num {
	[self generateGLAlphabetTexture:alphabet intoLocation:location withTag:tag ofSize:size withFont:font withOutline:YES withSides:sides withBGTexture:texture_num];
}

+ (void) generateGLAlphabetTexture:(NSArray *)alphabet intoLocation:(GLuint)location withTag:(uint)tag ofSize:(uint)size withFont:(UIFont *)font withOutline:(BOOL)outlined withSides:(uint)sides withBGTexture:(int)texture_num {
// need to look into making this a gray scale texture
	NSInteger texWidth = size;
	NSInteger texHeight = size;

#ifdef MATH
	font = [UIFont fontWithName:font.fontName size:2.0*(font.pointSize)];
#endif
	NSString *fontName = font.fontName;
	NSRange range_italic = [fontName rangeOfString:@"italic" options: NSCaseInsensitiveSearch];
	NSRange range_oblique = [fontName rangeOfString:@"oblique" options: NSCaseInsensitiveSearch];
	
	BOOL slanted = (range_italic.length > 0 || range_oblique.length > 0);

	int grid_size_x = (int)(ceilf(sqrtf((float)[alphabet count])));
	int grid_size_y = grid_size_x;
	int grid_size = grid_size_x;
	if (tag == 1) {
		grid_size_x = 1;
		grid_size_y = [alphabet count];
	}
	
	GLubyte *textureData = (GLubyte *)calloc(texWidth * texHeight, 4);
	CGColorSpaceRef color_space = CGColorSpaceCreateDeviceRGB();
	CGContextRef textureContext = CGBitmapContextCreate(textureData,texWidth,texHeight,8,texWidth * 4,color_space,kCGImageAlphaNoneSkipLast);
	
	if (tag == 1 || tag == 3) CGContextSetGrayFillColor(textureContext, 1.0, 1.0);
	if (tag == 2) CGContextSetGrayFillColor(textureContext, 0.3, 1.0);
	CGContextFillRect(textureContext, CGRectMake(0.0, 0.0, (float)texWidth, ((float)texHeight)));
	UIGraphicsPushContext(textureContext);

	CGContextSetShouldAntialias(textureContext, YES);
	CGMutablePathRef path, path_outline;
	float offset_x, offset_y;
	CGPoint point, point_outline;

	float tile_size_x = (float)size/(float)(grid_size);
	float tile_size_y = tile_size_x;
	float tile_size = tile_size_x;

	if (tag==1) {
		tile_size_x = (float)size/(float)(grid_size_x);
		tile_size_y = (float)size/(float)(grid_size_y);
	}

	CGColorRef white = [[UIColor colorWithWhite:1.0 alpha:1.0] CGColor];
	CGColorRef black = [[UIColor colorWithWhite:0.0 alpha:1.0] CGColor];

	CGImageRef textureImage = nil;
	float lightness = 0;
	// draw background texture
	if (tag == 2) {
		if (texture_num == 1) {
			lightness = 0;
		} else if (texture_num == 2) {
			lightness = 1;
		} else if (texture_num > 2) {
			NSArray *backgroundTextureArray = [self getBackgroundTextures];
			NSString *imagePath = [@"BackgroundTextures/" stringByAppendingString: [[backgroundTextureArray objectAtIndex:(texture_num - 3)] lastPathComponent]];
			textureImage = convertToGreyscale([UIImage imageNamed:imagePath],&lightness);
		} else {
			NSString *imagePath = [NSHomeDirectory() stringByAppendingString:@"/Documents/temp.png"];
			textureImage = convertToGreyscale([UIImage imageWithContentsOfFile:imagePath],&lightness);
		}
	}
	float edge_width = 8.0;
	if (tag == 1) edge_width = 10.0;

	// make embossed outline for mode items
	if (tag == 3) {
		for (int ii = 0; ii < [alphabet count]; ii++) {
			offset_x = tile_size*(float)(ii%grid_size);
			offset_y = tile_size*(float)(ii/grid_size);
			path = CGPathCreateMutable();
			
			point = CGPointMake(edge_width + offset_x, edge_width + offset_y);
			CGPathMoveToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(edge_width + offset_x, tile_size - edge_width + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(tile_size - edge_width + offset_x, tile_size - edge_width + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(tile_size - edge_width + offset_x, edge_width + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			CGPathCloseSubpath(path);

			point = CGPointMake(0.0 + offset_x, 0.0 + offset_y);
			CGPathMoveToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(0.0 + offset_x, tile_size + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(tile_size + offset_x, tile_size + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(tile_size + offset_x, 0.0 + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			CGPathCloseSubpath(path);
			
			CGContextSaveGState(textureContext);

			CGContextSetShadowWithColor(textureContext, CGSizeMake(2.0, 2.0), 4.0, black);
			
			CGContextAddPath(textureContext, path);
			CGContextSetGrayFillColor(textureContext, 0.5, 1.0);
			CGContextEOFillPath(textureContext);
// Ported to here
			CGContextSetShadowWithColor(textureContext, CGSizeMake(-2.0, -2.0), 4.0, white);
			
			CGContextAddPath(textureContext, path);
			CGContextSetGrayFillColor(textureContext, 0.5, 1.0);
			CGContextEOFillPath(textureContext);
			CGPathRelease(path);
			CGContextRestoreGState(textureContext);

			path = CGPathCreateMutable();

			point = CGPointMake(0.0 + offset_x, 0.0 + offset_y);
			CGPathMoveToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(0.0 + offset_x, tile_size + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(tile_size + offset_x, tile_size + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(tile_size + offset_x, 0.0 + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			CGPathCloseSubpath(path);

			CGContextSetLineWidth(textureContext, 10.0 * (float)size/512.0f);
			CGContextAddPath(textureContext, path);
			CGContextSetGrayStrokeColor(textureContext, 0.0, 1.0);
			CGContextStrokePath(textureContext);

			CGPathRelease(path);
		}
	}
	
	// make embossed outline for menu items
	if (tag == 1) {
		for (int ii = 0; ii < [alphabet count]; ii++) {
			offset_x = 0.0;
			offset_y = tile_size_y*(float)(ii%grid_size_y);
			path = CGPathCreateMutable();
			
			point = CGPointMake(edge_width + offset_x, edge_width + offset_y);
			CGPathMoveToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(edge_width + offset_x, tile_size_y - edge_width + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(tile_size_x - edge_width + offset_x, tile_size_y - edge_width + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(tile_size_x - edge_width + offset_x, edge_width + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			CGPathCloseSubpath(path);
			
			point = CGPointMake(0.0 + offset_x, 0.0 + offset_y);
			CGPathMoveToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(0.0 + offset_x, tile_size_y + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(tile_size_x + offset_x, tile_size_y + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(tile_size_x + offset_x, 0.0 + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			CGPathCloseSubpath(path);
			
			CGContextSaveGState(textureContext);
			
			CGContextSetShadowWithColor(textureContext, CGSizeMake(2.0, 2.0), 4.0, black);
			
			CGContextAddPath(textureContext, path);
			CGContextSetGrayFillColor(textureContext, 0.5, 1.0);
			CGContextEOFillPath(textureContext);
			
			CGContextSetShadowWithColor(textureContext, CGSizeMake(-2.0, -2.0), 4.0, white);
			
			CGContextAddPath(textureContext, path);
			CGContextSetGrayFillColor(textureContext, 0.5, 1.0);
			CGContextEOFillPath(textureContext);
			CGPathRelease(path);
			CGContextRestoreGState(textureContext);
			
			path = CGPathCreateMutable();
			
			point = CGPointMake(0.0 + offset_x, 0.0 + offset_y);
			CGPathMoveToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(0.0 + offset_x, tile_size_y + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(tile_size_x + offset_x, tile_size_y + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			point = CGPointMake(tile_size_x + offset_x, 0.0 + offset_y);
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
			CGPathCloseSubpath(path);
			
			CGContextSetLineWidth(textureContext, 2.0 * (float)size/512.0f);
			CGContextAddPath(textureContext, path);
			CGContextSetGrayStrokeColor(textureContext, 0.0, 1.0);
			CGContextStrokePath(textureContext);
			
			CGPathRelease(path);
		}
	}

	// draw embossed mode text in alphabet array
	if (tag == 3) {
		CGContextSetGrayFillColor(textureContext, 0.0, 1.0);
		CGContextSetShadowWithColor(textureContext, CGSizeMake(2.0, 2.0), 4.0, black);
		for (int ii = 0; ii < [alphabet count]; ii++) {
			CGSize string_size = [[alphabet objectAtIndex:ii] sizeWithFont:font constrainedToSize:CGSizeMake(tile_size,tile_size) lineBreakMode:UILineBreakModeWordWrap];
			[[alphabet objectAtIndex:ii] drawInRect:CGRectMake(tile_size*(float)(ii%grid_size) + (tile_size - string_size.width)/2, tile_size*(float)(ii/grid_size) + (tile_size - string_size.height)/2, string_size.width, string_size.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
		}
		CGContextSetShadowWithColor(textureContext, CGSizeMake(-2.0, -2.0), 4.0, white);
		for (int ii = 0; ii < [alphabet count]; ii++) {
			CGSize string_size = [[alphabet objectAtIndex:ii] sizeWithFont:font constrainedToSize:CGSizeMake(tile_size,tile_size) lineBreakMode:UILineBreakModeWordWrap];
			[[alphabet objectAtIndex:ii] drawInRect:CGRectMake(tile_size*(float)(ii%grid_size) + (tile_size - string_size.width)/2, tile_size*(float)(ii/grid_size) + (tile_size - string_size.height)/2, string_size.width, string_size.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
		}
	}
	// draw embossed menu text in alphabet array
	else if (tag == 1) {
		CGContextSetGrayFillColor(textureContext, 0.0, 1.0);
		CGContextSetShadowWithColor(textureContext, CGSizeMake(2.0, 2.0), 4.0, black);
		for (int ii = 0; ii < [alphabet count]; ii++) {
			CGSize string_size = [[alphabet objectAtIndex:ii] sizeWithFont:font constrainedToSize:CGSizeMake(tile_size_x,tile_size_y) lineBreakMode:UILineBreakModeWordWrap];
			[[alphabet objectAtIndex:ii] drawInRect:CGRectMake((tile_size_x - string_size.width)/2, tile_size_y*(float)(ii%grid_size_y) + (tile_size_y - string_size.height)/2, string_size.width, string_size.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
		}
		CGContextSetShadowWithColor(textureContext, CGSizeMake(-2.0, -2.0), 4.0, white);
		for (int ii = 0; ii < [alphabet count]; ii++) {
			CGSize string_size = [[alphabet objectAtIndex:ii] sizeWithFont:font constrainedToSize:CGSizeMake(tile_size_x,tile_size_y) lineBreakMode:UILineBreakModeWordWrap];
			[[alphabet objectAtIndex:ii] drawInRect:CGRectMake((tile_size_x - string_size.width)/2, tile_size_y*(float)(ii%grid_size_y) + (tile_size_y - string_size.height)/2, string_size.width, string_size.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
		}
	}
	// draw outlined text in alphabet array
	else if (tag == 2) {
		float height = tile_size;
		float radius = (height - 6.0)/2; // adjust this to change offset of outline from polygon edge
		offset_x = 2.0;
		float offset_factor = 0.9;
		CGContextTranslateCTM(textureContext, 0.0, texHeight);
		CGContextScaleCTM(textureContext, 1.0, -1.0);
		if (texture_num == 0) {
			CGContextSetGrayFillColor(textureContext, 1.0, 1.0);
			CGContextFillRect(textureContext, CGRectMake(0.0,0.0,texWidth,texHeight));
		} else if (texture_num == 1) {
			CGContextSetGrayFillColor(textureContext, 0.0, 1.0);
			CGContextFillRect(textureContext, CGRectMake(0.0,0.0,texWidth,texHeight));
		} else {
			for (int ii = 0; ii < [alphabet count]; ii++) {
				CGContextDrawImage(textureContext, CGRectMake(tile_size*(float)(ii%grid_size), texHeight - tile_size - tile_size*(float)(ii/grid_size), tile_size, tile_size), textureImage);
			}
		}
		CGContextScaleCTM(textureContext, 1.0, -1.0);
		CGContextTranslateCTM(textureContext, 0.0, -texHeight);

		for (int ii = 0; ii < [alphabet count]; ii++) {
			path = CGPathCreateMutable();
			path_outline = CGPathCreateMutable();
			
			if (sides == 3) {
				uint jj = 0;
				point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 - radius * cosf(2.0f * M_PI * (float)jj/(float)sides));
				point_outline = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + (radius + offset_x) * sinf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 - (radius + offset_x) * cosf(2.0f * M_PI * (float)jj/(float)sides));
				CGPathMoveToPoint(path, NULL, point.x, point.y);
				CGPathMoveToPoint(path_outline, NULL, point_outline.x, point_outline.y);
				for (uint jj = 1; jj < sides; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 - radius * cosf(2.0f * M_PI * (float)jj/(float)sides));
					point_outline = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + (radius + offset_x) * sinf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 - (radius + offset_x) * cosf(2.0f * M_PI * (float)jj/(float)sides));
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
					CGPathAddLineToPoint(path_outline, NULL, point_outline.x, point_outline.y);
				}
				CGPathCloseSubpath(path);
				CGPathCloseSubpath(path_outline);
				jj = 0;
				point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + offset_factor * radius * sinf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 - offset_factor * radius * cosf(2.0f * M_PI * (float)jj/(float)sides));
				CGPathMoveToPoint(path, NULL, point.x, point.y);
				for (uint jj = 1; jj < sides; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + offset_factor * radius * sinf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 - offset_factor * radius * cosf(2.0f * M_PI * (float)jj/(float)sides));
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
			}
			else if (sides == 4) {
				uint jj = 0;
				point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides));
				point_outline = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + (radius + offset_x) * cosf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + (radius + offset_x) * sinf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides));
				CGPathMoveToPoint(path, NULL, point.x, point.y);
				CGPathMoveToPoint(path_outline, NULL, point_outline.x, point_outline.y);
				for (uint jj = 1; jj < sides; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides));
					point_outline = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + (radius + offset_x) * cosf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + (radius + offset_x) * sinf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides));
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
					CGPathAddLineToPoint(path_outline, NULL, point_outline.x, point_outline.y);
				}
				CGPathCloseSubpath(path);
				CGPathCloseSubpath(path_outline);
				jj = 0;
				point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + offset_factor * radius * cosf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + offset_factor * radius * sinf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides));
				CGPathMoveToPoint(path, NULL, point.x, point.y);
				for (uint jj = 1; jj < sides; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + offset_factor * radius * cosf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + offset_factor * radius * sinf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides));
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
			}
			else if (sides == 5) {
				uint jj = 0;
				point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 - radius * cosf(2.0f * M_PI * (float)jj/(float)sides));
				point_outline = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + (radius + offset_x) * sinf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 - (radius + offset_x) * cosf(2.0f * M_PI * (float)jj/(float)sides));
				CGPathMoveToPoint(path, NULL, point.x, point.y);
				CGPathMoveToPoint(path_outline, NULL, point_outline.x, point_outline.y);
				for (uint jj = 1; jj < sides; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 - radius * cosf(2.0f * M_PI * (float)jj/(float)sides));
					point_outline = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + (radius + offset_x) * sinf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 - (radius + offset_x) * cosf(2.0f * M_PI * (float)jj/(float)sides));
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
					CGPathAddLineToPoint(path_outline, NULL, point_outline.x, point_outline.y);
				}
				CGPathCloseSubpath(path);
				CGPathCloseSubpath(path_outline);
				jj = 0;
				point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + offset_factor * radius * sinf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 - offset_factor * radius * cosf(2.0f * M_PI * (float)jj/(float)sides));
				CGPathMoveToPoint(path, NULL, point.x, point.y);
				for (uint jj = 1; jj < sides; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + offset_factor * radius * sinf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 - offset_factor * radius * cosf(2.0f * M_PI * (float)jj/(float)sides));
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
			}
			else if (sides == 6) {
				uint jj = 0;
				point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides));
				point_outline = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + (radius + offset_x) * cosf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + (radius + offset_x) * sinf(2.0f * M_PI * (float)jj/(float)sides));
				CGPathMoveToPoint(path, NULL, point.x, point.y);
				CGPathMoveToPoint(path_outline, NULL, point_outline.x, point_outline.y);
				for (uint jj = 1; jj < sides; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides));
					point_outline = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + (radius + offset_x) * cosf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + (radius + offset_x) * sinf(2.0f * M_PI * (float)jj/(float)sides));
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
					CGPathAddLineToPoint(path_outline, NULL, point_outline.x, point_outline.y);
				}
				CGPathCloseSubpath(path);
				CGPathCloseSubpath(path_outline);
				jj = 0;
				point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + offset_factor * radius * cosf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + offset_factor * radius * sinf(2.0f * M_PI * (float)jj/(float)sides));
				CGPathMoveToPoint(path, NULL, point.x, point.y);
				for (uint jj = 1; jj < sides; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + offset_factor * radius * cosf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + offset_factor * radius * sinf(2.0f * M_PI * (float)jj/(float)sides));
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
			}
			else if (sides == 8) {
				uint jj = 0;
				point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides));
				point_outline = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + (radius + offset_x) * cosf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + (radius + offset_x) * sinf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides));
				CGPathMoveToPoint(path, NULL, point.x, point.y);
				CGPathMoveToPoint(path_outline, NULL, point_outline.x, point_outline.y);
				for (uint jj = 1; jj < sides; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides));
					point_outline = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + (radius + offset_x) * cosf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + (radius + offset_x) * sinf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides));
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
					CGPathAddLineToPoint(path_outline, NULL, point_outline.x, point_outline.y);
				}
				CGPathCloseSubpath(path);
				CGPathCloseSubpath(path_outline);
				jj = 0;
				point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + offset_factor * radius * cosf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + offset_factor * radius * sinf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides));
				CGPathMoveToPoint(path, NULL, point.x, point.y);
				for (uint jj = 1; jj < sides; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + offset_factor * radius * cosf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + offset_factor * radius * sinf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides));
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
			}
			else if (sides == 10) {
				uint jj = 0;
				point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides));
				point_outline = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + (radius + offset_x) * cosf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + (radius + offset_x) * sinf(2.0f * M_PI * (float)jj/(float)sides));
				CGPathMoveToPoint(path, NULL, point.x, point.y);
				CGPathMoveToPoint(path_outline, NULL, point_outline.x, point_outline.y);
				for (uint jj = 1; jj < sides; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides));
					point_outline = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + (radius + offset_x) * cosf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + (radius + offset_x) * sinf(2.0f * M_PI * (float)jj/(float)sides));
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
					CGPathAddLineToPoint(path_outline, NULL, point_outline.x, point_outline.y);
				}
				CGPathCloseSubpath(path);
				CGPathCloseSubpath(path_outline);
				jj = 0;
				point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + offset_factor * radius * cosf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + offset_factor * radius * sinf(2.0f * M_PI * (float)jj/(float)sides));
				CGPathMoveToPoint(path, NULL, point.x, point.y);
				for (uint jj = 1; jj < sides; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + offset_factor * radius * cosf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + offset_factor * radius * sinf(2.0f * M_PI * (float)jj/(float)sides));
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
			}
			else if (sides == 12) {
				uint jj = 0;
				point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides));
				point_outline = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + (radius + offset_x) * cosf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + (radius + offset_x) * sinf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides));
				CGPathMoveToPoint(path, NULL, point.x, point.y);
				CGPathMoveToPoint(path_outline, NULL, point_outline.x, point_outline.y);
				for (uint jj = 1; jj < sides; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides));
					point_outline = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + (radius + offset_x) * cosf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + (radius + offset_x) * sinf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides));
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
					CGPathAddLineToPoint(path_outline, NULL, point_outline.x, point_outline.y);
				}
				CGPathCloseSubpath(path);
				CGPathCloseSubpath(path_outline);
				jj = 0;
				point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + offset_factor * radius * cosf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + offset_factor * radius * sinf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides));
				CGPathMoveToPoint(path, NULL, point.x, point.y);
				for (uint jj = 1; jj < sides; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + offset_factor * radius * cosf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + offset_factor * radius * sinf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides));
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
			}
			else if (sides == 104) {
				float temp2[] = {0.5, 1.0 - 0.0871677, 0.879126, 1.0 - 0.456416, 0.5, 1.0 - 1., 0.120874, 1.0 - 0.456416};
				CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp2[0], tile_size*(float)(ii/grid_size) + height*temp2[1]);
				CGPathMoveToPoint(path_outline, NULL, tile_size*(float)(ii%grid_size) + height*temp2[0], tile_size*(float)(ii/grid_size) + height*temp2[1]);
				for (uint jj = 1; jj < 4; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp2[2*jj], tile_size*(float)(ii/grid_size) + height*temp2[2*jj+1]);
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
					CGPathAddLineToPoint(path_outline, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
				CGPathCloseSubpath(path_outline);
				float temp3[] = {0.5, 0.912832 - 0.0558365*offset_factor, 0.879126 - 0.0522314*offset_factor, 0.543584 - 0.00496589*offset_factor, 0.5, 0.0699226*offset_factor, 0.120874 + 0.0522314*offset_factor, 0.543584 - 0.00496589*offset_factor};
				CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp3[0], tile_size*(float)(ii/grid_size) + height*temp3[1]);
				for (uint jj = 1; jj < 4; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp3[2*jj], tile_size*(float)(ii/grid_size) + height*temp3[2*jj+1]);
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
			}
			else if (sides == 204) {
				float temp2[] = {0.0, 0.5, 0.5, 0.191, 1.0, 0.5, 0.5, 0.809};
				CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp2[0], tile_size*(float)(ii/grid_size) + height*temp2[1]);
				CGPathMoveToPoint(path_outline, NULL, tile_size*(float)(ii%grid_size) + height*temp2[0], tile_size*(float)(ii/grid_size) + height*temp2[1]);
				for (uint jj = 1; jj < 4; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp2[2*jj], tile_size*(float)(ii/grid_size) + height*temp2[2*jj+1]);
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
					CGPathAddLineToPoint(path_outline, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
				CGPathCloseSubpath(path_outline);
				float temp3[] = {0.0760875*offset_factor, 0.5, 0.5, 0.191 + 0.0470221*offset_factor, 1. - 0.0760875*offset_factor, 0.5, 0.5, 0.809 - 0.0470221*offset_factor};
				CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp3[0], tile_size*(float)(ii/grid_size) + height*temp3[1]);
				for (uint jj = 1; jj < 4; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp3[2*jj], tile_size*(float)(ii/grid_size) + height*temp3[2*jj+1]);
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
			}
			else if (sides == 304) {
				float temp2[] = {0.5, 1.0 - 1., 0.105022, 1.0 - 0.412023, 0.5, 1.0 - 0.175955, 0.894978, 1.0 - 0.412023};
				CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp2[0], tile_size*(float)(ii/grid_size) + height*temp2[1]);
				CGPathMoveToPoint(path_outline, NULL, tile_size*(float)(ii%grid_size) + height*temp2[0], tile_size*(float)(ii/grid_size) + height*temp2[1]);
				for (uint jj = 1; jj < 4; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp2[2*jj], tile_size*(float)(ii/grid_size) + height*temp2[2*jj+1]);
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
					CGPathAddLineToPoint(path_outline, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
				CGPathCloseSubpath(path_outline);
				float temp3[] = {0.5, 0.0717331*offset_factor, 0.105022 + 0.0567189*offset_factor, 0.587977 - 0.0127004*offset_factor, 0.5, 0.824045 - 0.0465998*offset_factor, 0.894978 - 0.0567189*offset_factor, 0.587977 - 0.0127004*offset_factor};
				CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp3[0], tile_size*(float)(ii/grid_size) + height*temp3[1]);
				for (uint jj = 1; jj < 4; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp3[2*jj], tile_size*(float)(ii/grid_size) + height*temp3[2*jj+1]);
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
			}
			else if (sides == 103) {
				float temp2[] = {0.352115, 1.0 - 1., 0.318793, 1.0 - 0.318182, 0.829092, 1.0 - 0.318182};
				CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp2[0], tile_size*(float)(ii/grid_size) + height*temp2[1]);
				CGPathMoveToPoint(path_outline, NULL, tile_size*(float)(ii%grid_size) + height*temp2[0], tile_size*(float)(ii/grid_size) + height*temp2[1]);
				for (uint jj = 1; jj < 3; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp2[2*jj], tile_size*(float)(ii/grid_size) + height*temp2[2*jj+1]);
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
					CGPathAddLineToPoint(path_outline, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
				CGPathCloseSubpath(path_outline);
				float temp3[] = {0.352115 + 0.034245*offset_factor, 0.118733*offset_factor, 0.318793 + 0.0420026*offset_factor, 0.681818 - 0.04*offset_factor, 0.829092 - 0.0767989*offset_factor, 0.681818 - 0.04*offset_factor};
				CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp3[0], tile_size*(float)(ii/grid_size) + height*temp3[1]);
				for (uint jj = 1; jj < 3; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp3[2*jj], tile_size*(float)(ii/grid_size) + height*temp3[2*jj+1]);
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
			}
			else if (sides == 105) {
				float temp2[] = {1.0 - 0.352115, 1.0 - 1., 1.0 - 0.318793, 1.0 - 0.318182, 1.0 - 0.829092, 1.0 - 0.318182};
				CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp2[0], tile_size*(float)(ii/grid_size) + height*temp2[1]);
				CGPathMoveToPoint(path_outline, NULL, tile_size*(float)(ii%grid_size) + height*temp2[0], tile_size*(float)(ii/grid_size) + height*temp2[1]);
				for (uint jj = 1; jj < 3; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp2[2*jj], tile_size*(float)(ii/grid_size) + height*temp2[2*jj+1]);
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
					CGPathAddLineToPoint(path_outline, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
				CGPathCloseSubpath(path_outline);
				float temp3[] = {0.647885 - 0.034245*offset_factor, 0.118733*offset_factor, 0.681207 - 0.0420026*offset_factor, 0.681818 - 0.04*offset_factor, 0.170908 + 0.0767989*offset_factor, 0.681818 - 0.04*offset_factor};
				CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp3[0], tile_size*(float)(ii/grid_size) + height*temp3[1]);
				for (uint jj = 1; jj < 3; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp3[2*jj], tile_size*(float)(ii/grid_size) + height*temp3[2*jj+1]);
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
			}
			else if (sides == 203) {
				float temp2[] = {0.512355, 1.0 - 0.741774, -0.0123553, 1.0 - 0.341613, 1., 1.0 - 0.341613};
				CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp2[0], tile_size*(float)(ii/grid_size) + height*temp2[1]);
				CGPathMoveToPoint(path_outline, NULL, tile_size*(float)(ii%grid_size) + height*temp2[0], tile_size*(float)(ii/grid_size) + height*temp2[1]);
				for (uint jj = 1; jj < 3; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp2[2*jj], tile_size*(float)(ii/grid_size) + height*temp2[2*jj+1]);
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
					CGPathAddLineToPoint(path_outline, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
				CGPathCloseSubpath(path_outline);
				float temp3[] = {0.512355 - 0.0227212*offset_factor/25., 0.258226 + 1.27495*offset_factor/25., -0.0123553 + 2.9603*offset_factor/25., 0.658387 - offset_factor/25., 1. - 2.79502*offset_factor/25., 0.658387 - offset_factor/25.};
				CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp3[0], tile_size*(float)(ii/grid_size) + height*temp3[1]);
				for (uint jj = 1; jj < 3; jj++) {
					point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp3[2*jj], tile_size*(float)(ii/grid_size) + height*temp3[2*jj+1]);
					CGPathAddLineToPoint(path, NULL, point.x, point.y);
				}
				CGPathCloseSubpath(path);
			}
			
			{
				CGContextSaveGState(textureContext);
				CGContextSetShadowWithColor(textureContext, CGSizeMake(1.,1.), 2.0, black);
				CGContextAddPath(textureContext, path);
				CGContextSetGrayFillColor(textureContext, 0.5, 1.0);
				CGContextEOFillPath(textureContext);
				
				CGContextSetShadowWithColor(textureContext, CGSizeMake(-1., -1.), 2.0, white);
				CGContextAddPath(textureContext, path);
				CGContextSetGrayFillColor(textureContext, 0.5, 1.0);
				CGContextEOFillPath(textureContext);

				CGPathRelease(path);
				CGContextRestoreGState(textureContext);
			}

			{
				CGContextSaveGState(textureContext);
				CGContextAddPath(textureContext, path_outline);
				CGContextSetLineWidth(textureContext, 3.0);
				if (texture_num == 0) {
					CGContextSetGrayStrokeColor(textureContext, 0.1, 1.0);
				} else if (texture_num == 1) {
					CGContextSetGrayStrokeColor(textureContext, 0.9, 1.0);
				} else {
					if (lightness > 0.25)
						CGContextSetGrayStrokeColor(textureContext, 0.1, 1.0);
					else
						CGContextSetGrayStrokeColor(textureContext, 0.9, 1.0);
				}
				CGContextSetLineJoin(textureContext,  kCGLineJoinBevel);
				CGContextStrokePath(textureContext);
				CGPathRelease(path_outline);
				CGContextRestoreGState(textureContext);
			}
		}
		CGContextSetGrayFillColor(textureContext, 0.0, 0.5);
		if (texture_num == 0) {
			CGContextSetGrayStrokeColor(textureContext, 0.1, 1.0);
		} else if (texture_num == 1) {
			CGContextSetGrayStrokeColor(textureContext, 0.9, 1.0);
		} else {
			if (lightness > 0.25)
				CGContextSetGrayStrokeColor(textureContext, 0.1, 1.0);
			else
				CGContextSetGrayStrokeColor(textureContext, 0.9, 1.0);
			if (lightness > 0.25)
				CGContextSetGrayFillColor(textureContext, 0.0, 0.5);
			else
				CGContextSetGrayFillColor(textureContext, 1.0, 0.5);
		}
		// Ported to here
		CGContextSetLineWidth(textureContext, 2.0);
		if (outlined) CGContextSetTextDrawingMode(textureContext, kCGTextFillStroke);
		else CGContextSetTextDrawingMode(textureContext, kCGTextFill);
		float shift_y = 0.0, shift_x = 0.0;
		if (sides == 3) shift_y = 2.0;
		if (sides == 104) shift_y = 2.0;
		if (sides == 204) shift_y = 2.0;
		if (sides == 203) shift_x = 2.0;
		if (slanted) shift_x = -2.0;
		if (sides == 103 || sides == 105 || sides == 203) font = [UIFont fontWithName:font.familyName size:0.75*(font.pointSize)];
		if (sides == 105) {
			CGContextScaleCTM(textureContext, -1.0, 1.0);
			CGContextTranslateCTM(textureContext, -texWidth, 0.0);
			for (int ii = 0; ii < [alphabet count]; ii++) {
				CGSize string_size = [[alphabet objectAtIndex:ii] sizeWithFont:font constrainedToSize:CGSizeMake(tile_size,tile_size) lineBreakMode:UILineBreakModeWordWrap];
				[[alphabet objectAtIndex:ii] drawInRect:CGRectMake(texWidth - (shift_x + tile_size*(float)(ii%grid_size)) - tile_size/2 - string_size.width/2, shift_y + tile_size*(float)(ii/grid_size) + (tile_size - string_size.height)/2, string_size.width, string_size.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
			}
		}
		else {
			for (int ii = 0; ii < [alphabet count]; ii++) {
				CGSize string_size = [[alphabet objectAtIndex:ii] sizeWithFont:font constrainedToSize:CGSizeMake(tile_size,tile_size) lineBreakMode:UILineBreakModeWordWrap];
				[[alphabet objectAtIndex:ii] drawInRect:CGRectMake(shift_x + tile_size*(float)(ii%grid_size) + (tile_size - string_size.width)/2, shift_y + tile_size*(float)(ii/grid_size) + (tile_size - string_size.height)/2, string_size.width, string_size.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
			}
		}
	}
	
	UIGraphicsPopContext();

	glBindTexture(GL_TEXTURE_2D, location);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	CGContextRelease(textureContext);
	CGColorSpaceRelease(color_space);
	
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glEnable(GL_TEXTURE_2D);
}

+ (void) generatePolygonOutlineTextureIntoLocation:(GLuint)location withTag:(uint)tag ofSize:(uint)size withBGTexture:(int)texture_num {
	CGMutablePathRef path;
	CGPoint point;
	CGImageRef textureImage = nil;
	float lightness;
	NSInteger texWidth = size;
	NSInteger texHeight = size;
	int grid_size = 4;
	
	NSArray *backgroundTextureArray = [self getBackgroundTextures];
		
	CGColorSpaceRef color_space = CGColorSpaceCreateDeviceGray();	
	GLubyte *textureData = (GLubyte *)calloc(texWidth, texHeight);
	CGContextRef textureContext = CGBitmapContextCreate(textureData,texWidth,texHeight,8,texWidth,color_space,kCGImageAlphaNone);

	UIGraphicsPushContext(textureContext);
	
	CGContextSetShouldAntialias(textureContext, YES);
	float tile_size = (float)size/(float)(grid_size);
	
	if (texture_num > 2) {
		NSString *imagePath = [@"BackgroundTextures/" stringByAppendingString: [[backgroundTextureArray objectAtIndex:(texture_num - 3)] lastPathComponent]];
		textureImage = convertToGreyscale([UIImage imageNamed:imagePath],&lightness);
	}
	
	float height = tile_size;
	float radius = (height - 6.0)/2; // adjust this to change offset of outline from polygon edge
	if (texture_num == 0) {
		CGContextSetGrayFillColor(textureContext, 1.0, 0.6);
		CGContextFillRect(textureContext, CGRectMake(0.0,0.0,texWidth,texHeight));
	} else if (texture_num == 1) {
		CGContextSetGrayFillColor(textureContext, 1.0, 0.6);
		CGContextFillRect(textureContext, CGRectMake(0.0,0.0,texWidth,texHeight));
	} else {
		for (int ii = 0; ii < 16; ii++) {
			CGContextDrawImage(textureContext, CGRectMake(tile_size*(float)(ii%grid_size), tile_size*(float)(ii/grid_size), tile_size, tile_size), textureImage);
		}
	}
	
	path = CGPathCreateMutable();
	uint sides = 3, ii = 0, jj = 0;
	point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 - radius * cosf(2.0f * M_PI * (float)jj/(float)sides));
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	for (uint jj = 1; jj < sides; jj++) {
		point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 - radius * cosf(2.0f * M_PI * (float)jj/(float)sides));
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
	}
	CGPathCloseSubpath(path);

	sides = 4, ii++, jj = 0;
	point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides));
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	for (uint jj = 1; jj < sides; jj++) {
		point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides));
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
	}
	CGPathCloseSubpath(path);
	
	sides = 5, ii++, jj = 0;
	point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 - radius * cosf(2.0f * M_PI * (float)jj/(float)sides));
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	for (uint jj = 1; jj < sides; jj++) {
		point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 - radius * cosf(2.0f * M_PI * (float)jj/(float)sides));
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
	}
	CGPathCloseSubpath(path);

	sides = 6, ii++, jj = 0;
	point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides));
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	for (uint jj = 1; jj < sides; jj++) {
		point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides));
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
	}
	CGPathCloseSubpath(path);

	sides = 8, ii++, jj = 0;
	point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides));
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	for (uint jj = 1; jj < sides; jj++) {
		point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides));
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
	}
	CGPathCloseSubpath(path);

	sides = 10, ii++, jj = 0;
	point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides));
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	for (uint jj = 1; jj < sides; jj++) {
		point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides));
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
	}
	CGPathCloseSubpath(path);

	sides = 12, ii++, jj = 0;
	point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides));
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	for (uint jj = 1; jj < sides; jj++) {
		point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides));
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
	}
	CGPathCloseSubpath(path);

	ii++;
	float temp2[] = {0.5, 1.0 - 0.0871677, 0.879126, 1.0 - 0.456416, 0.5, 1.0 - 1., 0.120874, 1.0 - 0.456416};
	CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp2[0], tile_size*(float)(ii/grid_size) + height*temp2[1]);
	for (uint jj = 1; jj < 4; jj++) {
		point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp2[2*jj], tile_size*(float)(ii/grid_size) + height*temp2[2*jj+1]);
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
	}
	CGPathCloseSubpath(path);

	ii++;
	float temp3[] = {0.0, 0.5, 0.5, 0.191, 1.0, 0.5, 0.5, 0.809};
	CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp3[0], tile_size*(float)(ii/grid_size) + height*temp3[1]);
	for (uint jj = 1; jj < 4; jj++) {
		point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp2[2*jj], tile_size*(float)(ii/grid_size) + height*temp3[2*jj+1]);
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
	}
	CGPathCloseSubpath(path);

	ii++;
	float temp4[] = {0.5, 1.0 - 1., 0.105022, 1.0 - 0.412023, 0.5, 1.0 - 0.175955, 0.894978, 1.0 - 0.412023};
	CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp4[0], tile_size*(float)(ii/grid_size) + height*temp4[1]);
	for (uint jj = 1; jj < 4; jj++) {
		point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp4[2*jj], tile_size*(float)(ii/grid_size) + height*temp4[2*jj+1]);
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
	}
	CGPathCloseSubpath(path);

	ii++;	
	float temp5[] = {0.352115, 1.0 - 1., 0.318793, 1.0 - 0.318182, 0.829092, 1.0 - 0.318182};
	CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp5[0], tile_size*(float)(ii/grid_size) + height*temp5[1]);
	for (uint jj = 1; jj < 3; jj++) {
		point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp5[2*jj], tile_size*(float)(ii/grid_size) + height*temp5[2*jj+1]);
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
	}
	CGPathCloseSubpath(path);

	ii++;
	float temp6[] = {0.512355, 1.0 - 0.741774, -0.0123553, 1.0 - 0.341613, 1., 1.0 - 0.341613};
	CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp6[0], tile_size*(float)(ii/grid_size) + height*temp6[1]);
	for (uint jj = 1; jj < 3; jj++) {
		point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp6[2*jj], tile_size*(float)(ii/grid_size) + height*temp6[2*jj+1]);
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
	}
	CGPathCloseSubpath(path);
	
	ii++;
	ii++;
	float temp20[] = {1.0, 0.5, 0.5, 1.0 - 0.190983, 0.0, 0.5, 0.5, 1.0 - 0.809017};
	CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp20[0], tile_size*(float)(ii/grid_size) + height*temp20[1]);
	for (uint jj = 1; jj < 4; jj++) {
		point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp20[2*jj], tile_size*(float)(ii/grid_size) + height*temp20[2*jj+1]);
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
	}
	CGPathCloseSubpath(path);
	
	ii++;	
	float temp21[] = {1.0 - 0.352115, 1.0 - 1.0, 1.0 - 0.318793, 1.0 - 0.318182, 1.0 - 0.829092, 1.0 - 0.318182};
	CGPathMoveToPoint(path, NULL, tile_size*(float)(ii%grid_size) + height*temp21[0], tile_size*(float)(ii/grid_size) + height*temp21[1]);
	for (uint jj = 1; jj < 3; jj++) {
		point = CGPointMake(tile_size*(float)(ii%grid_size) + height*temp21[2*jj], tile_size*(float)(ii/grid_size) + height*temp21[2*jj+1]);
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
	}
	CGPathCloseSubpath(path);
	
	sides = 4, ii++, jj = 0;
	point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides));
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	for (uint jj = 1; jj < sides; jj++) {
		point = CGPointMake(tile_size*(float)(ii%grid_size) + height/2 + radius * cosf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides), tile_size*(float)(ii/grid_size) + height/2 + radius * sinf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides));
		CGPathAddLineToPoint(path, NULL, point.x, point.y);
	}
	CGPathCloseSubpath(path);
	
	CGContextSaveGState(textureContext);
	CGContextAddPath(textureContext, path);

	CGContextSetGrayStrokeColor(textureContext, 1.0, 1.0);
	
	CGContextSetLineWidth(textureContext, 5.0);
	CGContextSetLineJoin(textureContext,  kCGLineJoinMiter);
	CGContextStrokePath(textureContext);
	CGPathRelease(path);
	CGContextRestoreGState(textureContext);
	
	CGContextSetGrayFillColor(textureContext, 1.0, 1.0);
	
	textureImage = [UIImage imageNamed:@"lock.png"].CGImage;
	NSInteger texImageWidth = CGImageGetWidth(textureImage);//*size/128;
	NSInteger texImageHeight = CGImageGetHeight(textureImage);//*size/128;
	CGContextDrawImage(textureContext, CGRectMake(3.0*512.0/4.0 + 32.0, 3.0*512.0/4.0 + 32.0, (float)texImageWidth/2, (float)texImageHeight/2), textureImage);
	
	UIGraphicsPopContext();
	
	glBindTexture(GL_TEXTURE_2D, location);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, texWidth, texHeight, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	CGContextRelease(textureContext);
	CGColorSpaceRelease(color_space);
	
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glEnable(GL_TEXTURE_2D);
}

+ (void) generateGLPolygonTextureIntoLocation:(GLuint)location withTag:(uint)tag ofSize:(uint)size withSides:(uint)sides withBGTexture:(int)texture_num {
	NSInteger texWidth = size;
	NSInteger texHeight = size;
	
	NSArray *backgroundTextureArray = [self getBackgroundTextures];
	
	CGColorSpaceRef color_space = CGColorSpaceCreateDeviceGray();	
	GLubyte *textureData = (GLubyte *)malloc(texWidth * texHeight);
	CGContextRef textureContext = CGBitmapContextCreate(textureData,texWidth,texHeight,8,texWidth,color_space,kCGImageAlphaNone);

	UIGraphicsPushContext(textureContext);
	
	CGContextSetShouldAntialias(textureContext, YES);
	CGMutablePathRef path;
	CGPoint point;
	float tile_size = (float)size/2.0;
	
	CGImageRef textureImage = nil;
	float lightness;
	
	if (texture_num > 2) {
		NSString *imagePath = [@"BackgroundTextures/" stringByAppendingString: [[backgroundTextureArray objectAtIndex:(texture_num - 3)] lastPathComponent]];
		textureImage = convertToGreyscale([UIImage imageNamed:imagePath],&lightness);
	}
	
	float height = tile_size;
	float radius = (height - 6.0)/2; // adjust this to change offset of outline from polygon edge
	if (texture_num == 0) {
		CGContextSetGrayFillColor(textureContext, 1.0, 0.6);
		CGContextFillRect(textureContext, CGRectMake(0.0,0.0,texWidth,texHeight));
	} else if (texture_num == 1) {
		CGContextSetGrayFillColor(textureContext, 1.0, 0.6);
		CGContextFillRect(textureContext, CGRectMake(0.0,0.0,texWidth,texHeight));
	} else {
		CGContextDrawImage(textureContext, CGRectMake(((float)size - tile_size)/2, ((float)size - tile_size)/2, tile_size, tile_size), textureImage);
	}
	
	path = CGPathCreateMutable();
	uint jj = 0;
	float offset = ((float)size - tile_size)/2;
	switch (sides) {
		case 3:
			point = CGPointMake(offset + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides), offset + height/2 - radius * cosf(2.0f * M_PI * (float)jj/(float)sides));
			CGPathMoveToPoint(path, NULL, point.x, point.y);
			for (uint jj = 1; jj < sides; jj++) {
				point = CGPointMake(offset + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides), offset + height/2 - radius * cosf(2.0f * M_PI * (float)jj/(float)sides));
				CGPathAddLineToPoint(path, NULL, point.x, point.y);
			}
			break;
		case 4:
			point = CGPointMake(offset + height/2 + radius * cosf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides), offset + height/2 + radius * sinf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides));
			CGPathMoveToPoint(path, NULL, point.x, point.y);
			for (uint jj = 1; jj < sides; jj++) {
				point = CGPointMake(offset + height/2 + radius * cosf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides), offset + height/2 + radius * sinf(0.25f*M_PI + 2.0f * M_PI * (float)jj/(float)sides));
				CGPathAddLineToPoint(path, NULL, point.x, point.y);
			}
			break;
		case 5:
			point = CGPointMake(offset + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides), offset + height/2 - radius * cosf(2.0f * M_PI * (float)jj/(float)sides));
			CGPathMoveToPoint(path, NULL, point.x, point.y);
			for (uint jj = 1; jj < sides; jj++) {
				point = CGPointMake(offset + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides), offset + height/2 - radius * cosf(2.0f * M_PI * (float)jj/(float)sides));
				CGPathAddLineToPoint(path, NULL, point.x, point.y);
			}
			break;
		case 6:
			point = CGPointMake(offset + height/2 + radius * cosf(2.0f * M_PI * (float)jj/(float)sides), offset + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides));
			CGPathMoveToPoint(path, NULL, point.x, point.y);
			for (uint jj = 1; jj < sides; jj++) {
				point = CGPointMake(offset + height/2 + radius * cosf(2.0f * M_PI * (float)jj/(float)sides), offset + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides));
				CGPathAddLineToPoint(path, NULL, point.x, point.y);
			}
			break;
		case 8:
			point = CGPointMake(offset + height/2 + radius * cosf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides), offset + height/2 + radius * sinf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides));
			CGPathMoveToPoint(path, NULL, point.x, point.y);
			for (uint jj = 1; jj < sides; jj++) {
				point = CGPointMake(offset + height/2 + radius * cosf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides), offset + height/2 + radius * sinf(M_PI/8.0f + 2.0f * M_PI * (float)jj/(float)sides));
				CGPathAddLineToPoint(path, NULL, point.x, point.y);
			}
			break;
		case 10:
			point = CGPointMake(offset + height/2 + radius * cosf(2.0f * M_PI * (float)jj/(float)sides), offset + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides));
			CGPathMoveToPoint(path, NULL, point.x, point.y);
			for (uint jj = 1; jj < sides; jj++) {
				point = CGPointMake(offset + height/2 + radius * cosf(2.0f * M_PI * (float)jj/(float)sides), offset + height/2 + radius * sinf(2.0f * M_PI * (float)jj/(float)sides));
				CGPathAddLineToPoint(path, NULL, point.x, point.y);
			}
			break;
		case 12:
			point = CGPointMake(offset + height/2 + radius * cosf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides), offset + height/2 + radius * sinf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides));
			CGPathMoveToPoint(path, NULL, point.x, point.y);
			for (uint jj = 1; jj < sides; jj++) {
				point = CGPointMake(offset + height/2 + radius * cosf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides), offset + height/2 + radius * sinf(M_PI/12.0f + 2.0f * M_PI * (float)jj/(float)sides));
				CGPathAddLineToPoint(path, NULL, point.x, point.y);
			}
			break;
		default:
			break;
	}
	CGPathCloseSubpath(path);
	CGPathMoveToPoint(path, NULL, 0.0, 0.0);
	CGPathAddLineToPoint(path, NULL, size, 0.0);
	CGPathAddLineToPoint(path, NULL, size, size);
	CGPathAddLineToPoint(path, NULL, 0.0, size);
	CGPathCloseSubpath(path);
	
	CGContextSaveGState(textureContext);
	
	CGContextAddPath(textureContext, path);
	CGContextSetGrayFillColor(textureContext, 0.0, 1.0);
	CGContextEOFillPath(textureContext);

	CGPathRelease(path);
	CGContextRestoreGState(textureContext);
	
	UIGraphicsPopContext();
	
	glBindTexture(GL_TEXTURE_2D, location);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, texWidth, texHeight, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	CGContextRelease(textureContext);
	CGColorSpaceRelease(color_space);
}

+ (UIImage *) generateCellBackgroundTextureWithText:(NSString *)string withTag:(uint)tag ofWidth:(uint)width ofHeight:(uint)height withColor:(UIColor *)color {
	return [self generateCellBackgroundTextureWithText:string withTag:tag ofWidth:width ofHeight:height withColor:color withBorderWidth:5.0 withPolygon:YES];
}

+ (UIImage *) generateCellBackgroundTextureWithText:(NSString *)string withTag:(uint)tag ofWidth:(uint)width ofHeight:(uint)height withColor:(UIColor *)color withBorderWidth:(CGFloat)border_width {
	return [self generateCellBackgroundTextureWithText:string withTag:tag ofWidth:width ofHeight:height withColor:color withBorderWidth:border_width withPolygon:YES];	
}

+ (UIImage *) generateCellBackgroundTextureWithText:(NSString *)string withTag:(uint)tag ofWidth:(uint)width ofHeight:(uint)height withColor:(UIColor *)color withBorderWidth:(CGFloat)border_width withPolygon:(BOOL)polygonQ {
	CGColorSpaceRef color_space = CGColorSpaceCreateDeviceRGB();
	GLubyte *textureData = (GLubyte *)malloc(width * height * 4);
	CGContextRef textureContext = CGBitmapContextCreate(textureData,width,height,8,width * 4,color_space,kCGImageAlphaPremultipliedLast);
	CGContextSetFillColorWithColor(textureContext, [color CGColor]);
	CGContextFillRect(textureContext, CGRectMake(0.0, 0.0, (float)width, (float)height));
	UIGraphicsPushContext(textureContext);
	
	CGContextSetShouldAntialias(textureContext, YES);
	CGMutablePathRef path;
	float offset_x, offset_y;
	CGPoint point;
	CGColorRef white = [[UIColor colorWithWhite:1.0 alpha:1.0] CGColor];
	CGColorRef black = [[UIColor colorWithWhite:0.0 alpha:1.0] CGColor];
		
	offset_x = 0.0;
	offset_y = 0.0;
	path = CGPathCreateMutable();
	
	point = CGPointMake(border_width + offset_x, border_width + offset_y);
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(border_width + offset_x, height - border_width + offset_y);
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(width - border_width + offset_x, height - border_width + offset_y);
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(width - border_width + offset_x, border_width + offset_y);
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	CGPathCloseSubpath(path);
	
	point = CGPointMake(0.0 + offset_x, 0.0 + offset_y);
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(0.0 + offset_x, height + offset_y);
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(width + offset_x, height + offset_y);
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(width + offset_x, 0.0 + offset_y);
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	CGPathCloseSubpath(path);
	
	CGContextSaveGState(textureContext);
	
	CGContextSetShadowWithColor(textureContext, CGSizeMake(2.0, 2.0), 4.0, white);
	CGContextAddPath(textureContext, path);
	CGContextSetGrayFillColor(textureContext, 0.5, 1.0);
	CGContextEOFillPath(textureContext);
	
	CGContextSetShadowWithColor(textureContext, CGSizeMake(-2.0, -2.0), 4.0, black);
	CGContextAddPath(textureContext, path);
	CGContextSetGrayFillColor(textureContext, 0.5, 1.0);
	CGContextEOFillPath(textureContext);
	CGPathRelease(path);
	CGContextRestoreGState(textureContext);
	
	if (polygonQ) {
		path = CGPathCreateMutable();
		float radius = (height - 20.0)/2;
		point = CGPointMake(height/2 + radius, height/2);
		CGPathMoveToPoint(path, NULL, point.x, point.y);
		for (uint ii = 1; ii < tag+1; ii++) {
			point = CGPointMake(height/2 + radius * cosf(2.0f * M_PI * (float)ii/(float)tag), height/2 + radius * sinf(2.0f * M_PI * (float)ii/(float)tag));
			CGPathAddLineToPoint(path, NULL, point.x, point.y);
		}
		CGPathCloseSubpath(path);
		CGContextSaveGState(textureContext);
		CGContextSetShadowWithColor(textureContext, CGSizeMake(2.0, 2.0), 4.0, white);
		CGContextAddPath(textureContext, path);
		CGContextSetGrayFillColor(textureContext, 0.5, 1.0);
		CGContextFillPath(textureContext);
		CGContextSetShadowWithColor(textureContext, CGSizeMake(-2.0, -2.0), 4.0, black);
		CGContextAddPath(textureContext, path);
		CGContextSetGrayFillColor(textureContext, 0.5, 1.0);
		CGContextFillPath(textureContext);
		CGPathRelease(path);
		CGContextRestoreGState(textureContext);
		UIGraphicsPopContext();
	}

	if (![string isEqual:@""]) {
		UIGraphicsPushContext(textureContext);
		CGSize string_size = [string sizeWithFont:[UIFont boldSystemFontOfSize:30.0] constrainedToSize:CGSizeMake(width,height) lineBreakMode:UILineBreakModeWordWrap];
		CGContextScaleCTM(textureContext, 1.0, -1.0);
		CGContextSetRGBFillColor(textureContext, 0.1, 0.0, 0.0, 1.0);
		CGContextSetShadowWithColor(textureContext, CGSizeMake(2.0, 2.0), 4.0, white);
		[string drawInRect:CGRectMake(height + 10.0, -(height + string_size.height)/2, string_size.width, string_size.height) withFont:[UIFont boldSystemFontOfSize:30.0] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
		CGContextSetShadowWithColor(textureContext, CGSizeMake(-2.0, -2.0), 4.0, black);
		[string drawInRect:CGRectMake(height + 10.0, -(height + string_size.height)/2, string_size.width, string_size.height) withFont:[UIFont boldSystemFontOfSize:30.0] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
		UIGraphicsPopContext();
	}
	
	for (int ii=0;ii<height;ii+=1) {
		for (int kk=0;kk<4*width;kk+=4) {
			if (sinf((float)(ii)/(1))*sinf((float)(kk/4)/(1)) > 1/8) {
				float ran = frandom(0.75, 1.0);
				for (int jj=0;jj<3;jj+=1) {
					textureData[4*width*ii + kk + jj] = ran*textureData[4*width*ii + kk + jj];//(GLubyte)((0.5 + 0.5*c * c) * textureData[4*texWidth*ii + kk + jj]);
				}
			}
		}
	}

	CGImageRef myImage = CGBitmapContextCreateImage(textureContext);
	UIImage *image = [UIImage imageWithCGImage:myImage];
	CGImageRelease(myImage);
	CGContextRelease(textureContext);
	CGColorSpaceRelease(color_space);
	free(textureData);
	
	return image;
}

+ (void) generateTextureWithGradientLocations:(CGFloat *)locations withColors:(CGFloat *)colors intoLocation:(GLuint)location withTag:(uint)tag {
	[self generateTextureWithGradientLocations:locations withColors:colors intoLocation:location withTag:tag withSize:32];
}

+ (void) generateTextureWithGradientLocations:(CGFloat *)locations withColors:(CGFloat *)colors intoLocation:(GLuint)location withTag:(uint)tag withSize:(NSInteger)size {
	
	NSInteger texWidth = size;//(texShapeWidth > texLetterWidth)?(texShapeWidth):(texLetterWidth);
	NSInteger texHeight = size;//(texShapeHeight > texLetterHeight)?(texShapeHeight):(texLetterHeight);
	
	GLubyte *textureData = (GLubyte *)calloc(texWidth * texHeight, 4);
	CGColorSpaceRef color_space = CGColorSpaceCreateDeviceRGB();
	CGContextRef textureContext = CGBitmapContextCreate(textureData,texWidth,texHeight,8,texWidth * 4,color_space,kCGImageAlphaPremultipliedLast);
	CGContextSetGrayFillColor(textureContext, 1.0, 1.0);
	CGContextFillRect(textureContext, CGRectMake(0.0, 0.0, (float)texWidth/2, (float)texHeight));

	CGContextSaveGState(textureContext);
    CGContextBeginPath (textureContext);
    CGContextAddRect (textureContext, CGRectMake(0.0, 0.0, (float)texWidth/2, (float)texHeight));
    CGContextClosePath (textureContext);
    CGContextClip (textureContext);

	CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
	size_t size_of_locations = sizeof(locations)/2;
	CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, colors, locations, size_of_locations);
	CGPoint myStartPoint, myEndPoint;
	myStartPoint.x = 0.0;
	myStartPoint.y = 0.0;
	myEndPoint.x = 0.0;
	myEndPoint.y = texHeight;
	CGContextDrawLinearGradient(textureContext, myGradient, myStartPoint, myEndPoint, 0);
	CGColorSpaceRelease(myColorspace);
	CGGradientRelease(myGradient);
	CGContextRestoreGState(textureContext);
	
	UIGraphicsPushContext(textureContext);
	GLfloat background_color[2] = {0.0,1.0};
	GLfloat font_fill_color[2] = {1.0,1.0};
	GLfloat font_stroke_color[2] = {1.0,1.0};
	background_color[0] = 1.0, background_color[1] = 0.0;
	draw_numbers(textureContext,[UIFont fontWithName:@"Helvetica-Bold" size:40],size,texWidth,0.55,background_color,font_fill_color,font_stroke_color);
	draw_symbols(textureContext,[UIFont fontWithName:@"Helvetica-Bold" size:40],size,texWidth,0.67,background_color,font_fill_color,font_stroke_color);
	draw_labels(textureContext,size,[UIFont fontWithName:@"Helvetica-Bold" size:40]);
	UIGraphicsPopContext();

	CGContextRelease(textureContext);
	CGColorSpaceRelease(color_space);
	
	glBindTexture(GL_TEXTURE_2D, location);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glEnable(GL_TEXTURE_2D);
}

@end

//	for (int ii=0;ii<texHeight;ii+=1) {
//		for (int kk=0;kk<4*texWidth;kk+=4) {
//			float ran = frandom(0.75, 1.0);
//			if (4*ii == kk || 4*ii == (4*texWidth - kk)) // cross pattern
//			if (4*ii < kk || 4*ii < (4*texWidth - kk))
//			if ((ii - 64)*(ii - 64) + (kk/4 - 64)*(kk/4 - 64) < 50*50)
//			if (cosf((float)((ii-64)*(kk/4-64)/64)) < 0.5)
//			if (sinf((float)(ii - 64)/4)*sinf((float)(kk/4 - 64)/4) > 1/8)
//				if (((int)(floor((float)ii/8))*(int)(floor((float)kk/32))%2 == 1) && tag == 27)
//					for (int jj=0;jj<4;jj+=1) {
//						textureData[4*texWidth*ii + kk + jj] = (GLubyte)(0.75 * textureData[4*texWidth*ii + kk + jj]);
//					}
//				for (int jj=0;jj<4;jj+=1) {
//					textureData[4*texWidth*ii + kk + jj] = (GLubyte)(ran * textureData[4*texWidth*ii + kk + jj]);
//				}
//		}
//	}

// this gives vertical stripes
//	for (int ii=0;ii<texHeight;ii+=1) {
//		for (int kk=0;kk<4*texWidth;kk+=4) {
//			for (int jj=0;jj<4;jj+=1) {
//				float c = cosf((float)kk/8);
//				textureData[4*texWidth*ii + kk + jj] = (GLubyte)((0.5 + 0.5*c * c) * textureData[4*texWidth*ii + kk + jj]);
//			}
//		}
//	}


// this gives horizontal stripes - cool with a longer period
//	for (int ii=0;ii<texHeight;ii+=1) {
//		for (int kk=0;kk<4*texWidth;kk+=4) {
//			for (int jj=0;jj<4;jj+=1) {
//				float c = cosf((float)ii/3);
//				textureData[4*texWidth*ii + kk + jj] = (GLubyte)((0.5 + 0.5*c * c) * textureData[4*texWidth*ii + kk + jj]);
//			}
//		}
//	}


