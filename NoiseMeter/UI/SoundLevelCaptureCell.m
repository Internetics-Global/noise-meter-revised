//
//  SoundLevelCaptureCell.m
//  NoiseMeter
//
//  Created by Dave Finster on 13/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "SoundLevelCaptureCell.h"

@implementation SoundLevelCaptureCell

@synthesize capture = _capture;

- (void)setCapture:(SoundLevelCapture *)capture
{
    [self willChangeValueForKey:@"capture"];
    _capture = capture;
    _nameLabel.text = _capture.name;
    _levelLabel.text = [NSString stringWithFormat:@"%.1f", [_capture.soundLevel floatValue]];
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
	NSLocale *au = [[NSLocale alloc] initWithLocaleIdentifier:@"en_AU"];
	[date setLocale:au];
	[date setDateFormat:@"dd/MM/yyyy"];
	_dateLabel.text = [date stringFromDate:_capture.date];
    [self didChangeValueForKey:@"capture"];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 90, self.contentView.frame.size.height)];
        _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor lightGrayColor];
        _nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
          _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        }
        [self.contentView addSubview:_nameLabel];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 95, 0, 90, self.contentView.frame.size.height)];
        _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _dateLabel.textAlignment = NSTextAlignmentRight;
        _dateLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_dateLabel];
        
        
        _levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(_dateLabel.frame.origin.x - 45, 0, 45, self.contentView.frame.size.height)];
        _levelLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _levelLabel.backgroundColor = [UIColor clearColor];
        _levelLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        _levelLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_levelLabel];
        
        
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"soundOnButton@2x"] forState:UIControlStateNormal];
        _playButton.frame = CGRectMake(_levelLabel.frame.origin.x - 30, 13, 20, 15);
        _playButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:_playButton];
        _playButton.showsTouchWhenHighlighted = YES;
        
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton setImage:[UIImage imageNamed:@"shareButton"] forState:UIControlStateNormal];
        _shareButton.frame = CGRectMake(_playButton.frame.origin.x - 30, 13, 20, 15);
        _shareButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:_shareButton];
        _shareButton.showsTouchWhenHighlighted = YES;
    }
    return self;
}

- (void)dealloc
{
    _nameLabel = nil;
    _levelLabel = nil;
}

@end
