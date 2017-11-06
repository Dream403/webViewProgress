//
//  ZLWebViewProgressBar.h
//  WebViewProdDemo
//
//  Created by snowlu on 2017/11/6.
//  Copyright © 2017年 LittleShrimp. All rights reserved.
//

#import <UIKit/UIKit.h>
#define UIColorFromRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]
@interface ZLWebViewProgressBar : UIView
/**
 *
 */
@property(nonatomic) CGFloat progress;
/**
 *
 */
@property(nonatomic,readonly)UIView *progressBarView;
/**
 *    工具动画时间    default 0.5
 */
@property (nonatomic) NSTimeInterval barAnimationDuration;
/**
 *   渐色动画时间 default 0.1
 */
@property (nonatomic) NSTimeInterval graduallyAnimationDuration;
/**
 *  default
 */
@property(nonatomic,copy)UIColor *progressBarViewColor;

/**
 *  <#Description#>
 *
 *  @param progress <#progress description#>
 *  @param animated <#animated description#>
 */
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
@end
