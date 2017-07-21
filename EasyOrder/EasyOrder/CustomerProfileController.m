//
//  CustomerProfileController.m
//  EasyOrder
//
//  Created by Yu Zhou on 7/14/17.
//  Copyright © 2017 Carnegie Mellon University. All rights reserved.
//

#import "CustomerProfileController.h"
#import "CustomerTabBarController.h"

@interface CustomerProfileController ()
{
    __weak IBOutlet UIImageView *_profileImageView;
    __weak IBOutlet UILabel *_profileUserName;
}
@end

@implementation CustomerProfileController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:@"profileCell" forIndexPath:indexPath];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    // add a bottom border to the table view
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(0, _profileView.frame.size.height-bottomBorder.borderWidth, _profileView.frame.size.width, 1);
    _profileView.clipsToBounds = YES;
    [_profileView.layer addSublayer:bottomBorder];
    
    // set profile image and name
    CustomerTabBarController *controller = (CustomerTabBarController *)self.tabBarController;
    _profileUserName.text = controller.profileUserName;
    _profileImageView.image = controller.profileImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
