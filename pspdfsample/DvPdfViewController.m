//
//  DvPdfViewController.m
//  DocumentViewer
//
//  Created by Marcin Fraczak on 10/23/12.
//
//

#import "DvPdfViewController.h"
#import "DvPdfDocument.h"

@implementation DvPdfViewController

- (id)init
{
    self = [super init];
    
    return self;
}

- (id)initWithDocument:(PSPDFDocument *)document
{
    return [super initWithDocument:document];
}

- (void) dealloc
{
    [super dealloc];
}

- (void)addRotationAngleForCurrentPage:(NSInteger)angle
{
    PSPDFPageInfo* pageInfo = [self.document pageInfoForPage:self.page];
    
    NSInteger rotation = pageInfo.pageRotation + angle;
    while ( rotation > 270 )
    {
        rotation -= 360;
    }
    
    while ( rotation < 0 )
    {
        rotation += 360;
    }
    
    [((DvPdfDocument*)self.document) setOverrideAngle:rotation forPage:self.page];
    [self.document clearCache];
    [self reloadData];

}

- (void)forceRotationLeftForCurrentPage
{
    [self addRotationAngleForCurrentPage:-90];
}

- (void)forceRotationRightForCurrentPage
{
    [self addRotationAngleForCurrentPage:90];
}


@end

@implementation DVPDFBookmarkBarButtonItem

- (void)action:(PSPDFBarButtonItem *)sender
{
    [self.delegate barButtonItemActionInvoked:self];
    [super action:sender];
}

@end

@implementation DVPDFAnnotationBarButtonItem : PSPDFAnnotationBarButtonItem

- (void)action:(PSPDFBarButtonItem *)sender
{
    [self.delegate barButtonItemActionInvoked:self];
    [super action:sender];
}

@end

@implementation DVPDFTOCBarButtonItem : PSPDFOutlineBarButtonItem

- (void)action:(PSPDFBarButtonItem *)sender
{
    [self.delegate barButtonItemActionInvoked:self];
    [super action:sender];
}

@end

@implementation DVPDFSearchBarButtonItem : PSPDFSearchBarButtonItem

- (void)action:(PSPDFBarButtonItem *)sender
{
    [self.delegate barButtonItemActionInvoked:self];
    [super action:sender];
}

@end
