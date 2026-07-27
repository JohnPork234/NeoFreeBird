//
//  Profile.x
//  NeoFreeBird
//

#import "HookHelpers.h"

// MARK: - Copy profile info

// The redesigned header builds its row from a closed Swift catalog, and neither
// its buttons nor their configuration can be constructed from Objective-C. The
// button is instead hosted inside the row: the row's own content insets reserve
// the space, and the button is placed alongside the arranged buttons.

// Set on the main action row's controller and on its row view.
static char kActionRowControllerKey;
static char kActionRowMarkerKey;
static char kCopyButtonKey;

static XDSButtonSizeClass* CopyButtonSizeClass(void) {
    return [%c(XDSButtonSizeClass) large];
}

static CGFloat CopyButtonDiameter(void) {
    return CopyButtonSizeClass().height;
}

static CGFloat CopyButtonSpacing(void) {
    return CopyButtonSizeClass().interButtonSpacing;
}

static CGFloat CopyButtonReservedWidth(void) {
    return CopyButtonDiameter() + CopyButtonSpacing();
}

static BOOL RowIsRightToLeft(UIView* rowView) {
    return rowView.effectiveUserInterfaceLayoutDirection ==
           UIUserInterfaceLayoutDirectionRightToLeft;
}

static T1ProfileHeaderViewController* HeaderViewControllerForView(UIView* view) {
    for (UIResponder* responder = view; responder;
         responder = responder.nextResponder) {
        if ([responder isKindOfClass:%c(T1ProfileHeaderViewController)]) {
            return (T1ProfileHeaderViewController*)responder;
        }
    }
    return nil;
}

// Rebuilt on each open so the values track the loaded profile.
static NSArray<UIMenuElement*>* CopyActionsForProfile(
    T1ProfileUserViewModel* viewModel) {
    NSMutableArray* actions = [NSMutableArray array];
    void (^addAction)(NSString*, NSString*, NSString*) =
        ^(NSString* titleKey, NSString* iconName, NSString* value) {
            if (!value.length) {
                return;
            }
            [actions
                addObject:[UIAction
                              actionWithTitle:[[BHTBundle sharedBundle]
                                                  localizedStringForKey:titleKey]
                                        image:[UIImage
                                                  tfn_vectorImageNamed:iconName
                                                              fitsSize:CGSizeMake(
                                                                           16.0,
                                                                           16.0)
                                                             fillColor:UIColor
                                                                           .labelColor]
                                   identifier:nil
                                      handler:^(__kindof UIAction* action) {
                                          UIPasteboard.generalPasteboard.string =
                                              value;
                                      }]];
        };

    addAction(@"COPY_PROFILE_INFO_MENU_OPTION_3", @"account", viewModel.fullName);
    addAction(@"COPY_PROFILE_INFO_MENU_OPTION_2", @"at", viewModel.username);
    addAction(@"COPY_PROFILE_INFO_MENU_OPTION_1", @"news_stroke", viewModel.bio);
    addAction(@"COPY_PROFILE_INFO_MENU_OPTION_5", @"location_stroke",
              viewModel.location);
    addAction(@"COPY_PROFILE_INFO_MENU_OPTION_4", @"link", viewModel.url);

    return actions;
}

static UIButton* CopyButtonForRow(UIView* rowView) {
    UIButton* button = objc_getAssociatedObject(rowView, &kCopyButtonKey);
    if (button) {
        return button;
    }

    CGFloat diameter = CopyButtonDiameter();
    XDSButtonDisplayStyle* style = [%c(XDSButtonDisplayStyle) outlined];
    XDSButtonBorder* border = style.border;

    button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tintColor = style.foregroundColor;
    button.layer.borderWidth = border.width;
    button.layer.borderColor = border.color.CGColor;
    button.layer.cornerRadius =
        [[%c(XDSButtonCornerRadius) pill] resolvedForHeight:diameter];
    button.accessibilityLabel =
        [[BHTBundle sharedBundle] localizedStringForKey:@"COPY_PROFILE_INFO_TITLE"];
    CGFloat iconSize = CopyButtonSizeClass().iconSize;
    [button setImage:[UIImage tfn_vectorImageNamed:@"copy_stroke"
                                          fitsSize:CGSizeMake(iconSize, iconSize)
                                         fillColor:style.foregroundColor]
            forState:UIControlStateNormal];
    button.showsMenuAsPrimaryAction = YES;

    __weak UIView* weakRow = rowView;
    void (^actionsProvider)(void (^)(NSArray<UIMenuElement*>*)) =
        ^(void (^completion)(NSArray<UIMenuElement*>*)) {
            T1ProfileHeaderViewController* header =
                HeaderViewControllerForView(weakRow);
            completion(header ? CopyActionsForProfile(header.viewModel) : @[]);
        };
    UIDeferredMenuElement* deferred;
    if (@available(iOS 15.0, *)) {
        deferred = [UIDeferredMenuElement elementWithUncachedProvider:actionsProvider];
    } else {
        deferred = [UIDeferredMenuElement elementWithProvider:actionsProvider];
    }
    button.menu = [UIMenu menuWithTitle:@"" children:@[deferred]];

    objc_setAssociatedObject(rowView, &kCopyButtonKey, button,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return button;
}

%hook ProfileActionButtonsCatalog

// Location 2 is the main action row; the nav rows pass through untouched.
- (id)makeControllerFor:(NSInteger)location {
    id controller = %orig;

    if (location == 2 && controller) {
        objc_setAssociatedObject(controller, &kActionRowMarkerKey, @YES,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        UIView* rowView = [(T1ProfileActionButtonsController*)controller rowView];
        // Assigned, not retained: the controller owns the row view.
        objc_setAssociatedObject(rowView, &kActionRowControllerKey, controller,
                                 OBJC_ASSOCIATION_ASSIGN);
    }

    return controller;
}

%end

%hook T1ProfileActionButtonsController

- (void)setContentInsets:(UIEdgeInsets)insets {
    if ([BHTSettings boolForKey:@"copy_profile_info"] &&
        objc_getAssociatedObject(self, &kActionRowMarkerKey)) {
        if (RowIsRightToLeft(self.rowView)) {
            insets.right += CopyButtonReservedWidth();
        } else {
            insets.left += CopyButtonReservedWidth();
        }
    }

    %orig(insets);
}

// The summary view keeps its name and handle clear of this rect, so the
// reserved space has to be part of it.
- (CGRect)occupiedContentRect {
    CGRect rect = %orig;

    if (![BHTSettings boolForKey:@"copy_profile_info"] ||
        !objc_getAssociatedObject(self, &kActionRowMarkerKey) ||
        CGRectIsEmpty(rect)) {
        return rect;
    }

    CGFloat reserved = CopyButtonReservedWidth();
    if (!RowIsRightToLeft(self.rowView)) {
        rect.origin.x -= reserved;
    }
    rect.size.width += reserved;
    return rect;
}

%end

%hook XDSButtonRow

// The row arranges only its own items and never walks its subviews, so the
// button has to be placed here, after the arrangement pass.
- (void)layoutSubviews {
    %orig;

    T1ProfileActionButtonsController* controller =
        objc_getAssociatedObject(self, &kActionRowControllerKey);
    if (!controller) {
        return;
    }

    UIButton* button = objc_getAssociatedObject(self, &kCopyButtonKey);
    if (![BHTSettings boolForKey:@"copy_profile_info"]) {
        button.hidden = YES;
        return;
    }

    button = CopyButtonForRow(self);
    button.hidden = NO;
    if (button.superview != self) {
        [self addSubview:button];
    }

    CGRect occupied = CGRectNull;
    for (UIView* arranged in controller.visibleButtons) {
        occupied = CGRectUnion(occupied, arranged.frame);
    }

    CGFloat diameter = CopyButtonDiameter();
    CGFloat x, y;
    if (CGRectIsNull(occupied)) {
        x = RowIsRightToLeft(self) ? CGRectGetWidth(self.bounds) - diameter : 0.0;
        y = (CGRectGetHeight(self.bounds) - diameter) / 2.0;
    } else {
        x = RowIsRightToLeft(self)
                ? CGRectGetMaxX(occupied) + CopyButtonSpacing()
                : CGRectGetMinX(occupied) - CopyButtonSpacing() - diameter;
        y = CGRectGetMidY(occupied) - diameter / 2.0;
    }
    button.frame = CGRectMake(x, y, diameter, diameter);
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
