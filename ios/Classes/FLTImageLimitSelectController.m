//
//  FLTImageLimitSelectController.m
//  image_picker_ios
//
//  Created by 周兴 on 2022/10/19.
//

#import "FLTImageLimitSelectController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PHPhotoLibrary+PhotosUISupport.h>
#import <PhotosUI/PhotosUI.h>

//TODO: Implement localization on this file later

NSMutableDictionary<PHAsset *, UIImage *> *cellImageCache;

@interface FLTImageLimitSelectCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
//22 * 22
//添加按钮配置
@property (nonatomic, strong) UIView *addBackView;
@property (nonatomic, strong) UILabel *addIconLabel;
@property (nonatomic, strong) UILabel *addTitleLabel;

//选中框
@property (nonatomic, strong) UIImageView *selectedIcon;

@property (nonatomic, assign) BOOL isAddCell;
@property (nonatomic, assign) BOOL cellSelected;

@property (nonatomic, strong) PHImageRequestOptions *requestOption;
@property (nonatomic, strong) PHAsset *currentAsset;

@end

@implementation FLTImageLimitSelectCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.addBackView];
        [self.contentView addSubview:self.selectedIcon];
        if (!cellImageCache) cellImageCache = @{}.mutableCopy;
    }
    return self;
}

- (void)setIsAddCell:(BOOL)isAddCell {
    if (_isAddCell != isAddCell) {
        _isAddCell = isAddCell;
        self.addBackView.hidden = !_isAddCell;
        self.imageView.hidden = _isAddCell;
    }
}

- (void)setCellSelected:(BOOL)cellSelected {
    if (_cellSelected != cellSelected) {
        _cellSelected = cellSelected;
        if (_cellSelected && !self.isAddCell) {
            self.selectedIcon.hidden = NO;
        } else {
            self.selectedIcon.hidden = YES;
        }
    }
}

- (void)setCurrentAsset:(PHAsset *)currentAsset {
    if (currentAsset == nil) {
        _currentAsset = nil;
        self.imageView.image = nil;
        return;
    }
    
    if (_currentAsset != currentAsset) {
        _currentAsset = currentAsset;
        UIImage *cachedImage = cellImageCache[_currentAsset];
        if (cachedImage) {
            //使用缓存
            self.imageView.image = cachedImage;
        } else {
            //请求图片
            [[PHImageManager defaultManager] requestImageForAsset:_currentAsset targetSize:CGSizeMake(self.frame.size.width * 2, self.frame.size.height * 2) contentMode:PHImageContentModeAspectFill options:self.requestOption resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                [cellImageCache setObject:result forKey:self->_currentAsset];
                self.imageView.image = result;
            }];
        }
    }
}

- (PHImageRequestOptions *)requestOption {
    if (!_requestOption) {
        _requestOption = [[PHImageRequestOptions alloc] init];
        _requestOption.resizeMode = PHImageRequestOptionsResizeModeExact;
        _requestOption.networkAccessAllowed = YES;
        _requestOption.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    }
    return _requestOption;
}

//图片展示
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}

//添加cell背景
- (UIView *)addBackView {
    if (!_addBackView) {
        _addBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [_addBackView addSubview:self.addIconLabel];
        [_addBackView addSubview:self.addTitleLabel];
        _addBackView.hidden = YES;
    }
    return _addBackView;
}

//添加的加号
- (UILabel *)addIconLabel {
    if (!_addIconLabel) {
        _addIconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.frame.size.width, 30)];
        _addIconLabel.textColor = [UIColor blackColor];
        _addIconLabel.textAlignment = NSTextAlignmentCenter;
        _addIconLabel.font = [UIFont systemFontOfSize:30];
        _addIconLabel.text = @"+";
    }
    return _addIconLabel;
}

//添加提示
- (UILabel *)addTitleLabel {
    if (!_addTitleLabel) {
        _addTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.addIconLabel.frame) + 5, self.frame.size.width - 20, 50)];
        _addTitleLabel.textColor = [UIColor blackColor];
        _addTitleLabel.textAlignment = NSTextAlignmentCenter;
        _addTitleLabel.font = [UIFont systemFontOfSize:14];
        _addTitleLabel.numberOfLines = 0;
        _addTitleLabel.text = @"Add more accessible photos";
    }
    return _addTitleLabel;
}

//选中框
- (UIImageView *)selectedIcon {
    if (!_selectedIcon) {
        NSString *iconData = @"iVBORw0KGgoAAAANSUhEUgAAAEIAAABCCAMAAADUivDaAAAA4VBMVEUAAAD///+11v8AZ//w9//p8//u9f/w9f/w9f/r8//r8//j7v/k7//e7P/o8f/g7P/i7f/0+P/P4v/Q5P/L3v+x0v+31f+Yw/9st/8An//i7v/i7f/B2f8Ab//////9/v8AZv8JcP8AYf/6/f8AXf8idP8ecv8Ucf/v9f+vyP8AbP8bcP8Aav/L2/8NcP/Y5f/O3v/y+P9akf8Obv8AWf8Ycv8cc//g6v9vn//D1P+VtP9ilf9ckv9Kif8Hev8WcP+90f8teP/Q4P/Q3/+vw/89hf81gP+Mr/+Mrv+Jrf8Ye//Cvu4ZAAAAHXRSTlMA/DcK/Pf28erm3cKwqqijnIl0aF4+PC8aEOzsSuSplFsAAAN6SURBVFjDlJRpc9owEIZNgHCfISGXzEq2JWOMMbXpcA43af//H6pWdtokJUR5P3gYjfbh3V3tGp8pe9VuVZ7yOcvK5Z8qrfZV1viWHjr1kmW+k1Wqdx60AVfNIgZlMpleKvkTT4rNKy3AXVX+v4p+a0JxpJfq3ZeA+4aMTON7ljvaDYe7kWv1Uor8Nu4vE24KCMCAcXiYrraeD+B729X0EI6RgpDCzQVAtpYCrP38BDEDL1pzvo48YDGc5nsrhdQ+7U63LGuAgNmC2f7AEQGlRIrSQDgD32aLmYRgTcrd84TbazNjSkK4tIFzSj6Icg72MpQMee369hzheawI7gsDR5CzEg6wF1cxxs9nPCSE0dHmgnwqwe3jKGH856OLWZjmBsAhF+UAbEwTc+l+6EVZEfosmpAvNIlYXzHK7/tSU1n0Yx6QLxXwuK9yqb17UYqwYZwSDVHONopx8+ZVF8yMrCREAdFSEIGsacYs/HvrDSS4R5gQTU3g6CKj8Xc2e6Z81b9sh2jLsV8wpvc6t1U0ETJOviHOQrRRTTeMJWtjLUFolcFJnq6ApQpLdlATTcz00pj4cQwiSWWGNppqTxaRtgChZX+1mSVXBSzQRhH3aQdN7LUq4bCla5ruyg8Ubo82OhJRR8Tc5jqEH7KVlrz8ExH2HBF1OR0laWd88qkeAXfaVGVC/dNYhpayST9CGGgS1CwmT3AAYdKTNuZxiJ1vEER6Eh8wk7bRwgmbMqFNsAdpzoJNcdZaRkV+rRW8DhgVQpNAAlhZMrhiPOK+3Ho0JVAGa6pFINTb4uGjkceF6UU0OfXJdAqe0CEQGnm4RvNGTn53/jr1QGSRZx4yLhOU1v5OHucM7OkQeDIB9m9Tauh7QoNAOAyxq39qMZcUhGEoii5FKSnFojixFVQUR5buf0EWJ4fmJZfCxQ0c2uS9+0lALCIAQxBA5D9yhqEJ/Mj6OLvjfIUhCRxndqnD/glDErjUfLTGFUMRGC0GPDLegsCAs2aR0V8egsCaseyRcRcElh3JCYwljAgCkhOED4YkIHxF+eU7dlUC8lsyARiKgAlEK4LxU7kKASuKhghjPpxuzatMwBCVLXd9atKwwZYJB5/U5mGmHTeEAz+i+EHJj2t+aPSjqx+g/RhfLxOTLhMTZcKtNH6x8uudXTL9qmsXbrv2/+nxwX8C+QL6pa6MaQ9vpwAAAABJRU5ErkJggg==";
        _selectedIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 22 - 10, self.frame.size.height - 22 - 10, 22, 22)];
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:iconData options:NSDataBase64DecodingIgnoreUnknownCharacters];
        _selectedIcon.image = [UIImage imageWithData:imageData];
        _selectedIcon.hidden = YES;
    }
    return _selectedIcon;
}

@end

#define ToolbarHeight 55 //顶部工具栏高度
#define BottombarHeight 110 //底部权限提示高度

@interface FLTImageLimitSelectController ()<UICollectionViewDelegate, UICollectionViewDataSource, PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) UICollectionView *imageCollectionView;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) NSString *rightArrowData;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) BOOL isMulitiSelect;
@property (nonatomic, copy) SelectedBlock selectedBlock;

//数据
@property (nonatomic, strong) NSArray<PHAsset *> *allAssets;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *selectedAssets;

@end

@implementation FLTImageLimitSelectController

- (instancetype)initWithIsMulitiSelect:(BOOL)isMulitiSelect
                         selectedBlock:(SelectedBlock)selectedBlock {
    if (self = [super init]) {
        self.isMulitiSelect = isMulitiSelect;
        self.selectedBlock = [selectedBlock copy];
        self.selectedAssets = @[].mutableCopy;
    }
    return self;
}

- (void)dealloc {
    [PHPhotoLibrary.sharedPhotoLibrary unregisterChangeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.rightArrowData = @"iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAANhJREFUWEft2DEOAjEQQ1HvyeBmwMmWo6HpULRN4u8hBSkjJXrjyppDm59jc59c4FPSTdJL0jsxrAO8Szq/UIUsMHocYGEegwZHOsCyxZEuMI4kgFEkBYwhSWAESQNxZAKIIlNADJkEIsg00EZ2AC1kF3AZ2QlcQnYDp5G/AE4h/8CLej3VIbsTnMLVcJ3AaVwncAnXBVzGdQAtXBpo45JABJcCYrgEEMXRQBxHAiM4ChjDEcAozgWO+8H6b6v125gejnMTrPe1Ya0kIzgCeNFH2avOPrgk/wDgkkgpr1cV3AAAAABJRU5ErkJggg==";

    //工具栏
    [self initToolbar];
    
    //内容视图
    [self initCollectionView];
    
    //底部提示
    [self initBottombar];
    
    //监听相册变化
    [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];
    
    [self reloadAllowedAlbumImages];
}

#pragma mark -Methods
- (void)initToolbar {
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, ToolbarHeight)];
    toolBar.backgroundColor = [UIColor whiteColor];
    
    //关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    closeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    closeButton.frame = CGRectMake(10, 0, 60, ToolbarHeight);
    [toolBar addSubview:closeButton];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, CGRectGetWidth(toolBar.frame)-200, ToolbarHeight)];
    titleLabel.text = @"Recent Projects";
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [toolBar addSubview:titleLabel];
    
    //确定按钮 - 多选时展示
    if (self.isMulitiSelect) {
        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmButton setTitle:@"Sure" forState:UIControlStateNormal];
        [confirmButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [confirmButton setTitleColor:[[UIColor blueColor] colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
        [confirmButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
        confirmButton.titleLabel.font = [UIFont systemFontOfSize:16];
        confirmButton.frame = CGRectMake(CGRectGetWidth(toolBar.frame) - 10 - 60, 0, 60, ToolbarHeight);
        confirmButton.enabled = NO;
        [toolBar addSubview:confirmButton];
        self.confirmButton = confirmButton;
    }
    
    [self.view addSubview:toolBar];
}

- (void)initCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWidth = floor((CGRectGetWidth(self.view.frame) - 4) / 4.0);
    self.itemWidth = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    layout.minimumLineSpacing = 2;
    layout.minimumInteritemSpacing = 2;
    layout.sectionHeadersPinToVisibleBounds = YES;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, ToolbarHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - ToolbarHeight - BottombarHeight - [self safeAreaBottom]) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    self.imageCollectionView = collectionView;
    [self.view addSubview:self.imageCollectionView];
    
    //注册cell
    [collectionView registerClass:FLTImageLimitSelectCell.class forCellWithReuseIdentifier:NSStringFromClass(FLTImageLimitSelectCell.class)];
}

- (void)initBottombar {
    
    UIControl *bottombar = [[UIControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageCollectionView.frame), CGRectGetWidth(self.view.frame), BottombarHeight + [self safeAreaBottom])];
    [bottombar addTarget:self action:@selector(gotoAppSetting) forControlEvents:UIControlEventTouchUpInside];
    bottombar.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:bottombar];
    
    UILabel *leftTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 40, 60)];
    leftTextLabel.text = @"⚠️";
    [bottombar addSubview:leftTextLabel];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, CGRectGetWidth(self.view.frame) - 100, 60)];
    textLabel.numberOfLines = 0;
    textLabel.textColor = [UIColor blackColor];
    textLabel.font = [UIFont systemFontOfSize:14];
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoPlist objectForKey:@"CFBundleDisplayName"];
    if (appName.length == 0) {
        appName = [infoPlist objectForKey:@"CFBundleName"];
    }
    textLabel.text = [NSString stringWithFormat:@"you have set %@ Only some photos in the album can be accessed, it is recommended to allow access "All Photos"", appName];
    [bottombar addSubview:textLabel];
    
    UIImageView *rightArrow = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(bottombar.frame) - 16 - 24, (60 - 24) / 2.0, 24, 24)];
    NSData *showData = [[NSData alloc] initWithBase64EncodedString:self.rightArrowData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    rightArrow.image = [UIImage imageWithData:showData];
    [bottombar addSubview:rightArrow];
}

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)confirmAction {
    !self.selectedBlock ?: self.selectedBlock(self.selectedAssets.copy);
    [self closeAction];
}

- (void)gotoAppSetting {
    if (@available(iOS 10, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                           options:[[NSDictionary alloc] init]
                                 completionHandler:nil];
    } else if (@available(iOS 8.0, *)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
#pragma clang diagnostic pop
    }
}

//刷新所有允许访问的图片
- (void)reloadAllowedAlbumImages {
    
    NSMutableArray<PHAsset *> *allAssets = @[].mutableCopy;
    
    //获取图片配置
    PHFetchOptions *resultFetchOption = [[PHFetchOptions alloc] init];
    resultFetchOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    resultFetchOption.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    
    //相机胶卷
    PHFetchResult *cameraAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    //用户自定义相册
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    NSMutableArray *arrAllAlbums = @[].mutableCopy;
    if (cameraAlbums) [arrAllAlbums addObject:cameraAlbums];
    if (userAlbums) [arrAllAlbums addObject:userAlbums];
        
    
    for (PHFetchResult<PHAssetCollection *> *album in arrAllAlbums) {
        for (PHAssetCollection *collection in album) {
            if (![collection isKindOfClass:PHAssetCollection.class]) continue;
            // 过滤空相册
            if (collection.estimatedAssetCount < 1) continue;
            // 过滤无用相册
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden ||
                collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumRecentlyAdded ||
                collection.assetCollectionSubtype > 217) continue;
            
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:resultFetchOption];
            // 遍历
            [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
                [allAssets addObject:asset];
            }];
        }
    }
    
    self.allAssets = allAssets.copy;
    [self.imageCollectionView reloadData];
}

#pragma mark -- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allAssets.count + 1;
}

//cell
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FLTImageLimitSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(FLTImageLimitSelectCell.class) forIndexPath:indexPath];
    if (indexPath.row == self.allAssets.count) {
        //选择更多cell
        cell.isAddCell = YES;
    } else {
        cell.isAddCell = NO;
        cell.currentAsset = self.allAssets[indexPath.row];
        cell.cellSelected = [self.selectedAssets containsObject:self.allAssets[indexPath.row]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.allAssets.count) {
        //添加更多可访问照片
        if (@available(iOS 14, *)) {
            [[PHPhotoLibrary sharedPhotoLibrary] presentLimitedLibraryPickerFromViewController:self];
        }
    } else {
        PHAsset *current = self.allAssets[indexPath.row];
        //选择的照片回调
        if (self.isMulitiSelect) {
            //多选
            if ([self.selectedAssets containsObject:current]) {
                //取消选中
                [self.selectedAssets removeObject:current];
            } else {
                //增加选中
                [self.selectedAssets addObject:current];
            }
            [collectionView reloadData];
            self.confirmButton.enabled = self.selectedAssets.count > 0;
            if (self.selectedAssets.count) {
                [self.confirmButton setTitle:[NSString stringWithFormat:@"Sure(%ld)", self.selectedAssets.count] forState:UIControlStateNormal];
            } else {
                [self.confirmButton setTitle:@"Sure" forState:UIControlStateNormal];
            }
            
        } else {
            //单选
            !self.selectedBlock ?: self.selectedBlock(@[current]);
            [self closeAction];
        }
    }
}


#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
            [self reloadAllowedAlbumImages];
        }
    });
}


/// 底部安全区高度
- (CGFloat)safeAreaBottom {
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIWindow *window = windowScene.windows.firstObject;
        return window.safeAreaInsets.bottom;
    } else if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        return window.safeAreaInsets.bottom;
    }
    return 0;
}

@end
