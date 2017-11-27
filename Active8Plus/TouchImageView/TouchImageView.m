//
//  TouchImageView.m
//  Active8Plus
//
//  Created by forever on 1/6/16.
//  Copyright © 2016 forever. All rights reserved.
//

#import "TouchImageView.h"
#import "TouchImageView_Private.h"

@implementation TouchImageView
@synthesize originalTransform;

- (id)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame] == nil) {
        return nil;
    }
    
    [self setContentMode:UIViewContentModeScaleAspectFit];
    
    self.image          = m_pViewImage;
    originalTransform   = CGAffineTransformIdentity;
    touchBeginPoints    = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled   = YES;
    self.exclusiveTouch         = YES;

    return self;
}

-(void)setUIImage:(UIImage *)image
{
    if(m_pViewImage != nil)
        m_pViewImage = nil;
    
    m_pViewImage = [[UIImage alloc] initWithCGImage:image.CGImage];

    [self setImage:m_pViewImage];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
    NSMutableSet *currentTouches = [[event touchesForView:self] mutableCopy];
    [currentTouches minusSet:touches];
    if ([currentTouches count] > 0) {
        [self updateOriginalTransformForTouches:currentTouches];
        [self cacheBeginPointForTouches:currentTouches];
    }
    
    [self cacheBeginPointForTouches:touches];

    if ([(id)self.delegate respondsToSelector:@selector(touchImageView:didTouchBegin:withEvent:)]) {

        [self.delegate touchImageView:self didTouchBegin:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGAffineTransform incrementalTransform = [self incrementalTransformWithTouches:[event touchesForView:self]];
    self.transform = CGAffineTransformConcat(originalTransform, incrementalTransform);

    if ([(id)self.delegate respondsToSelector:@selector(touchImageView:didTouchMove:withEvent:)]) {

        [self.delegate touchImageView:self didTouchMove:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    [self updateOriginalTransformForTouches:[event touchesForView:self]];
    [self removeTouchesFromCache:touches];
    
    NSMutableSet *remainingTouches = [[event touchesForView:self] mutableCopy];
    [remainingTouches minusSet:touches];
    [self cacheBeginPointForTouches:remainingTouches];

    if ([(id)self.delegate respondsToSelector:@selector(touchImageView:didTouchEnd:withEvent:)]) {
        [self.delegate touchImageView:self didTouchEnd:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

}
/*
- (void)beginTouch:(NSSet *)touches eventTouches:(NSSet *)eventTouches
{
    NSMutableSet *currentTouches = [eventTouches mutableCopy];
    [currentTouches minusSet:touches];
    if ([currentTouches count] > 0) {

        [self updateOriginalTransformForTouches:currentTouches];
        [self cacheBeginPointForTouches:currentTouches];
    }

    [self cacheBeginPointForTouches:touches];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TOUCHVIEW_CHANGED object:nil];
}

- (void)moveTouch:(NSSet *)touches eventTouches:(NSSet *)eventTouches
{
    CGAffineTransform incrementalTransform = [self incrementalTransformWithTouches:eventTouches];
    self.transform = CGAffineTransformConcat(originalTransform, incrementalTransform);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TOUCHVIEW_CHANGED object:nil];
}

- (void)endTouch:(NSSet *)touches eventTouches:(NSSet *)eventTouches
{
    [self updateOriginalTransformForTouches:eventTouches];
    [self removeTouchesFromCache:touches];

    NSMutableSet *remainingTouches = [eventTouches mutableCopy];
    [remainingTouches minusSet:touches];
    [self cacheBeginPointForTouches:remainingTouches];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TOUCHVIEW_CHANGED object:nil];
}*/


// helper to get pre transform frame
-(CGRect)originalFrame {
    CGAffineTransform currentTransform = self.transform;
    self.transform = CGAffineTransformIdentity;
    CGRect originalFrame = self.frame;
    self.transform = currentTransform;
    
    return originalFrame;
}

// helper to get point offset from center
-(CGPoint)centerOffset:(CGPoint)thePoint {
    return CGPointMake(thePoint.x - self.center.x, thePoint.y - self.center.y);
}
// helper to get point back relative to center
-(CGPoint)pointRelativeToCenter:(CGPoint)thePoint {
    return CGPointMake(thePoint.x + self.center.x, thePoint.y + self.center.y);
}
// helper to get point relative to transformed coords
-(CGPoint)newPointInView:(CGPoint)thePoint {
    // get offset from center
    CGPoint offset = [self centerOffset:thePoint];
    // get transformed point
    CGPoint transformedPoint = CGPointApplyAffineTransform(offset, self.transform);
    // make relative to center
    return [self pointRelativeToCenter:transformedPoint];
}

// now get your corners
-(CGPoint)newTopLeft {
    CGRect frame = [self originalFrame];
    return [self newPointInView:frame.origin];
}
-(CGPoint)newTopRight {
    CGRect frame = [self originalFrame];
    CGPoint point = frame.origin;
    point.x += frame.size.width;
    return [self newPointInView:point];
}
-(CGPoint)newBottomLeft {
    CGRect frame = [self originalFrame];
    CGPoint point = frame.origin;
    point.y += frame.size.height;
    return [self newPointInView:point];
}
-(CGPoint)newBottomRight {
    CGRect frame = [self originalFrame];
    CGPoint point = frame.origin;
    point.x += frame.size.width;
    point.y += frame.size.height;
    return [self newPointInView:point];
}


- (void) dealloc
{
    CFRelease(touchBeginPoints);
}

@end
