//
//  RetailerPostDishController.m
//  EasyOrder
//
//  Created by Yu Zhou on 7/23/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "RetailerPostDishController.h"

@interface RetailerPostDishController () {
    UIActivityIndicatorView *spinner;
}

@end

@implementation RetailerPostDishController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    spinner.backgroundColor = UIColor.lightGrayColor;
    spinner.alpha = 0.5;
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    spinner.hidesWhenStopped = YES;
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
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"dishPostDialog"];
    UITextField *dishName = [controller.view viewWithTag:1];
    UITextField *dishPrice = [controller.view viewWithTag:2];
    CGRect rect = CGRectMake(0, 0, 330, 350);
    [controller setPreferredContentSize:rect.size];
    UIAlertController *dialog = [UIAlertController alertControllerWithTitle:@"Enter Dish Information" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [dialog setValue:controller forKey:@"contentViewController"];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [spinner startAnimating];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURL *url = [NSURL URLWithString:@"http://54.202.127.83/backend/dish/"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPMethod:@"POST"];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:dishName.text forKey:@"name"];
        [params setValue:[NSNumber numberWithDouble:[dishPrice.text doubleValue]] forKey:@"price"];
        [params setValue:[UIImagePNGRepresentation(_imageView.image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] forKey:@"photo"];
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
        [request setHTTPBody:data];
        NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [spinner stopAnimating];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }];
        [task resume];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [dialog addAction:confirm];
    [dialog addAction:cancel];
    [self presentViewController:dialog animated:YES completion:nil];
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
