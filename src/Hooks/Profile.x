//
//  Profile.x
//  NeoFreeBird
//

#import "HookHelpers.h"

// MARK: - Copy profile info

// A submenu of the profile's overflow menu, built fresh on each open so the
// values track the loaded profile.
static TFNActionItem* ProfileCopyMenu(T1ProfileUserViewModel* viewModel) {
    NSMutableArray* items = [NSMutableArray array];
    void (^addItem)(NSString*, NSString*, NSString*) =
        ^(NSString* titleKey, NSString* iconName, NSString* value) {
            if (!value.length) {
                return;
            }
            [items addObject:[%c(TFNActionItem)
                                 actionItemWithTitle:
                                     [[BHTBundle sharedBundle]
                                         localizedStringForKey:titleKey]
                                           imageName:iconName
                                              action:^{
                                                  UIPasteboard.generalPasteboard
                                                      .string = value;
                                              }]];
        };

    addItem(@"COPY_PROFILE_INFO_MENU_OPTION_3", @"account", viewModel.fullName);
    addItem(@"COPY_PROFILE_INFO_MENU_OPTION_2", @"at", viewModel.username);
    addItem(@"COPY_PROFILE_INFO_MENU_OPTION_1", @"news_stroke", viewModel.bio);
    addItem(@"COPY_PROFILE_INFO_MENU_OPTION_5", @"location_stroke",
            viewModel.location);
    addItem(@"COPY_PROFILE_INFO_MENU_OPTION_4", @"link", viewModel.url);

    if (!items.count) {
        return nil;
    }

    return [%c(TFNActionItem)
        nestedMenuWithTitle:[[BHTBundle sharedBundle]
                                localizedStringForKey:@"COPY_PROFILE_INFO_TITLE"]
                      items:items];
}

%hook T1ProfileHeaderViewController

// The redesigned header builds its buttons from a closed catalog, so the
// overflow menu is the only seam left. It exists on other people's profiles
// only, matching where the (…) button is offered.
- (NSArray*)profileMoreActionsBaseActionItemsWithSender:(UIView*)sender {
    NSArray* items = %orig ?: @[];

    if (![BHTSettings boolForKey:@"copy_profile_info"]) {
        return items;
    }

    TFNActionItem* copyMenu = ProfileCopyMenu(self.viewModel);
    return copyMenu ? [items arrayByAddingObject:copyMenu] : items;
}

%end

// MARK: - Hide premium offer

%hook T1ProfileSummaryView

- (BOOL)shouldShowGetVerifiedButton {
    return [BHTSettings boolForKey:@"hide_premium_offer"] ? NO : %orig;
}

%end

// MARK: - Show unrounded follower/following counts

%hook T1ProfileFriendsFollowingViewModel

- (id)_t1_followCountTextWithLabel:(__unsafe_unretained id)label
                     singularLabel:(__unsafe_unretained id)singularLabel
                             count:(NSNumber*)count
                       highlighted:(BOOL)highlighted {
    id original = %orig;

    if (![count isKindOfClass:[NSNumber class]] ||
        ![original isKindOfClass:[NSAttributedString class]]) {
        return original;
    }

    NSString* abbreviated = [count tfs_twitterAbbreviated];
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSString* fullCount = [formatter stringFromNumber:count];

    if (!abbreviated.length || !fullCount.length || [abbreviated isEqualToString:fullCount]) {
        return original;
    }

    NSRange range = [[original string] rangeOfString:abbreviated];
    if (range.location == NSNotFound) {
        return original;
    }

    NSMutableAttributedString* expanded = [original mutableCopy];
    [expanded replaceCharactersInRange:range withString:fullCount];
    return [expanded copy];
}

%end
