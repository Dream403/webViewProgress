//
//  ZLWebViewProgressView.h
//  WebViewProdDemo
//
//  Created by snowlu on 2017/11/6.
//  Copyright © 2017年 LittleShrimp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZLWebViewProgressBar.h"
#import <UIKit/UIKit.h>
@interface ZLWebViewProgressView : NSObject<UIWebViewDelegate>
/**
 *  WebViewDelegate
 */
@property (weak, nonatomic) id <UIWebViewDelegate> webViewProxy;
@end
