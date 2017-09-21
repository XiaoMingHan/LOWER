//
//  VEOverlayVideoComposition.m
//  VideoEditor
//
//  Created by Apple Macintosh on 4/17/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "VEOverlayVideoComposition.h"
#import "VEVideoComponent.h"
#import "VEUtilities.h"
#import "VEVideoTrack.h"
#import "VETimer.h"

@implementation VEOverlayVideoComposition

- (id)init {
    self = [super init];
    
    if (self != nil) {
        view = [[UIView alloc] init];
    }
    
    return self;
}

- (void)setEditor:(VEVideoEditor *)_editor {
    editor = _editor;
    
 }

- (void)addComponent:(VEVideoComponent *)component {
    [super addComponent:component];
    [view addSubview:component.view];
}

- (void)removeComponent:(VEVideoComponent *)component {
    [component.view removeFromSuperview];
    [super removeComponent:component];
}

- (void)removeAllComponents {
    for (VEVideoComponent *component in components) {
        [component.view removeFromSuperview];
    }
    
    [super removeAllComponents];
}

- (void)bringToFront:(VEVideoComponent *)component {
    if ([components indexOfObject:component] != NSNotFound) {
        [super bringToFront:component];
        
        [component.view removeFromSuperview];
        [view addSubview:component.view];
    }
}

- (void)sendToBack:(VEVideoComponent *)component {
    if ([components indexOfObject:component] != NSNotFound) {
        [super sendToBack:component];
        
        [component.view removeFromSuperview];
        [view insertSubview:component.view atIndex:0];
    }
}

- (void)rearrangeComponent:(VEVideoComponent *)component To:(int)index {
    if ([components indexOfObject:component] != NSNotFound) {
        [super rearrangeComponent:component To:index];
        
        [component.view removeFromSuperview];
        [view insertSubview:component.view atIndex:index];
    }
}

- (void)calculateDuration {
    previousSplited = -2;
}

- (void)beginExport {
  //  view.frame = CGRectMake(0.0f, 0.0f, editor.size.width, editor.size.height);
    previousSplited = -2;
    
    [super beginExport];
}

- (CGImageRef)nextFrameImage {
      return nil;
}

- (CGImageRef)frameImageAtTime:(double)time {
    
    return nil;
}

@end
