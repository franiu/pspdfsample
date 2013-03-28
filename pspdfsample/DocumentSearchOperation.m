//
//  DocumentSearchOperation.m
//  pspdfsample
//
//  Created by Marcin Fraczak on 3/28/13.
//  Copyright (c) 2013 MapText. All rights reserved.
//

#import "DocumentSearchOperation.h"

@implementation Document

@end

@implementation SearchResult

+ (id)searchResultWithDocument:(Document*)document andNumberOfMatches:(unsigned int)numberOfMatches searchComplete:(BOOL)complete
{
    SearchResult* result = [[[SearchResult alloc] init] autorelease];
    result.document = document;
    result.numberOfMatchesFound = numberOfMatches;
    result.searchComplete = complete;
    
    return result;
}

- (void)dealloc
{
    [_document release];
    [_firstOccurencePageHint release];
    
    [super dealloc];
}

@end


@implementation DocumentSearchOperation

#pragma mark - Lifecycle
- (id)initWithSearchUUID:(NSString*)searchUUID documentToSearch:(Document*)document searchPhrase:(NSString*)searchPhrase delegate:(id<DocumentSearchOperationDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
        _isFinished = NO;
        _isExecuting = NO;
        self.documentToSearch = document;
        self.searchPhrase = searchPhrase;
        self.searchUUID = searchUUID;
        self.delegate = delegate;
        self.startPage = 0;
        
        // Register for search cancellation notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(searchCancelled:)
                                                     name:kSearchCancelledNotification
                                                   object:nil];
    }
    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_documentToSearch release];
    [_pdfDocument release];
    [_textSearch release];
    [_searchPhrase release];
    [_searchUUID release];
    
    [super dealloc];
}

#pragma mark - NSOperation

- (BOOL)isFinished
{
    return _isFinished;
}

- (BOOL) isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return _isExecuting;
}

- (void)finalize
{
    if ( !self.isOperationStarted )
    {
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = YES;
    _isExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)start
{
    self.operationStarted = YES;
    if ( !self.documentToSearch || !self.searchPhrase || [self isCancelled] )
    {
        [self finalize];
        return;
    }
    
    NSString* fullPath = [self.documentToSearch filename];
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:fullPath] )
    {
        // Whoops!
        assert(false);
    }
    
#ifdef DEBUG
    kPSPDFLogLevel = PSPDFLogLevelInfo;
#endif
    _pdfDocument = [[PSPDFDocument PDFDocumentWithURL:[NSURL fileURLWithPath:fullPath]] retain];
    
    _textSearch = [[PSPDFTextSearch alloc] initWithDocument:_pdfDocument];
    _textSearch.delegate = self;
    _textSearch.searchMode = PSPDFSearchModeBasic;
    [_textSearch searchForString:self.searchPhrase];
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

#pragma mark - Notifications

- (void)searchCancelled:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    NSString* cancelledSearchUUID = [userInfo objectForKey:kCancelledSearchUUID];
    
    if ( [cancelledSearchUUID isEqualToString:self.searchUUID] )
    {
        [_textSearch cancelAllOperationsAndWait];
        _textSearch.delegate = nil;
        _isCancelled = YES;
        [self finalize];
    }
}

#pragma mark - PSPDFTextSearchDelegate

/// Called when search is started.
- (void)willStartSearch:(PSPDFTextSearch *)textSearch forTerm:(NSString *)searchTerm isFullSearch:(BOOL)isFullSearch
{
    // Ignore
}

/// Search was updated, a new page has been scanned.
- (void)didUpdateSearch:(PSPDFTextSearch *)textSearch forTerm:(NSString *)searchTerm newSearchResults:(NSArray *)searchResults forPage:(NSUInteger)page
{
    if ( searchResults.count > 0 && !_isCancelled )
    {
        // Notify the delegate
        dispatch_async(dispatch_get_main_queue(), ^{ [self.delegate documentSearchOperation:self didUpdateSearch:self.searchUUID withResults:searchResults]; } );
    }
}

/// Search has finished.
- (void)didFinishSearch:(PSPDFTextSearch *)textSearch forTerm:(NSString *)searchTerm searchResults:(NSArray *)searchResults isFullSearch:(BOOL)isFullSearch
{
    if ( searchResults.count > 0 && !_isCancelled )
    {
        // Notify the delegate
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate documentSearchOperation:self didFinishSearch:self.searchUUID withResults:searchResults earlyTermination:NO lastPageSearched:0];
        } );
    }
    
    [self finalize];
}

/// Search has been cancelled.
- (void)didCancelSearch:(PSPDFTextSearch *)textSearch forTerm:(NSString *)searchTerm isFullSearch:(BOOL)isFullSearch
{
    // We're done with the search
    [self finalize];
}

@end