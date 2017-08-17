//
//  DCRoundSwitchToggleLayer.m
//
//  Created by Patrick Richards on 29/06/11.
//  MIT License.
//
//  http://twitter.com/patr
//  http://domesticcat.com.au/projects
//  http://github.com/domesticcatsoftware/DCRoundSwitch
//

#import "DCRoundSwitchToggleLayer.h"

@implementation DCRoundSwitchToggleLayer
@synthesize onString, offString, onTintColor;
@synthesize drawOnTint;
@synthesize clip;
@synthesize labelFont;



- (id)initWithOnString:(NSString *)anOnString offString:(NSString *)anOffString onTintColor:(UIColor *)anOnTintColor
{
	if ((self = [super init]))
	{
		self.onString = anOnString;
		self.offString = anOffString;
		self.onTintColor = anOnTintColor;
	}

	return self;
}

- (UIFont *)labelFont
{
	return [UIFont boldSystemFontOfSize:ceilf(self.bounds.size.height * .6)];
}

- (void)drawInContext:(CGContextRef)context
{
	CGFloat knobRadius = self.bounds.size.height - 2.0;
	CGFloat knobCenter = self.bounds.size.width / 2.0;
	CGRect knobRect = CGRectMake(knobCenter - knobRadius / 2.0, 1.0, knobRadius, knobRadius);

	if (self.clip)
	{
		UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-self.frame.origin.x + 0.5, 0, self.bounds.size.width / 2.0 + self.bounds.size.height / 2.0 - 1.5, self.bounds.size.height) cornerRadius:self.bounds.size.height / 2.0];
		CGContextAddPath(context, bezierPath.CGPath);
		CGContextClip(context);
	}

	// on tint color
	if (self.drawOnTint)
	{
		CGContextSetFillColorWithColor(context, self.onTintColor.CGColor);
		CGContextFillRect(context, CGRectMake(0, 0, knobCenter, self.bounds.size.height));
	}

	// off tint color (white)
	CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.963 alpha:1.0].CGColor);
	CGContextFillRect(context, CGRectMake(knobCenter, 0, self.bounds.size.width - knobCenter, self.bounds.size.height));

	// knob shadow
	CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 1.5, [UIColor colorWithWhite:0.2 alpha:1.0].CGColor);
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.42 alpha:1.0].CGColor);
	CGContextSetLineWidth(context, 1.0);
	CGContextStrokeEllipseInRect(context, knobRect);
	CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 0, NULL);
	

	// strings
	CGFloat textSpaceWidth = (self.bounds.size.width / 2) - (knobRadius / 2);

	UIGraphicsPushContext(context);

	// 'ON' state label (self.onString)
	
    CGSize onTextSize = [self.onString sizeWithAttributes:
                         @{NSFontAttributeName:
                               self.labelFont}];
    
	CGPoint onTextPoint = CGPointMake((textSpaceWidth - onTextSize.width) / 2.0 + knobRadius * .15, floorf((self.bounds.size.height - onTextSize.height) / 2.0) + 1.0);
//	[[UIColor colorWithWhite:0.45 alpha:1.0] set]; // .2 & .4
    
    // Create text attributes
    NSDictionary *textAttributes = @{NSFontAttributeName: self.labelFont,NSForegroundColorAttributeName:[UIColor colorWithWhite:0.45 alpha:1.0]};
    
    // Create string drawing context
    NSStringDrawingContext *drawingContext = [[NSStringDrawingContext alloc] init];
    drawingContext.minimumScaleFactor = 0.5; // Half the font size
    
    CGRect drawRect = CGRectMake(onTextPoint.x, onTextPoint.y - 1.0, 200.0, 100.0);
    [self.onString drawWithRect:drawRect
                 options:NSStringDrawingUsesLineFragmentOrigin
              attributes:textAttributes
                 context:drawingContext];
    
    
//	[self.onString drawAtPoint:CGPointMake(onTextPoint.x, onTextPoint.y - 1.0) withFont:self.labelFont];
//	[[UIColor whiteColor] set];
    
    textAttributes = @{NSFontAttributeName: self.labelFont,NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    CGRect drawRect1 = CGRectMake(onTextPoint.x, onTextPoint.y, 200.0, 100.0);
    [self.onString drawWithRect:drawRect1
                        options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:textAttributes
                        context:drawingContext];
    
//	[self.onString drawAtPoint:onTextPoint withFont:self.labelFont];

	// 'OFF' state label (self.offString)
	
    CGSize offTextSize = [self.offString sizeWithAttributes:
                         @{NSFontAttributeName:
                               self.labelFont}];
	CGPoint offTextPoint = CGPointMake(textSpaceWidth + (textSpaceWidth - offTextSize.width) / 2.0 + knobRadius * .86, floorf((self.bounds.size.height - offTextSize.height) / 2.0) + 1.0);
//	[[UIColor whiteColor] set];
    textAttributes = @{NSFontAttributeName: self.labelFont,NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    CGRect drawRect2 = CGRectMake(offTextPoint.x, offTextPoint.y + 1.0, 200.0, 100.0);
    [self.offString drawWithRect:drawRect2
                        options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:textAttributes
                        context:drawingContext];
    
//	[self.offString drawAtPoint:CGPointMake(offTextPoint.x, offTextPoint.y + 1.0) withFont:self.labelFont];
//	[[UIColor colorWithWhite:0.52 alpha:1.0] set];
    textAttributes = @{NSFontAttributeName: self.labelFont,NSForegroundColorAttributeName:[UIColor colorWithWhite:0.52 alpha:1.0]};
    
    CGRect drawRect3 = CGRectMake(offTextPoint.x, offTextPoint.y, 200.0, 100.0);
    [self.offString drawWithRect:drawRect3
                         options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:textAttributes
                         context:drawingContext];
    
//	[self.offString drawAtPoint:offTextPoint withFont:self.labelFont];

	UIGraphicsPopContext();
}

@end
