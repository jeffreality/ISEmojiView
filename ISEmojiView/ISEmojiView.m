//
//  ISEmojiView.m
//  ISEmojiViewSample
//
//  Created by isaced on 14/12/25.
//  Copyright (c) 2014年 isaced. All rights reserved.
//

#import "ISEmojiView.h"

static const CGFloat EmojiWidth = 53;
static const CGFloat EmojiHeight = 50;
static const CGFloat EmojiFontSize = 32;

@interface ISEmojiView()<UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *emojis;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation ISEmojiView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        // init emojis
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ISEmojiList" ofType:@"plist"];
        self.emojis = [NSArray arrayWithContentsOfFile:plistPath];
        
        //
        NSInteger rowNum = (CGRectGetWidth(frame) / EmojiWidth);
        NSInteger colNum = (CGRectGetHeight(frame) / EmojiHeight);
        NSInteger numOfPage = ceil((float)[self.emojis count] / (float)(rowNum * colNum));
        
        // init scrollview
        self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.delegate = self;
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(frame) * numOfPage,
                                                 CGRectGetHeight(frame));
        [self addSubview:self.scrollView];
        
        // add emojis
        
        NSInteger row = 0;
        NSInteger column = 0;
        NSInteger page = 0;
        
        for (int i = 0; i < [self.emojis count]; i++) {
            
            NSString *emoji = self.emojis[i];
            
            // init Emoji Button
            UIButton *emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
            emojiButton.titleLabel.font = [UIFont fontWithName:@"Apple color emoji" size:EmojiFontSize];
            [emojiButton setTitle:emoji forState:UIControlStateNormal];
            [emojiButton addTarget:self action:@selector(emojiButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            // Pagination
            if (i % (rowNum * colNum) == 0) {
                page ++;    // Increase the number of pages
                row = 0;    // the number of lines is 0
                column = 0; // the number of columns is 0
            }else if (i % rowNum == 0) {
                // NewLine
                row += 1;   // Increase the number of lines
                column = 0; // The number of columns is 0
            }
            
            emojiButton.frame = CGRectMake(((page-1) * frame.size.width) + (column * EmojiWidth),
                                           row * EmojiHeight,
                                           EmojiWidth,
                                           EmojiHeight);
            column++;
            
            [self.scrollView addSubview:emojiButton];
        }
        
        // add PageControl
        self.pageControl = [[UIPageControl alloc] init];
        self.pageControl.hidesForSinglePage = YES;
        self.pageControl.currentPage = 0;
        self.pageControl.backgroundColor = [UIColor clearColor];
        self.pageControl.numberOfPages = numOfPage;
        CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:numOfPage];
        self.pageControl.frame = CGRectMake(CGRectGetMidX(frame) - pageControlSize.width,
                                            CGRectGetHeight(frame) - pageControlSize.height + 5,
                                            pageControlSize.width,
                                            pageControlSize.height);
        [self.pageControl addTarget:self action:@selector(pageControlTouched:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.pageControl];
    }
    return self;
}

- (void)pageControlTouched:(UIPageControl *)sender {
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * sender.currentPage;
    [self.scrollView scrollRectToVisible:bounds animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    NSInteger newPageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (self.pageControl.currentPage == newPageNumber) {
        return;
    }
    self.pageControl.currentPage = newPageNumber;
}

- (void)emojiButtonPressed:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(emojiView:didSelectEmoji:)]) {
        [self.delegate emojiView:self didSelectEmoji:button.titleLabel.text];
    }
}

@end
