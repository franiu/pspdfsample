//
//  PSPDFSelectionBorderView.h
//  PSPDFKit
//
//  Copyright (c) 2012 Peter Steinberger. All rights reserved.
//

#import "PSPDFKitGlobal.h"
#import "PSPDFLongPressGestureRecognizer.h"

@class PSPDFSelectionBorderView;

/// Delegate on frame changes.
@protocol PSPDFSelectionBorderViewDelegate <NSObject>

/// Called after frame change.
- (void)selectionBorderViewChangedFrame:(PSPDFSelectionBorderView *)selectionView;

@end

/// Handles view selection with resize knobs.
@interface PSPDFSelectionBorderView : UIView <PSPDFLongPressGestureRecognizerDelegate>

/// Designated initializer.
- (id)initWithTrackedView:(UIView *)trackedView;

/// View that will be changed on selection change.
@property (nonatomic, strong) UIView *trackedView;

/// Set zoomscale to be able to draw the page knobs at the correct size.
@property (nonatomic, assign) CGFloat zoomScale;

/// If set to NO, won't show selection knobs and dragging. Defaults to YES.
@property (nonatomic, assign) BOOL allowEditing;

// forward parent gesture recognizer longPress action.
- (BOOL)longPress:(UILongPressGestureRecognizer *)recognizer;

/// Delegate called on frame change.
@property (nonatomic, weak) id<PSPDFSelectionBorderViewDelegate> delegate;

@end
