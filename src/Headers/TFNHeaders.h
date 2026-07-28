//
//  TFNHeaders.h
//  BHTwitter
//
//  Created by BandarHelal
//

#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
#import "TFSHeaders.h"

@interface TFNTwitterAccount : NSObject
@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* displayUsername;
@end

@interface TFNTableView : UITableView
@end

@interface TFNPillControl : UIControl
@property (nonatomic, copy) NSString* text;
@end

@class TFNDataViewItemArgs;
@class TFNItemsDataViewController;

@interface TFNDataViewController : UIViewController
@property (readonly, nonatomic) TFNTableView* tableView;
@property (readonly, nonatomic) NSString* adDisplayLocation;
- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout*)layout;
- (void)update:(BOOL)animated;
- (void)setNeedsUpdate:(BOOL)animated;
- (void)reloadCellsForItemsAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths
                       withRowAnimation:(UITableViewRowAnimation)animation;
@end

@interface TFNItemsDataViewController : TFNDataViewController
@property (copy, nonatomic) NSArray* sections;
- (NSArray*)updatedSections:(NSArray*)sections forStyle:(NSInteger)style;
- (void)updateSections:(NSArray*)sections;
- (void)useDataViewAdapter:(id)adapter forItemsOfClass:(Class)itemClass;
- (NSIndexPath*)indexPathForItem:(id)item;
@end

@interface TFNDataViewItemArgs : NSObject
@property (readonly, nonatomic) id item;
@property (readonly, nonatomic) id controller;
@property (readonly, nonatomic) NSIndexPath* indexPath;
@end

@interface TFNBooleanItem : NSObject
@property (nonatomic, copy) NSString* text;
@property (nonatomic) BOOL value;
- (instancetype)initWithStyle:(NSInteger)style
                         text:(NSString*)text
                        value:(BOOL)value
                 updateAction:(void (^)(TFNDataViewItemArgs* args))updateAction;
@end

@interface TFNSettingsDescriptionItem : NSObject
- (instancetype)initForNoActionWithText:(NSString*)text;
@end

@interface TFNGenericItem : NSObject
@property (nonatomic, copy) UITableViewCell* (^cellForRowAtIndexPathBlock)
    (TFNGenericItem* item, TFNItemsDataViewController* controller, UITableView* tableView,
     NSIndexPath* indexPath);
@property (nonatomic, copy) CGFloat (^heightForRowAtIndexPathBlock)
    (TFNGenericItem* item, TFNItemsDataViewController* controller, UITableView* tableView,
     NSIndexPath* indexPath);
@property (nonatomic, copy) void (^didSelectRowAtIndexPathBlock)
    (TFNGenericItem* item, TFNItemsDataViewController* controller, UITableView* tableView,
     NSIndexPath* indexPath);
@property (nonatomic, strong) id userInfo;
@end

@interface TFNTextCell : UITableViewCell
+ (instancetype)iconCellForTableView:(UITableView*)tableView
                           indexPath:(NSIndexPath*)indexPath
                            withText:(NSString*)text
                          detailText:(NSString*)detailText
                                icon:(UIImage*)icon
                       accessoryType:(UITableViewCellAccessoryType)accessoryType;
@end

@interface NSObject (TFNDataViewItem)
- (id)tfn_withMultipleLines:(BOOL)multipleLines;
@end

@interface NSString (TFNDataViewItem)
- (id)tfn_asNextSectionHeader;
@end

@interface TFNNavigationController : UINavigationController
@end

@interface TFNActionItem : NSObject
+ (instancetype)cancelActionItemWithAction:(void (^)(void))arg1;
+ (instancetype)cancelActionItemWithTitle:(NSString*)arg1;
+ (instancetype)actionItemWithTitle:(NSString*)arg1 action:(void (^)(void))arg2;
+ (instancetype)actionItemWithTitle:(NSString*)arg1
                          imageName:(NSString*)arg2
                             action:(void (^)(void))arg3;
+ (instancetype)actionItemWithTitle:(NSString*)arg1
                           subtitle:(NSString*)arg2
                          imageName:(NSString*)arg3
                             action:(void (^)(void))arg4;
+ (instancetype)nestedMenuWithTitle:(NSString*)arg1 items:(NSArray*)arg2;
@end

@interface TFNAttributedTextModel : NSObject
@property (copy, nonatomic) NSAttributedString* attributedString;
- (instancetype)initWithAttributedString:(NSMutableAttributedString*)arg;
- (void)fitToSize:(CGSize)size;
- (CTFrameRef)coreTextFrame;
@end

@interface TFNAttributedTextView : UIView
@property (strong, nonatomic) TFNAttributedTextModel* textModel;
@end

// TFN draws with CoreText and leaves CTFont/CTParagraphStyle values under the
// UIKit attribute keys; this rewrites them so TextKit can render the string.
@interface NSAttributedString (TFNUIKitSafe)
- (NSAttributedString*)tfnUIKitSafeAttributedString;
@end

@interface TFNActiveTextItem : NSObject
- (instancetype)initWithTextModel:(id)arg activeRanges:(id)arg1;
@end

@interface TFNMenuSheetViewController : TFNItemsDataViewController
@property (nonatomic, assign, readwrite) BOOL shouldPresentAsMenu;
@property (retain, nonatomic) UIView* sourceView;
- (instancetype)initWithTitle:(NSString*)sheetTitle
                  actionItems:(NSArray*)actionItems;
- (instancetype)initWithMessage:(NSString*)sheetMessage
                    actionItems:(NSArray*)actionItems;
- (instancetype)initWithActionItems:(NSArray*)actionItems;
- (instancetype)initWithTitle:(NSString*)sheetTitle
                   titleStyle:(long long)sheetTitleStyle
                      message:(NSString*)sheetMessage
              messageIconName:(id)sheetMessageIconName
           actionItemSections:(NSArray*)actionItemSections;
- (void)tfnPresentedCustomPresentFromViewController:(id)arg1
                                           animated:(BOOL)arg2
                                         completion:(void (^)(void))arg3;
@end

@interface TFNHUD : NSObject
- (instancetype)initWithText:(NSString*)text;
- (void)setText:(NSString*)text;
- (void)show;
- (void)hide;
@end

@interface TFNSettingsNavigationItem : NSObject
@property (readonly, nonatomic) NSString* title;
- (instancetype)initWithTitle:(NSString*)arg1
                       detail:(NSString*)arg2
                     iconName:(NSString*)arg3
            controllerFactory:(UIViewController* (^)(void))arg4;
- (instancetype)initWithTitle:(NSString*)arg1
                       detail:(NSString*)arg2
            controllerFactory:(UIViewController* (^)(void))arg4;
- (instancetype)initWithTitle:(NSString*)arg1
            controllerFactory:(UIViewController* (^)(void))arg2;
@end

@interface TFNButton : UIButton
+ (id)buttonWithImage:(id)arg1 style:(long long)arg2 sizeClass:(long long)arg3;
+ (id)buttonWithTitle:(id)arg1
           imageNamed:(id)arg2
                style:(long long)arg3
            sizeClass:(long long)arg4;
@end

@interface TFNTwitterStatus : NSObject
@property (readonly, nonatomic) NSDictionary* scribeParameters;
@property (readonly, nonatomic) _Bool isPromoted;
@property (readonly, nonatomic) TFSTwitterEntitySet* entities;
@property (nonatomic, copy) NSString* fromUserName;
@property (nonatomic, assign) NSInteger statusID;
- (id)init;
@end

@interface TFNTwitter : NSObject
+ (instancetype)sharedTwitter;
@property (readonly, nonatomic) NSArray* accounts;
@end

@interface TFNTwitterComposition : NSObject
@property (nonatomic, strong) NSDate* undoableAddedDate;
@property (nonatomic, assign) double undoTimeInterval;
@end

@interface UIViewController (TFNPresentation)
- (void)tfn_dismissAnimated:(id)sender;
- (void)tfn_presentFromViewController:(UIViewController*)viewController
                             animated:(BOOL)animated;
@end

@interface TFNTitleView : UIView
+ (instancetype)titleViewWithTitle:(NSString*)title
                          subtitle:(NSString*)subTitle;
@end

@interface UIImage (TFNAdditions)
+ (id)tfn_vectorImageNamed:(id)arg1
                  fitsSize:(struct CGSize)arg2
                 fillColor:(id)arg3;
+ (BOOL)tfn_vectorImageExistsNamed:(id)arg1
                          fitsSize:(struct CGSize)arg2
                              size:(out struct CGSize*)arg3;
+ (id)tfn_vectorImageNamed:(id)arg1
    highContrastVariantNamed:(id)arg2
                    fitsSize:(struct CGSize)arg3
                   fillColor:(id)arg4;
+ (id)tfn_vectorImageNamed:(id)arg1 height:(double)arg2 fillColor:(id)arg3;
+ (void)tfn_vectorImageSetOverrideContainersDirectoryURL:(NSURL*)arg1;
+ (NSURL*)tfn_vectorImageOverrideContainersDirectoryURL;
+ (void)tfn_vectorImageSetSearchDirectoryURLs:(NSArray*)arg1;
+ (NSArray*)tfn_vectorImageSearchDirectoryURLs;
+ (void)tfn_vectorImageSetOverrideContainerName:(NSString*)arg1;
+ (NSString*)tfn_vectorImageOverrideContainerName;
@end
