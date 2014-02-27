//
//  FCAutosizeLabel.m
//  TrueTPL
//
//  Created by toon on 12/20/13.
//  Copyright (c) 2013 qlovr. All rights reserved.
//

#import "FCAutosizeLabel.h"

static const CGFloat TOLERANCE = 1.0;

@implementation FCAutosizeLabel{
    CGFloat originalFontSize;
}

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        [self customInit];
    }
    return self;
}

-(instancetype) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self customInit];
    }
    return self;
}

-(void) customInit
{
    if(self.font){
        originalFontSize = self.font.pointSize;
    }
}

#pragma mark record original font size

-(void) setFont:(UIFont *)font
{
    [super setFont:font];
    originalFontSize = font.pointSize;
}

-(void) setFontNotRecordSize:(UIFont *) font
{
    [super setFont:font];
}

#pragma mark -

-(void) adjustFontSizeToFitWithNoWordBreaking
{
    if(!self.text || !self.font) return;
    
    UIFont *font = self.font;
    CGSize size = self.bounds.size;
    
    CGFloat minSize = originalFontSize * self.minimumScaleFactor;
    CGFloat maxSize = [self minimumFontSizeForLongestWord];
    
    while (maxSize >= minSize)
    {
        font = [self.font fontWithSize:maxSize];
        CGSize constraintSize = CGSizeMake(size.width, MAXFLOAT);
        
        CGSize textSize = [self boundingSizeForText:self.text maxSize:constraintSize inFont:font];
        
        if(size.height - textSize.height >= TOLERANCE)
        {
            break;
        }
        maxSize -= 0.5;
    }
    // set the font to the minimum size anyway
    [self setFontNotRecordSize:font];
    [self setNeedsLayout];
}

-(CGFloat) minimumFontSizeForLongestWord
{
    __block CGFloat maxLength = 0;
    __block NSString *longestWord = nil;
    CGSize maxSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
    CGFloat fontSize = originalFontSize;
    UIFont *font = [self.font fontWithSize:fontSize];
    [self.text enumerateSubstringsInRange:NSMakeRange(0, self.text.length) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        CGSize textSize = [self boundingSizeForText:substring maxSize:maxSize inFont:font];
        
        if(textSize.width > maxLength){
            maxLength = textSize.width;
            longestWord = substring;
        }
        
    }];
    
    if(self.bounds.size.width - maxLength < TOLERANCE){
        
        CGFloat minFontSize = fontSize * self.minimumScaleFactor;
        
        while (fontSize >= minFontSize)
        {
            font = [self.font fontWithSize:fontSize];
            
            CGSize textSize = [self boundingSizeForText:longestWord maxSize:maxSize inFont:font];
            if(self.bounds.size.width - textSize.width >= TOLERANCE)
            {
                return  fontSize;
            }
            fontSize -= 0.5;
        }
        return minFontSize;
    } else {
        return fontSize;
    }
    
}

//handle ios6/7
-(CGSize) boundingSizeForText:(NSString *) text maxSize:(CGSize) maxSize inFont:(UIFont *) font
{
    if([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]){
        return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    } else {
        return [text sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    
}

@end
