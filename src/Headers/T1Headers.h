//
//  T1Headers.h
//  BHTwitter
//
//  Created by BandarHelal
//

#import <SafariServices/SafariServices.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "TFNHeaders.h"
#import "TFSHeaders.h"

@interface T1AppDelegate : UIResponder <UIApplicationDelegate>
@property (retain, nonatomic) UIWindow* window;
@end

// The "new posts" pill shown at the top of the timeline
@interface TUIUpdateIndicator : UIViewController
@property (nonatomic, strong) TFNPillControl* pillControl;
@end

@interface TTMAssetVideoFile : NSObject
@property (nonatomic, copy, readonly) NSString* filePath;
@property (nonatomic, assign, readonly) CGFloat duration;

@end

@interface TTMAssetVoiceRecording : TTMAssetVideoFile
@property (nonatomic, strong, readwrite) NSNumber* totalDurationMillis;
@end

@interface T1MediaAttachmentsViewCell : UICollectionViewCell
@property (nonatomic, strong, readwrite) id attachment;
@property (nonatomic, strong) UIButton* uploadButton;
@end

@interface T1MediaAttachmentsViewCell () <UINavigationControllerDelegate,
                                          UIImagePickerControllerDelegate>
@end

@interface T1StandardStatusAttachmentViewAdapter : NSObject
@property (nonatomic, assign, readonly) NSUInteger attachmentType;
@end

#pragma mark - Tab bar

@interface T1PanelIdentity : NSObject
+ (NSString*)iconImageNameForPanelID:(long long)panelID;
@end

@interface T1TabView : UIView
@property (readonly, nonatomic) UILabel* titleLabel;
@property (readonly, nonatomic) long long panelID;
@property (copy, nonatomic) NSString* scribePage;
@property (readonly, nonatomic) NSString* title;
@property (readonly, nonatomic) NSString* imageName;
@property (retain, nonatomic) UIColor* iconColor;
@property (readonly, nonatomic, getter=isSelected) BOOL selected;
- (void)_t1_updateTitleLabel;
- (void)_t1_updateImageViewAnimated:(BOOL)animated;
@end

@interface T1TabBarViewController : UIViewController
@property (copy, nonatomic) NSArray* tabViews;
@end

// Each entry backs one tab and owns its T1TabView; the app orders both the tab
// buttons and their content view controllers from this single array.
@protocol T1AppNavigationTabEntry <NSObject>
- (T1TabView*)tabView;
@end

@interface T1TabbedAppNavigationViewController : UIViewController
- (void)setVisibleTabEntries:(NSArray<id<T1AppNavigationTabEntry>>*)entries;
// Recomputes the visible tab set at runtime (rebuilds buttons and content).
- (void)recalculateVisiblePanels;
@end

#pragma mark - Settings

// T1GenericSettingsViewController backs the 12.3 "settings revamp" root and its
// sub-pages; T1SettingsViewController is the legacy fallback root.
@interface T1GenericSettingsViewController : TFNItemsDataViewController
@property (nonatomic, strong) TFNTwitterAccount* account;
@end

#pragma mark - Profile

@interface T1ProfileActionButtonSpec : NSObject
- (instancetype)initWithPosition:(NSUInteger)position
                        priority:(NSUInteger)priority
                 visibilityBlock:(BOOL (^)(double))visibilityBlock
             buttonCreationBlock:(UIView* (^)(void))buttonCreationBlock;
@end

@interface T1ProfileUserViewModel : NSObject
@property (readonly, copy, nonatomic) NSString* location;
@property (readonly, copy, nonatomic) NSString* fullName;
@property (readonly, copy, nonatomic) NSString* username;
@property (readonly, copy, nonatomic) NSString* bio;
@property (readonly, copy, nonatomic) NSString* url;
@end

@interface T1ProfileHeaderViewController : UIViewController
@property (retain, nonatomic) T1ProfileUserViewModel* viewModel;
@end

// The redesigned profile header's action button row and its metrics.

@interface T1ProfileActionButtonsController : NSObject
@property (nonatomic) UIEdgeInsets contentInsets;
@property (readonly, nonatomic) UIView* rowView;
@property (readonly, nonatomic) NSArray<UIView*>* visibleButtons;
@property (readonly, nonatomic) CGRect occupiedContentRect;
@end

@interface XDSButtonBorder : NSObject
@property (readonly, nonatomic) CGFloat width;
@property (readonly, nonatomic) UIColor* color;
@end

@interface XDSButtonRow : UIView
@end

@interface XDSButtonSizeClass : NSObject
+ (instancetype)large;
@property (readonly, nonatomic) CGFloat height;
@property (readonly, nonatomic) CGFloat iconSize;
@property (readonly, nonatomic) CGFloat interButtonSpacing;
@end

@interface XDSButtonDisplayStyle : NSObject
+ (instancetype)outlined;
@property (readonly, nonatomic) UIColor* foregroundColor;
@property (readonly, nonatomic) XDSButtonBorder* border;
@end

@interface XDSButtonCornerRadius : NSObject
+ (instancetype)pill;
- (CGFloat)resolvedForHeight:(CGFloat)height;
@end

#pragma mark - Status views

@protocol TTAStatusInlineActionButtonDelegate <NSObject>
@end

@interface TTAStatusInlineShareButton : UIView
@end

@interface T1PersistentComposeViewController : UIViewController
@property (readonly, nonatomic) id statusViewModel;
@end

@protocol TTACoreStatusViewEventHandler <NSObject>
@end

@interface TTAStatusInlineActionsView
    : UIView <TTAStatusInlineActionButtonDelegate>
@property (readonly, nonatomic) id viewModel;
@property (nonatomic) id delegate;
@end

@interface T1StandardStatusView : UIView
@property (nonatomic) __weak id<TTACoreStatusViewEventHandler> eventHandler;
@end

@interface T1TweetComposeViewController : UIViewController
@end

#pragma mark - Media views

@class DownloadInlineButton;

// DM media message container (DMConversation.MessageAttachmentView)
@interface _TtC14DMConversation21MessageAttachmentView : UIView
@property (nonatomic, strong) UIContextMenuInteraction* downloadMenuInteraction;
@property (nonatomic, strong) DownloadInlineButton* downloadHandler;
@end

@interface _TtC14DMConversation21MessageAttachmentView () <
    UIContextMenuInteractionDelegate>
@end

// Shared media view (TweetMediaAttachments.MultiMediaView); its carousel
// variant exposes -inlineMediaInfos as well
@interface _TtC21TweetMediaAttachments14MultiMediaView : UIView
@property (nonatomic, readonly) NSArray* inlineMediaInfos;
@end

#pragma mark - Host & web views

@interface T1HostViewController : UIViewController
+ (instancetype)sharedHostViewController;
- (id)currentAccount;
@end

@interface T1BaseWebViewController : UIViewController
- (void)setCurrentURL:(NSURL*)url;
- (WKWebView*)webView;
@end

@interface T1WebViewController : T1BaseWebViewController
- (instancetype)initWithRootURL:(NSURL*)rootURL
                        account:(id)account
             shouldAuthenticate:(BOOL)shouldAuthenticate
      shouldPresentAsNativePage:(BOOL)shouldPresentAsNativePage
                   sourceStatus:(id)sourceStatus
                scribeComponent:(id)scribeComponent
               scribeParameters:(id)scribeParameters;
@property (nonatomic, strong) id account;
- (BOOL)doesURLResultTypeOpenInWebview:(long long)resultType;
@end

@interface T1SafariViewController : SFSafariViewController
@property (nonatomic, readonly) NSURL* rootURL;
@end

#pragma mark - Status & timeline text

@interface T1ConversationFooterTextView : UIView
@property (nonatomic, readonly) id viewModel;
- (void)updateFooterTextView;
@end

// Hooked for unrounded follower/following counts
@interface T1ProfileFriendsFollowingViewModel : NSObject
- (id)_t1_followCountTextWithLabel:(id)arg1
                     singularLabel:(id)arg2
                             count:(id)arg3
                       highlighted:(_Bool)arg4;
@end
