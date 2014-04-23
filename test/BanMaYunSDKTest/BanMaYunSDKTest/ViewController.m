//
//  ViewController.m
//  BanmayunSDKTest
//
//  Copyright (c) 2014年 Banmayun. All rights reserved.
//

#import "ViewController.h"
#import "BMYRestClient.h"
#import "NSObject+BMYJSON.h"
#import "BMYUser.h"
#import "BMYLink.h"
#import "BMYResultList.h"
#import "BMYUserRole.h"
#import "BMYRelationRole.h"
#import "BMYGroup.h"
#import "BMYGroupType.h"
#import "BMYRoot.h"
#import "BMYComment.h"
#import "BMYShare.h"
#import "BMYTrash.h"
#import "BMYMetadata.h"

#define USER_ACCESS_TOKEN @"accessToken"

@interface ViewController () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSMutableData *receivedData;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    
    BMYRestClient *restclient = [[BMYRestClient alloc] initWithSession:nil];
    restclient.delegate = self;
    
    NSString *token = @"2yn4a8z2qefyx66dfxhrz5i53z";
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:USER_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    /* Test Create User */
    //    NSString *name = @"CuiShengLi";
    //    NSString *passwd = @"123456";
    //    NSString *email = @"cumt0516@gmail.com";
    //    NSString *displayname = @"testBanMaYunSDKtest";
//    [restclient createUser:name password:passwd email:email displayName:displayname source:@"hehe" groupsCanOwn:nil role:nil];
    
    /* Test SignIn */
    //    NSString *username = @"testSDK";
    //    NSString *password = @"123456";
    //    NSString *linkname = @"";
    //    NSString *linkDevice = @"phone_ios";
    //    [restclient signInWithUsername:username passwd:password linkName:linkname linkDevice:linkDevice ldapName:nil];
    
    // 管理员账户CuiShengLi
    //    NSString *username = @"CuiShengLi";
    //    NSString *password = @"123456";
    //    NSString *linkname = @"随便的LinkName";
    //    NSString *linkDevice = @"phone_ios";
    //    [restclient signInWithUsername:username passwd:password linkName:linkname linkDevice:linkDevice ldapName:nil];
    
    /* Test SignOut */
    //    NSString *token = @"s2uviqfrh69je3jz5igc7dayve";
    //    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"accessToken"];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    //    [NSThread sleepForTimeInterval:5];
    //    [restclient signOut];
    
    /* Change User Password */
    //    NSString *username = @"testSDK";
    //    NSString *password = @"";
    //    NSString *newPasswd = @"123456";
    //    [restclient changePassword:username oldPassword:password newPassword:newPasswd];
    
    /* Forgot User Password */
    //    NSString *email = @"cumt0516@gmail.com";
    //    [restclient forgotPassword:email];
    
    /* Reset User Password */
    //    NSString *token = @"8xehuzxk8e9s36tr5sdcfepz89";
    //    [[NSUserDefaults standardUserDefaults] setObject:token forKey:USER_ACCESS_TOKEN];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    //    NSString *newPassword = @"654321";
    //    [restclient resetPassword:newPassword];
    
    
    /*
     User Authorized Device Interface
     */
    
    /* Get User Link */
    //    NSString *userId = @"3rzznz12d9wd";
    //    NSString *deviceId = @"gackhe181z13";
    //    NSString *token = @"zrpydh54mpghn4mi9ikqvxkxm6";
    //    [[NSUserDefaults standardUserDefaults] setObject:token forKey:USER_ACCESS_TOKEN];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    //    [restclient getUserLink:userId linkId:deviceId];
    
    /* List User Links */
    //    NSString *userId = @"3rzznz12d9wd";
    //    [restclient listUserLinks:userId];
//    [restclient listUserLinks:userId offset:[NSNumber numberWithInteger:1] limit:[NSNumber numberWithInteger:1]];
    
    /* Delete User Link */
    //    NSString *userId = @"3rzznz12d9wd";
    //    NSString *linkId = @"g9sduh181rs9";
    //    [restclient deleteUserLink:userId linkId:linkId];
    
    /* Delete All User Links */
    //    NSString *userId = @"3rzznz12d9wd";
    //    [restclient deleteAllUserLinks:userId];
    
    /* Exists User */
    //    NSString *username = @"danteng0000";
    //    NSString *email = @"danteng00000@gmail.com";
    //    [restclient existsUser:username email:email];
    
    /* Get User */
    //    NSString *userId = @"3rzznz12d9wd";
    //    [restclient getUser:userId];
    
    /* List Users */
    //    [[NSUserDefaults standardUserDefaults] setObject:@"4uzfuujzc8ni45gfwvipp97np7" forKey:USER_ACCESS_TOKEN]; // 设置管理员账号的token
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    ////    [restclient listUsers];
//    [restclient listUsers:@"user" isActivated:[NSNumber numberWithBool:YES] isBlocked:[NSNumber numberWithBool:NO] offset:[NSNumber numberWithInteger:-10] limit:[NSNumber numberWithInteger:10]];
    
    /* Update User */
    //    NSString *userId = @"3rzznz12d9wd";
    //    NSString *displayname = @"testSDK";
//    [restclient updateUser:userId displayName:displayname groupsCanOwn:[NSNumber numberWithInteger:0] role:nil isBlocked:nil];
    
    //    [[NSUserDefaults standardUserDefaults] setObject:@"4uzfuujzc8ni45gfwvipp97np7" forKey:USER_ACCESS_TOKEN];  //设置管理员账号的token
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    //    NSString *userId = @"3rzznz12d9wd"; // 管理员账号的userId
    //    NSString *displayname = @"测试时设置回来的user";
    //    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
    //                          @"user", @"name",
    //                          @"用户", @"display_value",
    //                          nil];
    //    BMYUserRole *role = [[BMYUserRole alloc] initWithDictionary:dict];
//    [restclient updateUser:userId displayName:displayname groupsCanOwn:[NSNumber numberWithInteger:3] role:role isBlocked:nil];
    
    /* Verify User Email */
    //    NSString *userId = @"3rzznz12d9wd";
    //    [restclient verifyUserEmail:userId];
    
    /* Set User Password */
//        [[NSUserDefaults standardUserDefaults] setObject:@"4uzfuujzc8ni45gfwvipp97np7" forKey:USER_ACCESS_TOKEN];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        NSString *userId = @"3rzznz12d9wd";
//        NSString *newPassword = @"123456";
//        [restclient setUserPassword:userId newPassword:newPassword];
    
    
    
    /* Set User Avatar */
//    NSString *userId = @"3rzznz12d9wd";
//    NSMutableString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *avatarFile = [documentPath stringByAppendingPathComponent:@"avatar.jpg"];
//    NSData *data = [NSData dataWithContentsOfFile:avatarFile];
//    [restclient setUserAvatar:userId avatar:data format:@"jpg"];
    
    
    /* Get User Avatar */
//        NSString *userId = @"3rzznz12d9wd";
//        NSString *format = @"";
//        NSString *size = @"";
//        [restclient getUserAvatar:userId format:nil size:nil];
    
    /*
     User Group Interface
     */
    
    /* Add User Group */
//        NSString *userId = @"3s8wac12dets";
//        NSString *groupId = @"28y1mk11mnrq";
//        NSString *remark = @"test测试add to a group";
//        [restclient addUserGroup:userId groupId:groupId remarks:remark isFromAdmin:NO role:nil];
    
//        NSString *userId = @"3rzznz12d9wd";     // For Admin
//        NSString *groupId = @"28y1mk11mnrq";
//        NSString *remark = @"hehe";
//        [[NSUserDefaults standardUserDefaults] setObject:@"4uzfuujzc8ni45gfwvipp97np7" forKey:USER_ACCESS_TOKEN];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        NSMutableDictionary *roleDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                         @"member", @"name",
//                                         @"普通成员", @"display_value",
//                                         nil];
//        BMYRelationRole *role = [[BMYRelationRole alloc] initWithDictionary:roleDict];
//        [restclient addUserGroup:userId groupId:groupId remarks:remark role:role];
    
    /* Get User Group */
//        NSString *userId = @"3rzznz12d9wd";
//        NSString *groupId = @"28y1mk11mnrq";
//        [restclient getUserGroup:userId groupId:groupId];
    
    /* List User Groups */
//        NSString *userId = @"3rzznz12d9wd";
//        NSString *role = @"member";
//        BOOL isActivated = YES;
//        BOOL isBlocked = NO;
//        NSInteger offset = 0;
//        NSInteger limit = 3;
//        [restclient listUserGroups:userId];
//        [restclient listUserGroups:userId role:role];
//    [restclient listUserGroups:userId role:role isActivated:[NSNumber numberWithBool:isActivated] isBlocked:[NSNumber numberWithBool:isBlocked] offset:[NSNumber numberWithInteger:offset] limit:[NSNumber numberWithInteger:limit]];
    
    /* Update User Group */
//        [[NSUserDefaults standardUserDefaults] setObject:@"4uzfuujzc8ni45gfwvipp97np7" forKey:USER_ACCESS_TOKEN];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        NSString *userId = @"3rzznz12d9wd";
//        NSString *groupId = @"28y1mk11mnrq";
//        NSMutableDictionary *roleDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                         @"admin", @"name",
//                                         @"test管理员", @"display_value",
//                                         nil];
//        BMYRelationRole *role = [[BMYRelationRole alloc] initWithDictionary:roleDict];
//        [restclient updateUserGroup:userId groupId:groupId];
//    [restclient updateUserGroup:userId groupId:groupId role:role isActivated:[NSNumber numberWithBool:YES] isBlocked:[NSNumber numberWithBool:NO]];
    
    /* Remove User Group */
//        NSString *userId = @"3rzznz12d9wd";
//        NSString *groupId = @"28y1mk11mnrq";
//        [restclient removeUserGroup:userId groupId:groupId];
    
    /*
     Group Interface
     */
    
    /* Exists Group */
//        NSString *groupName = @"测试群组名";
//        [restclient existsGroup:groupName];
    
    
    /* Create Group */
//        NSString *groupName = @"测试群组名";
//        NSMutableDictionary *typeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                          @"public", @"name",
//                                          @"公开群组", @"display_value",
//                                          nil];
//        BMYGroupType *type = [[BMYGroupType alloc] initWithDictionary:typeDict];
//        BOOL isVisible = YES;
//        NSString *intro = @"测试群组";
//        NSString *tags = @"测试 test";
//        NSString *announceString = @"不知道啊";
//        [restclient createGroup:groupName type:type isVisible:isVisible];
    
    //    // 对管理员
//        [[NSUserDefaults standardUserDefaults] setObject:@"4uzfuujzc8ni45gfwvipp97np7" forKey:USER_ACCESS_TOKEN];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        NSString *ownerId = @"3rzznz12d9wd";
//        NSString *groupName = @"管理员创建的测试群组";
//        NSMutableDictionary *typeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                          @"public", @"name",
//                                          @"公开群组", @"display_value",
//                                          nil];
//        BMYGroupType *type = [[BMYGroupType alloc] initWithDictionary:typeDict];
//        BOOL isVisible = YES;
//        NSString *intro = @"管理员创建的群组";
//        NSString *tags = @"管理员创建, 群组";
//        NSString *announce = @"sheneme ";
//        NSString *source = @"";
//    [restclient createGroup:groupName type:type isVisible:[NSNumber numberWithBool:isVisible] intro:intro tags:tags announce:announce ownerId:ownerId source:source];
    
    /* Get Group */
//        NSString *groupId = @"28fte911mehi";
//        [[NSUserDefaults standardUserDefaults] setObject:@"4uzfuujzc8ni45gfwvipp97np7" forKey:USER_ACCESS_TOKEN];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        [restclient getGroup:groupId];
    
    /* List Groups */
//        NSString *type = @"public";
//        [restclient listGroups];
//    [restclient listGroups:type isAcivated:[NSNumber numberWithBool:NO] isBlocked:[NSNumber numberWithBool:NO] offset:[NSNumber numberWithInteger:0] limit:[NSNumber numberWithInteger:1]];
    
    /* Update Group */
//        NSString *groupId = @"28fte911mehi";
//        NSMutableDictionary *typeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                         @"private", @"name",
//                                         @"私有群组", @"diaplay_value",
//                                         nil];
//        BMYGroupType *type = [[BMYGroupType alloc] initWithDictionary:typeDict];
//        BOOL isVisible = YES;
//        NSString *intro = @"呵呵呵";
//        NSString *tags = @"私有群 ";
//        NSString *announce = @"公告";
//        [restclient updateGroup:groupId type:type isVisible:isVisible isFromAdmin:NO usingIsBlocked:YES isBlocked:NO];
//        [restclient updateGroup:groupId type:type isVisible:isVisible];
//        [restclient updateGroup:groupId type:type isVisible:isVisible intro:intro tags:tags announce:announce isFromAdmin:NO usingIsBlocked:YES isBlocked:NO];
    //
    //    // 对管理员
//        [[NSUserDefaults standardUserDefaults] setObject:@"4uzfuujzc8ni45gfwvipp97np7" forKey:USER_ACCESS_TOKEN];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        NSString *groupId = @"28fte911mehi";
//        NSMutableDictionary *typeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                         @"public", @"name",
//                                         @"公有群组", @"diaplay_value",
//                                         nil];
//        BMYGroupType *type = [[BMYGroupType alloc] initWithDictionary:typeDict];
//        BOOL isVisible = YES;
//        NSString *intro = @"呵呵呵";
//        NSString *tags = @"公有群 ";
//        NSString *announce = @"公告";
//    [restclient updateGroup:groupId type:type isVisible:[NSNumber numberWithBool:isVisible] isBlocked:[NSNumber numberWithBool:YES]];
//    [restclient updateGroup:groupId type:type isVisible:[NSNumber numberWithBool:isVisible]];
//    [restclient updateGroup:groupId type:type isVisible:[NSNumber numberWithBool:isVisible] intro:intro tags:tags announce:announce isBlocked:[NSNumber numberWithBool:isBlocked]];
    
    /* Delete Group */
//        NSString *groupId = @"28fte911mehi";
//        [restclient deleteGroup:groupId];

    
    /*
     Group Logo Interface
     */
    
    /* Set Group Logo */
//        NSString *groupId = @"28pnax11mimx";
//        NSMutableString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        NSString *logoPath = [documentPath stringByAppendingPathComponent:@"avatar.jpg"];
//        NSData *groupLogoData = [NSData dataWithContentsOfFile:logoPath];
//        [restclient setGroupLogo:groupId logo:groupLogoData format:@"jpg"];
    
    /* Get Group Logo */
//        NSString *groupId = @"28pnax11mimx";
//        NSString *format = @"png";
//        NSString *size = @"";
//        [restclient getGroupLogo:groupId format:format size:nil];
    
    /*
     Group User Interface
     */
    
    /* Add Group User */
//        NSString *groupId = @"28pnax11mimx";
//        NSString *userId = @"3rg8m812d1nq";
//        [[NSUserDefaults standardUserDefaults] setObject:@"4uzfuujzc8ni45gfwvipp97np7" forKey:USER_ACCESS_TOKEN];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        [restclient addGroupUser:groupId userId:userId];
    
    /* Get Group User */
//        NSString *groupId = @"28pnax11mimx";
//        NSString *userId = @"3rzznz12d9wd";
//        [restclient getGroupUser:groupId userId:userId];
    
    /* List Group Users */
//        NSString *groupId = @"";
//        NSString *role = @"member";
//        [restclient listGroupUsers:groupId];
//    [restclient listGroupUsers:groupId role:role isActivated:[NSNumber numberWithBool:YES] isBlocked:[NSNumber numberWithBool:YES] offset:[NSNumber numberWithInteger:0] limit:[NSNumber numberWithInteger:0]];
    
    /* Update Group User */
//        NSString *groupId = @"28pnax11mimx";
//        NSString *userId = @"3rzznz12d9wd";
//        [[NSUserDefaults standardUserDefaults] setObject:@"4uzfuujzc8ni45gfwvipp97np7" forKey:USER_ACCESS_TOKEN];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        NSMutableDictionary *roleDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                         @"owner", @"name",
//                                         @"普通用户", @"display_value",
//                                         nil];
//        BMYRelationRole *role = [[BMYRelationRole alloc] initWithDictionary:roleDict];
//        [restclient updateGroupUser:groupId userId:userId];
//    [restclient updateGroupUser:groupId userId:userId role:role isActivated:[NSNumber numberWithBool:YES] isBlocked:[NSNumber numberWithBool:NO]];
    
    /* Remove Group User */
//        NSString *groupId = @"28pnax11mimx";
//        NSString *userId = @"3rg8m812d1nq";
//        [restclient removeGroupUser:groupId userId:userId];
    
    /* Get Root */
//        NSString *rootId = @"42q89f12i2za";
//        [restclient getRoot:rootId];
    
    
    /* Set Default Permission */
//        NSString *root_id = @"42q89f12i2za";
//    [restclient setDefaultPermission:root_id insertableToOwner:[NSNumber numberWithBool:YES] readableToOwner:[NSNumber numberWithBool:YES] writableToOwner:[NSNumber numberWithBool:YES] deletableToOwner:[NSNumber numberWithBool:NO] insertableToOthers:[NSNumber numberWithBool:YES] readableToOthers:[NSNumber numberWithBool:YES] writableToOthers:[NSNumber numberWithBool:NO] deletableToOthers:[NSNumber numberWithBool:NO]];
    
    /* Set Root Quota */
//        NSString *rootId = @"42q89f12i2za";
//        [[NSUserDefaults standardUserDefaults] setObject:@"4uzfuujzc8ni45gfwvipp97np7" forKey:USER_ACCESS_TOKEN];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        NSString *quota = @"1 GB";
//        [restclient setRootQuota:rootId quota:quota];
    
    /*
     File Interface
     */
    
    /* Put File by Path */
//    NSString *rootId = @"42q89f12i2za";
//    NSString *path = @"test.txt";
//    NSString *docPath = NSHomeDirectory();
//    NSString *testFilePath = [docPath stringByAppendingPathComponent:@"documents/test.txt"];
//    [restclient putFileByPathWithRootId:rootId path:path modifiedAtMillis:[NSNumber numberWithLong:12331243124312] overwrite:[NSNumber numberWithBool:NO] fromPath:testFilePath];
    
    /* Get File by Path */
//    NSString *rootId = @"42q89f12i2za";
//    NSString *path = @"test.txt";
//    NSString *tmpFolderPath = NSTemporaryDirectory();
//    NSString *tmpTestFilePath = [tmpFolderPath stringByAppendingPathComponent:@"tempTestFile.txt"];
//    [restclient getFileBypathWithRootId:rootId path:path toPath:tmpTestFilePath];
//    [restclient getFileByPathWithRootId:rootId path:path version:nil offset:[NSNumber numberWithInteger:0] bytes:nil toPath:tmpTestFilePath];
    
    /* Trash File by Path */
//    NSString *rootId = @"42q89f12i2za";
//    NSString *path = @"aaa.txt";
//    [restclient trashFileByPathWithRootId:rootId path:path];
    
    /* Comment Interface */
    
    /* Create Comment */
//        NSString *rootId = @"42q89f12i2za";
//        NSString *metaId = @"ehgtq53642cg";
//        NSString *contents = @"好啊";
//        [restclient createComment:rootId metaId:metaId contents:contents];
    
    /* Get Comment */
//        NSString *rootId = @"42q89f12i2za";
//        NSString *metaId =  @"ehgtq53642cg";
//        NSString *commentId = @"1xz7fs11grq3";
//        [restclient getComment:rootId metaId:metaId commentId:commentId];
    
    /* List Comments */
//        NSString *rootId = @"42q89f12i2za";
//        NSString *metaId = @"ehgtq53642cg";
//        NSInteger offset = 0;
//        NSInteger limit = 0;
//        [restclient listComments:rootId metaId:metaId];
//    [restclient listComments:rootId metaId:metaId offset:[NSNumber numberWithInteger:0] limit:nil];
    
    /* Delete Comment */
//        NSString *rootId = @"42q89f12i2za";
//        NSString *metaId = @"ehgtq53642cg";
//        NSString *commentId = @"1y8cvg11gvu8";
//        [restclient deleteComment:rootId metaId:metaId commentId:commentId];
    
    /* Delete All Comments */
//        NSString *rootId = @"42q89f12i2za";
//        NSString *metaId = @"ehgtq53642cg";
//        [restclient deleteAllComments:rootId metaId:metaId];
    
    /*
     Share Interface
     */
    
    /* Create Share */
//        NSString *rootId = @"42q89f12i2za";
//        NSString *metaId = @"ehgtq53642cg";
//        NSString *passwd = @"123456";
//        long expires_at_millis = 1222222341421512;
//    [restclient createShare:rootId metaId:metaId password:passwd expiresAt:[NSNumber numberWithLong:1222222341421512]];
    
    /* Get Share */
//    NSString *rootId = @"42q89f12i2za";
//    NSString *metaId = @"ehgtq53642cg";
//    NSString *shareId = @"4kwymqe7scwj";
//    [restclient getShare:rootId metaId:metaId shareId:shareId];
    
    /* List Shares */
//        NSString *rootId = @"42q89f12i2za";
//        NSString *metaId = @"ehgtq53642cg";
//        [restclient listShares:rootId metaId:metaId];
//    [restclient listShares:rootId metaId:metaId offset:[NSNumber numberWithInteger:0] limit:nil];
    
    /* Delete Share */
//        NSString *rootId = @"42q89f12i2za";
//        NSString *metaId = @"ehgtq53642cg";
//        NSString *shareId = @"4kwymqe7scwj";
//        [restclient deleteShare:rootId metaId:metaId shareId:shareId];
    
    /* Delete All Shares */
//        NSString *rootId = @"42q89f12i2za";
//        NSString *metaId = @"ehgtq53642cg";
//        [restclient deleteAllShares:rootId metaId:metaId];
    
    
    
    /*
     File Operation Interface
     */
    
    /* Fileops Get Meta */
//    NSString *rootId = @"42q89f12i2za";
//    NSString *path = @"test.txt";
//    [restclient getMetaOfFileOpsWithRootId:rootId path:path isListDirContent:[NSNumber numberWithBool:NO]];
    
    /* Fileops List Folder */
//    NSString *rootId = @"42q89f12i2za";
//    NSString *path = @"/";
//    [restclient listFolderOfFileOpsWithRootId:rootId path:path];
    /*
     Trash Interface
     */
    
    /* Get Trash */
//        NSString *rootId = @"42q89f12i2za";
//        NSString *trashId = @"41ejzg12hf67";
//        [restclient getTrash:rootId trashId:trashId];
    
    /* List Trashes */
//        NSString *rootId = @"42q89f12i2za";
//        [restclient listTrashes:rootId];
//    [restclient listTrashes:rootId offset:[NSNumber numberWithInteger:0] limit:nil];
    
    /* Delete Trash */
//        NSString *rootId = @"42q89f12i2za";
//        NSString *trashId = @"41ejzg12hf67";
//        [restclient deleteTrash:rootId trashId:trashId];
    
    /* Delete All Trashes */
//        NSString *rootId = @"42q89f12i2za";
//        [restclient deleteAllTrashes:rootId];
    
    
    /* Restore Trash */
    //    NSString *rootId = @"42q89f12i2za";
    //    NSString *trashId = @" ";
    //    NSString *toPath = nil;
    //    [restclient restoreTrash:rootId trashId:trashId toPath:toPath];
    
    /*
     Search Interface
     */
    
    /* Search Users */
//        NSString *query = @"test";
//        NSString *groupId = @"28pnax11mimx";
//        [[NSUserDefaults standardUserDefaults] setObject:@"4uzfuujzc8ni45gfwvipp97np7" forKey:USER_ACCESS_TOKEN];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        [restclient searchUsers:query];
//        [restclient searchUsers:query groupId:groupId];
//    [restclient searchUsers:query groupId:groupId offset:[NSNumber numberWithInteger:0] limit:nil];

    /* Search Groups */
//        NSString *query = @"test";
//        NSString *useId = @"3rzznz12d9wd";
//        [restclient searchGroups:query];
    //    [restclient searchGroups:query userId:userId];
//    [restclient searchGroups:query userId:userId offset:[NSNumber numberWithInteger:0] limit:nil];
    
    /* Search Files */
//        NSString *query = @"aaa";
//        NSString *rootId = @"42q89f12i2za";
//        NSString *path = nil;
//        [[NSUserDefaults standardUserDefaults] setObject:@"4uzfuujzc8ni45gfwvipp97np7" forKey:USER_ACCESS_TOKEN];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        [restclient searchFiles:query];
    //    [restclient searchFiles:query rootId:rootId path:path];
//    [restclient searchFiles:query rootId:rootId path:path offset:[NSNumber numberWithInteger:0] limit:nil];
    /*
     Top Interface
     */
    
    /* Top Users*/
//        NSString *orderBy = @"group_count";
//        [restclient topUsers:orderBy];
//    [restclient topUsers:orderBy offset:[NSNumber numberWithInteger:0] limit:nil];
    
    /* Top Groups */
//        NSString *orderBy = @"user_count";
//        [restclient topGroups:orderBy];
//    [restclient topGroups:orderBy offset:[NSNumber numberWithInteger:0] limit:nil];
    
    /* Top Files */
//        NSString *orderBy = @"comment_count";
//        NSString *rootId = @"42q89f12i2za";
//        [restclient topFiles:orderBy rootId:rootId];
//    [restclient topFiles:orderBy rootId:rootId offset:[NSNumber numberWithInteger:0] limit:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark - Auth Interface

/* Create User */
- (void)restClient:(BMYRestClient *)restClient createdUser:(BMYUser *)user
{
    NSLog(@"%@", [user JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient createUserFailedWithError:(NSError *)error
{
    NSLog(@"restClient:%@\n", [restClient description]);
    NSLog(@"error:%d, domain:%@ userInfo:%@", error.code, error.domain, error.userInfo.description);
}


/* Sign In */
- (void)restClient:(BMYRestClient *)restClient signedIn:(BMYLink *)link
{
    NSLog(@"SignIn Succeed: %@", [link JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient signInFailedWithError:(NSError *)error
{
    NSLog(@"SignIn Failed: %@", [error description]);
}


/* Sign Out */
- (void)restClient:(BMYRestClient *)restClient signedOut:(BMYLink *)link
{
    NSLog(@"SignOut Succeed: %@", [link JSONRepresentation]);
}


- (void)restClient:(BMYRestClient *)restClient signOutFailedWithError:(NSError *)error
{
    NSLog(@"SignOut Failed: %@", [error description]);
}


/* Change User Password */
- (void)restClient:(BMYRestClient *)restClient changedPassword:(BMYUser *)user
{
    NSLog(@"Change Password Succeed: %@", [user JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient changePasswordFailedWithError:(NSError *)error
{
    NSLog(@"Change Password Failed: %@", [error description]);
}

/* Forgot User Password */
- (void)restClient:(BMYRestClient *)restClient forgottenPassword:(BMYUser *)user
{
    NSLog(@"Forgot Passord Interface Called Succeed: %@", [user JSONRepresentation]);
}


- (void)restClient:(BMYRestClient *)restClient forgotPasswordFailedWithError:(NSError *)error
{
    NSLog(@"Forgot Password Interface Called Failed: %@", [error description]);
}


/* Reset User Password */
- (void)restClient:(BMYRestClient *)restClient resetPassword:(BMYUser *)user
{
    NSLog(@"Reset Password Succeed: %@", [user JSONRepresentation]);
}


- (void)restClient:(BMYRestClient *)restClient resetPasswordFailedWithError:(NSError *)error
{
    NSLog(@"Reset Password Failed: %@", [error description]);
}


#pragma mark -
#pragma mark - User Authorized Device Interface

/* Get User Link */
- (void)restClient:(BMYRestClient *)restClient gotUserLink:(BMYLink *)link
{
    NSLog(@"Get User Link Succeed: %@", [link JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient getUserLinkFailedWithError:(NSError *)error
{
    NSLog(@"Get User Link Failed: %@", [error description]);
}


/* List User Links */
- (void)restClient:(BMYRestClient *)restClient listedUserLinks:(BMYResultList *)resultList
{
    NSLog(@"List User Links Succeed: %@", [resultList JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient listUserLinksFailedWithError:(NSError *)error
{
    NSLog(@"List User Links Failed: %@", [error description]);
}

/* Delete User Link */
- (void)restClient:(BMYRestClient *)restClient deletedUserLink:(BMYLink *)link
{
    NSLog(@"Delete User Link Succeed: %@", [link JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient deleteUserLinkFailedWithError:(NSError *)error
{
    NSLog(@"Delete User Link Failed: %@", [error description]);
}


/* Delete All User Links */
- (void)restClientDeletedAllUserLinks:(BMYRestClient *)restClient
{
    NSLog(@"Delete All User Links Succeed: %@", restClient);
}

- (void)restClient:(BMYRestClient *)restClient deleteAllUserLinksFailedWithError:(NSError *)error
{
    NSLog(@"Delete All User Links Failed: %@", error.description);
}


/*
 User Interface
 */

/* Exists User */
- (void)restClient:(BMYRestClient *)restClient existedUser:(BMYUser *)user
{
    NSLog(@"Exists User Succeed: %@", [user JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient existsUserFailedWithError:(NSError *)error
{
    NSLog(@"Exists User Failed: %@", [error description]);
}


/* Get User */
- (void)restClient:(BMYRestClient *)restClient gotUser:(BMYUser *)user
{
    NSLog(@"Get User Succeed: %@", [user JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient getUserFailedWithError:(NSError *)error
{
    NSLog(@"Get User Failed: %@", [error description]);
}

/* List Users */
- (void)restClient:(BMYRestClient *)restClient listedUsers:(BMYResultList *)list
{
    NSLog(@"List Users Succeed: %@", [list JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient listUsersFailedWithError:(NSError *)error
{
    NSLog(@"List Users Failed: %@", [error description]);
}

/* Update User */
- (void)restClient:(BMYRestClient *)restClient updatedUser:(BMYUser *)user
{
    NSLog(@"Update User Succeed: %@", [user JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient updateUserFailedWithError:(NSError *)error
{
    NSLog(@"Update User Failed: %@", [error description]);
}


/* Verify User Email */
- (void)restClient:(BMYRestClient *)restClient verifiedUserEmail:(BMYUser *)user
{
    NSLog(@"Verfify User Email Succeed: %@", [user JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient verifyUserEmailFailedWithError:(NSError *)error
{
    NSLog(@"Verify User Email Failed: %@", error.description);
}

/* Set User Password */
- (void)restClient:(BMYRestClient *)restClient doneSetUserPassword:(BMYUser *)user
{
    NSLog(@"Set User Password Succeed: %@", [user JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient setUserPasswordFailedWithError:(NSError *)error
{
    NSLog(@"Set User Password Failed: %@", [error description]);
}


/* Set User Avatar */
- (void)restClientSetUserAvatar:(BMYRestClient *)restClient
{
    
    NSLog(@"Set User Avatar Succeed!");
}

- (void)restClient:(BMYRestClient *)restClient setUserAvatarFailedWithError:(NSError *)error
{
    NSLog(@"Set User Avatar Failed: %@", error.description);
}

/* Get User Avatar */
- (void)restClient:(BMYRestClient *)restClient gotUserAvatar:(NSData *)avatar
{
    NSLog(@"Get User Avatar Succeed! %@", avatar);
    if (avatar) {
        NSString *tmpPath = NSTemporaryDirectory();
        NSString *tmpAvatarFilePath = [tmpPath stringByAppendingPathComponent:@"tmpAvatar"];
        [avatar writeToFile:tmpAvatarFilePath atomically:YES];
    }
}

- (void)restClient:(BMYRestClient *)restClient getUserAvatarFailedWithError:(NSError *)error
{
    NSLog(@"Get User Avatar Failed: %@", [error description]);
}


/* Add User Group */
- (void)restClient:(BMYRestClient *)restClient addedUserGroup:(BMYGroup *)group
{
    NSLog(@"Add User Group Succeed: %@", [group JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient addUserGroupFailedWithError:(NSError *)error
{
    NSLog(@"Add User Group Failed: %@", [error description]);
}

/* Get User Group */
- (void)restClient:(BMYRestClient *)restClient gotUserGroup:(BMYGroup *)group
{
    NSLog(@"Get User Group Succeed: %@", [group JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient getUserGroupFailedWithError:(NSError *)error
{
    NSLog(@"Get User Group Failed: %@",  [error description]);
}

/* List User Groups */
- (void)restClient:(BMYRestClient *)restClient listedUserGroups:(BMYResultList *)groupList
{
    NSLog(@"List User Groups Succeed: %@", [groupList JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient listUserGroupsFailedWithError:(NSError *)error
{
    NSLog(@"List User Groups Failed: %@", [error description]);
}

/* Update User Group */
- (void)restClient:(BMYRestClient *)restClient updatedUserGroup:(BMYGroup *)group
{
    NSLog(@"Update User Group Succeed: %@", [group JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient updateUserGroupFailedWithError:(NSError *)error
{
    NSLog(@"Update User Group Failed: %@", [error description]);
}

/* Remove User Group */
- (void)restClient:(BMYRestClient *)restClient removedUserGroup:(BMYGroup *)group
{
    NSLog(@"Remove User Group Succeed: %@", [group JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient removeUserGroupFailedWithError:(NSError *)error
{
    NSLog(@"Remove User Group Failed: %@", [error description]);
}


/* Exists Group */
- (void)restClient:(BMYRestClient *)restClient existedGroup:(BMYGroup *)group
{
    NSLog(@"Exists Group Succeed: %@", [group JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient existsGroupFailedWithError:(NSError *)error
{
    NSLog(@"Exists Group Failed: %@", [error description]);
}


/* Create Group */
- (void)restClient:(BMYRestClient *)restClient createdGroup:(BMYGroup *)group
{
    NSLog(@"Create Group Succeed: %@", [group JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient createGroupFailedWithError:(NSError *)error
{
    NSLog(@"Create Group Failed: %@", [error description]);
}

/* Get Group */
- (void)restClient:(BMYRestClient *)restClient gotGroup:(BMYGroup *)group
{
    NSLog(@"Get Group Succeed: %@", [group JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient getGroupFailedWithError:(NSError *)error
{
    NSLog(@"Get Group Failed: %@", [error description]);
}

/* List Groups */
- (void)restClient:(BMYRestClient *)restClient listedGroups:(BMYResultList *)groupList
{
    NSLog(@"List Groups Succeed: %@", [groupList JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient listGroupsFailedWithError:(NSError *)error
{
    NSLog(@"List Groups Failed: %@", [error description]);
}

/* Update Group */
- (void)restClient:(BMYRestClient *)restClient updatedGroup:(BMYGroup *)group
{
    NSLog(@"Update Group Succeed: %@", [group JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient updateGroupFailedWithError:(NSError *)error
{
    NSLog(@"Update Group Failed: %@", [error description]);
}

/* Delete Group */
- (void)restClient:(BMYRestClient *)restClient deletedGroup:(BMYGroup *)group
{
    NSLog(@"Delete Group Succeed: %@", [group JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient deleteGroupFailedWithError:(NSError *)error
{
    NSLog(@"Delete Group Failed: %@", [error description]);
}

/* Set Group Logo */
- (void)restClientDoneSetGroupLogo:(BMYRestClient *)restClient
{
    NSLog(@"Set Group Logo Succeed");
}

- (void)restClient:(BMYRestClient *)restClient setGroupLogoFailedWithError:(NSError *)error
{
    NSLog(@"Set Group Logo Failed: %@", [error description]);
}

/* Get Group Logo */
- (void)restClient:(BMYRestClient *)restClient gotGroupLogo:(NSData *)groupLogo
{
    NSLog(@"Get Group Logo Succeed: %@", groupLogo);
    if (groupLogo) {
        NSString *tmpPath = NSTemporaryDirectory();
        NSString *logoPath = [tmpPath stringByAppendingPathComponent:@"tempGroupLogo.png"];
        [groupLogo writeToFile:logoPath atomically:YES];
    }
}

- (void)restClient:(BMYRestClient *)restClient getGroupLogoFailedWithError:(NSError *)error
{
    NSLog(@"Get Group Logo Failed: %@", [error description]);
}


/* Add Group User */
- (void)restClient:(BMYRestClient *)restClient addedGroupUser:(BMYUser *)user
{
    NSLog(@"Add Group User Succeed: %@", [user JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient addGroupUserFailedWithError:(NSError *)error
{
    NSLog(@"Add Group User Failed: %@", [error description]);
}

/* Get Group User */
- (void)restClient:(BMYRestClient *)restClient gotGroupUser:(BMYUser *)user
{
    NSLog(@"Get Group User Succeed: %@", [user JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient getGroupUserFailedWithError:(NSError *)error
{
    NSLog(@"Get Group User Failed: %@", [error description]);
}

/* List Group Users */
- (void)restClient:(BMYRestClient *)restClient listedGroupUsers:(BMYResultList *)groupUsersList
{
    NSLog(@"List Group Users Succeed: %@", [groupUsersList JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient listGroupUsersFailedWithError:(NSError *)error
{
    NSLog(@"List Group Users Failed: %@", [error description]);
}

/* Update Group User */
- (void)restClient:(BMYRestClient *)restClient updatedGroupUser:(BMYUser *)user
{
    NSLog(@"Update Group User Succeed: %@", [user JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient updateGroupUserFailedWithError:(NSError *)error
{
    NSLog(@"Update Group User Failed: %@", [error description]);
}

/* Remove Group User */
- (void)restClient:(BMYRestClient *)restClient removedGroupUser:(BMYUser *)user
{
    NSLog(@"Remove Group User Succeed: %@", [user JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient removeGroupUserFailedWithError:(NSError *)error
{
    NSLog(@"Remove Group User Failed: %@", [error description]);
}

/* Get Root */
- (void)restClient:(BMYRestClient *)restClient gotRoot:(BMYRoot *)root
{
    NSLog(@"Get Root Succeed: %@", [root JSONRepresentation]);
}
- (void)restClient:(BMYRestClient *)restClient getRootFailedWithError:(NSError *)error
{
    NSLog(@"Get Root Failed: %@", [error description]);
}

/* Set Default Permission */
-(void)restClient:(BMYRestClient *)restClient doneSetDefaultPermission:(BMYRoot *)aRoot
{
    NSLog(@"Set Default Permission Succeed: %@", [aRoot JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient setDefaultPermissionFailedWithError:(NSError *)error
{
    NSLog(@"Set Default Permission Failed: %@", [error description]);
}


/* Set Root Quota */
- (void)restClient:(BMYRestClient *)restClient doneSetRootQuota:(BMYRoot *)aRoot
{
    NSLog(@"Set Root Quota Succeed: %@", [aRoot JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient setRootQuotaFailedWithError:(NSError *)error
{
    NSLog(@"Set Root Quota Failed: %@", [error description]);
}


/* Put File By Path */
- (void)restClient:(BMYRestClient *)restClient putFileProgress:(CGFloat)progress forRootId:(NSString *)rootId path:(NSString *)destPath fromPath:(NSString *)srcPath
{
    NSLog(@"%f", progress);
}
- (void)restClient:(BMYRestClient *)restClient donePutFileByPathWithRootId:(NSString *)rootId path:(NSString *)destPath fromPath:(NSString *)srcPath metadata:(BMYMetadata *)metadata
{
    NSLog(@"Put File By Path Succeed: %@", [metadata JSONRepresentation]);
}
- (void)restClient:(BMYRestClient *)restClient putFileFailedWithError:(NSError *)error
{
    NSLog(@"Put File By Path Failed: %@", [error description]);
}


/* Get File By Path */
- (void)restClient:(BMYRestClient *)restClient gotFileByPathToPath:(NSString *)toPath
{
    NSLog(@"Get File By Path Succeed");
}
- (void)restClient:(BMYRestClient *)restClient gotFileByPathToPath:(NSString *)toPath contentType:(NSString *)contentType metadata:(BMYMetadata *)metadata
{
    NSLog(@"Get File By Path Succeed: %@", [metadata JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient getFileByPathFailedWithError:(NSError *)error
{
    NSLog(@"Get File By Path Failed: %@", [error description]);
}


/* Trash File By Path */
- (void)restClient:(BMYRestClient *)restClient trashedFileByPath:(BMYMetadata *)metadata
{
    NSLog(@"Trash File Succeed: %@", [metadata JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient trashFileByPathFailedWithError:(NSError *)error
{
    NSLog(@"Trash File By Path Failed: %@", [error description]);
}

/* Create Comment */
- (void)restClient:(BMYRestClient *)restClient createdComment:(BMYComment *)comment
{
    NSLog(@"Create Comment Succeed: %@", [comment JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient createCommentFailedWithError:(NSError *)error
{
    NSLog(@"Create Comment Failed: %@", [error description]);
}


/* Get Comment */
- (void)restClient:(BMYRestClient *)restClient gotComment:(BMYComment *)comment
{
    NSLog(@"Get Comment Succeed: %@", [comment JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient getCommentFailedWithError:(NSError *)error
{
    NSLog(@"Get Comment Failed: %@", [error description]);
}


/* List Comments */
- (void)restClient:(BMYRestClient *)restClient listedComments:(BMYResultList *)commentList
{
    NSLog(@"List Comment Succeed: %@", [commentList JSONRepresentation]);
}
-(void)restClient:(BMYRestClient *)restClient listCommentsFailedWithError:(NSError *)error
{
    NSLog(@"List Comment Failed: %@", [error description]);
}

/* Delete Comment */
- (void)restClient:(BMYRestClient *)restClient deletedComment:(BMYComment *)comment
{
    NSLog(@"Delete Comment Succeed: %@", [comment JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient deleteCommentFailedWithError:(NSError *)error
{
    NSLog(@"Delete Comment Failed: %@", [error description]);
}

/* Delete All Comments */
- (void)restClientDeletedAllComments:(BMYRestClient *)restClient
{
    NSLog(@"Delete All Comments Succeed");
}

- (void)restClient:(BMYRestClient *)restClient deleteAllCommentsFailedWithError:(NSError *)error
{
    NSLog(@"Delete All Comments Failed: %@", [error description]);
}


/* Create Share */
- (void)restClient:(BMYRestClient *)restClient createdShare:(BMYShare *)share
{
    NSLog(@"Share Create Succeed: %@", [share JSONRepresentation]);
}
- (void)restClient:(BMYRestClient *)restClient createShareFailedWithError:(NSError *)error
{
    NSLog(@"Share Create Failed: %@", [error JSONRepresentation]);
}

/* Get Share */
- (void)restClient:(BMYRestClient *)restClient gotShare:(BMYShare *)share
{
    NSLog(@"Get Share Succeed: %@", [share JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient getShareFailedWithError:(NSError *)error
{
    NSLog(@"Get Share Failed: %@", [error description]);
}


/* List Shares */
- (void)restClient:(BMYRestClient *)restClient listedShares:(BMYResultList *)sharesList
{
    NSLog(@"List Shares Succeed: %@", [sharesList JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient listSharesFailedWithError:(NSError *)error
{
    NSLog(@"List Shares Failed: %@", [error description]);
}

/* Delete Share */
- (void)restClient:(BMYRestClient *)restClient deletedShare:(BMYShare *)share
{
    NSLog(@"Delete Share Succeed: %@", [share JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient deleteShareFailedWithError:(NSError *)error
{
    NSLog(@"Delete Share Failed: %@", [error description]);
}

/* Delete All Shares */
- (void)restClientDeletedAllShares:(BMYRestClient *)restClient
{
    NSLog(@"Delete All Shares Succeed");
}

- (void)restClient:(BMYRestClient *)restClient deleteAllSharesFailedWithError:(NSError *)error
{
    NSLog(@"Delete All Shares Failed: %@", [error description]);
}


/* Fileops Get Meta */
- (void)restClient:(BMYRestClient *)restClient gotMetaOfFileOps:(BMYMetadata *)metadata
{
    NSLog(@"Get Meta of File Ops Succeed: %@", [metadata JSONRepresentation]);
}
- (void)restclient:(BMYRestClient *)restClient getMetaOfFileOpsFailedWithError:(NSError *)error
{
    NSLog(@"Get Meta of File Ops Failed: %@", [error description]);
}

/* List Folder */
- (void)restClient:(BMYRestClient *)restClient listedFolderOfFileOps:(NSArray *)metadataList
{
    NSLog(@"List Folder Of Fileops Succeed: %@", [metadataList JSONRepresentation]);
}
- (void)restClient:(BMYRestClient *)restClient listFolderOfFileOpsFailedWithError:(NSError *)error
{
    NSLog(@"List Folder Of Fileops Failed: %@", [error description]);
}

/* Get Trash */
- (void)restClient:(BMYRestClient *)restClient gotTrash:(BMYTrash *)trash
{
    NSLog(@"Get Trash Succeed: %@", [trash JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient getTrashFailedWithError:(NSError *)error
{
    NSLog(@"Get Trash Failed: %@", [error description]);
}

/* List Trashes */
- (void)restClient:(BMYRestClient *)restClient listedTrashes:(BMYResultList *)trashesList
{
    NSLog(@"List Trashes Succeed: %@", [trashesList JSONRepresentation]);
}

-(void)restClient:(BMYRestClient *)restClient listTrashesFailedWithError:(NSError *)error
{
    NSLog(@"List Trashes Failed: %@", [error description]);
}

/* Delete Trash */
- (void)restClient:(BMYRestClient *)restClient deletedTrash:(BMYTrash *)trash
{
    NSLog(@"Delete Trash Succeed: %@", [trash JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient deleteTrashFailedWithError:(NSError *)error
{
    NSLog(@"Delete Trash Failed: %@", [error description]);
}

/* Delete All Trashes */
- (void)restClientDeletedAllTrashes:(BMYRestClient *)restClient
{
    NSLog(@"Delete All Trashes Succeed");
}

- (void)restClient:(BMYRestClient *)restClient deleteAllTrashesFailedWithError:(NSError *)error
{
    NSLog(@"Delete All Trashes Failed: %@", [error description]);
}

/* Restore Trash */
- (void)restClient:(BMYRestClient *)restClient restoredTrash:(BMYTrash *)trash
{
    NSLog(@"Restore Trash Succeed: %@", [trash JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient restoreTrashFailedWithError:(NSError *)error
{
    NSLog(@"Restore Trash Failed: %@", [error description]);
}

/* Search Users */
- (void)restClient:(BMYRestClient *)restClient searchedUsers:(BMYResultList *)usersList
{
    NSLog(@"Search Users Succeed: %@", [usersList JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient searchUsersFailedWithError:(NSError *)error
{
    NSLog(@"Search Users Failed: %@", [error description]);
}

/* Search Groups */
- (void)restClient:(BMYRestClient *)restClient searchedGroups:(BMYResultList *)groupsList
{
    NSLog(@"Search Groups Succeed: %@", [groupsList JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient searchGroupsFailedWithError:(NSError *)error
{
    NSLog(@"Search Groups Failed: %@", [error description]);
}

/* Search Files */
- (void)restClient:(BMYRestClient *)restClient searchedFiles:(BMYResultList *)filesList
{
    NSLog(@"Search Files Succeed: %@", [filesList JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient searchFilesFailedWithError:(NSError *)error
{
    NSLog(@"Search Files Failed: %@", [error description]);
}

/* Top Users */
- (void)restClient:(BMYRestClient *)restClient doneTopUsers:(BMYResultList *)usersList
{
    NSLog(@"Top Users Succeed: %@", [usersList JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient topUsersFailedWithError:(NSError *)error
{
    NSLog(@"Top Users Failed: %@", [error description]);
}

/* Top Groups */
- (void)restClient:(BMYRestClient *)restClient doneTopGroups:(BMYResultList *)groupsList
{
    NSLog(@"Top Groups Succeed: %@", [groupsList JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient topGroupsFailedWithError:(NSError *)error
{
    NSLog(@"Top Groups Failed: %@", [error description]);
}

/* Top Files */
- (void)restClient:(BMYRestClient *)restClient doneTopFiles:(BMYResultList *)filesList
{
    NSLog(@"Top Files Succeed: %@", [filesList JSONRepresentation]);
}

- (void)restClient:(BMYRestClient *)restClient topFilesFailedWithError:(NSError *)error
{
    NSLog(@"Top Files Failed: %@", [error description]);
}
@end


