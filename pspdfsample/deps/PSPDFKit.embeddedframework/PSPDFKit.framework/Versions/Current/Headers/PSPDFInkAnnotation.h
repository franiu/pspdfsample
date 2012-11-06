//
//  PSPDFInkAnnotation.h
//  PSPDFKit
//
//  Copyright 2012 Peter Steinberger. All rights reserved.
//

#import "PSPDFAnnotation.h"

// Helper to convert UIBezierPath into an array of lines (of CGPoints inside NSValues).
NSArray *PSPDFBezierPathGetPoints(UIBezierPath *path);

/// PDF Ink Annotation. (Free Drawing)
@interface PSPDFInkAnnotation : PSPDFAnnotation

/// Array of lines (which is a array of CGPoint's)
@property (nonatomic, strong) NSArray *lines;

/// Array of UIBezierPath (a cached version of lines for faster drawing)
@property (nonatomic, strong) NSArray *paths;

/// Designated initializer.
- (id)initWithAnnotationDictionary:(CGPDFDictionaryRef)annotDict inAnnotsArray:(CGPDFArrayRef)annotsArray;

/// Rebuilds paths using the data in lines.
- (void)rebuildPaths;

/// Generate new line array by applying transform.
/// This is used internally when boundingBox is changed.
- (NSArray *)copyLinesByApplyingTransform:(CGAffineTransform)transform;

@end
