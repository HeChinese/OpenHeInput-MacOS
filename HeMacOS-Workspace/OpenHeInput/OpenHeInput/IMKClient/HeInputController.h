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

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import "HeInputLibrary/Input_DataServer.h"
#import "HeInputLibrary/Input_Setting.h"
#import "HeInputLibrary/Globel_Helper.h"


@interface HeInputController : IMKInputController {
    
    id currentClient;
    
    Input_DataServer *dataServer;
    
    DataServer_Return serverReturnValue;

    //bool bPreviousPage, bNextPage;
    NSUInteger maxItemsOfPage, numOfItemsInCurrentPage, pageIndex, itemIndexOfCurrentPage;
        
    bool bOpenDoubleQuote, bOpenSingleQuote;
    BOOL bPreviousChineseChar;
        
    NSInteger atSignContinueTypedTimes;
    NSInteger periodSignContinueTypedTimes;
    NSInteger commaSignContinueTypedTimes;
    
    NSString *previousInsertText;
}

@property (strong, nonatomic) NSString *typedString;

- (void)heCommitComposition:(id)sender;
- (void)displayTypedString:(id)sender;

- (void)heChangePage;
- (void)heRefrechPage;
- (void)clearState;
//- (void)simulateEnterKeyEvent;
- (void)hideIMKCandidates;
@end
