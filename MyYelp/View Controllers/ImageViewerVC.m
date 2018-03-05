//
//  ImageViewerVC.m
//  MyYelp
//
//  Created by Deepak Venkatesh on 2018-03-04.
//  Copyright © 2018 Deepak Venkatesh. All rights reserved.
//

#import "ImageViewerVC.h"

@interface ImageViewerVC ()
@property (strong,nonatomic) UIImageView *imageView;
@property (strong,nonatomic) UIButton *exitButton;

@end

@implementation ImageViewerVC


//displays an image in full screen

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpView];
    [self setUpExitButton];
    [self setUpImageView];
    
}

-(void) setUpExitButton{
    self.exitButton = [UIButton new];
    [self.view addSubview:self.exitButton];
    [self.exitButton setImage:[UIImage imageNamed:@"leftArrow"] forState:UIControlStateNormal];
    self.exitButton.frame = CGRectMake(10, 10, 40, 40);
    self.exitButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.exitButton addTarget:self action:@selector(exitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

-(void) setUpImageView{
    self.imageView = [UIImageView new];
    [self.view addSubview:self.imageView];
    self.imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
    self.imageView.image = self.image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.imageView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
}

-(void) setUpView{
    self.view.backgroundColor = UIColor.blackColor;
}

-(void) exitButtonClicked{
    [self dismissViewControllerAnimated:true completion:nil];
}



@end
