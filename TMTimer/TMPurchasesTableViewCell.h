//
//  TMPurchasesTableViewCell.h
//  TMTimer
//
//  Created by Derrick Ho on 9/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMPurchasesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *productGraphicView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *productPriceButton;

@end
