//
//  TouchImageView.h
//  Active8Plus
//
//  Created by forever on 1/6/16.
//  Copyright © 2016 forever. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TouchImageView;

@protocol TouchImageViewDelegate

- (void)touchImageView:(TouchImageView *)touchView didTouchBegin:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchImageView:(TouchImageView *)touchView didTouchMove:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchImageView:(TouchImageView *)touchView didTouchEnd:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@interface TouchImageView : UIImageView {
    
    CGAffineTransform       originalTransform;
    CFMutableDictionaryRef  touchBeginPoints;
    UIImage                 *m_pViewImage;
}

- (void)setUIImage:(UIImage *)image;

- (CGPoint)newTopLeft;
- (CGPoint)newTopRight;
- (CGPoint)newBottomLeft;
- (CGPoint)newBottomRight;

@property (nonatomic, assign) id<TouchImageViewDelegate> delegate;

@property CGAffineTransform originalTransform;

@end
