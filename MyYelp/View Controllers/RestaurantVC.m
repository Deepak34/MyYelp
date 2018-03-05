//
//  RestaurantVC.m
//  MyYelp
//
//  Created by Deepak Venkatesh on 2018-03-04.
//  Copyright © 2018 Deepak Venkatesh. All rights reserved.
//

#import "RestaurantVC.h"
#import "AppDelegate.h"
#import <YelpAPI/YLPBusiness.h>
#import <YelpAPI/YLPCategory.h>
#import <YelpAPI/YLPClient+Business.h>
#import <YelpAPI/YLPClient+Reviews.h>
#import <YelpAPI/YLPUser.h>
#import <YelpAPI/YLPBusinessReviews.h>
#import "ReviewCell.h"
#import "ImageViewerVC.h"
#import "Font.h"

@import Cosmos;

@interface RestaurantVC (){
    NSArray<UIImageView*> *imageViews;
   
}
@property (strong, nonatomic) NSArray<YLPReview*> *reviews;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet CosmosView *starsView;
@property (strong, nonatomic) IBOutlet UILabel *reviewCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UILabel *photosLabel;
@property (strong, nonatomic) IBOutlet UIImageView *image1;
@property (strong, nonatomic) IBOutlet UIImageView *image2;
@property (strong, nonatomic) IBOutlet UIImageView *image3;
@property (strong, nonatomic) IBOutlet UILabel *reviewLabel;
@property (strong, nonatomic) IBOutlet UITableView *reviewsTable;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *photoImageViews;

@end

@implementation RestaurantVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set up
    [self setUpView];
    [self setUpTableView];
    [self assignValuesToView];
    [self getMainImage];
    [self getImages];
    [self getReviews];
}

//set the content size of the scroll view, and the height of the tableview here, once the view has been laid out.
-(void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.reviewsTable.frame.origin.y + self.reviewsTable.contentSize.height);
    
    //make the height of the tableView equal to its content size (this tableView does not scroll)
    _tableViewHeight.constant = self.reviewsTable.contentSize.height;
}

//set up the view, including the navigation bar, the pictures, and the fonts.
-(void) setUpView{
    self.navigationItem.title = @"Restaurant";
    [self.navigationController.navigationItem.backBarButtonItem setTitle:@""];
    [self.navigationItem.backBarButtonItem setTitle:@""];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    UITapGestureRecognizer *rec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    [self.image1 addGestureRecognizer:rec];
    UITapGestureRecognizer *rec2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    [self.image2 addGestureRecognizer:rec2];
    UITapGestureRecognizer *rec3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    [self.image3 addGestureRecognizer:rec3];
    
    
    imageViews = @[self.image1,self.image2,self.image3];
    
    self.nameLabel.font = [UIFont fontWithName:[Font MyBoldFont] size:18];
    self.reviewCountLabel.font = [UIFont fontWithName:[Font MyNormalFont] size:14];
    self.distanceLabel.font = [UIFont fontWithName:[Font MyNormalFont] size:14];
    self.categoryLabel.font = [UIFont fontWithName:[Font MyNormalFont] size:16];
    self.photosLabel.font = [UIFont fontWithName:[Font MyBoldFont] size:18];
     self.reviewLabel.font = [UIFont fontWithName:[Font MyBoldFont] size:18];
    
    self.reviewCountLabel.textColor = UIColor.lightGrayColor;
    self.distanceLabel.textColor = UIColor.lightGrayColor;
    self.categoryLabel.textColor = UIColor.lightGrayColor;
}

//set up the reviews table view. This does not scroll.
-(void) setUpTableView{
    UINib *nib = [UINib nibWithNibName:@"ReviewCell" bundle:nil];
    [self.reviewsTable registerNib:nib forCellReuseIdentifier:@"cell"];
    [self.reviewsTable setDataSource:self];
    [self.reviewsTable setDelegate:self];
    self.scrollView.showsVerticalScrollIndicator = false;
    
    [self.reviewsTable setScrollEnabled:false];
    [self.reviewsTable setAlwaysBounceVertical:false];
    self.reviewsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
}

//Assign the values from the restaurant property (which was passed from HomeVC).
//Note that this does not including information that needs to be downloaded
-(void) assignValuesToView{
    
    self.nameLabel.text = self.restaurant.name;
    self.imageView.clipsToBounds = true;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.starsView.rating = self.restaurant.rating;
    self.reviewCountLabel.text = [NSString stringWithFormat: @"%ld reviews", (long)self.restaurant.reviewCount];
    self.distanceLabel.text = [NSString stringWithFormat:@"%0.1f km",self.distance/1000];
    
    NSString *categoryString = @"";
    int i = 0;
    for (i = 0; i < self.restaurant.categories.count; i++){
        YLPCategory *category = self.restaurant.categories[i];
        NSString *thisString = category.name;
        if (i != self.restaurant.categories.count-1 && self.restaurant.categories.count > 1){
            thisString = [thisString stringByAppendingString:@", "];
        }
        categoryString = [categoryString stringByAppendingString:thisString];
    }
    
    for (i = 0; i < self.photoImageViews.count; i++){
        UIImageView *imageView = self.photoImageViews[i];
        imageView.clipsToBounds = true;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.cornerRadius = 5;
        
    }
    
    self.categoryLabel.text = categoryString;
}

//Get the main image of the restaurant. Downlaod in background thread, then update UI on main thread.
-(void)getMainImage{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^(void) {
        
        NSData *imageData = [NSData dataWithContentsOfURL:self.restaurant.imageURL];
        
        UIImage* image = [[UIImage alloc] initWithData:imageData];
        
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
            });
        }
    });
}

//get the 3 photos of the restaurant. Download on background then, then update UI on main thread.
-(void) getImages{
    [[AppDelegate sharedClient] businessWithId:self.restaurant.identifier completionHandler:^(YLPBusiness * _Nullable business, NSError * _Nullable error) {
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^(void) {
            
            int i = 0;
            
            for (i = 0; i < business.photos.count; i++){
                NSData *imageData = [NSData dataWithContentsOfURL: [NSURL URLWithString:business.photos[i]]];
                
                UIImage* image = [[UIImage alloc] initWithData:imageData];
                
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageViews[i].image = image;
                    });
                }
            }
            
            
        });
        
    }];
}

//Get 3 reviews of the restaurant. Downlaod in background thread, then update UI in main thread.
-(void) getReviews{
    [[AppDelegate sharedClient] reviewsForBusinessWithId:self.restaurant.identifier completionHandler:^(YLPBusinessReviews * _Nullable reviews, NSError * _Nullable error) {
        
        int endRange = 3;
        if (reviews.reviews.count < 3){
            endRange = reviews.reviews.count;
        }
        if (reviews.reviews.count > 0){
            self.reviews = [reviews.reviews subarrayWithRange:NSMakeRange(0, endRange)];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.reviewsTable reloadData];
        });
        
    }];
}

//If a photo is tapped, open ImageViewerVC so the user sees a full screen version of the photo
-(void)photoTapped: (UITapGestureRecognizer *)recognizer{
    ImageViewerVC *vc = [ImageViewerVC new];
    UIImageView *imageView = (UIImageView*) recognizer.view;
    vc.image = imageView.image;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.modalPresentationCapturesStatusBarAppearance = YES;
    [self presentViewController:vc animated:true completion:nil];
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.reviews.count;
}

//display the review cell. Download the person image in a background thread, assign image to cell on main thread if cell is still being displayed
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ReviewCell *cell = (ReviewCell*) [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tag = indexPath.row;
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^(void) {
        
        NSData *imageData = [NSData dataWithContentsOfURL:self.reviews[indexPath.item].user.imageURL];
        
        UIImage* image = [[UIImage alloc] initWithData:imageData];
        
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (cell.tag == indexPath.row) {
                    cell.personImageView.image = image;
                    [cell setNeedsLayout];
                }
            });
        }
    });
    
    [cell setUp:self.reviews[indexPath.item]];
    
    
    return cell;
}

@end
