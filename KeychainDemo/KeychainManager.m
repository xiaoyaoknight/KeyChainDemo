//
//  KeychainManager.m
//  KeychainDemo
//
//  Created by ShanCheli on 2018/4/28.
//  Copyright © 2018年 ShanCheli. All rights reserved.
//

#import "KeychainManager.h"
#import <Security/Security.h>



@implementation KeychainManager


/*!
 创建生成保存数据查询条件
 
 kSecClass：条目类别
 
 kSecAttrGeneric：条目id
 
 kSecAttrService：条目所属服务
 
 kSecAttrAccount：条目所属账户名
 
 其中kSecAttrService和kSecAttrAccount在整个keychain里必须唯一，不能重名。
 
 */
+(NSMutableDictionary*) keyChainIdentifier:(NSString*)identifier {
    NSMutableDictionary *keyChainMutableDictionary = [NSMutableDictionary dictionary];
                                                                                                                                                                                                                                                                                                    
    //设置条目类别，我们用该条目存储普通密码，所以设置成kSecClassGenericPassword
    [keyChainMutableDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];

    //设置条目的id，比如“MyPasswordForFtp",条目id必须时NSDate，而不是NSString
//    NSData *itemID= [identifier dataUsingEncoding:NSUTF8StringEncoding];
//    [keyChainMutableDictionary setObject:itemID forKey:(id)kSecAttrGeneric];

    //设置条目所属的服务和账户，为了避免重名，我们使用常见的反转域名规则，比如com.mykeychain.ftppassword
    [keyChainMutableDictionary setObject:identifier forKey:(id)kSecAttrAccount];
    [keyChainMutableDictionary setObject:identifier forKey:(id)kSecAttrService];
    [keyChainMutableDictionary setObject:(id)kSecAttrAccessibleAfterFirstUnlock forKey:(id)kSecAttrAccessible];

    //设置查询条件，只返回一个条目
//    [keyChainMutableDictionary setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];

    //设置查询条件，返回条目存储的数据 （kSecReturnData == True）
//    [keyChainMutableDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    
    return keyChainMutableDictionary;
}

/*!
 保存数据
 */
+(BOOL) keyChainSaveData:(id)data withIdentifier:(NSString*)identifier{
    // 获取存储的数据的条件
    NSMutableDictionary * saveQueryMutableDictionary = [self keyChainIdentifier:identifier];
    // 删除旧的数据
    SecItemDelete((CFDictionaryRef)saveQueryMutableDictionary);
    // 设置新的数据
    [saveQueryMutableDictionary setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    // 添加数据
    OSStatus saveState = SecItemAdd((CFDictionaryRef)saveQueryMutableDictionary, nil);
    // 释放对象
    saveQueryMutableDictionary = nil ;
    // 判断是否存储成功
    if (saveState == errSecSuccess) {
        return YES;
    }
    return NO;
}

/*!
 读取数据
 */
+(id) keyChainReadData:(NSString*)identifier{
    id idObject = nil ;
    // 通过标记获取数据查询条件
    NSMutableDictionary * keyChainReadQueryMutableDictionary = [self keyChainIdentifier:identifier];
    // 这是获取数据的时，必须提供的两个属性
    // TODO: 查询结果返回到 kSecValueData
    [keyChainReadQueryMutableDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    // TODO: 只返回搜索到的第一条数据
    [keyChainReadQueryMutableDictionary setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    // 创建一个数据对象
    CFDataRef keyChainData = nil ;
    // 通过条件查询数据
    if (SecItemCopyMatching((CFDictionaryRef)keyChainReadQueryMutableDictionary , (CFTypeRef *)&keyChainData) == noErr){
        @try {
            idObject = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)(keyChainData)];
        } @catch (NSException * exception){
            NSLog(@"Unarchive of search data where %@ failed of %@ ",identifier,exception);
        }
    }
    if (keyChainData) {
        CFRelease(keyChainData);
    }
    // 释放对象
    keyChainReadQueryMutableDictionary = nil;
    // 返回数据
    return idObject ;
}

/*!
 更新数据
 
 @data  要更新的数据
 @identifier 数据存储时的标示
 */
+(BOOL)keyChainUpdata:(id)data withIdentifier:(NSString*)identifier {
    // 通过标记获取数据更新的条件
    NSMutableDictionary * keyChainUpdataQueryMutableDictionary = [self keyChainIdentifier:identifier];
    // 创建更新数据字典
    NSMutableDictionary * updataMutableDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    // 存储数据
    [updataMutableDictionary setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    // 获取存储的状态
    OSStatus  updataStatus = SecItemUpdate((CFDictionaryRef)keyChainUpdataQueryMutableDictionary, (CFDictionaryRef)updataMutableDictionary);
    // 释放对象
    keyChainUpdataQueryMutableDictionary = nil;
    updataMutableDictionary = nil;
    // 判断是否更新成功
    if (updataStatus == errSecSuccess) {
        return  YES ;
    }
    return NO;
}



/*!
 删除数据
 */
+(void) keyChainDelete:(NSString*)identifier {
    // 获取删除数据的查询条件
    NSMutableDictionary * keyChainDeleteQueryMutableDictionary = [self keyChainIdentifier:identifier];
    // 删除指定条件的数据
    SecItemDelete((CFDictionaryRef)keyChainDeleteQueryMutableDictionary);
    // 释放内存
    keyChainDeleteQueryMutableDictionary = nil ;
}

@end
