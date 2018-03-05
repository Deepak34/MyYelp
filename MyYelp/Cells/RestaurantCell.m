//
//  RestaurantCell.m
//  MyYelp
//
//  Created by Deepak Venkatesh on 2018-03-04.
//  Copyright © 2018 Deepak Venkatesh. All rights reserved.
//

#import "RestaurantCell.h"
#import "Font.h"

@implementation RestaurantCell

-(void) layoutSubviews{
    [super layoutSubviews];
    
    //set the top corners of the image view to be rounded, while the bottom corners are not rounded
    UIBezierPath *maskPath = [UIBezierPath
                              bezierPathWithRoundedRect:self.imageView.bounds
                              byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                              cornerRadii:CGSizeMake(10, 10)
                              ];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.imageView.layer.mask = maskLayer;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = true;
    [self.nameLabel setFont:[UIFont fontWithName:[Font MyBoldFont] size:16]];
    
    [self.numberOfReviewsLabel setFont:[UIFont fontWithName:[Font MyNormalFont] size:14]];
    [self.distanceLabel setFont:[UIFont fontWithName:[Font MyNormalFont] size:14]];
    
    self.numberOfReviewsLabel.textColor = UIColor.lightGrayColor;
    self.distanceLabel.textColor = UIColor.lightGrayColor;

    //add shadow and corner radius to the cell
    self.layer.cornerRadius = 10;
    self.clipsToBounds = false;
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(0,3);
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowRadius = 2;
   
}



@end
