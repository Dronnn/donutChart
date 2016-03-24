//
//  MFDonutChartView.m
//  Megafon
//
//  Created by Andrey Vanyurin on 17/02/15.
//  Copyright (c) 2015 Andrey Vanyurin. All rights reserved.
//

#import "MFDonutChartView.h"
#import <QuartzCore/QuartzCore.h>

#define DEG_TO_RAD(angle) angle * M_PI / 180.0f
#define RAD_TO_DEG(radians) ((radians) * (180.0 / M_PI))

@interface MFDonutChartView()

@property (nonatomic, strong) NSMutableArray* arcs;
@property (nonatomic)         BOOL showApearAnim;

@end

@implementation MFDonutChartView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if (self = [super initWithCoder:coder])
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.contentMode     = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor clearColor];

    self.showApearAnim   = YES;
    self.lineWidth       = 20;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

-(void)reloadData
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    //Name Drawing
    [self nameOfChart:rect];

    //Percent Drawing
    [self numberOnChart:rect];

    //Chart Drawing
    [self drawChart:rect];
}

- (void)drawChart:(CGRect)rect
{
    //Preparing
    CGFloat theHalf = rect.size.width/2;
    CGFloat radius;

    CGFloat centerX = theHalf;
    CGFloat centerY = rect.size.height/2;

    //Chart Drawing
    CGFloat sum             = 0.0f;
    NSUInteger slicesCount = [self.dataSource numberOfSlicesInDonutChartView:self];
    self.arcs              = [NSMutableArray arrayWithCapacity:slicesCount];

    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];

    for (int i = 0; i < slicesCount; i++)
        sum += [self.dataSource donutChartView:self valueForSliceAtIndex:i];

    CGFloat slicesInterval = 0.7;
    if ([self.dataSource respondsToSelector:@selector(slicesIntervalForDonutChartView:)])
        slicesInterval = [self.dataSource slicesIntervalForDonutChartView:self];
    
    CGFloat intervalAngle = DEG_TO_RAD(slicesCount == 1 ? 0 : slicesInterval);
    CGFloat intervalValue = intervalAngle * sum / (M_PI * 2 - 2 * slicesCount * intervalAngle);
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = 0.0f;
    CALayer* prevLayer = nil;

    for (int i = 0; i < slicesCount; i++)
    {
        CGFloat value = [self.dataSource donutChartView:self valueForSliceAtIndex:i];

        if ([self.dataSource respondsToSelector:@selector(donutChartView:lineWidtForSliceAtIndex:)])
            self.lineWidth = [self.dataSource donutChartView:self lineWidtForSliceAtIndex:i];

        radius = theHalf - self.lineWidth / 2 - 5.0f;
        if ([self.dataSource respondsToSelector:@selector(donutChartView:selectedLineIncreaseWidthForSliceAtIndex:)])
            radius += [self.dataSource donutChartView:self selectedLineIncreaseWidthForSliceAtIndex:i];


        endAngle = startAngle + (M_PI * 2 * (value + intervalValue * 2) / (sum + slicesCount * intervalValue * 2)) - intervalAngle;

        [self.arcs addObject:[NSValue valueWithCGPoint:CGPointMake(RAD_TO_DEG(startAngle), RAD_TO_DEG(endAngle))]];

        UIColor* drawColor = [self.dataSource donutChartView:self colorForSliceAtIndex:i];

        CGMutablePathRef path = CGPathCreateMutable();

        CGPathAddArc(path, NULL, centerX, centerY, radius, startAngle, endAngle, NO);

        CAShapeLayer* progressLayer = [CAShapeLayer layer];
        progressLayer.frame         = self.bounds;
        progressLayer.lineWidth     = self.lineWidth;
        progressLayer.strokeColor   = drawColor.CGColor;
        progressLayer.fillColor     = nil;
        progressLayer.strokeStart   = 0.0f;
        progressLayer.strokeEnd     = 1.0f;
        
        if (self.showShadow)
        {
            progressLayer.shadowColor   = [[UIColor blackColor] CGColor];
            progressLayer.shadowOffset  = CGSizeMake(0.0f, 2.5f);
            progressLayer.shadowRadius  = 2.0f;
            progressLayer.shadowOpacity = 0.3f;
        }

        progressLayer.path = path;
        CGPathRelease(path);

        if (prevLayer == nil)
            [self.layer addSublayer:progressLayer];
        else
            [self.layer insertSublayer:progressLayer below:prevLayer];

        if (self.showApearAnim)
            [self addAnimationToLayer:progressLayer];

        prevLayer = progressLayer;

        startAngle = endAngle + intervalAngle;
    }
    self.showApearAnim = NO;
}
- (void)addAnimationToLayer:(CAShapeLayer*)progressLayer
{
    CABasicAnimation* animation   = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue           = [NSNumber numberWithFloat:progressLayer.strokeStart];
    animation.toValue             = [NSNumber numberWithFloat:progressLayer.strokeEnd];
    animation.duration            = 1.0f;
    animation.removedOnCompletion = YES;

    [progressLayer addAnimation:animation forKey:@"animation"];
}

// Touches
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    touchPoint.y = self.bounds.size.height - touchPoint.y;
    NSUInteger slicesCount = [self.dataSource numberOfSlicesInDonutChartView:self];
    for (int i = 0; i < slicesCount; i++)
    {
        if ([self isPoint:touchPoint onArc:((NSValue*)self.arcs[i]).CGPointValue])
        {
            if ([self.dataSource respondsToSelector:@selector(donutChartView:numberOfSelectedSegment:)])
                [self.dataSource donutChartView:self numberOfSelectedSegment:i];
        }
    }
}

- (BOOL) isPoint:(CGPoint)point onArc:(CGPoint)arc
{
    CGFloat theHalf = self.frame.size.width / 2;
    CGFloat lineWidth = self.lineWidth + 5;

    CGFloat radius = theHalf - lineWidth / 2;

    CGFloat distanceCenterAndPoint = [self distanceBetweenFirstPiont:CGPointMake(theHalf, self.frame.size.height / 2) andSecondPoint:point];

    if (distanceCenterAndPoint > radius - 30 && distanceCenterAndPoint < radius + 10 )
    {
        CGFloat angle = [self angleToPoint:point];
        if (angle >= arc.x && angle <= arc.y)
        {
            return YES;
        }
    }
    return NO;
}

- (CGFloat) distanceBetweenFirstPiont:(CGPoint)from andSecondPoint:(CGPoint)to
{
    CGFloat dx = from.x - to.x;
    CGFloat dy = from.y - to.y;
    return sqrtf(dx * dx + dy * dy);
}

- (CGFloat)angleToPoint:(CGPoint)point
{
    NSInteger x = self.frame.size.width / 2;
    NSInteger y = self.frame.size.height / 2;
    CGFloat dx = point.x - x;
    CGFloat dy = point.y - y;
    CGFloat radians = atan2(dy,dx);
    CGFloat degrees = RAD_TO_DEG(radians);

    if (degrees < 0)
        return fabs(degrees);
    else if (degrees < 90 && degrees > 0)
        return -degrees;
    else
        return 360 - degrees;
}

- (void)numberOnChart:(CGRect)rect
{
    CGFloat textMaxWidth = rect.size.width - 40;

    if ([self.dataSource respondsToSelector:@selector(donutChartViewTitleNumber:)])
    {
        NSString* textContent = [self.dataSource donutChartViewTitleNumber:self];
        if ([textContent isEqualToString:@""]) return;
        textContent = [textContent stringByAppendingString:@" ₽"];
        if ([textContent length] > 10)
            textContent = [[textContent substringToIndex:10] stringByAppendingString:@"..."];
        CGRect textRect = CGRectIntegral(CGRectMake((rect.size.width / 2) - textMaxWidth / 2, rect.size.height / 2 - 20, textMaxWidth, 45));
        [[UIColor blackColor] setFill];

        UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:22];

        NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        textStyle.lineBreakMode = NSLineBreakByClipping;
        textStyle.alignment = NSTextAlignmentCenter;

        [textContent drawInRect:textRect withAttributes:@{NSFontAttributeName:font,
                                                          NSParagraphStyleAttributeName:textStyle}];
    }
}

- (void)nameOfChart:(CGRect)rect
{
    CGFloat textMaxWidth = rect.size.width - 40;

    if ([self.dataSource respondsToSelector:@selector(donutChartViewTitleDiagramName:)])
    {
        NSString* unitContent = [self.dataSource donutChartViewTitleDiagramName:self];
        CGRect unitRect = CGRectIntegral(CGRectMake((rect.size.width / 2) - textMaxWidth / 2, rect.size.height / 2, textMaxWidth, 45));
        [[UIColor blackColor] setFill];
        UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Light" size:[unitContent length] > 17 ? 15 : 18];

        NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        textStyle.lineBreakMode = NSLineBreakByWordWrapping;
        textStyle.alignment = NSTextAlignmentCenter;

        [unitContent drawInRect:unitRect withAttributes:@{NSFontAttributeName:font,
                                                          NSParagraphStyleAttributeName:textStyle}];

    }
}

@end
