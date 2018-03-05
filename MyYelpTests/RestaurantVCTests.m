//
//  RestaurantVCTests.m
//  MyYelpTests
//
//  Created by Deepak Venkatesh on 2018-03-05.
//  Copyright © 2018 Deepak Venkatesh. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RestaurantVC.h"
#import <YelpAPI/YLPClient.h>
#import <YelpAPI/YLPClient+Search.h>
#import <YelpAPI/YLPCoordinate.h>
#import <YelpAPI/YLPBusiness.h>
#import <YelpAPI/YLPSearch.h>
#import <YelpAPI/YLPLocation.h>
#import <YelpAPI/YLPClient+Business.h>
#import <YelpAPI/YLPClient+Reviews.h>
#import <YelpAPI/YLPUser.h>
#import <YelpAPI/YLPBusinessReviews.h>
#import <YelpAPI/YLPReview.h>

@interface RestaurantVCTests : XCTestCase{
    YLPClient *client;
    YLPCoordinate *currentLocation;
}

@end

@implementation RestaurantVCTests

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

-(void)testGetMainImage{
    
    [client searchWithCoordinate:currentLocation term:nil limit:10 offset:0 sort:YLPSortTypeHighestRated completionHandler:^(YLPSearch * _Nullable search, NSError * _Nullable error) {
        YLPBusiness *business = search.businesses[0];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^(void) {
            
            NSData *imageData = [NSData dataWithContentsOfURL:business.imageURL];
            XCTAssertNotNil(imageData,@"Image data is nil");
        });
        
    }];
    
}

-(void)testGetImages{
    
    [client businessWithId:@"gary-danko-san-francisco" completionHandler:^(YLPBusiness * _Nullable business, NSError * _Nullable error) {
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^(void) {
            
            int i = 0;
            
            for (i = 0; i < business.photos.count; i++){
                NSData *imageData = [NSData dataWithContentsOfURL: [NSURL URLWithString:business.photos[i]]];
                XCTAssertNotNil(imageData,@"Image data is nil");
                
                
            }
            
            
        });
        
    }];
}

-(void)testGetReviews{
    
    [client reviewsForBusinessWithId:@"gary-danko-san-francisco" completionHandler:^(YLPBusinessReviews * _Nullable reviews, NSError * _Nullable error) {
        
        XCTAssertNotNil(reviews.reviews,@"Reviews data is nil");
        
        
    }];
}

-(void) testGetUserPicture{
    
    
    [client reviewsForBusinessWithId:@"gary-danko-san-francisco" completionHandler:^(YLPBusinessReviews * _Nullable reviews, NSError * _Nullable error) {
        

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^(void) {
            
            NSData *imageData = [NSData dataWithContentsOfURL:reviews.reviews[0].user.imageURL];
            
            XCTAssertNotNil(imageData,@"Image data is nil");
        });
        
    }];
}

@end

