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

#import "HeInputController.h"
#import "CandidateView.h"
#import "HandleTyping.h"

@implementation HeInputController

- (id)initWithServer:(IMKServer *)server delegate:(id)delegate client:(id)inputClient {
    
    self = [super initWithServer:server delegate:delegate client:inputClient];
    if (self) {
        dataServer = [Input_DataServer sharedInstance];
        [dataServer clearState];
        currentClient = inputClient;
        
        //InputMethodKit default value,
        //function setSelectionKeys design to change this value,
        //but this function does not work.
        maxItemsOfPage = 9;
        numOfItemsInCurrentPage = 0;
        pageIndex = 0;
        itemIndexOfCurrentPage = 0;
    }
    return self;
}

/*
 @method
 @abstract   Receive all keydown and mouse events as an NSEvent (i.e. the event is simply forwarded onto the input method).
 @discussion Return YES if the event was handled. NO if not handled.
 */
- (BOOL)handleEvent:(NSEvent*)event client:(id)sender
{
    /*
     IMKInputController only process NSKeydown event (not for NSKeyUp, NSFlagsChanged event)
     if ([event type] == NSKeyDown)  //always in NSKeyDown event
     */
    
    NSUInteger cocoaModifiers = [event modifierFlags];
    NSInteger virtualKeyCode = [event keyCode];
    
    BOOL is26EnglisKey = [Globel_Helper is26EnglishCharKey:virtualKeyCode];
    BOOL isPunctuationKey = [Globel_Helper isPunctuationKey:virtualKeyCode];
    BOOL isMainKeyboardNumberKey = [Globel_Helper isMainKeyboardNumberKey: virtualKeyCode];
    BOOL isMainKeyboardControlKey = [Globel_Helper isMainKeyboardControlKey:virtualKeyCode];
    BOOL isNumPadNumberKey = false;
    BOOL isNumPadControlKey = false;
    
    BOOL isWithShiftKey =  false;
    
    if (cocoaModifiers & NSShiftKeyMask)
    {
        isWithShiftKey = true;
    }
    
    if (isWithShiftKey) {
        
        if ( dataServer.setting.mainKeyboardMode != EnglishMode)
        {
            if (is26EnglisKey || virtualKeyCode == kVK_Space ) {
                dataServer.setting.mainKeyboardMode = EnglishMode;
  
                [self clearState];
                extern IMKCandidates* imkCandidates;
                if ( imkCandidates ) {
                    [imkCandidates hide];
                }
                [currentClient setMarkedText:@"英文" selectionRange:NSMakeRange(0, 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
                return true;
            }
            else if (isPunctuationKey || isMainKeyboardNumberKey)
            {
                // since punctuationKey + shift at HeMaMode, need to insert Chinese Punctuation
                // Go through
            }
        }
        return false;
    }
    else if (virtualKeyCode == kVK_ANSI_KeypadDivide) {
        if (dataServer.setting.numPadMode != NumberMode)
        {
            dataServer.setting.numPadMode = NumberMode;
        }
        else //if ( dataServer.setting.numPadMode == NumberMode)
        {
            dataServer.setting.numPadMode = HeMaMode;
        }
        [self wipeTyping];
        return true;
    }
    
    BOOL inputHandled = NO;
    
    if (cocoaModifiers & NSControlKeyMask)
    {
        return false;
    }
    
    if (cocoaModifiers & NSAlternateKeyMask)
    {
        return false;
    }
    
    if (cocoaModifiers & NSCommandKeyMask)
    {
        return false;
    }
    
    unichar uniChar = 0;
    
    NSString *chars = [event characters];
    
    if ([chars length] > 0)
    {
        uniChar = [chars characterAtIndex:0];
    }
    
    //Very strangely Arrow keys goes in to follow conditon.
    // It seems all Arrow keys are FunctionKey
    // So I filter all Arrow key
    if (cocoaModifiers & NSFunctionKeyMask) {
        
        if (
            virtualKeyCode == kVK_PageUp ||
            virtualKeyCode == kVK_PageDown ||
            virtualKeyCode == kVK_LeftArrow ||
             virtualKeyCode == kVK_RightArrow ||
             virtualKeyCode == kVK_DownArrow ||
             virtualKeyCode == kVK_UpArrow
            )
        {
            // Go through
        }
        else
            return [self quickModeChange:uniChar];
    }
    
    if (is26EnglisKey ||
        isPunctuationKey ||
        (isMainKeyboardNumberKey && isWithShiftKey) ||
        isMainKeyboardControlKey)
    {
        if  (dataServer.setting.mainKeyboardMode == EnglishMode)
        {
            return false;
        }
        dataServer.keySource = MainKeyboardKey;
        dataServer.setting.currentKeyMode = dataServer.setting.mainKeyboardMode;
    }
    else if ((isNumPadNumberKey = [Globel_Helper isNumberPadNumberKey:virtualKeyCode]) ||
             (isNumPadControlKey = [Globel_Helper isNumPadControlKey:virtualKeyCode]))
    {
        if (dataServer.setting.numPadMode == NumberMode){
            return false;
        }
        dataServer.keySource = NumPadKey;
        dataServer.setting.currentKeyMode = dataServer.setting.numPadMode;
    }
    
    //We should use virtualKeyCode and unicharCode
    //Because Qwerty vs Dvorak, same phisical key (same HeInput code) but produce different unicharCode.
    
    if( is26EnglisKey || isNumPadNumberKey )
    {
        inputHandled = [self handleCharOrShuMa:uniChar TypedShuMa:[Globel_Helper keyCodeToShuMa:virtualKeyCode]];
    }
    else if(isPunctuationKey || (isMainKeyboardNumberKey && isWithShiftKey))
    {
        inputHandled = [self handlePunctuationKey:uniChar];
    }
    else if( isMainKeyboardControlKey || isNumPadControlKey)
    {
        inputHandled = [self handleControlKey:virtualKeyCode];
    }
    
    return inputHandled;
}

- (BOOL)quickModeChange:(unichar)uniChar
{
    bool bRet = false;
    
    Input_Setting *setting = dataServer.setting;
    
    NSString *promptStr = nil;
    
    switch (uniChar)
    {
        case ' ':
        {
            if ( setting.mainKeyboardMode != setting.systemMode) {
                
                setting.mainKeyboardMode = setting.systemMode;
                setting.bSimplified_Chinese = setting.isSystem_simplified_chinese;
            }
            else if (setting.systemMode == HeMaMode)
            {
                setting.mainKeyboardMode = PinYinMode;
            }
            else //if (dataServer.setting.systemMode == HeEnglishMode)
            {
                setting.mainKeyboardMode = HeMaMode;
            }
            
            if (setting.mainKeyboardMode == PinYinMode) {
                promptStr = @"拼音查码";
            }
            else if (setting.mainKeyboardMode == HeMaMode)
            {
                if (setting.bSimplified_Chinese) {
                    promptStr = @"简体";
                }
                else {
                    promptStr = @"繁体";
                }
            }
            else if (setting.mainKeyboardMode == HeEnglishMode) {
                promptStr = @"HeEnglish";
            }
            
            [dataServer setMenuArray];
        }
            bRet = true;
            break;
        case 'r':	//Reset
        case 'R':
            setting.mainKeyboardMode=setting.systemMode;
            setting.bSimplified_Chinese = setting.isSystem_simplified_chinese;
            promptStr = @"回复初选设置";
            bRet = true;
            break;
        case 'a':
        case 'A':
        {
            setting.bPinYinPrompt = !setting.bPinYinPrompt;
            if(setting.bPinYinPrompt) {
                promptStr = @"开启拼音提示";
            }
            else {
                promptStr = @"关闭拼音提示";
            }
        }
            bRet = true;
            break;
        case 's':	//Simplified Chinese
        case 'S':
        case 'j':	//Jian Ti Chinese
        case 'J':
            setting.bSimplified_Chinese = true;
            setting.mainKeyboardMode=HeMaMode;
            promptStr = @"简体";
            bRet = true;
            break;
        case 'f':	//FanTi Chinese
        case 'F':
        case 't':	//Traditional Chinese
        case 'T':
            setting.bSimplified_Chinese = false;
            setting.mainKeyboardMode=HeMaMode;
            promptStr = @"繁体";
            bRet = true;
            break;
        case 'e':	//English
        case 'E':
            setting.mainKeyboardMode=HeEnglishMode;
            promptStr = @"HeEnglish";
            bRet = true;
            break;
        case 'p':	//PinYin
        case 'P':
            setting.mainKeyboardMode=PinYinMode;
            promptStr = @"拼音查码";
            bRet = true;
            break;
            //            case 'l':	//LianXiang
            //            case 'L':
            //                setting.bSystemLianXiangOn = !setting.bSystemLianXiangOn;
            //                //pSetting->numPadMode = LianXiangMode;
            //                if(setting.bSystemLianXiangOn)
            //                {
            //                promptStr = @"开启联想";
            //                }
            //                else {
            //                promptStr = @"关闭联想";
            //                }
            //
            //                bRet = true;
            //                break;
        default:
            bRet = false;
            break;
            
    }
    
    if(bRet)
    {
        [currentClient setMarkedText:promptStr
                      selectionRange:NSMakeRange(0, [promptStr length])
                    replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
        
        [self clearState];
        extern IMKCandidates* imkCandidates;
        if ( imkCandidates ) {
            [imkCandidates hide];
        }
    }
    
    return bRet;
}

//This method is called by the InputMethodKit
//when the user as selected a new input mode from the text input menu.
- (void)setValue:(id)value forTag:(long)tag client:(id)sender
{
    NSString *newModeString = (NSString*)value;
    
    if ([newModeString isEqual:@"net.HeZi.MacOS.inputmethod.JianTi"] )
    {
        dataServer.setting.systemMode = HeMaMode;
        dataServer.setting.mainKeyboardMode = HeMaMode;
        dataServer.setting.numPadMode = HeMaMode;
        dataServer.setting.isSystem_simplified_chinese = true;
        dataServer.setting.bSimplified_Chinese = true;
    }
    else if ( [newModeString isEqual:@"net.HeZi.MacOS.inputmethod.FanTi"] )
    {
        dataServer.setting.systemMode = HeMaMode;
        dataServer.setting.isSystem_simplified_chinese = false;
        dataServer.setting.mainKeyboardMode = HeMaMode;
        dataServer.setting.numPadMode = HeMaMode;
        dataServer.setting.bSimplified_Chinese = false;
    }
    else if ( [newModeString isEqual:@"net.HeZi.MacOS.inputmethod.HeEnglish"] )
    {
        dataServer.setting.systemMode = HeEnglishMode;
        dataServer.setting.mainKeyboardMode = HeEnglishMode;
        dataServer.setting.numPadMode = HeMaMode;
        dataServer.setting.bSimplified_Chinese = true;
    }
    [self wipeTyping];
}

// Display typed string at cursor
- (void)displayTypedString:(id)sender
{
    NSString *str = [dataServer provideTypedString];
    [sender setMarkedText:str selectionRange:NSMakeRange(0, str.length) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
}

/*!
 @method
 @abstract   Called to inform the controller that the composition should be committed.
 @discussion If an input method implements this method it will be called when the client wishes to end the composition session immediately. A typical response would be to call the client's insertText method and then clean up any per-session buffers and variables.  After receiving this message an input method should consider the given composition session finished.
 */
//- (void)commitComposition:(id)sender
//{
//    [dataServer clearState];
//    [currentClient setMarkedText:@"" selectionRange:NSMakeRange(0, 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
//}

// When commit text by space key
// or by continue typing
// or by repeat tying from menu
- (void)heCommitComposition:(id)sender
{
    if (dataServer.numOfCand == 0 || ![dataServer isInputable])
        return;
    
    // candidate item can be menu,
    // however if it is menu, it can't come to here
    ZiCiObject *ziCiObj = [dataServer.candidateArray objectAtIndex:pageIndex*maxItemsOfPage + itemIndexOfCurrentPage];
    
    [sender insertText:ziCiObj.ziCi replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    previousInsertText = [NSString stringWithString: ziCiObj.ziCi];
    
    [self clearState];
    extern IMKCandidates* imkCandidates;
    if ( imkCandidates ) {
        [imkCandidates hide];
    }
}

/*!
 @method
 @abstract   Called when a new candidate has been finally selected.
 @discussion The candidate parameter is the users final choice from the candidate window. The candidate window will have been closed before this method is called.
 */
// When return key event pass out to InputMethod Kit (retrun false by handleEvnet function)
// InputMethod Kit Client function for return key
- (void)candidateSelected:(NSAttributedString*)candidateString
{
    if (![dataServer isInputable] && dataServer.numOfCand>0)
    {
        // select candidate with mainkeyboard number key does not work in this situation
        [self clearState];
        [currentClient setMarkedText:@"" selectionRange:NSMakeRange(0, 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
        return;
    }
    
    NSMutableString* text = [NSMutableString stringWithString:[candidateString string]];
    
    if ( text == nil || [text length] == 0 ) {
        return;
    }
    
    NSRange aRang = [text rangeOfString:@" "];
    
    if(aRang.location == NSNotFound && [text length]>0)
    {
        aRang.location = 0;
        aRang.location =[text length];
    }
    
    text = [NSMutableString stringWithString:[text substringToIndex:aRang.location]];
    
    [currentClient insertText:text replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    previousInsertText = [NSString stringWithString:text];
    
    [self clearState];
}

// InputMethodKet function called by [imkCandidates updateCandidates]
- (NSArray*)candidates:(id)sender
{
    NSMutableArray*	theCandidates = [NSMutableArray array];
    
    NSUInteger numOfCand =dataServer.numOfCand;
    
    if(numOfCand == 0 || numOfItemsInCurrentPage == 0) {
        return theCandidates;
    }
    
    switch(dataServer.setting.currentKeyMode)
    {
        case HeMaMode:
        case NumberMode:		//process *
        {
            for (NSInteger i = pageIndex*maxItemsOfPage; i<pageIndex*maxItemsOfPage + numOfItemsInCurrentPage; i++) {
                
                ZiCiObject *ziCiObj = [dataServer.candidateArray objectAtIndex:i];
                [theCandidates addObject:[ziCiObj provideZiCiPlusPromptMa]];
            }
        }
            break;
        case PinYinMode:
        {
            for (NSInteger i = pageIndex*maxItemsOfPage; i<pageIndex*maxItemsOfPage + numOfItemsInCurrentPage; i++) {
                
                ZiCiObject *ziCiObj = [dataServer.candidateArray objectAtIndex:i];
                
                [theCandidates addObject: [NSString stringWithFormat:@"%@ %@",
                                           ziCiObj.ziCi,
                                           [dataServer provideDanZiCodeString:ziCiObj.ziCi]]];
            }
        }
            break;
        case HeEnglishMode:
        {
            for (NSInteger i = pageIndex*maxItemsOfPage; i<pageIndex*maxItemsOfPage + numOfItemsInCurrentPage; i++) {
                
                ZiCiObject *ziCiObj = [dataServer.candidateArray objectAtIndex:i];
                [theCandidates addObject:ziCiObj.ziCi];
            }
        }
            break;
            
        default:
            break;
    }
    
    return theCandidates;
}

- (void)candidateSelectionChanged:(NSAttributedString*)candidateString
{
    if (!dataServer.setting.bPinYinPrompt)
        return;
    
    if ( dataServer.setting.currentKeyMode == HeMaMode
        || dataServer.setting.currentKeyMode == PinYinMode ) {
        
        NSMutableString* text = [NSMutableString stringWithString:[candidateString string]];
        
        NSString *pinYinString = [dataServer getPinYinPromptString:[text substringToIndex:1]];
        
        if([pinYinString length]>0)
        {
            extern IMKCandidates *imkCandidates;
            
            NSFont *font = [NSFont fontWithName:@"Palatino-Roman" size:16.0];
            NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
            
            [imkCandidates showAnnotation:[[NSAttributedString alloc] initWithString:pinYinString attributes:attrsDictionary]];
        }
    }
}

- (void)heChangePage
{
    [self getNumOfItemsOfCurrentPage];
    
    extern IMKCandidates* imkCandidates;
    if ( imkCandidates ) {
        
        itemIndexOfCurrentPage = 0;
        
        [imkCandidates updateCandidates];   // will call - (NSArray*)candidates:(id)sender
        [imkCandidates show:kIMKLocateCandidatesBelowHint];
        
        // when move arrow, we change typed engShuMa
        if ([dataServer needShowEnglishCodeList]) {
            itemIndexOfCurrentPage = [dataServer provideEnglishShuMa] -1;
        }
        
        [imkCandidates selectCandidateWithIdentifier:[imkCandidates candidateIdentifierAtLineNumber:itemIndexOfCurrentPage]];
    }
}

- (void)heRefrechPage
{
    extern IMKCandidates* imkCandidates;
    
    if ( imkCandidates ) {
        
        itemIndexOfCurrentPage = 0;
        
        if ([dataServer needShowEnglishCodeList]) {
            
            dataServer.setting.currentKeyMode = PinYinMode;
            [dataServer heBackspace];
            [dataServer changeTypingState4Modes:0xffff TypedShuMa:(itemIndexOfCurrentPage + 1)];
        }
        
        [imkCandidates selectCandidateWithIdentifier:[imkCandidates candidateIdentifierAtLineNumber:itemIndexOfCurrentPage]];
    }
}

- (void)clearState;
{
    itemIndexOfCurrentPage = 0;
    pageIndex = 0;
    numOfItemsInCurrentPage = 0;
    [dataServer clearState];
}

// Key simulater does not work with App SandBox security
//- (void)simulateEnterKeyEvent;
//{
//    CGEventRef keyup, keydown;
//    keydown = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)kVK_Return, true);
//    keyup = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)kVK_Return, false);
//
//    CGEventPost(kCGHIDEventTap, keydown);
//    CGEventPost(kCGHIDEventTap, keyup);
//    CFRelease(keydown);
//    CFRelease(keyup);
//}

- (void)wipeTyping;
{
    [self clearState];
    extern IMKCandidates* imkCandidates;
    if ( imkCandidates ) {
        [imkCandidates hide];
    }
    [currentClient setMarkedText:@"" selectionRange:NSMakeRange(0, 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
}
@end
