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
#import "DocumentSearchOperation.h"
#import "MBProgressHUD.h"

@interface MTViewController () <PSPDFViewControllerDelegate, DVPDFBarButtonItemDelegate, DocumentSearchOperationDelegate>
{
}

@property (retain, nonatomic) IBOutlet UIView *pdfContainer;
@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;
@property (retain, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (retain, nonatomic) DvPdfViewController* pdfvc;
@property (nonatomic) unsigned int documentIndex;
@property (retain, nonatomic) NSArray* documentNames;
@property (retain, nonatomic) NSOperationQueue* documentSearchOperations;
@property (retain, nonatomic) MBProgressHUD* hud;

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
    [items insertObject:self.pdfvc.searchButtonItem atIndex:0];
    self.pdfvc.searchButtonItem.tag = 1;
    ((DVPDFSearchBarButtonItem*)self.pdfvc.searchButtonItem).delegate = self;
    self.toolbar.items = items;
    
    
    [self.pdfContainer addSubview:self.pdfvc.view];
    [self addChildViewController:self.pdfvc];
    
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
    
    self.documentNames = @[@"DevelopersGuide", @"yahtzee", @"CodeCharts"];

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
    if ( self.documentSearchOperations )
    {
        [self.documentSearchOperations removeObserver:self forKeyPath:@"operationCount"];
    }
    [_documentSearchOperations cancelAllOperations];
    [_documentSearchOperations release];
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

- (IBAction)demoSearchCrash:(UIBarButtonItem *)sender {

    kPSPDFLowMemoryMode = YES;
    if ( !self.documentSearchOperations )
    {
        self.documentSearchOperations = [[[NSOperationQueue alloc] init] autorelease];
        // 2 simultaneous operations seem to give good performance without causing memory exhaustion.
        // This number may be tweaked in the future.
        self.documentSearchOperations.maxConcurrentOperationCount = 2;
        [self.documentSearchOperations addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    NSString* uuid = [[NSUUID UUID] UUIDString];
    for ( NSString* docName in self.documentNames )
    {
        NSURL* docUrl = [[NSBundle mainBundle] URLForResource:docName withExtension:@"pdf"];
        Document* doc = [[[Document alloc] init] autorelease];
        doc.filename = [docUrl path];
        
        DocumentSearchOperation* searchOperation = [[[DocumentSearchOperation alloc] initWithSearchUUID:uuid documentToSearch:doc searchPhrase:@"test" delegate:self] autorelease];
        [self.documentSearchOperations addOperation:searchOperation];
    }
    
    // Also start the search in the currently open document immediately
    [self.pdfvc searchForString:@"test" animated:NO];
    [self.pdfvc.searchButtonItem dismissAnimated:NO];
    [self.pdfvc.searchButtonItem presentAnimated:YES sender:self.pdfvc.searchButtonItem];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = [NSString stringWithFormat:@"Searching... (%d operations active)", self.documentSearchOperations.operationCount];
}

#pragma mark - DocumentSearchOperationDelegate


- (void) updateSearchResultsWithOperation:(DocumentSearchOperation *)operation withSearchId:(NSString *)searchId withResults:(NSArray *)searchResults completed:(BOOL)completed interrupted:(BOOL)interrupted
{
    assert( [NSThread isMainThread] );
    
    if ( searchResults.count > 0 )
    {
        NSLog(@"Found an instance of the string in a document");
    }
}

- (void) documentSearchOperation:(DocumentSearchOperation *)operation didFinishSearch:(NSString *)searchId withResults:(NSArray *)searchResults earlyTermination:(BOOL)earlyTermination lastPageSearched:(unsigned int)lastPageSearched
{
}

- (void) documentSearchOperation:(DocumentSearchOperation *)operation didUpdateSearch:(NSString *)searchId withResults:(NSArray *)searchResults
{

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( object == self.documentSearchOperations && [keyPath isEqualToString:@"operationCount"] )
    {
        // Operation count changed
        BOOL searchActive = self.documentSearchOperations.operationCount > 0;
        
        if ( !searchActive )
        {
            [self.hud hide:YES];
            return;
        }
        
        self.hud.labelText = [NSString stringWithFormat:@"Searching... (%d operations active)", self.documentSearchOperations.operationCount];
    }
}

#pragma mark - PSPDFViewControllerDelegate

- (void)pdfViewController:(PSPDFViewController *)pdfController didDisplayDocument:(PSPDFDocument *)document
{
//    [self.pdfvc searchForString:@"Foo" animated:YES];
}

@end
