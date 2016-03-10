//
//  AppDelegate.m
//  HeInput
//
//  Created by Ouyang on 2016-02-21.
//  Copyright © 2016 Guilin Ouyang. All rights reserved.
//

#import "AppDelegate.h"
#import <InputMethodKit/InputMethodKit.h>
#import "HeInputLibrary/Input_DataServer.h"

//Each input method needs a unique connection name.
//Note that periods and spaces are not allowed in the connection name.
const NSString* kConnectionName = @"OpenHeInput_1_Connection";

//let this be a global so our application controller delegate can access it easily
IMKServer*       server;
IMKCandidates*		imkCandidates = nil;

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    server = [[IMKServer alloc] initWithName:(NSString*)kConnectionName bundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
    
    //create the candidate window
    imkCandidates = [[IMKCandidates alloc] initWithServer:server panelType:kIMKSingleColumnScrollingCandidatePanel];

    //setSelectionKeys function does not work
//    //NSArray *array = @[@29,@18, @19, @20,@21,@23,@22,@26,@28,@25];
//    NSArray *array = [NSArray arrayWithObjects:
//                      [NSNumber numberWithInt:kVK_ANSI_0],
//                      [NSNumber numberWithInt:kVK_ANSI_1],
//                      [NSNumber numberWithInt:kVK_ANSI_2],
//                      [NSNumber numberWithInt:kVK_ANSI_3],
//                      [NSNumber numberWithInt:kVK_ANSI_4],
//                      [NSNumber numberWithInt:kVK_ANSI_5],
//                      [NSNumber numberWithInt:kVK_ANSI_6],
//                      [NSNumber numberWithInt:kVK_ANSI_7],
//                      [NSNumber numberWithInt:kVK_ANSI_8],
//                      [NSNumber numberWithInt:kVK_ANSI_9],nil];
//    
//    [imkCandidates setSelectionKeys: array];
    
    //This is not what I want
    //[candidates setDismissesAutomatically:NO];
    //	Value is a NSNumber with a boolean value of NO (keyevents are sent to the candidate window first)
    //or YES (keyevents are sent to the IMKInputController first).
    //Note this is only applicable when a candidate window is displayed.
    //The default behavior is to send the key event to the candidate window first.
    //Then if it is not processed there to send it on to the input controller.
    [imkCandidates setAttributes:[NSDictionary dictionaryWithObject: [NSNumber numberWithBool:YES] forKey:IMKCandidatesSendServerKeyEventFirst]];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
