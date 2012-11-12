//
//  DvPdfViewController.h
//  DocumentViewer
//
//  Created by Marcin Fraczak on 10/23/12.
//
//

#import <UIKit/UIKit.h>
#import <PSPDFKit/PSPDFKit.h>

/**
 * Subclassing the PSPDFViewController to control the fine aspects of behavior.
 */
@interface DvPdfViewController : PSPDFViewController

/**
 * Forces a rotation of the currently displayed page by 90 degrees counter-clockwise
 */
- (void)forceRotationLeftForCurrentPage;
/**
 * Forces a rotation of the currently displayed page by 90 degrees clockwise
 */
- (void)forceRotationRightForCurrentPage;

@end

/**
 * The following subclasses have the sole purpose of notifying the
 * delegate about an action being performed. They have been implemented
 * to allow for notifications about the SDK buttons being used and
 * closing of the other, non-sdk popovers.
 * After some clarifications with Peter Steinberger this could have been
 * done differently, by using the .popoverController property of PSPDFViewController,
 * but for now it would involve changing more code on our side, so we'll 
 * stick to this unless there's some other issue to change the approach.
 * @{
 */
@protocol DVPDFBarButtonItemDelegate <NSObject>

@required
-(void)barButtonItemActionInvoked:(PSPDFBarButtonItem*)item;

@end

@interface DVPDFBookmarkBarButtonItem : PSPDFBookmarkBarButtonItem
@property (nonatomic, assign) id<DVPDFBarButtonItemDelegate> delegate;
@end

@interface DVPDFAnnotationBarButtonItem : PSPDFAnnotationBarButtonItem
@property (nonatomic, assign) id<DVPDFBarButtonItemDelegate> delegate;
@end

@interface DVPDFTOCBarButtonItem : PSPDFOutlineBarButtonItem
@property (nonatomic, assign) id<DVPDFBarButtonItemDelegate> delegate;
@end

@interface DVPDFSearchBarButtonItem : PSPDFSearchBarButtonItem
@property (nonatomic, assign) id<DVPDFBarButtonItemDelegate> delegate;
@end

/** }@ */
 
