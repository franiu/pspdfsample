//
//  PSPDFAnnotationParser.h
//  PSPDFKit
//
//  Copyright 2011-2012 Peter Steinberger. All rights reserved.
//

#import "PSPDFKitGlobal.h"
#import "PSPDFAnnotation.h"
#import "PSPDFAnnotationProvider.h"

@protocol PSPDFAnnotationView;
@class PSPDFDocumentProvider, PSPDFFileAnnotationProvider;

extern NSString *const PSPDFAnnotationChangedNotification;

/**
 Parses and saves annotations for each page in a PDF.
 Supports many sources with the PSPDFAnnotationProvider protocol.

 Usually you want to add your custom PSPDFAnnotationProvider instead of subclassing this.
 If you subclass, use overrideClassNames in PSPDFDocument.
*/
@interface PSPDFAnnotationParser : NSObject <PSPDFAnnotationProviderChangeNotifier>

/// Initializes the annotation parser with the associated documentProvider.
- (id)initWithDocumentProvider:(PSPDFDocumentProvider *)documentProvider;

/**
 The simplest way to extend PSPDFAnnotationParser is to register a custom PSPDFAnnotationProvider.
 You can even remove the default PSPDFFileAnnotationProvider if you don't want file-based annotations.

 Your annotationProvider will be retained for the lifetime of PSPDFAnnotationParser.
 */
- (void)addAnnotationProvider:(id<PSPDFAnnotationProvider>)annotationProvider;
- (BOOL)removeAnnotationProvider:(id<PSPDFAnnotationProvider>)annotationProvider;
@property (nonatomic, strong, readonly) NSArray *annotationProviders;

/// Direct access to the file annotation provider, who default is the only registered annotationProvider.
/// Will never be nil, but can be removed from the annotationProviders list.
@property (nonatomic, strong, readonly) PSPDFFileAnnotationProvider *fileAnnotationProvider;

/**
 Return annotation array for specified page.

 Note: fetching annotations may take a while. You can do this in a background thread.
 
 This method will be called OFTEN. Multiple times during a page display, and basically each time you're scrolling or zooming. Ensure it is fast.
 
 This will query all annotationProviders and merge the result.
*/
- (NSArray *)annotationsForPage:(NSUInteger)page type:(PSPDFAnnotationType)type;

/// YES if annotations are loaded for a specific page.
/// This is used to determine if annotationsForPage:type: should be called directly or in a background thread.
- (BOOL)hasLoadedAnnotationsForPage:(NSUInteger)page;

/**
 Any annotation that returns YES on isOverlay needs a view class to be displayed.
 Will be called on all annotationProviders until someone doesn't return nil.

 If no class is found, the view will be ignored.
 */
- (Class)annotationViewClassForAnnotation:(PSPDFAnnotation *)annotation;

/// Save annotations. (returning NO + eventually an error if it fails)
/// Saving will be forwarded to all annotation providers.
/// Usually you want to override the method in PSPDFFileAnnotationProvider instead.
- (BOOL)saveAnnotationsWithError:(NSError **)error;

/// document provider for annotation parser. weak.
@property (nonatomic, ps_weak, readonly) PSPDFDocumentProvider *documentProvider;

@end


@interface PSPDFAnnotationParser (SubclassingHooks)

/// Fast path, same as annotationsForPage:type: but with already opened pageRef.
/// If you wanna override annotationsfForPage:type, override this instead.
- (NSArray *)annotationsForPage:(NSUInteger)page type:(PSPDFAnnotationType)type pageRef:(CGPDFPageRef)pageRef;

/// Searches the annotation cache for annotations that have the dirty flag set.
/// Dictionary key are the pages, object an array of annotations.
- (NSDictionary *)dirtyAnnotations;

@end


// Lots of methods have been moved to PSPDFFileAnnotationProvider.
@interface PSPDFAnnotationParser (Deprecated)

@property (nonatomic, copy) NSString *protocolString __attribute__ ((deprecated("Use fileAnnotationProvider.protocolString instead")));

@property (nonatomic, copy) NSString *annotationsPath __attribute__ ((deprecated("Use fileAnnotationProvider.annotationsPath instead")));

- (void)setAnnotations:(NSArray *)annotations forPage:(NSUInteger)page __attribute__ ((deprecated("Use the method in fileAnnotationProvider instead.")));

/// Append annotations to a specific page.
- (void)addAnnotations:(NSArray *)annotations forPage:(NSUInteger)page __attribute__ ((deprecated("Use the method in fileAnnotationProvider instead.")));

- (void)clearCache __attribute__ ((deprecated("Use the method in fileAnnotationProvider instead.")));

@end
