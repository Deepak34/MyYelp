//
//  ViewController.m
//  MyYelp
//
//  Created by Deepak Venkatesh on 2018-03-04.
//  Copyright © 2018 Deepak Venkatesh. All rights reserved.
//

#import "HomeVC.h"
#import <YelpAPI/YLPClient+PhoneSearch.h>
#import <YelpAPI/YLPSearch.h>
#import "AppDelegate.h"
#import <YelpAPI/YLPClient+Search.h>
#import <YelpAPI/YLPBusiness.h>
#import "RestaurantCell.h"
#import "RestaurantVC.h"
#import "Font.h"
#import <YelpAPI/YLPCoordinate.h>
#import <YelpAPI/YLPLocation.h>
@import CoreLocation;


@interface HomeVC (){
    YLPSortType sort;
    NSString *searchTerm;
    YLPBusiness *selectedBusiness;
    YLPCoordinate *currentLocation;
    CLLocationManager *locationManager;
    CGFloat cellHeight;
}
@property (nonatomic) YLPSearch *search;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIButton *bestMatchButton;
@property (strong, nonatomic) IBOutlet UIButton *distanceButton;
@property (strong, nonatomic) IBOutlet UIButton *ratingButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *sortButtons;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;


@property UISearchController *searchController;
@end

@implementation HomeVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    sort = YLPSortTypeBestMatched;
    cellHeight = 230;
    
    //default location is SceneDoc office location
    currentLocation = [[YLPCoordinate alloc] initWithLatitude:43.6159241 longitude:-79.7371815];
    
    //set up
   
    [self setUpSearchController];
    [self setUpView];
    [self setUpCollectionView];
    [self setUpSearchButtons];
    [self setUpLocationManager];
    [self formatSortButtons:_bestMatchButton];
}


//set up the location manager and get current location
-(void) setUpLocationManager{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];
}

//the delegate method for the location manager. When obtain location, stop updating and set currentLocation
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [manager stopUpdatingLocation];
    //store your location
    // self.location = [locations lastObject];
    currentLocation.latitude = locations.lastObject.coordinate.latitude;
    currentLocation.longitude = locations.lastObject.coordinate.longitude;
    [self searchForRestaurants];
    
    
}


//set up search bar.
-(void) setUpSearchController{
    self.searchController =  [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.obscuresBackgroundDuringPresentation = false;
    self.searchController.searchBar.placeholder = @"Search for restaurants close to you!";
    self.searchController.hidesNavigationBarDuringPresentation = false;
    self.searchController.searchBar.barTintColor = UIColor.groupTableViewBackgroundColor;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleDefault;
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = true;
    [self.searchController.searchBar sizeToFit];
}

//set up collection view and the item size of the cells
-(void) setUpCollectionView{
    self.collectionView.scrollEnabled = false;
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setShowsVerticalScrollIndicator:false];
    [self.collectionView setBackgroundColor:UIColor.groupTableViewBackgroundColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"RestaurantCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width - 30, cellHeight);
}

//set up search buttons, mostly formatting.
-(void) setUpSearchButtons{
    int i = 0;
    
    for (i = 0; i < self.sortButtons.count; i++){
        UIButton *button = self.sortButtons[i];
        [button setContentEdgeInsets:UIEdgeInsetsMake(5, 7, 5, 7)];
        [button setClipsToBounds:true];
        [button.layer setCornerRadius:5];
    }
}

//set up view and the navigation bar
-(void) setUpView{
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    self.navigationItem.titleView = self.searchController.searchBar;
    self.navigationController.navigationBar.tintColor = UIColor.blackColor;
    
}

//this is called when the sort buttons are clicked. Format them accordingly.
- (void) formatSortButtons: (UIButton *) selectedButton{
    
    int i = 0;
    
    for (i = 0; i < self.sortButtons.count; i++){
        UIButton *button = self.sortButtons[i];
        [button setBackgroundColor:UIColor.groupTableViewBackgroundColor];
        [button setTitleColor:UIColor.orangeColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    }
    
    [selectedButton setBackgroundColor:UIColor.orangeColor];
    selectedButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    [selectedButton setTitleColor:UIColor.groupTableViewBackgroundColor forState:UIControlStateNormal];
    
}

//this is called when the sort buttons are clicked. Change the sort, refresh the formatting, and search.
- (IBAction)changeSort:(UIButton *)sender {
    if (sender == self.distanceButton){
        sort = YLPSortTypeDistance;
    }
    else if (sender == self.bestMatchButton){
        sort = YLPSortTypeBestMatched;
    }
    else{
        sort = YLPSortTypeHighestRated;
    }
    [self formatSortButtons:sender];
    [self searchForRestaurants];
   
}

//the basic search function. takes location, searchText, and sort as parameters.
-(void) searchForRestaurants{

    [[AppDelegate sharedClient] searchWithCoordinate:currentLocation term:searchTerm limit:10 offset:0 sort:sort completionHandler:^(YLPSearch * _Nullable search, NSError * _Nullable error) {
        self.search = search;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            self.collectionViewHeight.constant = cellHeight*(self.search.businesses.count + 1);
        });
    }];
    
   
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    searchTerm = searchText;
    [self searchForRestaurants];
    
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchTerm = nil;
    [self searchForRestaurants];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.search.businesses.count;
}

/*set up the cell. assign values accordingly. Get the restaurant picture in a high priority background thread,
then assign it to the cell imageView in the main thread, if the cell is still being displayed
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantCell *cell = (RestaurantCell*) [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    
    YLPBusiness *business = self.search.businesses[indexPath.item];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^(void) {
        
        NSData *imageData = [NSData dataWithContentsOfURL:business.imageURL];
        
        UIImage* image = [[UIImage alloc] initWithData:imageData];
        
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (cell.tag == indexPath.row) {
                    cell.imageView.image = image;
                    [cell setNeedsLayout];
                }
            });
        }
    });
    
    cell.nameLabel.text = business.name;
    cell.starView.rating = business.rating;
    
    NSString *reviewCount = [NSString stringWithFormat: @"%ld reviews", (long)self.search.businesses[indexPath.item].reviewCount];
    cell.numberOfReviewsLabel.text = reviewCount;
    
    cell.distanceLabel.text = [NSString stringWithFormat:@"%0.1f km",[self getBusinessDistance:business]/1000];
    
    return cell;
}

//get the distance between the current location, and a restaurant
-(CLLocationDistance) getBusinessDistance:(YLPBusiness*)business{
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:business.location.coordinate.latitude longitude:business.location.coordinate.longitude];
    
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude];
    
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    
    return distance;
}

//if a cell is clicked, go to the RestaurantVC, passing the selected business as data
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    selectedBusiness = self.search.businesses[indexPath.item];
    [self performSegueWithIdentifier:@"toRestaurant" sender:nil];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    RestaurantVC *vc = (RestaurantVC*) segue.destinationViewController;
    vc.restaurant = selectedBusiness;
    vc.distance = [self getBusinessDistance:selectedBusiness];
}

@end

