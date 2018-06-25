//
//  ViewController.m
//  GRKeychain
//
//  Created by Gray on 2018/6/25.
//  Copyright © 2018年 gray. All rights reserved.
//

#import "ViewController.h"
#import "GRKeychain.h"

@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *account;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *submit;
@property (weak, nonatomic) IBOutlet UILabel *status;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.account.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)submitAction:(id)sender {
    [[GRKeychain defaultService] updateKeychainWithAccount:self.account.text password:self.password.text resultBlock:^(BOOL success) {
        if (success) {
            self.status.text = @"操作成功";
        } else {
            self.status.text = @"操作失败";
        }
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [[GRKeychain defaultService] searchKeychainWithAccount:self.account.text resultBlock:^(NSDictionary *query, BOOL success) {
        if (success) {
            NSString *password = [query objectForKey:GRKeychainKeyForPassword];
            self.password.text = password;
            self.status.text = @"查询密码成功，已自动填充";
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
