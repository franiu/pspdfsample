//
//  PSPDFActionNamed.h
//  PSPDFKit
//
//  Copyright (c) 2013 Peter Steinberger. All rights reserved.
//

#import "PSPDFAction.h"

@class PSPDFDocument;

typedef NS_ENUM(NSUInteger, PSPDFActionNamedName) {
    PSPDFActionNamedNone,
    PSPDFActionNamedNextPage,
    PSPDFActionNamedPreviousPage,
    PSPDFActionNamedFirstPage,
    PSPDFActionNamedLastPage,

    // TODO
    PSPDFActionNamedGoBack,
    PSPDFActionNamedGoForward,
    PSPDFActionNamedGoToPage,
    PSPDFActionNamedFind,
    PSPDFActionNamedPrint,
    PSPDFActionNamedOutline,
    PSPDFActionNamedSearch,
    PSPDFActionNamedBrightness,
    PSPDFActionNamedZoomIn,
    PSPDFActionNamedZoomOut,
    PSPDFActionNamedUnknown = NSUIntegerMax
};

/// PDFActionNamed defines methods used to work with actions in PDF documents, some of which are named in the Adobe PDF Specification.
@interface PSPDFActionNamed : PSPDFAction

/// Initialize with string. Will parse action, set to PSPDFActionNamedUnknown if not recognized.
- (id)initWithActionNamedString:(NSString *)actionNameString;

/// The type of the named action.
/// @note Will update `namedAction` if set.
@property (nonatomic, assign) PSPDFActionNamedName namedActionType;

/// The string of the named action.
/// @note Will update `namedActionType` if set.
@property (nonatomic, copy) NSString *namedAction;

/// Certain action types (PSPDFActionTypeNamed) calculate the target page dynamically from the current page.
/// @return The calculated page or NSNotFound if action doesn't specify page manipulation (like PSPDFActionNamedFind)
- (NSUInteger)pageIndexWithCurrentPage:(NSUInteger)currentPage fromDocument:(PSPDFDocument *)document;

/// Transforms named actions to enum type and back.
+ (NSValueTransformer *)namedActionTypeTransformer;

@end
