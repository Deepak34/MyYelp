//
//  MyYelpTests.m
//  MyYelpTests
//
//  Created by Deepak Venkatesh on 2018-03-04.
//  Copyright © 2018 Deepak Venkatesh. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HomeVC.h"
#import <YelpAPI/YLPClient.h>
#import <YelpAPI/YLPClient+Search.h>
#import <YelpAPI/YLPCoordinate.h>
#import <YelpAPI/YLPBusiness.h>
#import <YelpAPI/YLPSearch.h>
#import <YelpAPI/YLPLocation.h>


@interface HomeVCTests : XCTestCase<CLLocationManagerDelegate>{
    
    XCTestExpectation *locationManagerExpectation;
    YLPClient *client;
    YLPCoordinate *currentLocation;
}
@end

@implementation HomeVCTests


- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    client = [YLPClient alloc];
    currentLocation = [[YLPCoordinate alloc] initWithLatitude:43.6159241 longitude:-79.7371815];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    client = nil;
    currentLocation = nil;
}

- (void)testLocationManager{
    CLLocationManager *locationManager;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];
    locationManagerExpectation = [self expectationWithDescription:@"server responded"];
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Server Timeout Error: %@", error);
        }
    }];
    XCTAssert(YES, @"Pass");
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [manager stopUpdatingLocation];
    [locationManagerExpectation fulfill];
    XCTAssertNotNil(locations,@"Location object is nil");
}

-(void) testRestaurantSearch{
    NSString *searchTerm = @"pasta";

    [client searchWithCoordinate:currentLocation term:nil limit:10 offset:0 sort:YLPSortTypeDistance completionHandler:^(YLPSearch * _Nullable search, NSError * _Nullable error) {
        XCTAssertNotNil(search,@"Search object is nil");
    }];
    
    [client searchWithCoordinate:currentLocation term:nil limit:10 offset:0 sort:YLPSortTypeBestMatched completionHandler:^(YLPSearch * _Nullable search, NSError * _Nullable error) {
        XCTAssertNotNil(search,@"Search object is nil");
    }];
    
    [client searchWithCoordinate:currentLocation term:nil limit:10 offset:0 sort:YLPSortTypeHighestRated completionHandler:^(YLPSearch * _Nullable search, NSError * _Nullable error) {
        XCTAssertNotNil(search,@"Search object is nil");
    }];
    
    [client searchWithCoordinate:currentLocation term:searchTerm limit:10 offset:0 sort:YLPSortTypeDistance completionHandler:^(YLPSearch * _Nullable search, NSError * _Nullable error) {
        XCTAssertNotNil(search,@"Search object is nil");
    }];
    
    [client searchWithCoordinate:currentLocation term:searchTerm limit:10 offset:0 sort:YLPSortTypeBestMatched completionHandler:^(YLPSearch * _Nullable search, NSError * _Nullable error) {
        XCTAssertNotNil(search,@"Search object is nil");
    }];
    
    [client searchWithCoordinate:currentLocation term:searchTerm limit:10 offset:0 sort:YLPSortTypeHighestRated completionHandler:^(YLPSearch * _Nullable search, NSError * _Nullable error) {
        XCTAssertNotNil(search,@"Search object is nil");
    }];
    
}

- (void) testPictureDownload{

    [client searchWithCoordinate:currentLocation term:nil limit:10 offset:0 sort:YLPSortTypeHighestRated completionHandler:^(YLPSearch * _Nullable search, NSError * _Nullable error) {
        YLPBusiness *business = search.businesses[0];
         dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^(void) {
            
            NSData *imageData = [NSData dataWithContentsOfURL:business.imageURL];
            XCTAssertNotNil(imageData,@"Image data is nil");
        });
        
    }];
}

- (void) testDistanceFunction{

    [client searchWithCoordinate:currentLocation term:nil limit:10 offset:0 sort:YLPSortTypeHighestRated completionHandler:^(YLPSearch * _Nullable search, NSError * _Nullable error) {
        YLPBusiness *business = search.businesses[0];
        CLLocation *locA = [[CLLocation alloc] initWithLatitude:business.location.coordinate.latitude longitude:business.location.coordinate.longitude];
         CLLocation *locB = [[CLLocation alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude];
        CLLocationDistance distance = [locA distanceFromLocation:locB];
        XCTAssertTrue(distance >= 0);
        
    }];
}

@end

