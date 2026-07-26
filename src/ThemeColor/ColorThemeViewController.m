//
//  ColorThemeViewController.m
//  BHTwitter
//
//  Created by Bandar Alruwaili on 10/12/2023.
//  Modified by actuallyaridan on 25/05/2025.
//
//  Clones the native accent picker (ColorThemePickerItem).
//

#import "ColorThemeViewController.h"
#import <UIKit/UIKit.h>
#import "ColorSwatchControl.h"
#import "Core/BHTBundle.h"
#import "Core/TwitterChirpFont.h"
#import "Headers/TWHeaders.h"
#import "ThemeColor/Palette.h"

// Mirrors CurrentAccentColor's precedence (our override, then Twitter's own
// option) so the default swatch shows selected before any change.
static NSInteger CurrentSelectedColorOption(void) {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"bh_color_theme_selectedColor"]) {
        return [defaults integerForKey:@"bh_color_theme_selectedColor"];
    }
    // Twitter stores its default accent (blue) as option 0, and resets to 0 on
    // launch; our swatches are options 1-6, so map 0 (or unset) to blue.
    NSInteger option = [defaults integerForKey:@"T1ColorSettingsPrimaryColorOptionKey"];
    return option >= 1 ? option : 1;
}

// The accent picker ships no localized colour names, so the swatches borrow the
// Fleets accessibility labels for the same six colours.
static const NSUInteger kAccentOptionCount = 6;
static NSString* const kAccentColorNames[kAccentOptionCount] = {@"BLUE", @"YELLOW", @"RED",
                                                                @"PURPLE", @"ORANGE", @"GREEN"};

@interface ColorThemeViewController ()
@property (nonatomic, strong) NSMutableArray<ColorSwatchControl*>* swatches;
@end

@implementation ColorThemeViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.prefersLargeTitles = NO;
    self.view.backgroundColor = [Palette currentBackgroundColor];

    UILabel* detail = [UILabel new];
    detail.translatesAutoresizingMaskIntoConstraints = NO;
    detail.text =
        [[BHTBundle sharedBundle] localizedStringForKey:@"THEME_SETTINGS_NAVIGATION_DETAIL"];
    detail.font = [TwitterChirpFont(TwitterFontStyleRegular) fontWithSize:13];
    detail.textColor = [UIColor secondaryLabelColor];
    detail.numberOfLines = 0;
    [self.view addSubview:detail];

    // Evenly-spread row of swatches, matching the native picker's flex layout.
    UIStackView* row = [[UIStackView alloc] init];
    row.translatesAutoresizingMaskIntoConstraints = NO;
    row.axis = UILayoutConstraintAxisHorizontal;
    row.distribution = UIStackViewDistributionFillEqually;
    // Fill so each swatch spans the row height as a real tap target.
    row.alignment = UIStackViewAlignmentFill;
    [self.view addSubview:row];

    id palette = [[[objc_getClass("TAEColorSettings") sharedSettings]
        currentColorPalette] colorPalette];

    self.swatches = [NSMutableArray new];
    for (NSUInteger option = 1; option <= kAccentOptionCount; option++) {
        ColorSwatchControl* swatch = [[ColorSwatchControl alloc] init];
        swatch.translatesAutoresizingMaskIntoConstraints = NO;
        swatch.colorID = option;
        swatch.isAccessibilityElement = YES;
        swatch.accessibilityLabel = [[BHTBundle sharedBundle]
            localizedTwitterStringForKey:[NSString
                                             stringWithFormat:@"FLEETS_COLOR_%@_ACCESSIBILITY_LABEL",
                                                              kAccentColorNames[option - 1]]];
        UIColor* color = [palette primaryColorForOption:option];
        [swatch setSwatchColor:[color isKindOfClass:[UIColor class]] ? color
                                                                     : nil];
        [swatch addTarget:self
                      action:@selector(swatchTapped:)
            forControlEvents:UIControlEventTouchUpInside];
        [row addArrangedSubview:swatch];
        [self.swatches addObject:swatch];
    }

    [NSLayoutConstraint activateConstraints:@[
        [detail.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor
                                         constant:16],
        [detail.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                             constant:16],
        [detail.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                              constant:-16],

        [row.topAnchor constraintEqualToAnchor:detail.bottomAnchor
                                      constant:16],
        [row.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                          constant:16],
        [row.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor
                                           constant:-16],
        [row.heightAnchor constraintEqualToConstant:52]
    ]];

    [self refreshSelection];
}

#pragma mark - Selection

- (void)refreshSelection {
    NSInteger selected = CurrentSelectedColorOption();
    for (ColorSwatchControl* swatch in self.swatches) {
        [swatch setSwatchSelected:(swatch.colorID == selected)];
    }
}

- (void)swatchTapped:(ColorSwatchControl*)swatch {
    [[NSUserDefaults standardUserDefaults] setInteger:swatch.colorID
                                               forKey:@"bh_color_theme_selectedColor"];
    changeTwitterColor(swatch.colorID);

    [self refreshSelection];
}

@end
