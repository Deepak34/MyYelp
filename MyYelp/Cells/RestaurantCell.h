//
//  RestaurantCell.h
//  MyYelp
//
//  Created by Deepak Venkatesh on 2018-03-04.
//  Copyright © 2018 Deepak Venkatesh. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Cosmos;

@interface RestaurantCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *numberOfReviewsLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
IB_DESIGNABLE
@property (strong, nonatomic) IBOutlet CosmosView *starView;
@end
