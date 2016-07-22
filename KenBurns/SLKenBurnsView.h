//
//  SLKenBurnsView.h
//  SLKenBurnsView
//
//  Created by Ryan Grimm on 8/4/13.
//  Copyright 2013 Swell Lines LLC.
//
//  Inspiration from JBKenBurnsView by Javier Berlana.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this 
//  software and associated documentation files (the "Software"), to deal in the Software 
//  without restriction, including without limitation the rights to use, copy, modify, merge, 
//  publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons 
//  to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies 
//  or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
//  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
//  IN THE SOFTWARE.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class SLKenBurnsView;

typedef void (^SLKenBurnsViewImageProviderBlock)(UIImage *imageResult, NSUInteger forIndex);

#pragma - KenBurnsViewDelegate
@protocol SLKenBurnsViewDelegate <NSObject>
- (NSUInteger)numberOfPhotosInKenBurnsView:(SLKenBurnsView *)kenBurnsView;
- (void)kenBurnsView:(SLKenBurnsView *)kenBurnsView imageAtIndex:(NSUInteger)index imageResult:(SLKenBurnsViewImageProviderBlock)imageResult;
@optional
- (void)kenBurnsView:(SLKenBurnsView *)kenBurnsView imageChanged:(NSUInteger)imageIndex;
- (void)didFinishAllAnimationsInKenBurnsView:(SLKenBurnsView *)kenBurnsView;
@end

@interface SLKenBurnsView : UIView

@property (nonatomic, weak) NSObject<SLKenBurnsViewDelegate> *delegate;
@property (nonatomic) NSTimeInterval timeBetweenTransitions;
@property (nonatomic) BOOL loop;
@property (nonatomic) BOOL cacheImages;
@property (nonatomic) NSUInteger currentImageIndex;
@property (nonatomic) CGFloat maximumEnlargement;

- (void)reloadData;
- (void)setImages:(NSArray *)array startAnimating:(BOOL)startAnimating;

@end
