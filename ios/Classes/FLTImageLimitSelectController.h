//
//  FLTImageLimitSelectController.h
//  image_picker_ios
//
//  Created by 周兴 on 2022/10/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PHAsset;

typedef void(^SelectedBlock)(NSArray<PHAsset *> *assets);

@interface FLTImageLimitSelectController : UIViewController

- (instancetype)initWithIsMulitiSelect:(BOOL)isMulitiSelect
                         selectedBlock:(SelectedBlock)selectedBlock;

@end

NS_ASSUME_NONNULL_END
