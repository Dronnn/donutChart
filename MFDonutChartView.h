//
//  MFDonutChartView.h
//  Megafon
//
//  Created by Andrey Vanyurin on 17/02/15.
//  Copyright (c) 2015 Andrey Vanyurin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MFDonutChartView;

/**
 *  Donut Chart Data Source
 */
@protocol MFDonutChartViewDataSource <NSObject>

@required

/**
 *  To take number for slices
 *
 *  @param donutChartView - link
 *
 *  @return number Of Slices In Donut Chart View
 */
- (NSUInteger)numberOfSlicesInDonutChartView:(MFDonutChartView*)donutChartView;

/**
 *  To take a percent for certain slice
 *
 *  @param donutChartView - link
 *  @param index          - index of slice
 *
 *  @return number of percent for certain slice
 */
- (double)donutChartView:(MFDonutChartView*)donutChartView valueForSliceAtIndex:(NSUInteger)index;

/**
 *  To take a color for cirtain slice
 *
 *  @param donutChartView - link
 *  @param index          - index of color
 *
 *  @return color for certain slice
 */
- (UIColor *)donutChartView:(MFDonutChartView*)donutChartView colorForSliceAtIndex:(NSUInteger)index;

@optional
/**
 *  To take line width for certain slice
 *
 *  @param donutChartView - link
 *  @param index          - index of slice
 *
 *  @return line width for slice
 */
- (CGFloat)donutChartView:(MFDonutChartView*)donutChartView lineWidtForSliceAtIndex:(NSUInteger)index;

- (CGFloat)slicesIntervalForDonutChartView:(MFDonutChartView*)donutChartView;

/**
 *  To take line width for certain slice
 *
 *  @param donutChartView - link
 *  @param index          - index of slice
 *
 *  @return line width for slice
 */
- (CGFloat)donutChartView:(MFDonutChartView*)donutChartView selectedLineIncreaseWidthForSliceAtIndex:(NSUInteger)index;

/**
 *  To take title for certain slice
 *
 *  @param donutChartView - link
 *  @param index          - index of slice
 *
 *  @return name of slice
 */
- (NSString*)donutChartViewTitleDiagramName:(MFDonutChartView*)donutChartView;

/**
 *  To take title for certain slice
 *
 *  @param donutChartView - link
 *  @param index          - index of slice
 *
 *  @return name of slice
 */
- (NSString*)donutChartViewTitleNumber:(MFDonutChartView*)donutChartView;

/**
 *  To send the selected slice number
 *
 *  @param donutChartView - link
 *
 *  @return void
 */
- (void)donutChartView:(MFDonutChartView*)donutChartView numberOfSelectedSegment:(NSInteger)number;

@end


/**
 * Displaying a donut chart view.
 */
@interface MFDonutChartView : UIView

/**
 *  Data Source
 */
@property (nonatomic, strong) id <MFDonutChartViewDataSource> dataSource;

/**
 *  Delegate
 */
@property (nonatomic, strong) id      delegate;

/**
 *  Line width
 */
@property (nonatomic, assign) CGFloat lineWidth;

/**
 *  Show shadow
 */
@property (nonatomic, assign) BOOL    showShadow;

/**
 *  Refresh diagram
 */
-(void)reloadData;

@end
