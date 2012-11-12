//
//  DvPdfDocumentProvider.m
//  DocumentViewer
//
//  Created by Marcin Fraczak on 11/9/12.
//
//

#import "DvPdfDocumentProvider.h"
#import "DvPdfDocument.h"

@implementation DvPdfDocumentProvider

- (PSPDFPageInfo*)pageInfoForPage:(NSUInteger)page
{
    PSPDFPageInfo* info = [super pageInfoForPage:page];
    
    DvPdfDocument* doc = (DvPdfDocument*) self.document;
    
    NSUInteger angle = 0;
    
    if ( [doc getOverrideAngle:&angle forPage:page] )
    {
        info.pageRotation = angle;
        NSLog(@"Page %d, rotation %d", page, info.pageRotation );
    }
    
    return info;
}

@end
