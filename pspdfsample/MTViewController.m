//
//  MTViewController.m
//  pspdfsample
//
//  Created by Marcin Fraczak on 10/24/12.
//  Copyright (c) 2012 MapText. All rights reserved.
//

#import "MTViewController.h"
#import <PSPDFKit/PSPDFKit.h>

/**
 * Subclassing button items
 */
@protocol DVPDFBarButtonItemDelegate <NSObject>

@required
-(void)barButtonItemActionInvoked:(PSPDFBarButtonItem*)item;

@end

@interface DVPDFBookmarkBarButtonItem : PSPDFBookmarkBarButtonItem

- (void)action:(PSPDFBarButtonItem *)sender;
@property (nonatomic, assign) id<DVPDFBarButtonItemDelegate> delegate;

@end

@interface DVPDFAnnotationBarButtonItem : PSPDFAnnotationBarButtonItem

- (void)action:(PSPDFBarButtonItem *)sender;
@property (nonatomic, assign) id<DVPDFBarButtonItemDelegate> delegate;

@end

@interface DVPDFTOCBarButtonItem : PSPDFOutlineBarButtonItem

- (void)action:(PSPDFBarButtonItem *)sender;
@property (nonatomic, assign) id<DVPDFBarButtonItemDelegate> delegate;

@end

@interface DVPDFSearchBarButtonItem : PSPDFSearchBarButtonItem

- (void)action:(PSPDFBarButtonItem *)sender;
@property (nonatomic, assign) id<DVPDFBarButtonItemDelegate> delegate;

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


#define DOCS_COUNT 2

@interface MTViewController () <PSPDFViewControllerDelegate, DVPDFBarButtonItemDelegate>
{
    unsigned int _documentIndex;
    NSString* _documentNames[DOCS_COUNT];
}

@property (retain, nonatomic) IBOutlet UIView *pdfContainer;
@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;
@property (retain, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (retain, nonatomic) PSPDFViewController* pdfvc;
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
    _documentIndex = (_documentIndex+1 ) % DOCS_COUNT;
    
    kPSPDFLogLevel = PSPDFLogLevelInfo;
    
    NSURL* docUrl = [[NSBundle mainBundle] URLForResource:_documentNames[_documentIndex] withExtension:@"pdf"];
    PSPDFDocument* pdfDocument = [PSPDFDocument PDFDocumentWithURL:docUrl];
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
    self.pdfvc = [[[PSPDFViewController alloc] initWithDocument:pdfDocument] autorelease];
    
    // Setup the look and feel
    CGRect frame = self.pdfContainer.frame;
    frame.origin = CGPointMake(0, 0);
    self.pdfvc.view.frame = frame;
    self.pdfvc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // Setup subclassing of the bar button items
    self.pdfvc.overrideClassNames = @{
    // TODO: UNCOMMENT THIS
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
    // TODO: AND THIS
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
    
    [self.pdfvc showControls];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    _documentIndex = 0;
    
    _documentNames[0] = @"DevelopersGuide";
    _documentNames[1] = @"yahtzee";

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
    [super dealloc];
}
@end
