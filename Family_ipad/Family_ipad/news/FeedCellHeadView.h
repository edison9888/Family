//
//  FeedCellHeadView.h
//  Family
//
//  Created by Aevitx on 13-1-20.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageAndLabelView.h"
#import "MyButton.h"
@interface FeedCellHeadView : UIView

@property (nonatomic, strong) NSDictionary *dataDict;
@property (nonatomic, strong) IBOutlet UIImageView *headImgView;
@property (nonatomic, strong) IBOutlet UILabel *nameLbl;
@property (nonatomic, strong) IBOutlet ImageAndLabelView *timeView;
@property (nonatomic, strong) IBOutlet MyButton *headBtn;
@property (nonatomic, strong) UILabel *actionLabel;
@property (nonatomic, strong) UIImageView *actionImage;
//- (void)initHeadViewData:(NSDictionary*)_aDict;

@end
