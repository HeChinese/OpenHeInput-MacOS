/*
 * Copyright (c) 2016 Guilin Ouyang. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "CandidateView.h"

@implementation HeInputController (CandidateView)

// Return true: eat the event
// Return false: send the event out.
- (BOOL)hePageUp;
{
    if ([dataServer numOfCand]>0) {
        return [self changePageIndexBy:-1];
    }
    else
        return false;
}

// Return true: eat the event
// Return false: send the event out.
- (BOOL)hePageDown;
{
    if ([dataServer numOfCand]>0) {
        return [self changePageIndexBy:1];
    }
    else
        return false;
}

// Return true: eat the event
// Return false: send the event out.
- (BOOL)heUpArrow;
{
    if ([dataServer numOfCand]>0) {
       return [self changeItemIndexBy:-1];
    }
    else
        return false;
}

// Return true: eat the event
// Return false: send the event out.
- (BOOL)heDownArrow;
{
    if ([dataServer numOfCand]>0) {
        return [self changeItemIndexBy:1];
    }
    else
        return false;
}

// Return true: eat the event
// Return false: send the event out.
- (BOOL)changePageIndexBy:(NSInteger)num
{
    NSInteger pageIndexBeforeChange = pageIndex;
    
    if(num == 1)
    {
        if((pageIndex + 1)*maxItemsOfPage < dataServer.numOfCand)
        {
            pageIndex++;
        }
        else {
            // reached end page
        }
    }
    else if( num == -1)
    {
        if(pageIndex > 0 )
        {
            pageIndex--;
        }
        else {
            // reached the top page.
            //pageIndex = (numOfCand + maxItemsOfPage - 1)/maxItemsOfPage-1; //when numOfCand = 1
        }
    }
    else {
        //unexpected num value
        return false;
    }
    
    if(pageIndex != pageIndexBeforeChange)
    {
        [self heChangePage];
    }
    else
    {
        [self heRefrechPage];
    }
    [self displayTypedString:currentClient];
    
    return true;
}

// Return true: eat the event
// Return false: send out the event.
- (BOOL)changeItemIndexBy:(NSInteger)num
{
    NSInteger itemIndexBeforeChange = itemIndexOfCurrentPage;
    
    if(numOfItemsInCurrentPage<=1)
        return true;
    
    if(num == 1)
    {
        itemIndexOfCurrentPage++;
        if(itemIndexOfCurrentPage == numOfItemsInCurrentPage)
        {
            itemIndexOfCurrentPage = 0;
            if((pageIndex + 1)*maxItemsOfPage < dataServer.numOfCand)
            {
                return [self hePageDown];
            }
        }
    }
    else if (num == -1)
    {
        itemIndexOfCurrentPage--;
        if(itemIndexOfCurrentPage == -1)
        {
            itemIndexOfCurrentPage = numOfItemsInCurrentPage-1;
            if (pageIndex >= 1 ) {
               return [self hePageUp];
            }
        }
    }
    
    // when move arrow, we change typed engShuMa
    if(itemIndexOfCurrentPage != itemIndexBeforeChange)
    {
        if ([dataServer needShowEnglishCodeList]) {
            
            dataServer.setting.currentKeyMode = PinYinMode;
            [dataServer heBackspace];
            [dataServer changeTypingState4Modes:0xffff TypedShuMa:(itemIndexOfCurrentPage + 1)];
            [self displayTypedString:currentClient];
        }
    }
  
    extern IMKCandidates* imkCandidates;
    if ( imkCandidates ) {
        [imkCandidates selectCandidateWithIdentifier:[imkCandidates candidateIdentifierAtLineNumber:itemIndexOfCurrentPage]];
    }

    return true;
}

- (void)getNumOfItemsOfCurrentPage
{
    NSUInteger numOfItemLeft = dataServer.numOfCand - pageIndex*maxItemsOfPage;
    numOfItemsInCurrentPage = (numOfItemLeft>=maxItemsOfPage)? maxItemsOfPage:numOfItemLeft;
}

@end
