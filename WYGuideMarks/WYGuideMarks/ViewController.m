//
//  ViewController.m
//  WYGuideMarks
//
//  Created by Highden on 2019/6/14.
//  Copyright © 2019 Highden. All rights reserved.
//

#import "ViewController.h"
#import "WYGuideMarks.h"

@interface ViewController () <WYGuideMarksViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Setup coach marks
    CGRect guidemark0 = CGRectMake(([UIScreen mainScreen].bounds.size.width - 125) / 2, 60, 125, 125);
    CGRect guidemark1 = CGRectMake(20, 160, 125, 125);
    CGRect guidemark2 = CGRectMake(220, 160, 60, 80);
    CGRect guidemark3 = CGRectMake(20, 520, 80, 45);
    CGRect guidemark4 = CGRectMake(270, 590, 80, 45);

    // Setup coach marks
    NSArray *guideMarks = @[
                            @{
                                GUIDEMARKS_RECT: [NSValue valueWithCGRect:guidemark0],
                                GUIDEMARKS_CAPTION: @"You can put marks over images \nYou can put marks over images \nYou can put marks over images",
                                GUIDEMARKS_SHAPE: [NSNumber numberWithInteger:SHAPE_CIRCLE],
                                GUIDEMARKS_LABELWIDTH : [NSNumber numberWithFloat:200],
                                GUIDEMARKS_SHOWARROW:[NSNumber numberWithBool:YES]
                                },
                            @{
                                GUIDEMARKS_RECT: [NSValue valueWithCGRect:guidemark1],
                                GUIDEMARKS_CAPTION: @"You can put marks over images",
                                GUIDEMARKS_SHAPE: [NSNumber numberWithInteger:SHAPE_CIRCLE],
                                GUIDEMARKS_SHOWARROW:[NSNumber numberWithBool:YES]
                                },
                            @{
                                GUIDEMARKS_RECT: [NSValue valueWithCGRect:guidemark2],
                                GUIDEMARKS_CAPTION: @"Also, we can show buttons",
                                GUIDEMARKS_SHOWARROW:[NSNumber numberWithBool:YES]
                                },
                            @{
                                GUIDEMARKS_RECT: [NSValue valueWithCGRect:guidemark3],
                                GUIDEMARKS_CAPTION: @"And works with navigations buttons too",
                                GUIDEMARKS_SHAPE: [NSNumber numberWithInteger:SHAPE_SQUARE],
                                GUIDEMARKS_SHOWARROW:[NSNumber numberWithBool:YES]
                                },
                            @{
                                GUIDEMARKS_RECT: [NSValue valueWithCGRect:guidemark4],
                                GUIDEMARKS_CAPTION: @"And works with navigations buttons too",
                                GUIDEMARKS_ALIGNMENT:[NSNumber numberWithInteger:LABEL_ALIGNMENT_RIGHT],
                                GUIDEMARKS_SHAPE: [NSNumber numberWithInteger:SHAPE_SQUARE],
                                GUIDEMARKS_SHOWARROW:[NSNumber numberWithBool:YES]
                                }
                            ];
    
    WYGuideMarks *guideMarksView = [[WYGuideMarks alloc] initWithFrame:self.view.bounds guideMarks:guideMarks];
    [self.view addSubview:guideMarksView];
    [guideMarksView start];
}

@end
