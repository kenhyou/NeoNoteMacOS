//
//  NJPageZoomView.h
//  NeoNotesMacOS
//

#import "NJZoomView.h"
@class NJPage;

@interface NJPageZoomView : NJZoomView {
@private
    CGFloat mPaperWidth;
    CGFloat mPaperHeight;
    CGFloat mPageScale;
@protected
    CGPDFDocumentRef _PDFDocRef;
    CGPDFPageRef _PDFPageRef;
    NSInteger _pageAngle;
    CGFloat _pageWidth;
    CGFloat _pageHeight;
    CGFloat _pageOffsetX;
    CGFloat _pageOffsetY;
        
    NJPage *mPage;
    NSArray *_markingRanges;
    NSString *_matchWord;

}
+ (NSColor*)backgroundColour;
- (CGFloat)pageScale;
- (void)resetZoomView;
- (void)setPaperWidth:(CGFloat)width height:(CGFloat)height;
- (void)setNotebookUuid:(NSString *)notebookUuid pageNum:(NSUInteger)pageNumber;
@end
