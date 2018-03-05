//
//  ReviewCell.h
//  MyYelp
//
//  Created by Deepak Venkatesh on 2018-03-04.
//  Copyright © 2018 Deepak Venkatesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YelpAPI/YLPReview.h>

@interface ReviewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *personImageView;
@property (strong, nonatomic) IBOutlet UILabel *personNameLabel;

@property (strong, nonatomic) IBOutlet UILabel *reviewLabel;

-(void) setUp: (YLPReview*) review;
@end
