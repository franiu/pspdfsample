//
//  DocumentSearchOperation.h
//  pspdfsample
//
//  Created by Marcin Fraczak on 3/28/13.
//  Copyright (c) 2013 MapText. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PSPDFKit/PSPDFKit.h>


@interface Document : NSObject

@property (nonatomic, copy) NSString* filename;

@end



/**
 * A simple container alowing us to group a search result and the number of search matches inside.
 */
@interface SearchResult : NSObject

/**
 * The document which is matching the search either by name or by content
 */
@property (nonatomic, retain) Document* document;

/**
 * Number of phrase matches inside the document
 */
@property (nonatomic) unsigned int numberOfMatchesFound;

/**
 * Optional hint on the first page on which the seeked phrase occurs
 */
@property (nonatomic, retain) NSNumber* firstOccurencePageHint;

/**
 * Set to NO to indicate these are only partial results, i.e. document is still being searched.
 */
@property (nonatomic) BOOL searchComplete;

/**
 * If YES this search result operation has been suspended and it should be processed slightly different when resumed.
 */
@property (nonatomic) BOOL interrupted;

@end


@class DocumentSearchOperation;

/**
 * Handle the operation feedback.
 */
@protocol DocumentSearchOperationDelegate <NSObject>

@required
/**
 * Operation finished with some results. No results will not create a notification.
 * Guaranteed to be called on the main thread.
 * @param operation - The sender, a operation which has finished.
 * @param searchId - ID of the search. Receiver may have to handle multiple searches happening at the same time.
 * @param searchResults - The results of search.
 */
- (void)documentSearchOperation:(DocumentSearchOperation*)operation didUpdateSearch:(NSString*)searchId withResults:(NSArray*)searchResults;

/**
 * Search update arrived with some results.
 * Guaranteed to be called on the main thread.
 * @param operation - The sender, a operation which has finished.
 * @param searchId - ID of the search. Receiver may have to handle multiple searches happening at the same time.
 * @param searchResults - The results of search.
 * @param earlyTermination - Id the operation was supposed to terminate after the first match was found this will
 *                           be the flag raised it did. If set to YES the lastPageSearched will hold the last page searched
 *                           so that operation may be resumed. @see performQuickSearchOnly
 * @param lastPageSearched - Number of the last page searched if an early termination occured.
 */
- (void)documentSearchOperation:(DocumentSearchOperation*)operation didFinishSearch:(NSString*)searchId withResults:(NSArray*)searchResults earlyTermination:(BOOL)earlyTermination lastPageSearched:(unsigned int)lastPageSearched;

@end

/**
 * A document search operation. It will perform a search for the given phrase within a single PDF document.
 * Delegate will be notified when the search ends with some results. Operation can be cancelled by using the notification center.
 * A notification of kSearchCancelledNotification name needs to be sent with the userInfo containing a matching search UUID under
 * kCancelledSearchUUID key.
 */
@interface DocumentSearchOperation : NSOperation <PSPDFTextSearchDelegate>
{
    PSPDFTextSearch* _textSearch;
    PSPDFDocument* _pdfDocument;
    BOOL _isFinished;
    BOOL _isExecuting;
    BOOL _isCancelled;
}

@property (nonatomic, assign, getter=isOperationStarted) BOOL operationStarted;
@property (nonatomic, retain) Document* documentToSearch;
@property (nonatomic, retain) NSString* searchPhrase;
@property (nonatomic, assign) id<DocumentSearchOperationDelegate> delegate;

- (id)initWithSearchUUID:(NSString*)searchUUID documentToSearch:(Document*)document searchPhrase:(NSString*)searchPhrase delegate:(id<DocumentSearchOperationDelegate>)delegate;

/**
 * To distinguish between different simultaneous searches.
 */
@property (nonatomic, retain) NSString* searchUUID;

/**
 * Page at which the search should begin.
 */
@property (nonatomic) unsigned int startPage;

@end

/**
 * Search operation should be cancelled
 */
#define kSearchCancelledNotification @"DVSearchCancelled"

/**
 * UUID of the search operation which should be cancelled
 */
#define kCancelledSearchUUID @"SearchUUID"

