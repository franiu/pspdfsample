//
//  MTViewController.m
//  pspdfsample
//
//  Created by Marcin Fraczak on 10/24/12.
//  Copyright (c) 2012 MapText. All rights reserved.
//

#import "MTViewController.h"
#import <PSPDFKit/PSPDFKit.h>
#import "DvPdfDocument.h"
#import "DvPdfDocumentProvider.h"
#import "DvPdfViewController.h"

@interface MTViewController () <PSPDFViewControllerDelegate, DVPDFBarButtonItemDelegate>
{
}

@property (retain, nonatomic) IBOutlet UIView *pdfContainer;
@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;
@property (retain, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (retain, nonatomic) DvPdfViewController* pdfvc;
@property (nonatomic) unsigned int documentIndex;
@property (retain, nonatomic) NSArray* documentNames;
@end

@implementation MTViewController

- (id)init
{
    self = [super init];
    if ( self )
    {
    }
    
    return self;
}

#pragma mark - DVPDFBarButtonItemDelegate

- (void)dismissPopovers
{
    // Dismiss all the popovers here
}

- (void)barButtonItemActionInvoked:(PSPDFBarButtonItem *)item
{
    // Hide all popovers
    [self dismissPopovers];
}

- (IBAction)swapDocs:(id)sender {
    [self toggleDocuments];
}

- (void)toggleDocuments
{
    if ( self.documentIndex >= self.documentNames.count ) self.documentIndex = 0;
    
    kPSPDFLogLevel = PSPDFLogLevelInfo;
    
    NSURL* docUrl = [[NSBundle mainBundle] URLForResource:self.documentNames[_documentIndex++] withExtension:@"pdf"];
    DvPdfDocument* pdfDocument = [DvPdfDocument PDFDocumentWithURL:docUrl];
    pdfDocument.annotationSaveMode = PSPDFAnnotationSaveModeExternalFile;

    if ( self.pdfvc )
    {
        // Remove the old view controller
        [self.pdfvc removeFromParentViewController];
        [self.pdfvc.view removeFromSuperview];
        
        // Remove old button items
        
        NSMutableArray* items = [[self.bottomToolbar.items mutableCopy] autorelease];
        
        for ( int i = items.count-1; i >= 0; i-- )
        {
            if ( [items[i] tag] == 1 )
            {
                [items removeObjectAtIndex:i];
            }
        }
        self.bottomToolbar.items = items;
        
        items = [[self.toolbar.items mutableCopy] autorelease];
        
        for ( int i = items.count-1; i >= 0; i-- )
        {
            if ( [items[i] tag] == 1 )
            {
                [items removeObjectAtIndex:i];
            }
        }
        self.toolbar.items = items;
    }
    
    // Create a new PDF view controller
    self.pdfvc = [[[DvPdfViewController alloc] initWithDocument:pdfDocument] autorelease];
    
    // Setup the look and feel
    CGRect frame = self.pdfContainer.frame;
    frame.origin = CGPointMake(0, 0);
    self.pdfvc.view.frame = frame;
    self.pdfvc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // Setup subclassing of the bar button items
    self.pdfvc.overrideClassNames = @{
    (id)[PSPDFBookmarkBarButtonItem class] : [DVPDFBookmarkBarButtonItem class],
    (id)[PSPDFAnnotationBarButtonItem class] : [DVPDFAnnotationBarButtonItem class],
    (id)[PSPDFOutlineBarButtonItem class] : [DVPDFTOCBarButtonItem class],
    (id)[PSPDFSearchBarButtonItem class] : [DVPDFSearchBarButtonItem class] };
    
    self.pdfvc.toolbarEnabled = YES;
    self.pdfvc.HUDViewMode = PSPDFHUDViewAutomatic;
    self.pdfvc.delegate = self;
    self.pdfvc.tintColor = self.toolbar.tintColor;
    self.pdfvc.pageMode = PSPDFPageModeSingle;
    
    NSMutableArray* items = [[self.bottomToolbar.items mutableCopy] autorelease];
    
    [items addObject:self.pdfvc.bookmarkButtonItem];
    self.pdfvc.bookmarkButtonItem.tag = 1;
    ((DVPDFBookmarkBarButtonItem*)self.pdfvc.bookmarkButtonItem).delegate = self;
    self.pdfvc.bookmarkButtonItem.tapChangesBookmarkStatus = NO;
    [items addObject:self.pdfvc.annotationButtonItem];
    self.pdfvc.annotationButtonItem.tag = 1;
    ((DVPDFAnnotationBarButtonItem*)self.pdfvc.annotationButtonItem).delegate = self;
    [items addObject:self.pdfvc.outlineButtonItem];
    self.pdfvc.outlineButtonItem.tag = 1;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Update the outline button in the background
        if ( ![self.pdfvc.outlineButtonItem isAvailableBlocking] )
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.pdfvc.outlineButtonItem.enabled = NO;
            });
        }
    });
    ((DVPDFTOCBarButtonItem*)self.pdfvc.outlineButtonItem).delegate = self;
    [items addObject:self.pdfvc.viewModeButtonItem];
    self.pdfvc.viewModeButtonItem.tag = 1;
    
    self.bottomToolbar.items = items;
    
    items = [[self.toolbar.items mutableCopy] autorelease];
    [items addObject:self.pdfvc.searchButtonItem];
    self.pdfvc.searchButtonItem.tag = 1;
    ((DVPDFSearchBarButtonItem*)self.pdfvc.searchButtonItem).delegate = self;
    self.toolbar.items = items;
    
    
    [self.pdfContainer addSubview:self.pdfvc.view];
    [self addChildViewController:self.pdfvc];
    
    //[self.pdfvc showControls];
}
- (IBAction)dismiss:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)demoXib:(id)sender {
    MTViewController* modal = [[MTViewController alloc] init];
    [self presentViewController:modal animated:YES completion:nil];
    [modal release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.documentIndex = 0;
    
    self.documentNames = @[@"DevelopersGuide", @"yahtzee"];

    [self toggleDocuments];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_pdfContainer release];
    [_toolbar release];
    [_bottomToolbar release];
    [_documentNames release];
    [super dealloc];
}

#pragma mark - Rotation of content

- (IBAction)rotatePageLeft:(id)sender {
    if ( self.pdfvc )
    {
        [self.pdfvc forceRotationLeftForCurrentPage];
    }
}

- (IBAction)rotatePageRight:(id)sender {
    if ( self.pdfvc )
    {
        [self.pdfvc forceRotationRightForCurrentPage];
    }
}

#pragma mark - PSPDFViewControllerDelegate

- (void)pdfViewController:(PSPDFViewController *)pdfController didDisplayDocument:(PSPDFDocument *)document
{
//    [self.pdfvc searchForString:@"Foo" animated:YES];
}

@end
