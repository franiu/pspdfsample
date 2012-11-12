//
//  DvPdfDocument.h
//  DocumentViewer
//
//  Created by Marcin Fraczak on 11/9/12.
//
//

#import <UIKit/UIKit.h>
#import <PSPDFKit/PSPDFKit.h>

@interface DvPdfDocument : PSPDFDocument

/**
 * Set the override angle for the given page.
 * @param angle - 0..270 degs
 * @param page - page number
 */
- (void)setOverrideAngle:(NSUInteger)angle forPage:(NSUInteger)page;

/**
 * Get the override angle for a page if set.
 * @param[out] angle - 0..270 degs. Should not be nil.
 * @param page - page number
 */
- (BOOL)getOverrideAngle:(NSUInteger*)angle forPage:(NSUInteger)page;

@end
