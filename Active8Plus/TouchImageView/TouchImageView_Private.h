//
//  TouchImageView_Private.h
//  Active8Plus
//
//  Created by forever on 1/4/16.
//  Copyright © 2016 forever. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchImageView.h"

@interface UITouch (TouchSorting)

- (NSComparisonResult)compareAddress:(id)obj;

@end

@interface TouchImageView (Private)


- (CGAffineTransform)incrementalTransformWithTouches:(NSSet *)touches;
- (void)updateOriginalTransformForTouches:(NSSet *)touches;

- (void)cacheBeginPointForTouches:(NSSet *)touches;
- (void)removeTouchesFromCache:(NSSet *)touches;

@end																																																																																																																																																																																																																																																																																																																																																										
