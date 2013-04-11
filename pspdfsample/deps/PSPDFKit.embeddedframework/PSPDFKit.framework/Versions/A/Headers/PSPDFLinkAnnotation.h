//
//  PSPDFLinkAnnotation.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSPDFAnnotation.h"

// PSPDFKit has some custom sub-sets of the PSPDFAnnotationTypeLink
// that can be resolved to video, audio, image or browser views.
typedef NS_ENUM(NSInteger, PSPDFLinkAnnotationType) {
    PSPDFLinkAnnotationPage = 0,
    PSPDFLinkAnnotationWebURL,  // 1
    PSPDFLinkAnnotationDocument,// 2
    PSPDFLinkAnnotationVideo,   // 3
    PSPDFLinkAnnotationYouTube, // 4
    PSPDFLinkAnnotationAudio,   // 5
    PSPDFLinkAnnotationImage,   // 6
    PSPDFLinkAnnotationBrowser, // 7
    PSPDFLinkAnnotationCustom  /// any annotation format that is not recognized is custom (e.g. tel://)
};

@class PSPDFAction, PSPDFActionURL, PSPDFActionGoTo;

/**
 The PSPDFLinkAnnotation represents both classic PDF page/document/web links, and more types not supported by other PDF readers (video, audio, image, etc)

 PSPDFKit will automatically figure out the type for PDF link annotations loaded from a document, based on the file type. ("mpg" belongs to PSPDFLinkAnnotationVideo; a YouTube-URL to PSPDFLinkAnnotationYouTube, etc)

 If you create a PSPDFLinkAnnotation at runtime, be sure to set the correct type and use the URL parameter for your link.
 BoundingBox defines the frame, in PDF space coordinates.

 If you want to customize how links look in the PDF, customize PSPDFLinkAnnotationView's properties. There's currently no mapping between color/lineWidth/etc and the properties of the view. This might change in future releases.
 */
@interface PSPDFLinkAnnotation : PSPDFAnnotation

/// Designated initializer for custom, at runtime created PSPDFLinkAnnotations.
- (id)initWithLinkAnnotationType:(PSPDFLinkAnnotationType)linkAnotationType;

/// Initialze link annotation with target URL.
- (id)initWithURL:(NSURL *)URL;

/// Initialze link annotation with target URL string.
/// Can also be used for pspdfkit:// URLs.
- (id)initWithURLString:(NSString *)URLString;

/// Initalize link annotation with target page.
- (id)initWithPage:(NSUInteger)page;

/// PSPDFKit addition - set if the pspdfkit:// protocol is detected.
@property (nonatomic, assign) PSPDFLinkAnnotationType linkType;

/// The associated PDF action that will be executed on tap.
/// Will update the `linkType` when set.
/// @note Only evaluated if isMultimediaExtension returns NO.
@property (nonatomic, strong) PSPDFAction *action;

/// Convenience cast. Will return the URL action if action is of type PSPDFActionTypeURL, else nil.
- (PSPDFActionURL *)URLAction;

/// Convenience method, will create a new PSPDFActionURL and get the URL from it.
@property (nonatomic, strong) NSURL *URL;

/// Convenience cast. Will return the GoTo action if action is of type PSPDFActionTypeGoTo, else nil.
- (PSPDFActionGoTo *)GoToAction;

/// Will be YES if this is a regular link or a multimedia link annotation that should be displayed as link. (e.g. if isPopover/isModal is set to yes)
@property (nonatomic, assign, readonly) BOOL showAsLinkView;

/// Returns YES if this link is specially handled by PSPDFKit.
/// Returns true for any linkType >= PSPDFLinkAnnotationVideo && linkType <= PSPDFLinkAnnotationBrowser.
@property (nonatomic, assign, readonly, getter=isMultimediaExtension) BOOL multimediaExtension;


/// Show or hide controls. Only valid for PSPDFLinkAnnotationVideo and PSPDFLinkAnnotationAudio. Defaults to YES.
/// Some controls will add alternative ways to control if this is disabled.
/// e.g. videos can be paused via touch on the view if this is set to NO.
@property (nonatomic, assign) BOOL controlsEnabled;

/// Autoplay video/audio. Only valid for PSPDFLinkAnnotationVideo and PSPDFLinkAnnotationAudio. Defaults to NO.
@property (nonatomic, assign, getter=isAutoplayEnabled) BOOL autoplayEnabled;

/**
 Link if target is a website.

 If you create a PSPDFLinkAnnotation in code, setting the siteLinkTarget will invoke the parsing at the time you're adding the annotation to the PSPDFAnnotationParser.

 After parsing, the linkType will be set and the generate URL will be set.
 If you don't want this processing, directly set the URL and the linkType and don't use siteLinkTarget.

 An example for a siteLinkTarget to an image annotation would be:
 PSPDFLinkAnnotation *annotation = [[PSPDFLinkAnnotation alloc] initWithLinkAnnotationType:PSPDFLinkAnnotationImage];
 annotation.siteLinkTarget = [NSString stringWithFormat:@"pspdfkit://[contentMode=%d]localhost/%@/exampleimage.jpg", UIViewContentModeScaleAspectFill, [[NSBundle mainBundle] bundlePath]];
 // annotation frame is in PDF coordinate space. Use pageRect for the full page.
 annotation.boundingBox = [self.document pageInfoForPage:0].pageRect;
 // annotation.page/document is autodetecting set.
 [self.document.annotationParser addAnnotations:@[annotation] forPage:0];

 @note Do not add NSURL-encoded strings to siteLinkTarget.(no %20 - real space!)
 If you convert a path from NSURL, use URL.path and NOT [url description]. (Actually, never use URL description, except when you're debugging)
*/
//@property (nonatomic, copy) NSString *siteLinkTarget;

/// URL (generated from the siteLinkTarget after parsing. Will not be saved.)
/// If set to nil, this will be autocreated from siteLinkTarget.
//@property (nonatomic, strong) NSURL *URL;

/// Used for the preview string when the user long-presses on a link annotation.
/// Forwards to action.localizedDescription.
- (NSString *)targetString;

/// Link Type String <-> PSPDFLinkAnnotationType transformer.
+ (NSValueTransformer *)linkTypeTransformer;

@end


@interface PSPDFLinkAnnotation (Internal)

/// Will update `linkType` depending on the current set action.
/// @note This will be invoked automatically, you usually don't need to manually call this.
- (void)updateLinkTypeForCurrentAction;

@end


@interface PSPDFLinkAnnotation (Deprecated)

- (id)initWithSiteLinkTarget:(NSString *)siteLinkTarget __attribute__ ((deprecated("Use initWithURLString: instead")));
@property (nonatomic, assign) NSUInteger pageLinkTarget __attribute__ ((deprecated("Use GoToAction.pageIndex instead (which is zero-based)")));
@property (nonatomic, copy) NSString *siteLinkTarget __attribute__ ((deprecated("Use URL instead")));
@property (nonatomic, copy) NSDictionary *options __attribute__ ((deprecated("Use action.options instead")));
@property (nonatomic, assign, getter=isModal) BOOL modal __attribute__ ((deprecated("Use URLAction.isModal instead")));
@property (nonatomic, assign, getter=isPopover) BOOL popover __attribute__ ((deprecated("Use URLAction.isPopover instead")));

@end
