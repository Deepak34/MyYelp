//
//  ReviewCell.m
//  MyYelp
//
//  Created by Deepak Venkatesh on 2018-03-04.
//  Copyright © 2018 Deepak Venkatesh. All rights reserved.
//

#import "ReviewCell.h"
#import <YelpAPI/YLPReview.h>
#import <YelpAPI/YLPUser.h>
#import "Font.h"
@implementation ReviewCell

-(void) awakeFromNib{
    [super awakeFromNib];
    self.personImageView.clipsToBounds = true;
    self.personImageView.layer.cornerRadius = 22.5;
    self.personNameLabel.font = [UIFont fontWithName:[Font MyBoldFont] size:14];
     self.reviewLabel.font = [UIFont fontWithName:[Font MyNormalFont] size:14];
}
-(void) setUp: (YLPReview*) review{

    self.personNameLabel.text = review.user.name;
    self.reviewLabel.text = review.excerpt;
}

@end
