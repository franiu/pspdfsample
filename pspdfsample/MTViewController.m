//
//  MTViewController.m
//  pspdfsample
//
//  Created by Marcin Fraczak on 10/24/12.
//  Copyright (c) 2012 MapText. All rights reserved.
//

#import "MTViewController.h"
#import <PSPDFKit/PSPDFKit.h>

@interface MTViewController () <PSPDFViewControllerDelegate>

@property (retain, nonatomic) IBOutlet UIView *pdfContainer;
@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;
@property (retain, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@end

@implementation MTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    kPSPDFLogLevel = PSPDFLogLevelInfo;
    
    NSURL* docUrl = [[NSBundle mainBundle] URLForResource:@"DevelopersGuide" withExtension:@"pdf"];
    PSPDFDocument* pdfDocument = [PSPDFDocument PDFDocumentWithURL:docUrl];
    pdfDocument.annotationSaveMode = PSPDFAnnotationSaveModeExternalFile;
    
    PSPDFViewController* pdfvc = [[[PSPDFViewController alloc] initWithDocument:pdfDocument] autorelease];
    
    // Setup the look and feel
    CGRect frame = self.pdfContainer.frame;
    frame.origin = CGPointMake(0, 0);
    pdfvc.view.frame = frame;
    pdfvc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    pdfvc.toolbarEnabled = YES;
    pdfvc.HUDViewMode = PSPDFHUDViewAutomatic;
    pdfvc.delegate = self;
    pdfvc.tintColor = self.toolbar.tintColor;
    
    // So here I'd like to let the PDPDFViewController know that it should use the self.toolbar.
    
    NSMutableArray* items = [[self.bottomToolbar.items mutableCopy] autorelease];
    
    
    [items addObject:pdfvc.bookmarkButtonItem];
    [items addObject:pdfvc.annotationButtonItem];
    [items addObject:pdfvc.outlineButtonItem];
    
    self.bottomToolbar.items = items;
    
    items = [self.toolbar.items mutableCopy];
    [items addObject:pdfvc.searchButtonItem];
    self.toolbar.items = items;


    [self.pdfContainer addSubview:pdfvc.view];
    [self addChildViewController:pdfvc];
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
