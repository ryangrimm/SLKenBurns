//
//  SLKenBurnsView.m
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

#import "SLKenBurnsView.h"

#ifndef ARC4RANDOM_MAX
#define ARC4RANDOM_MAX 0x100000000
#endif

@interface SLKenBurnsView ()
@property (nonatomic) NSUInteger numberOfImages;
@property (nonatomic, strong) NSMutableArray *cachedImages;
@property (nonatomic, strong) NSTimer *nextImageTimer;
@property (nonatomic, strong) UIImage *currentImage;
@property (nonatomic, strong) UIImage *nextImage;
@property (nonatomic) BOOL manuallySetImages;
@end


@implementation SLKenBurnsView

- (id)init {
	self = [super init];
	if(self) {
		[self setup];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self) {
		[self setup];
	}
	return self;
}

- (void)awakeFromNib {
	[self setup];
}

- (void)setup {
	self.backgroundColor = [UIColor clearColor];
	self.layer.masksToBounds = YES;
	self.timeBetweenTransitions = 10;
	self.maximumEnlargement = 1.0;
	self.loop = YES;
	self.cacheImages = YES;
	self.cachedImages = [NSMutableArray arrayWithCapacity:10];
}


- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	[self showImage:self.currentImage];
}

- (void)setTimeBetweenTransitions:(NSTimeInterval)timeBetweenTransitions {
	_timeBetweenTransitions = timeBetweenTransitions;

	if([self.nextImageTimer isValid]) {
		[self.nextImageTimer invalidate];
		self.nextImageTimer = [NSTimer scheduledTimerWithTimeInterval:timeBetweenTransitions target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
	}
}

- (void)setImages:(NSArray *)array startAnimating:(BOOL)startAnimating {
    self.manuallySetImages = array != nil;
    self.cachedImages = [array mutableCopy];
    if(startAnimating) {
        [self reloadData];
    }
}

- (void)reloadData {
	self.currentImageIndex = 0;
    if(self.manuallySetImages) {
        self.numberOfImages = self.cachedImages.count;
    }
    else {
        [self.cachedImages removeAllObjects];

        self.numberOfImages = [self.delegate numberOfPhotosInKenBurnsView:self];
        if(self.numberOfImages == 0) {
            [self removeVisibleImage];
            return;
        }

        if(self.cacheImages) {
            for(NSUInteger i = 0; i < self.numberOfImages; i++) {
                self.cachedImages[i] = [NSNull null];
            }
        }
    }

    [self.nextImageTimer invalidate];
    self.nextImageTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeBetweenTransitions target:self selector:@selector(changeImage) userInfo:nil repeats:YES];

    [self fetchImageForIndex:self.currentImageIndex imageResult:^(UIImage *image, NSUInteger forIndex) {
        [self showImage:image];
        [self prepareNextImage];
    }];
}

- (void)fetchImageForIndex:(NSUInteger )index imageResult:(SLKenBurnsViewImageProviderBlock)imageResult {
	UIImage *cachedImage = nil;
	if(index < _cachedImages.count) {
		cachedImage = _cachedImages[index];
		if([cachedImage isKindOfClass:[UIImage class]]) {
			imageResult(cachedImage, index);
			return;
		}
	}

	[self.delegate kenBurnsView:self imageAtIndex:index imageResult:^(UIImage *image, NSUInteger forIndex) {
		if(self.cacheImages && image) {
			_cachedImages[forIndex] = image;
		}
		imageResult(image, forIndex);
	}];
}

- (void)prepareNextImage {
	self.nextImage = nil;
	NSUInteger indexToFetch = self.currentImageIndex + 1;
	if(indexToFetch  == self.numberOfImages) {
		if(self.loop == NO) {
			return;
		}
		indexToFetch = 0;
	}

	[self fetchImageForIndex:indexToFetch imageResult:^(UIImage *image, NSUInteger forIndex) {
		self.nextImage = image;
	}];
}

- (void)changeImage {
	self.currentImageIndex++;
	if(self.currentImageIndex == self.numberOfImages) {
		if(self.loop) {
			self.currentImageIndex = 0;
		}
		else {
			[_nextImageTimer invalidate];
			return;
		}
	}

	[self showImage:self.nextImage];
	[self prepareNextImage];
}


- (void)showImage:(UIImage *)image {
	if(image == nil) {
		return;
	}

	self.currentImage = image;

	CGFloat frameWidth = self.bounds.size.width;
	CGFloat frameHeight = self.bounds.size.height;

	CGFloat widthRatio = frameWidth / image.size.width;
	CGFloat heightRatio = frameHeight / image.size.height;
	CGFloat resizeRatio = MAX(widthRatio, heightRatio);

	// Resize the image
	CGFloat imageViewWidth  = image.size.width * resizeRatio * self.maximumEnlargement;
	CGFloat imageViewHeight = image.size.height * resizeRatio * self.maximumEnlargement;

	// Calcule the maximum move allowed
	CGFloat maxMoveX = imageViewWidth - frameWidth;
	CGFloat maxMoveY = imageViewHeight - frameHeight;

	CGFloat originX = 0;
	CGFloat originY = 0;
	CGFloat moveX = 0;
	CGFloat moveY = 0;
	CGFloat zoomIn = [self randomNumberBetween:1.1 and:1.5];

	switch(arc4random() % 4) {
		case 0:
			originX = 0;
			originY = 0;
			moveX = -maxMoveX;
			moveY = -maxMoveY;
			break;
		case 1:
			originX = 0;
			originY = frameHeight - imageViewHeight;
			moveX = -maxMoveX;
			moveY = maxMoveY;
			break;
		case 2:
			originX = frameWidth - imageViewWidth;
			originY = 0;
			moveX = maxMoveX;
			moveY = -maxMoveY;
			break;
		case 3:
			originX = frameWidth - imageViewWidth;
			originY = frameHeight - imageViewHeight;
			moveX = maxMoveX;
			moveY = maxMoveY;
			break;
	}

	CALayer *photoLayer = [CALayer layer];
	photoLayer.contents = (id)image.CGImage;
	photoLayer.anchorPoint = CGPointMake(0, 0); 
	photoLayer.bounds = CGRectMake(0, 0, imageViewWidth, imageViewHeight);
	photoLayer.position = CGPointMake(originX, originY);

	UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageViewWidth, imageViewHeight)];
	imageView.backgroundColor = [UIColor clearColor];
	[imageView.layer addSublayer:photoLayer];

	CATransition *animation = [CATransition animation];
	animation.duration = 1;
	animation.type = kCATransitionFade;
	[self.layer addAnimation:animation forKey:nil];

	// Swap out the image views
	[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[self addSubview:imageView];

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:self.timeBetweenTransitions + 2];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	CGAffineTransform move = CGAffineTransformMakeTranslation(moveX, moveY);
	CGAffineTransform zoom = CGAffineTransformMakeScale(zoomIn, zoomIn);
	imageView.transform = CGAffineTransformConcat(zoom, move);
	[UIView commitAnimations];

	if([_delegate respondsToSelector:@selector(kenBurnsView:imageChanged:)]) {
		[_delegate kenBurnsView:self imageChanged:self.currentImageIndex];
	}
	
	if(self.currentImageIndex == _cachedImages.count - 1 && _loop == NO) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.timeBetweenTransitions * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if([_delegate respondsToSelector:@selector(didFinishAllAnimationsInKenBurnsView:)]) {
                [_delegate didFinishAllAnimationsInKenBurnsView:self];
            }
            [self removeVisibleImage];
        });
	} 
}

- (void)removeVisibleImage {
    [UIView animateWithDuration:1 animations:^{
        for(UIView *view in self.subviews) {
            view.alpha = 0;
        }
    }
    completion:^(BOOL finished) {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }];
}

- (void)removeFromSuperview {
	[super removeFromSuperview];
	[self.nextImageTimer invalidate];
}

- (CGFloat)randomNumberBetween:(CGFloat)min and:(CGFloat)max {
	return min + (max - min) * arc4random() / ARC4RANDOM_MAX;
}

@end
