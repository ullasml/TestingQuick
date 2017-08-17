

#import "UIView+Dashed.h"

@implementation UIView (Dashed)

-(void)lineWithColor:(UIColor *)color type:(LineType)type;
{
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.name isEqualToString:@"DashedTopLine"]){
            [layer removeFromSuperlayer];
        };
    }
    
    NSArray *pattern = (type == Dashed) ? @[@(10), @(10)] : nil;
    self.backgroundColor = (type == Dashed) ? UIColor.clearColor : UIColor.clearColor;
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setName:@"DashedTopLine"];
    [shapeLayer setBounds:self.bounds];
    [shapeLayer setPosition:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
    [shapeLayer setFillColor:color.CGColor];
    [shapeLayer setStrokeColor:color.CGColor];
    [shapeLayer setLineWidth:self.frame.size.width];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:pattern];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, 0, self.frame.size.height*2);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    [[self layer] addSublayer:shapeLayer];
}

@end
