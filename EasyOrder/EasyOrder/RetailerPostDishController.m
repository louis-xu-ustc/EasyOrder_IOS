//
//  RetailerPostDishController.m
//  EasyOrder
//
//  Created by Yu Zhou on 7/23/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "RetailerPostDishController.h"

@interface RetailerPostDishController ()

@end

@implementation RetailerPostDishController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    // Dismiss the image picker.
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.imageView setImage:image];
    
    if (self.imagePickerController.sourceType==UIImagePickerControllerSourceTypeCamera) {
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    
    self.imagePickerController = nil;
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType fromButton:(UIButton *)button {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    //imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    imagePickerController.modalPresentationStyle =
    (sourceType == UIImagePickerControllerSourceTypeCamera) ? UIModalPresentationFullScreen : UIModalPresentationPopover;
    
    UIPopoverPresentationController *presentationController = imagePickerController.popoverPresentationController;
    //presentationController.barButtonItem = button;
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    _imagePickerController = imagePickerController;
    
    [self presentViewController:self.imagePickerController animated:YES completion:^{
        //.. done presenting
    }];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self dismissViewControllerAnimated:YES completion:^{
        //.. done dismissing
    }];
    self.imagePickerController = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)postDish:(id)sender {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURL *url = [NSURL URLWithString:@"http://54.202.127.83/backend/dish/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"Human4" forKey:@"name"];
    [params setValue:[NSNumber numberWithInt:14] forKey:@"price"];
    [params setValue:[UIImagePNGRepresentation(_imageView.image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] forKey:@"photo"];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    [request setHTTPBody:data];
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    }];
    [task resume];
}

- (IBAction)takePhoto:(id)sender {
    if([UIImagePickerController isSourceTypeAvailable:
        UIImagePickerControllerSourceTypeCamera])
        
    {[self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera fromButton:sender];}
    else NSLog(@"carmera not available");
}

- (IBAction)findPhoto:(id)sender {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary fromButton:sender];
}
@end
