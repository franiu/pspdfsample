//
//  PSPDFGenericAnnotationView.h
//  PSPDFKit
//
//  Copyright (c) 2012 Peter Steinberger. All rights reserved.
//

#import "PSPDFKitGlobal.h"
#import "PSPDFAnnotationView.h"

@class PSPDFAnnotation;

@interface PSPDFGenericAnnotationView : UIView <PSPDFAnnotationView>

/// Designated initializer.
- (id)initWithAnnotation:(PSPDFAnnotation *)annotation;

@end
