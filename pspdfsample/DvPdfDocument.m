//
//  DvPdfDocument.m
//  DocumentViewer
//
//  Created by Marcin Fraczak on 11/9/12.
//
//

#import "DvPdfDocument.h"
#import "DvPdfDocumentProvider.h"

@interface DvPdfDocument()

@property (nonatomic, retain) NSMutableDictionary* forcedPageRotations;

@end

@implementation DvPdfDocument

- (PSPDFDocumentProvider*)didCreateDocumentProvider:(PSPDFDocumentProvider*)documentProvider
{
    DvPdfDocumentProvider* provider = [[[DvPdfDocumentProvider alloc] initWithFileURL:self.fileURL document:self] autorelease];
    return provider;
}

- (BOOL)getOverrideAngle:(NSUInteger *)angle forPage:(NSUInteger)page
{
    assert( angle != nil );
    
    @synchronized(self)
    {
        if ( !self.forcedPageRotations || [self.forcedPageRotations objectForKey:[NSNumber numberWithUnsignedInteger:page]] == nil )
        {
            return NO;
        }
        
        NSUInteger value = [[self.forcedPageRotations objectForKey:[NSNumber numberWithUnsignedInteger:page]] unsignedIntegerValue];
        
        *angle = value;
        return YES;
    }
}

- (void)setOverrideAngle:(NSUInteger)angle forPage:(NSUInteger)page
{
    @synchronized(self)
    {
        if ( !self.forcedPageRotations )
        {
            self.forcedPageRotations = [NSMutableDictionary dictionary];
        }
        
        [self.forcedPageRotations setObject:[NSNumber numberWithUnsignedInteger:angle] forKey:[NSNumber numberWithUnsignedInteger:page]];
    }
}


- (void)dealloc
{
    [_forcedPageRotations release];
    
    [super dealloc];
}

@end
