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
	[date setDateFormat:@"dd.MM.yyyy"];
	_dateLabel.text = [date stringFromDate:_capture.date];
    [self didChangeValueForKey:@"capture"];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 150, self.contentView.frame.size.height)];
        _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:_nameLabel.font.pointSize];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
          _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        }
        [self.contentView addSubview:_nameLabel];
        
        
        _levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x + _nameLabel.frame.size.width + 5, 0, 50, self.contentView.frame.size.height)];
        _levelLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _levelLabel.backgroundColor = [UIColor clearColor];
        _levelLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_levelLabel];
        
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"soundOnButton@2x"] forState:UIControlStateNormal];
        _playButton.frame = CGRectMake(_levelLabel.frame.origin.x - 35, 13, 30, 15);
        _playButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:_playButton];
        _playButton.showsTouchWhenHighlighted = YES;
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(_levelLabel.frame.origin.x + _levelLabel.frame.size.width + 5, 0, 100, self.contentView.frame.size.height)];
        _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_dateLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _nameLabel.frame = CGRectMake(15, -4, 150, self.contentView.frame.size.height);
    _levelLabel.frame = CGRectMake(_nameLabel.frame.origin.x + _nameLabel.frame.size.width + 5, _nameLabel.frame.origin.y, 50, self.contentView.frame.size.height);
    _dateLabel.frame = CGRectMake(_levelLabel.frame.origin.x + _levelLabel.frame.size.width + 5, _nameLabel.frame.origin.y, 100, self.contentView.frame.size.height);
}

- (void)dealloc
{
    _nameLabel = nil;
    _levelLabel = nil;
}

@end
