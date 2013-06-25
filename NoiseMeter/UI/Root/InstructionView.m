//
//  InstructionView.m
//  NoiseMeter
//
//  Created by Dave Finster on 21/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "InstructionView.h"

@implementation InstructionView

- (void)loadView
{
    [super loadView];
    _textView.text = @"INSTRUCTIONS\n\nNoise Down allows you to set a desired sound level or limit. If the noise around you exceeds this level an alert will sound. You can also note the names of the noisiest culprits in The Noise League!\n\nWhen you launch the app, the meter is automatically running.\n\nSET OR CHANGE THE ALERT LEVEL:\n\nClick \"Set level\", then select the setting required. Optimum settings for the app will depend on your environment and the proximity of the subjects to the microphone. We find that settings between 85 and 92 to be most effective, depending on the environment. For example 85 in a room, or 92 in the car.\n\nCHANGE THE ALERT:\n\nClick the More button, and click on \"Select Alert Sound\". Select your desired alert.\n\nNAME AND SHAME!\n\nWhen someone or something has triggered the alarm you'll see a \"Capture\" button. This will remain on the screen, along with the peak reading. It is up to you if you want to capture the name - simply click the \"Capture\" button, enter their name,  and they'll appear on the Scores view - in The Noise League!\n\nThe top three noisiest sounds are also featured on the Meter view.\n\nTIPS:\n\nAuto-Lock: Ensure that \"Auto-Lock\" isn't shutting you out.\n\nGo to the Settings app and click on General >> Auto-Lock. Ideally you would set Auto-Lock to \"Never\". You'll still be able to lock the phone by clicking the button on the top right of the phone, but if you don't want Auto-Lock to interfere with Noise Down, you'll need to implement this setting.";
}

@end
