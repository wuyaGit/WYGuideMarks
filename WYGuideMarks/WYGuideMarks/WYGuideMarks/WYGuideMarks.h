//
//  WYGuideMarks.h
//  WYGuideMarks
//
//  Created by Highden on 2019/6/14.
//  Copyright © 2019 Highden. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define GUIDEMARKS_CAPTION      @"caption"          //标题文本
#define GUIDEMARKS_CAPTIONATTR  @"captionAttr"      //可变标题文本
#define GUIDEMARKS_RECT         @"rect"             //镂空位置
#define GUIDEMARKS_SHAPE        @"shape"            //镂空形状（有圆形和矩形）
#define GUIDEMARKS_ALIGNMENT    @"alignment"        //标题位置
#define GUIDEMARKS_LABELWIDTH   @"labelWidth"    //标题宽度
#define GUIDEMARKS_CUTOUTRADIUS @"cutoutRadius"     //镂空圆角半径
#define GUIDEMARKS_SHOWARROW    @"showArrow"        //是否显示箭头表示

/// 镂空形状
typedef NS_ENUM(NSInteger, GMarksShape) {
    SHAPE_DEFAULT,  //默认
    SHAPE_CIRCLE,   //圆形
    SHAPE_SQUARE    //矩形
};

/// 左右对其
typedef NS_ENUM(NSInteger, GMarksLabelAlignment) {
    LABEL_ALIGNMENT_CENTER,
    LABEL_ALIGNMENT_LEFT,
    LABEL_ALIGNMENT_RIGHT
};

/// '我知道(继续)'按钮位置
typedef NS_ENUM(NSInteger, GMarksContinueBtnLocation) {
    BUTTON_LOCATION_TOP,
    BUTTON_LOCATION_CENTER,
    BUTTON_LOCATION_BOTTOM
};

@protocol WYGuideMarksViewDelegate;

@interface WYGuideMarks : UIView

@property (nonatomic, weak) id<WYGuideMarksViewDelegate> delegate;

@property (nonatomic, strong) NSArray *guideMarks;
@property (nonatomic, assign) CGFloat cutoutRadius;
@property (nonatomic, strong) UIColor *maskColor;
@property (nonatomic, assign) BOOL enableContinueLabel; //是否显示操作提示
@property (nonatomic, assign) BOOL enableSkipButton;    //是否显示跳过按钮
@property (nonatomic, assign) BOOL enableIKnowButton;   //是否显示'我知道'按钮

- (instancetype)initWithFrame:(CGRect)frame guideMarks:(NSArray *)marks;
- (void)start;
- (void)end;

- (void)goToNextGuideMark;

@end

@protocol WYGuideMarksViewDelegate <NSObject>

@optional
- (void)guideMarksView:(WYGuideMarks *)marksView willNavigateToIndex:(NSUInteger)index;
- (void)guideMarksView:(WYGuideMarks *)marksView didNavigateToIndex:(NSUInteger)index;
- (void)guideMarksViewWillCleanup:(WYGuideMarks *)marksView;
- (void)guideMarksViewDidCleanup:(WYGuideMarks *)marksView;
- (void)guideMarksViewDidClicked:(WYGuideMarks *)marksView atIndex:(NSInteger)index;
- (void)guideMarksViewSkipButtonClicked:(WYGuideMarks *)marksView;
- (BOOL)guideMarksViewWillGoToNext:(WYGuideMarks *)marksView atIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
