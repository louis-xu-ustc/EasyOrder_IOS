//
//  RetailerPostDishController.h
//  EasyOrder
//
//  Created by Yu Zhou on 7/23/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RetailerPostDishController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic) UIImagePickerController *imagePickerController;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)postDish:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)findPhoto:(id)sender;

@end
