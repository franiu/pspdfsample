//
//  PSPDFColorSelectionViewController.m
//  PSPDFKit
//
//  Copyright 2012 Peter Steinberger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSPDFSimplePageViewController.h"

@protocol PSPDFColorSelectionViewControllerDelegate;

/// Beautiful color selection controller.
@interface PSPDFColorSelectionViewController : UIViewController

+ (PSPDFSimplePageViewController *)defaultColorPickerWithTitle:(NSString *)title delegate:(id<PSPDFColorSelectionViewControllerDelegate>)delegate;

+ (id)monoChromeSelectionViewController;
+ (id)modernColorsSelectionViewController;
+ (id)vintageColorsSelectionViewController;
+ (id)rainbowSelectionViewController;
+ (id)colorSelectionViewControllerFromColors:(NSArray *)colorsArray addDarkenedVariants:(BOOL)darkenedVariants;

- (id)initWithColors:(NSArray *)colors;

@property (nonatomic, weak) id <PSPDFColorSelectionViewControllerDelegate> delegate;

@end

@protocol PSPDFColorSelectionViewControllerDelegate <NSObject>

@required

- (UIColor *)colorSelectionControllerSelectedColor:(PSPDFColorSelectionViewController *)controller;
- (void)colorSelectionController:(PSPDFColorSelectionViewController *)controller didSelectedColor:(UIColor *)color;

@end
