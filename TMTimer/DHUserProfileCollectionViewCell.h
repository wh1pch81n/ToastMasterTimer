//
//  DHUserProfileCollectionViewCell.h
//  TMTimer
//
//  Created by Derrick Ho on 8/18/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol DHUserProfileCollectionViewCellDelegate;

@interface DHUserProfileCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelProfileName;
@property (weak, nonatomic) IBOutlet UILabel *labelProfileSpeechNumber;
@property (weak, nonatomic) IBOutlet UIImageView *ImageProfilePic;

@end


//@protocol DHUserProfileCollectionViewCellDelegate <NSObject>

//- (void)tappedCell:(DHUserProfileCollectionViewCell *)cell;

//@end
