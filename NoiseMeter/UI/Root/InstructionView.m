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
    _textView.text = @"INSTRUCTIONS\n\nNoise Down allows you to set a desired sound level or limit. If the noise around you exceeds this level an alert will sound. You can also note the names of the noisiest offenders in The Noise League!\n\nWhen you launch the app, the meter is automatically running.\n\nSET OR CHANGE THE ALERT LEVEL:\n\nClick \"Set level\", then select the setting required. Optimum settings for the app will depend on your environment and the proximity of the subjects to the microphone. We find that settings between 85 and 92 to be most effective, depending on the environment. For example 85 in a room, or 92 in the car.\n\nCHANGE THE ALERT:\n\nClick the More button, and click on \"Select Alert Sound\". Select your desired alert.\n\nNAME AND SHAME!\n\nWhen someone or something has triggered the alarm you'll see a \"Capture\" button. This will remain on the screen, along with the peak reading. It is up to you if you want to capture the name - simply click the \"Capture\" button, enter their name,  and they'll appear on the Scores view - in The Noise League!\n\nThe top three noisiest sounds are also featured on the Meter view.\n\nPRO Version\n\nWhen you are running the PRO version of the app - you will be able to:\r\r* Run the app in the background\r\r* Record the noise as it is happening so you can identify the noise makers\r\r* Record your own alarm sounds\r\r- All these settings are available from here in the Settings screen - just click the \"More\" button.\n\n\n\n\n ";
}

@end
