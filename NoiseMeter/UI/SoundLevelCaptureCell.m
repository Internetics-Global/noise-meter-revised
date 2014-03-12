//
//  SoundLevelCaptureCell.m
//  NoiseMeter
//
//  Created by Dave Finster on 13/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "SoundLevelCaptureCell.h"
#import "NSUserDefaultsHelper.h"


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
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 110, self.contentView.frame.size.height)];
        _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:_nameLabel.font.pointSize];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
          _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        }
        [self.contentView addSubview:_nameLabel];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(320-100-5, 0, 100, self.contentView.frame.size.height)];
        _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_dateLabel];
        
        _levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(_dateLabel.frame.origin.x - 50 - 5, 0, 50, self.contentView.frame.size.height)];
        _levelLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _levelLabel.backgroundColor = [UIColor clearColor];
        _levelLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_levelLabel];
        
        
        _playImageView = [[UIImageView alloc] init];
        _playImageView.frame = CGRectMake(_levelLabel.frame.origin.x - 30 - 5, 13, 30, 15);
        _playImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:_playImageView];
        _playImageView.userInteractionEnabled = YES;
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void) refreshPlayImageViewVisibility {
    if ([NSUserDefaultsHelper isAdRemoved]) {
        _playImageView.hidden = NO;
    } else {
        _playImageView.hidden = YES;
    }
}

- (void)dealloc
{
    _nameLabel = nil;
    _levelLabel = nil;
}

@end
