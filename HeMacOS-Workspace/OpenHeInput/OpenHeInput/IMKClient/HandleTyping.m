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

#import "HandleTyping.h"
#import "CandidateView.h"

@implementation HeInputController (HandleTyping)

// Return YES to indicate the the key input was received and dealt with.
// Key processing will not continue in that case.
// In other words the system will not deliver a key down event to the application.
// Returning NO means the original key down will be passed on to the client.
- (BOOL)handleCharOrShuMa:(unichar)uniChar TypedShuMa:(NSInteger)shuMa;
{
    BOOL bRet = false;
    
    //If it is continue typing
    if ([dataServer judgeContinueTyping:shuMa])
    {
        if (shuMa == 0)  //type 0 key
        {
            //[self changeItemIndexBy:1];
            return [self heDownArrow];
        }
        
        if (shuMa == 100)  //where shuma == 8  and backspace then come to here
        {
            //go through
        }
        else  // 11...55, 6, 7 8 9
        {
            [self heCommitComposition:currentClient];
        }
    }
    
    serverReturnValue = [dataServer typingCharOrNumber:uniChar TypedShuMa:shuMa];
    
    switch (serverReturnValue) {
        case CandidateArrayChanged:
        {
            pageIndex = 0;
            [self heChangePage];
            [self displayTypedString:currentClient];
            bRet = true;
        }
            break;
        case ShuMaChanged:
        {
            [self displayTypedString:currentClient];
            bRet = true;
        }
            break;
        case InvalidShuMa:
            bRet = false;
            break;
        case ChangeSelection:
        {
            bRet = [self heDownArrow];
        }
            break;
        case TypeAndTypeBack:  //candidates are same
            bRet = true;
            break;
        case CandidateArrayEmpty:
        {
            //When type backspace to 0
            [self wipeTyping];
            bRet = true;
        }
            break;
        case TypeBackspaceFailed:  //when typingState is clean
            // let application to use backspace key
            bRet = false;
            break;
            
            //Menu Selected Return
        case MenuSelected_Repeat:
            
            [currentClient insertText:previousInsertText replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
            [self clearState];
            extern IMKCandidates* imkCandidates;
            if ( imkCandidates ) {
                [imkCandidates hide];
            }
            bRet = true;
            break;
        case MenuSelected_InputMode_Changed:
            [dataServer setMenuArray];
            [self wipeTyping];
            bRet = true;
            break;
        case MenuSelected_MenuArray_NeedUpdate:
            [dataServer setMenuArray];
            [self wipeTyping];
            bRet = true;
            break;
        case MenuSelected_PleaseSaveSetting:
            bRet = true;
            break;
        default:
            break;
    }
    return bRet;
}

- (BOOL)handleControlKey:(NSInteger)keyCode
{
    BOOL bRet=FALSE;
    
    switch (keyCode)
    {
        case kVK_ANSI_KeypadDecimal:
        {
            if (dataServer.numOfCand>0) {
                //This dataServer.keySource = NumPadKey
                [self handleCharOrShuMa:0xfff TypedShuMa: 100];
            }
            bRet = true;
        }
            break;
        case kVK_ANSI_KeypadMinus:
            if (![dataServer isStateClean])
            {
                [self heUpArrow];
            }
            bRet = true;
            break;
        case kVK_ANSI_KeypadPlus:
            if (![dataServer isStateClean])
            {
                [self heDownArrow];
            }
            bRet = true;
            break;
        case kVK_ANSI_KeypadEnter: //3:	//NumPad, return Key
        {
            // menu selected
            if (![dataServer isInputable] && dataServer.numOfCand>0)
            {
                ZiCiObject *ziCiObj = dataServer.candidateArray[pageIndex*maxItemsOfPage + itemIndexOfCurrentPage];
                
                if (ziCiObj.ma1 == 0 || ziCiObj.ma1 == -2) {
                    [self handleCharOrShuMa:0xffff TypedShuMa:ziCiObj.promptMa];
                }
                bRet = true;
            }
            else if(![dataServer isStateClean])
            {
                [self heCommitComposition:currentClient];
                bRet = true;
            }
            else
            {
                bRet = false;
            }
            
        }
            break;
        case kVK_Return:	//Return keyDown
        {
            // menu selected
            if (![dataServer isInputable] && dataServer.numOfCand>0)
            {
                ZiCiObject *ziCiObj = dataServer.candidateArray[pageIndex*maxItemsOfPage + itemIndexOfCurrentPage];
                
                if (ziCiObj.ma1 == 0 || ziCiObj.ma1 == -2) {
                    [self handleCharOrShuMa:0xffff TypedShuMa:ziCiObj.promptMa];
                }
                bRet = true;
            }
            else {
                // use default return function
                bRet = false;
            }
        }
            break;
        case kVK_Space:    //Space KeyDown
        {
            if (dataServer.numOfCand == 0) {
                [currentClient insertText:@"　" replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
            }
            else if (![dataServer isInputable] && dataServer.numOfCand>0)
            {
                ZiCiObject *ziCiObj = dataServer.candidateArray[pageIndex*maxItemsOfPage + itemIndexOfCurrentPage];
                
                if (ziCiObj.ma1 == 0 || ziCiObj.ma1 == -2) {
                    [self handleCharOrShuMa:0xffff TypedShuMa:ziCiObj.promptMa];
                }
                bRet = true;
            }
            else if (![dataServer isStateClean])
            {
                [self heCommitComposition:currentClient];
                
                //pTypingState->lianXiangStrLen=1;
                //pTypingState->lianXiangStr[0] = L'和';
                
                //                if(pSetting->bSystemLianXiangOn){
                //                    pTypingState->currentShuMa=99;
                //                    pSetting->currentKeyMode = HeMaMode;
                //                    [self typingCharAndNumberClient];
                //                }
                //                else {
                return true;
            }
            bRet = true;
        }
            break;
        case kVK_ANSI_KeypadClear:
        case kVK_Delete:		//backspace keyDown
        {
            if (![dataServer isStateClean])
            {
                [self handleCharOrShuMa:0xffff TypedShuMa:100];  //type back
                bRet = true;
            }
            else
            {
                bRet = FALSE;
            }
        }
            break;
        case kVK_Escape:
        {
            if (dataServer.numOfCand>0) {
                [self clearState];
                
                //fix bug for browser url textbox
                [currentClient setMarkedText:@"" selectionRange:NSMakeRange(0, 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
            }
            bRet = false;
        }
            break;
        case kVK_PageUp:
        case kVK_LeftArrow:
        {
            bRet = [self hePageUp];
        }
            break;
        case kVK_PageDown:
        case kVK_RightArrow:
        {
            bRet = [self hePageDown];
        }
            break;
        case kVK_DownArrow:
        {
            bRet = [self heDownArrow];
        }
            break;
        case kVK_UpArrow:
        {
            bRet = [self heUpArrow];
        }
            break;
            
        default:
            break;
    }
    return bRet;
}

- (BOOL)handlePunctuationKey:(unichar)charCode //  modifier:(NSUInteger)flags
{
    NSString *newString = nil;
    BOOL bRet=FALSE;
    
    switch(charCode)
    {
        case 44:	//,
            newString = @"，";
            bRet = TRUE;
            break;
        case 46:	//.
            newString = @"。";
            bRet = TRUE;
            break;
        case 60:	//<
            newString = @"《";
            bRet = TRUE;
            break;
        case 62:	//>
            newString = @"》";
            bRet = TRUE;
            break;
        case 47:	///
            newString = @"、";
            bRet = TRUE;
            break;
        case 63:	//?
            newString = @"？";
            bRet = TRUE;
            break;
        case 59:	//;
            newString = @"；";
            bRet = TRUE;
            break;
        case 58:	//:
            newString = @"：";
            bRet = TRUE;
            break;
        case 39:	//'
            if(bOpenSingleQuote)
            {
                newString = @"‘";
                bOpenSingleQuote=FALSE;
            }
            else
            {
                newString = @"’";
                bOpenSingleQuote = TRUE;
            }
            bRet = TRUE;
            break;
        case 34:	//"
            if(bOpenDoubleQuote)
            {
                newString = @"“";
                bOpenDoubleQuote=FALSE;
            }
            else
            {
                newString = @"”";
                bOpenDoubleQuote =TRUE;
            }
            
            bRet = TRUE;
            break;
        case 91:	//[
            newString = @"［";
            bRet = TRUE;
            break;
        case 123:	//{
            newString = @"｛";
            bRet = TRUE;
            break;
        case 93:	//]
            newString = @"］";
            bRet = TRUE;
            break;
        case 125:	//}
            newString = @"｝";
            bRet = TRUE;
            break;
        case 92:	//\\
            newString = @"／";
            bRet = TRUE;
            break;
        case 124:	//|
            newString = @"｜";
            bRet = TRUE;
            break;
            //case 9:	//tab
        case '~': //126:	//~
            newString = @"～";
            bRet = TRUE;
            break;
        case '!': //33:	//!
            newString = @"！";
            bRet = TRUE;
            break;
        case '$': //36: // $
            newString = @"￥";
            bRet = true;
            break;
        case '(': //40: // (
            newString = @"（";
            bRet = true;
            break;
        case ')': //41: // )
            newString = @"）";
            bRet = true;
            break;
        case '-':
            newString = @"－";
            bRet = true;
            break;
        case '+':
            newString = @"＋";
            bRet = true;
            break;
            
        default:
            break;
    }
    
    if(bRet) {
        if  ([dataServer isInputable]) {
            [self heCommitComposition:currentClient];
        }
        
        [currentClient insertText:newString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    }
    
    return bRet;
}

@end
