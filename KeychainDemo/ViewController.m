//
//  ViewController.m
//  KeychainDemo
//
//  Created by ShanCheli on 2018/4/28.
//  Copyright © 2018年 ShanCheli. All rights reserved.
//

#import "ViewController.h"
#import "KeychainManager.h"

#define Keychain @"Keychain"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self saveData];
    
    [self getData];
    
    [self updateData];
    
    [self deleteData];

}

- (void)saveData {
    // 存储数据
    BOOL save = [KeychainManager keyChainSaveData:@"思念诉说，眼神多像云朵" withIdentifier:Keychain];
    if (save) {
        NSLog(@"存储成功");
    }else {
        NSLog(@"存储失败");
    }
}

- (void)getData {
    // 获取数据
    NSString * readString = [KeychainManager keyChainReadData:Keychain];
    NSLog(@"获取得到的数据:%@",readString);
}

- (void)updateData {
    // 更新数据
    BOOL updata = [KeychainManager keyChainUpdata:@"长发落寞，我期待的女孩" withIdentifier:Keychain];
    if (updata) {
        NSLog(@"更新成功");
    }else{
        NSLog(@"更新失败");
    }
    // 读取数据
    NSString * readUpdataString = [KeychainManager keyChainReadData:Keychain];
    NSLog(@"获取更新后得到的数据:%@",readUpdataString);
}

- (void)deleteData {
    // 删除数据
    [KeychainManager keyChainDelete:Keychain];

    // 读取数据
    NSString * readDeleteString = [KeychainManager keyChainReadData:Keychain];
    NSLog(@"获取删除后得到的数据:%@",readDeleteString);
}

@end
