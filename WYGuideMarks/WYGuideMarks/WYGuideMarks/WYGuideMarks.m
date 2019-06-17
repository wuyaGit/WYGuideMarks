//
//  WYGuideMarks.m
//  WYGuideMarks
//
//  Created by Highden on 2019/6/14.
//  Copyright © 2019 Highden. All rights reserved.
//

#import "WYGuideMarks.h"

static const CGFloat kAnimationDuration = 0.3f;
static const CGFloat kCutoutRadius = 5.0f;
static const CGFloat kMaxLblWidth = 300.0f;
static const CGFloat kLblSpacing = 15.0f;
static const CGFloat kLabelMargin = 5.0f;
static const CGFloat kMaskAlpha = 0.75f;

NSString *const kSkipButtonText = @"跳过";
NSString *const kContinueLabelText = @"点击继续";

@interface WYGuideMarks () <CAAnimationDelegate>

@property (nonatomic, strong) UILabel *lblCaption;
@property (nonatomic, strong) UILabel *lblContinue;

@property (nonatomic, strong) UIButton *btnSkipCoach;
@property (nonatomic, strong) UIButton *btnIKnow;

@property (nonatomic, strong) UIView *cutoutView;            //镂空view
@property (nonatomic, strong) UIImageView *arrowImageView;   //指示view
@property (nonatomic, strong) CAShapeLayer *mask;

@property (nonatomic) GMarksContinueBtnLocation continueLocation;
@end

@implementation WYGuideMarks {
    NSUInteger _markIndex;
    
}

#pragma mark - cycle life

- (instancetype)initWithFrame:(CGRect)frame guideMarks:(NSArray *)marks {
    if (self = [super initWithFrame:frame]) {
        [self setup];
        
        self.guideMarks = marks;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

// 配置
- (void)setup {
    // 默认值
    self.cutoutRadius = kCutoutRadius;
    self.enableSkipButton = YES;
    self.enableContinueLabel = YES;
    self.enableIKnowButton = YES;
    
    // mask
    self.mask = [CAShapeLayer layer];
    [self.mask setFillRule:kCAFillRuleEvenOdd];
    [self.mask setFillColor:[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:kMaskAlpha].CGColor];
    [self.layer addSublayer:self.mask];
    
    // tap touch
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapEventAction:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    // caption lbl
    self.lblCaption = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {kMaxLblWidth, 0.0f}}];
    self.lblCaption.backgroundColor = [UIColor clearColor];
    self.lblCaption.textColor = [UIColor whiteColor];
    self.lblCaption.font = [UIFont systemFontOfSize:18.f];
    self.lblCaption.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblCaption.textAlignment = NSTextAlignmentCenter;
    self.lblCaption.numberOfLines = 0;
    self.lblCaption.alpha = 0.0f;
    [self addSubview:self.lblCaption];
    
    self.continueLocation = BUTTON_LOCATION_BOTTOM;
    // hidden
    self.hidden = YES;
}

#pragma mark - public

- (void)start {
    self.alpha = 0.0f;
    self.hidden =  NO;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self goToGuideMarksAtIndex:0];
    }];
}

- (void)end {
    [self clearup:NO];
}

#pragma mark - touch event

- (void)userTapEventAction:(id)sender {
    // 当显示‘我知道’，点击背景无效
    if (!self.enableIKnowButton) {
        [self goToGuideMarksAtIndex:_markIndex + 1];
    }
}

- (void)cutoutViewTapAction:(id)sender {
    [self.delegate guideMarksViewDidClicked:self atIndex:_markIndex];
}

- (void)skipButtonClickAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(guideMarksViewSkipButtonClicked:)]) {
        [self.delegate guideMarksViewSkipButtonClicked:self];
    }
    [self goToGuideMarksAtIndex:self.guideMarks.count];
}

- (void)iKnowButtonClickAction:(id)sender {
    [self goToGuideMarksAtIndex:_markIndex + 1];
}

- (void)goToNextGuideMark {
    [self goToGuideMarksAtIndex:_markIndex + 1];
}

#pragma mark - private

- (void)goToGuideMarksAtIndex:(NSUInteger)index {
    if (index >= self.guideMarks.count) {
        [self clearup:YES];
        return;
    }
    
    // Delegate (guideMarksViewWillGoToNext:atIndex:)
    if (self.delegate && [self.delegate respondsToSelector:@selector(guideMarksViewWillGoToNext:atIndex:)]) {
        if (![self.delegate guideMarksViewWillGoToNext:self atIndex:index]) {
            return;
        }
    }
    
    _markIndex = index;
    
    NSDictionary *markDef = [self.guideMarks objectAtIndex:index];
    NSString *markCaption = [markDef objectForKey:GUIDEMARKS_CAPTION];
    CGRect markRect = [[markDef objectForKey:GUIDEMARKS_RECT] CGRectValue];
    GMarksLabelAlignment labelAlignment = [[markDef objectForKey:GUIDEMARKS_ALIGNMENT] integerValue];

    GMarksShape shape = SHAPE_DEFAULT;
    if ([[markDef allKeys] containsObject:GUIDEMARKS_SHAPE]) {
        shape = [[markDef objectForKey:GUIDEMARKS_SHAPE] integerValue];
    }
    
    if ([[markDef allKeys] containsObject:GUIDEMARKS_CUTOUTRADIUS]) {
        self.cutoutRadius = [[markDef objectForKey:GUIDEMARKS_CUTOUTRADIUS] floatValue];
    }else {
        self.cutoutRadius = kCutoutRadius;
    }
    
    BOOL showArrow = NO;
    if ([[markDef allKeys] containsObject:GUIDEMARKS_SHOWARROW]) {
        showArrow = [[markDef objectForKey:GUIDEMARKS_SHOWARROW] boolValue];
    }
    
    NSMutableAttributedString *captionAttr;
    if ([[markDef allKeys] containsObject:GUIDEMARKS_CAPTIONATTR]) {
        captionAttr = (NSMutableAttributedString *)[markDef objectForKey:GUIDEMARKS_CAPTIONATTR];
    }
    
    if (captionAttr) {
        self.lblCaption.attributedText = captionAttr;
    }
    
    CGFloat width = kMaxLblWidth;
    if ([[markDef allKeys] containsObject:GUIDEMARKS_LABELWIDTH]) {
        width = [[markDef objectForKey:GUIDEMARKS_LABELWIDTH] floatValue];
    }

    self.lblCaption.alpha = 0.0f;
    self.lblCaption.frame = (CGRect){{0.0f, 0.0f}, {width, 0.0f}};
    self.lblCaption.text = markCaption;
    [self.lblCaption sizeToFit];
    
    CGFloat x = 0.0f, y = 0.0f;
    CGFloat centerX = self.bounds.size.width/2.0f;
    CGFloat centerY = self.bounds.size.height/2.0f;
    CGPoint markCenter = CGPointMake(CGRectGetMidX(markRect), CGRectGetMidY(markRect));
    
    switch (labelAlignment) {
        case LABEL_ALIGNMENT_RIGHT:
            x = floorf(self.bounds.size.width - self.lblCaption.frame.size.width - kLabelMargin);
            break;
        case LABEL_ALIGNMENT_LEFT:
            x = kLabelMargin;
            break;
        default:
            x = floorf((self.bounds.size.width - self.lblCaption.frame.size.width) / 2.0f);
            break;
    }
    
    if (markCenter.y >= centerY) {
        y = markRect.origin.y - kLblSpacing - self.lblCaption.frame.size.height;
    }else {
        y = markRect.origin.y + kLblSpacing + markRect.size.height;
    }
    
    [self.arrowImageView removeFromSuperview];
    if(showArrow) {
        self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_top"]];
        [self addSubview:self.arrowImageView];

        if (markCenter.y >= centerY) {
            y = markRect.origin.y - kLblSpacing - self.arrowImageView.frame.size.height;
        }
        
        CGRect imageViewFrame = self.arrowImageView.frame;
        imageViewFrame.origin.y = y;
        self.arrowImageView.frame = imageViewFrame;

        CGPoint imageViewCenter = self.arrowImageView.center;
        
        if (markCenter.x<=centerX && markCenter.y<=centerY) {
            imageViewCenter.x = CGRectGetMidX(markRect) + 10;
            self.arrowImageView.center = imageViewCenter;

            self.arrowImageView.image = [UIImage imageNamed:@"arrow_down"];
            [self.arrowImageView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, M_PI)];
        }else if (markCenter.x>=centerX && markCenter.y<=centerY) {
            imageViewCenter.x = CGRectGetMidX(markRect) - 10;
            self.arrowImageView.center = imageViewCenter;
            
            self.arrowImageView.image = [UIImage imageNamed:@"arrow_top"];
        }else if (markCenter.x<=centerX && markCenter.y>=centerY) {
            imageViewCenter.x = CGRectGetMidX(markRect) + 10;
            self.arrowImageView.center = imageViewCenter;
            
            self.arrowImageView.image = [UIImage imageNamed:@"arrow_top"];
            [self.arrowImageView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, M_PI)];
        }else if (markCenter.x>=centerX && markCenter.y>=centerY) {
            imageViewCenter.x = CGRectGetMidX(markRect) - 10;
            self.arrowImageView.center = imageViewCenter;
            
            self.arrowImageView.image = [UIImage imageNamed:@"arrow_down"];
        }

        if (markCenter.y >= centerY) {
            y -= (self.lblCaption.frame.size.height + 2 * kLabelMargin);
        }else {
            y += (self.arrowImageView.frame.size.height + 2 * kLabelMargin);
        }
    }
    
    self.lblCaption.frame = (CGRect){{x, y}, self.lblCaption.frame.size};
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.lblCaption.alpha = 1.0f;
    }];
    
    // Delegate (guideMarksViewDidClicked:atIndex:)
    if (self.delegate && [self.delegate respondsToSelector:@selector(guideMarksViewDidClicked:atIndex:)]) {
        [self.cutoutView removeFromSuperview];
        self.cutoutView = [[UIView alloc] initWithFrame:markRect];
        self.cutoutView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.cutoutView];
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cutoutViewTapAction:)];
        [self.cutoutView addGestureRecognizer:singleFingerTap];
    }
    
    // Delegate (guideMarksView:willNavigateToIndex:)
    if (self.delegate && [self.delegate respondsToSelector:@selector(guideMarksView:willNavigateToIndex:)]) {
        [self.delegate guideMarksView:self willNavigateToIndex:index];
    }
    
    if (index == 0) {
        CGPoint center = CGPointMake(floorf(markRect.origin.x + (markRect.size.width / 2.0f)), floorf(markRect.origin.y + (markRect.size.height / 2.0f)));
        CGRect centerZero = (CGRect){center, CGSizeZero};
        [self setCutoutToRect:centerZero withShape:shape];
    }
    
    [self animateCutoutToRect:markRect withShape:shape];
    
    // 显示'我知道'
    if (self.enableIKnowButton) {
        [self.btnIKnow removeFromSuperview];
        CGFloat x = CGRectGetMidX(self.lblCaption.frame) - 55.0f;
        CGFloat y = CGRectGetMaxY(self.lblCaption.frame) + kLblSpacing;
        if (markCenter.y >= centerY) {
            y = CGRectGetMinY(self.lblCaption.frame) - kLblSpacing - 90.0f;
        }
        
        self.btnIKnow = [[UIButton alloc] initWithFrame:(CGRect){{x, y}, {110.0f, 90.0f}}];
        [self.btnIKnow setImage:[UIImage imageNamed:@"arrow_ok"] forState:UIControlStateNormal];
        [self.btnIKnow setImage:[UIImage imageNamed:@"arrow_ok"] forState:UIControlStateHighlighted];
        [self.btnIKnow addTarget:self action:@selector(iKnowButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnIKnow];
    }
    
    CGFloat lblContinueWidth = self.enableSkipButton ? (70.0/100.0) * self.bounds.size.width : self.bounds.size.width;
    CGFloat btnSkipWidth = self.bounds.size.width - lblContinueWidth;
    
    // 显示提示
    if (self.enableContinueLabel) {
        if (_markIndex == 0) {
            self.lblContinue = [[UILabel alloc] initWithFrame:(CGRect){{0, [self yOriginForContinueLabel]}, {lblContinueWidth, 30.0f}}];
            self.lblContinue.font = [UIFont boldSystemFontOfSize:13.0f];
            self.lblContinue.textAlignment = NSTextAlignmentCenter;
            self.lblContinue.text = kContinueLabelText;
            self.lblContinue.alpha = 0.0f;
            self.lblContinue.backgroundColor = [UIColor whiteColor];
            [self addSubview:self.lblContinue];
            [UIView animateWithDuration:0.3f delay:1.0f options:0 animations:^{
                self.lblContinue.alpha = 1.0f;
            } completion:nil];
        } else if (_markIndex > 0 && self.lblContinue != nil) {
            [self.lblContinue removeFromSuperview];
            self.lblContinue = nil;
        }
    }
    
    // 显示跳过按钮
    if (self.enableSkipButton && _markIndex == 0) {
        self.btnSkipCoach = [[UIButton alloc] initWithFrame:(CGRect){{lblContinueWidth, [self yOriginForContinueLabel]}, {btnSkipWidth, 30.0f}}];
        [self.btnSkipCoach addTarget:self action:@selector(skipButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnSkipCoach setTitle:kSkipButtonText forState:UIControlStateNormal];
        self.btnSkipCoach.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        self.btnSkipCoach.alpha = 0.0f;
        self.btnSkipCoach.tintColor = [UIColor whiteColor];
        [self addSubview:self.btnSkipCoach];
        [UIView animateWithDuration:0.3f delay:1.0f options:0 animations:^{
            self.btnSkipCoach.alpha = 1.0f;
        } completion:nil];
    }
}

- (void)clearup:(BOOL)animated {
    if (self.delegate && [self.delegate respondsToSelector:@selector(guideMarksViewWillCleanup:)]) {
        [self.delegate guideMarksViewWillCleanup:self];
    }
    
    CGFloat duration;
    if (animated) {
        duration = kAnimationDuration;
    }else {
        duration = 0.0f;
    }
    
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(guideMarksViewDidCleanup:)]) {
            [self.delegate guideMarksViewDidCleanup:self];
        }
    }];
}

- (UIImage *)fetchImage:(NSString*)name {
    // Check for iOS 8
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        return [UIImage imageNamed:name];
    }
}

- (void)setCutoutToRect:(CGRect)rect withShape:(GMarksShape)shape {
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath;
    
    if (shape == SHAPE_CIRCLE)
        cutoutPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    else if (shape == SHAPE_SQUARE)
        cutoutPath = [UIBezierPath bezierPathWithRect:rect];
    else
        cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];
    
    [maskPath appendPath:cutoutPath];
    
    // Set the new path
    self.mask.path = maskPath.CGPath;
}

- (void)animateCutoutToRect:(CGRect)rect withShape:(GMarksShape)shape {
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath;
    
    if (shape == SHAPE_CIRCLE)
        cutoutPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    else if (shape == SHAPE_SQUARE)
        cutoutPath = [UIBezierPath bezierPathWithRect:rect];
    else
        cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];
    
    [maskPath appendPath:cutoutPath];
    
    // Animate it
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.delegate = self;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = kAnimationDuration;
    anim.fromValue = (__bridge id)(self.mask.path);
    anim.toValue = (__bridge id)(maskPath.CGPath);
    [self.mask addAnimation:anim forKey:@"path"];
    self.mask.path = maskPath.CGPath;
}

- (CGFloat)yOriginForContinueLabel {
    float topOffset = 20.0f;
    float bottomOffset = 30.f;
    
#ifdef __IPHONE_11_0
    UIEdgeInsets safeInsets = [self getSafeAreaInsets];
    topOffset += safeInsets.top;
    bottomOffset += safeInsets.bottom;
#endif
    
    switch (self.continueLocation) {
        case BUTTON_LOCATION_TOP:
            return topOffset;
        case BUTTON_LOCATION_CENTER:
            return self.bounds.size.height / 2 - 15.0f;
        default:
            return self.bounds.size.height - bottomOffset;
    }
}

#ifdef __IPHONE_11_0
-(UIEdgeInsets)getSafeAreaInsets {
    UIEdgeInsets safeInsets = { .top = 0, .bottom = 0, .left = 0, .right = 0 };
    SEL selector = @selector(safeAreaInsets);
    if ([self respondsToSelector:selector])
    {
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
        invocation.selector = selector;
        invocation.target = self;
        [invocation invoke];
        
        [invocation getReturnValue:&safeInsets];
    }
    return safeInsets;
}
#endif

#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    // Delegate (guideMarksView:didNavigateToIndex:)
    if (self.delegate && [self.delegate respondsToSelector:@selector(guideMarksView:didNavigateToIndex:)]) {
        [self.delegate guideMarksView:self didNavigateToIndex:_markIndex];
    }
}

#pragma mark - getter & setter

- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    [self.mask setFillColor:[maskColor CGColor]];
}

@end
