//
//  LFActionSheet.h
//  LFActionSheet
//
//  Created by apple on 2017/3/31.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LFActionSheet;

typedef NS_ENUM(NSInteger, LFOtherActionItemAlignment) {
    LFOtherActionItemAlignmentLeft,
    LFOtherActionItemAlignmentCenter
};


@protocol LFActionSheetDelegate <NSObject>

@required

/**
 Delegate method
 
 @param actionSheet The LFActionSheet instance.
 @param index       Top is 0 and ++ to down, but cancelBtn's index is -1.
 */
- (void)actionSheet:(LFActionSheet *)actionSheet didSelectSheet:(NSInteger)index;

@end

/**
 Block callback
 
 @param actionSheet The same as the delegate.
 @param index       The same as the delegate.
 */
typedef void (^ActionSheetDidSelectSheetBlock)(LFActionSheet *actionSheet, NSInteger index);

@interface LFActionSheet : UIView

/**
 Default is LFOtherActionItemAlignmentCenter when no images.
 Default is LFOtherActionItemAlignmentLeft when there are images.
 */
@property (nonatomic, assign) LFOtherActionItemAlignment otherActionItemAlignment;

/**
 Create a sheet with block.
 
 @param title            Title on the top, not must.
 @param cancelTitle      Title of action item at the bottom, not must.
 @param destructiveTitle Title of action item at the other action items bottom, not must.
 @param otherTitles      Title of other action items, must.
 @param otherImages      Image of other action items, not must.
 @param selectSheetBlock The call-back's block when select a action item.
 */
+ (instancetype)lf_actionSheetViewWithTitle:(NSString *)title
                                cancelTitle:(NSString *)cancelTitle
                           destructiveTitle:(NSString *)destructiveTitle
                                otherTitles:(NSArray  *)otherTitles
                                otherImages:(NSArray  *)otherImages
                           selectSheetBlock:(ActionSheetDidSelectSheetBlock)selectSheetBlock;

/**
 Create a action sheet with delegate.
 */
+ (instancetype)lf_actionSheetViewWithTitle:(NSString *)title
                                cancelTitle:(NSString *)cancelTitle
                           destructiveTitle:(NSString *)destructiveTitle
                                otherTitles:(NSArray  *)otherTitles
                                otherImages:(NSArray  *)otherImages
                                   delegate:(id<LFActionSheetDelegate>)delegate;

- (void)show;

@end
