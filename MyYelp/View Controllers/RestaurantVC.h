//
//  RestaurantVC.h
//  MyYelp
//
//  Created by Deepak Venkatesh on 2018-03-04.
//  Copyright © 2018 Deepak Venkatesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YelpAPI/YLPBusiness.h>
@import CoreLocation;

@interface RestaurantVC : UIViewController <UITableViewDelegate,UITableViewDataSource>{
    
}

@property (strong, nonatomic) YLPBusiness *restaurant;
@property CLLocationDistance distance;

@end
