#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol BMYRestClientDelegate;

@class BMYAccountInfo;
@class BMYMetadata;
@class BMYLink;
@class BMYUser;
@class BMYResultList;
@class BMYUserRole;
@class BMYRelationRole;
@class BMYGroup;
@class BMYGroupType;
@class BMYRoot;
@class BMYComment;
@class BMYShare;
@class BMYTrash;
@class BMYChunkedUpload;
@class BMYSession;

@interface BMYRestClient : NSObject {
    NSString *userId;
    NSString *root;
    NSMutableSet *requests;

    /*
       Map from path to the load request. Needs to be expanded to a general framework for cancelling requests
     */
    NSMutableDictionary *loadRequests;
    NSMutableDictionary *imageLoadRequests;
    NSMutableDictionary *uploadRequests;
    __weak id<BMYRestClientDelegate> delegate;
}

- (id)initWithSession:(BMYSession *)session;

/* Cancels all outstanding requests. No callback for those requests will be sent */
- (void)cancelAllRequests;

/*
   Authorization Interfaces
 */

// Sign In
- (void)signInWithUsername:(NSString *)username
                    passwd:(NSString *)password
                  linkName:(NSString *)linkname
                linkDevice:(NSString *)linkDevice
                  ldapName:(NSString *)ldapname;

// Sign Out
- (void)signOut;

// Change Password
- (void)changePassword:(NSString *)username oldPassword:(NSString *)oldpasswd newPassword:(NSString *)newpasswd;

// Forgot Password
- (void)forgotPassword:(NSString *)email;

// Reset User Password
- (void)resetPassword:(NSString *)newPassword;

/*
   Links Interfaces
 */

// Get User Link
- (void)getUserLink:(NSString *)userId linkId:(NSString *)linkId;

// List User Links
- (void)listUserLinks:(NSString *)userId;
- (void)listUserLinks:(NSString *)userId offset:(NSNumber *)offset limit:(NSNumber *)limit;

// Delete User Link
- (void)deleteUserLink:(NSString *)aUserId linkId:(NSString *)aLinkId;

// Delete All User Links
- (void)deleteAllUserLinks:(NSString *)aUserId;

/*
   User Interfaces
 */

// Exists User

- (void)existsUser:(NSString *)name email:(NSString *)email;

// Create User
- (void)createUser:(NSString *)name
            password:(NSString *)password
               email:(NSString *)email
         displayName:(NSString *)displayName
              source:(NSString *)source
        groupsCanOwn:(NSNumber *)groupsCanOwn
                role:(BMYUserRole *)role;

// Get User
- (void)getUser:(NSString *)userId;

// List Users
- (void)listUsers;
- (void)listUsers:(NSString *)role
        isActivated:(NSNumber *)isActivated
          isBlocked:(NSNumber *)isBlocked
             offset:(NSNumber *)offset
              limit:(NSNumber *)limit;

// Update User
- (void)updateUser:(NSString *)aUserId
         displayName:(NSString *)displayName
        groupsCanOwn:(NSNumber *)groupsCanOwn
                role:(BMYUserRole *)role
           isBlocked:(NSNumber *)isBlocked;

// Verify User Email
- (void)verifyUserEmail:(NSString *)aUserId;

// Set User Password
- (void)setUserPassword:(NSString *)aUserId newPassword:(NSString *)password;

/*
   User Avatar Interface
 */

// Set User Avatar
- (void)setUserAvatar:(NSString *)aUserId avatar:(NSData *)avatar format:(NSString *)format;

// Get User Avatar
- (void)getUserAvatar:(NSString *)userId format:(NSString *)format size:(NSString *)size;

/*
   User Groups Interface
 */

// Add User Group
- (void)addUserGroup:(NSString *)aUserId
             groupId:(NSString *)groupId
             remarks:(NSString *)remarks
                role:(BMYRelationRole *)role;

// Get User Group
- (void)getUserGroup:(NSString *)aUserId groupId:(NSString *)groupId;

// List User Groups
- (void)listUserGroups:(NSString *)aUserId
                  role:(NSString *)role
           isActivated:(NSNumber *)isActivated
             isBlocked:(NSNumber *)isBlocked
                offset:(NSNumber *)offset
                 limit:(NSNumber *)limit;

- (void)listUserGroups:(NSString *)aUserId role:(NSString *)role;
- (void)listUserGroups:(NSString *)aUserId;

// Update User Group
- (void)updateUserGroup:(NSString *)aUserId
                groupId:(NSString *)groupId
                   role:(BMYRelationRole *)role
            isActivated:(NSNumber *)isActivated
              isBlocked:(NSNumber *)isBlocked;
- (void)updateUserGroup:(NSString *)aUserId groupId:(NSString *)groupId;

// Remove User Group
- (void)removeUserGroup:(NSString *)aUserId groupId:(NSString *)groupId;

/*
   Group Interface
 */

// Exists Group
- (void)existsGroup:(NSString *)name;

// Create Group
- (void)createGroup:(NSString *)name
               type:(BMYGroupType *)groupType
          isVisible:(NSNumber *)isVisible
              intro:(NSString *)introduction
               tags:(NSString *)tags
           announce:(NSString *)announce
            ownerId:(NSString *)ownerId
             source:(NSString *)source;
- (void)createGroup:(NSString *)name type:(BMYGroupType *)groupType isVisible:(NSNumber *)isVisible;

// Get Group
- (void)getGroup:(NSString *)groupId;

// List Groups
- (void)listGroups:(NSString *)type
        isAcivated:(NSNumber *)isActivated
         isBlocked:(NSNumber *)isBlocked
            offset:(NSNumber *)offset
             limit:(NSNumber *)limit;
- (void)listGroups;

// Update Group
- (void)updateGroup:(NSString *)groupId
               type:(BMYGroupType *)type
          isVisible:(NSNumber *)isVisible
              intro:(NSString *)intro
               tags:(NSString *)tags
           announce:(NSString *)announce
          isBlocked:(NSNumber *)isBlocked;
- (void)updateGroup:(NSString *)groupId
               type:(BMYGroupType *)type
          isVisible:(NSNumber *)isVisible
          isBlocked:(NSNumber *)isBlocked;

- (void)updateGroup:(NSString *)groupId type:(BMYGroupType *)type isVisible:(NSNumber *)isVisible;

// Delete Group
- (void)deleteGroup:(NSString *)groupId;

/*
   Group Logo Interface
 */

// Set Group Logo
- (void)setGroupLogo:(NSString *)groupId logo:(NSData *)logo format:(NSString *)format;

// Get Group Logo
- (void)getGroupLogo:(NSString *)groupId format:(NSString *)format size:(NSString *)size;

/*
   Group User Interface
 */

// Add Group User
- (void)addGroupUser:(NSString *)groupId userId:(NSString *)aUserId;

// Get Group User
- (void)getGroupUser:(NSString *)groupId userId:(NSString *)aUserId;

// List Group Users
- (void)listGroupUsers:(NSString *)groupId
                  role:(NSString *)role
           isActivated:(NSNumber *)isActivated
             isBlocked:(NSNumber *)isBlocked
                offset:(NSNumber *)offset
                 limit:(NSNumber *)limit;

- (void)listGroupUsers:(NSString *)groupId;

// Update Group User
- (void)updateGroupUser:(NSString *)groupId
                 userId:(NSString *)aUserId
                   role:(BMYRelationRole *)role
            isActivated:(NSNumber *)isActivated
              isBlocked:(NSNumber *)isBlocked;

- (void)updateGroupUser:(NSString *)groupId userId:(NSString *)aUserId;

// Remove Group User
- (void)removeGroupUser:(NSString *)groupId userId:(NSString *)aUserId;

/*
   Root Interface
 */

// Get Root
- (void)getRoot:(NSString *)rootId;

// Set Default Permission
- (void)setDefaultPermission:(NSString *)rootId
           insertableToOwner:(NSNumber *)insertableToOwner
             readableToOwner:(NSNumber *)readableToOwner
             writableToOwner:(NSNumber *)writableToOwner
            deletableToOwner:(NSNumber *)deletableToOwner
          insertableToOthers:(NSNumber *)insertableToOthers
            readableToOthers:(NSNumber *)readableToOthers
            writableToOthers:(NSNumber *)writableToOthers
           deletableToOthers:(NSNumber *)deletableToOthers;

// Set Root Quota
- (void)setRootQuota:(NSString *)aRootId quota:(NSString *)quota;

/*
   File Interface (By Path)
 */
// Put File By Path
- (void)putFileByPathWithRootId:(NSString *)rootId
                           path:(NSString *)path
               modifiedAtMillis:(NSNumber *)modifiedAtMillis
                      overwrite:(NSNumber *)overwrite
                       fromPath:(NSString *)sourcePath;

// Get File By Path
- (void)getFileByPathWithRootId:(NSString *)rootId
                           path:(NSString *)path
                        version:(NSNumber *)version
                         offset:(NSNumber *)offset
                          bytes:(NSNumber *)bytes
                         toPath:(NSString *)toPath;

- (void)getFileByPathWithRootId:(NSString *)rootId path:(NSString *)path toPath:(NSString *)toPath;

// Trash File By Path
- (void)trashFileByPathWithRootId:(NSString *)rootId path:(NSString *)path;

/*
   File Interface (By id)
 */

// Upload File By Id
- (void)uploadFileByIdWithRootId:(NSString *)rootId
                          metaId:(NSString *)metaId
                modifiedAtMillis:(NSNumber *)modifiedAtMillis
                        fromPath:(NSString *)sourcePath;

// Get File By Id
- (void)getFileByIdWithRootId:(NSString *)rootId metaId:(NSString *)metaId toPath:(NSString *)toPath;
- (void)getFileByIdWithRootId:(NSString *)rootId
                       metaId:(NSString *)metaId
                      version:(NSNumber *)version
                       offset:(NSNumber *)offset
                        bytes:(NSNumber *)bytes
                       toPath:(NSString *)toPath;

// Trash File By Id
- (void)trashFileByPathWithRootId:(NSString *)rootId metaId:(NSString *)metaId;

// Get File Meta
- (void)getFileMetaWithRootId:(NSString *)rootId metaId:(NSString *)metaId;

// Get File Thumbnail
- (void)getFileThumbnailWithRootId:(NSString *)rootId
                            metaId:(NSString *)metaId
                            format:(NSString *)format
                              size:(NSString *)size
                            toPath:(NSString *)toPath;

// List File Revisions
- (void)listFileRevisionsWithRootId:(NSString *)rootId
                             metaId:(NSString *)metaId
                             offset:(NSNumber *)offset
                              limit:(NSNumber *)limit;

/*
   Comment Interface
 */

// Create Comment
- (void)createComment:(NSString *)rootId metaId:(NSString *)metaId contents:(NSString *)contents;

// Get Comment
- (void)getComment:(NSString *)rootId metaId:(NSString *)metaId commentId:(NSString *)commentId;

// List Comments
- (void)listComments:(NSString *)rootId metaId:(NSString *)metaId offset:(NSNumber *)offset limit:(NSNumber *)limit;

- (void)listComments:(NSString *)rootId metaId:(NSString *)metaId;

// Delete Comment
- (void)deleteComment:(NSString *)rootId metaId:(NSString *)metaId commentId:(NSString *)commentId;

// Delete All Comment
- (void)deleteAllComments:(NSString *)rootId metaId:(NSString *)metaId;

/*
   Outer Share Interface
 */

// Create Share
- (void)createShare:(NSString *)rootId
             metaId:(NSString *)metaId
           password:(NSString *)passwd
          expiresAt:(NSNumber *)expiresAt;

// Get Share
- (void)getShare:(NSString *)rootId metaId:(NSString *)metaId shareId:(NSString *)shareId;

// List Shares
- (void)listShares:(NSString *)rootId metaId:(NSString *)metaId offset:(NSNumber *)offset limit:(NSNumber *)limit;
- (void)listShares:(NSString *)rootId metaId:(NSString *)metaId;

// Delete Share
- (void)deleteShare:(NSString *)rootId metaId:(NSString *)metaId shareId:(NSString *)shareId;

// Delete All Shares
- (void)deleteAllShares:(NSString *)rootId metaId:(NSString *)metaId;

/*
   File Ops Interface
 */

// Fileops Commit Chunked Upload
- (void)commitChunkedUploadWithRootId:(NSString *)rootId
                                 path:(NSString *)path
                             uploadId:(NSString *)uploadId
                     modifiedAtMillis:(NSNumber *)modifiedAtMillis;

// Fileops Copy
- (void)copyFileWithRootId:(NSString *)rootId path:(NSString *)path toPath:(NSString *)toPath;

// Fileops Create Folder
- (void)createFolderWithRootId:(NSString *)rootId path:(NSString *)path modifiedAtMillis:(NSNumber *)modifiedAtMillis;

// Fileops Get Meta
- (void)getMetaOfFileOpsWithRootId:(NSString *)rootId
                              path:(NSString *)path
                  isListDirContent:(NSNumber *)isListDirContent;

// Fileops List Folder
- (void)listFolderOfFileOpsWithRootId:(NSString *)rootId path:(NSString *)path;

// Fileops Move
- (void)moveOfFileOpsWithRootId:(NSString *)rootId path:(NSString *)path toPath:(NSString *)toPath;

// Fileops Rollback
- (void)rollbackOfFileOpsWithRootId:(NSString *)rootId path:(NSString *)path toVersion:(NSNumber *)toVersion;

// Fileops thunder upload
- (void)thunderUploadOfFileOpsWithRootId:(NSString *)rootId
                                    path:(NSString *)path
                                     md5:(NSString *)md5
                                   bytes:(NSNumber *)bytes
                        modifiedAtMillis:(NSNumber *)modifiedAtMillis;

// Fileops Utime Folder
- (void)utimeFolderOfFileOpsWithRootId:(NSString *)rootId
                                  path:(NSString *)path
                      modifiedAtMillis:(NSNumber *)modifiedAtMillis;

// Fileops Set Permission
- (void)setPermissionOfFileOpsWithRootId:(NSString *)rootId
                                    path:(NSString *)path
                       insertableToOwner:(NSNumber *)insertableOwner
                         readableToOwner:(NSNumber *)readableOwner
                         writableToOwner:(NSNumber *)writableOwner
                        deletableToOwner:(NSNumber *)deletableOwner
                      insertableToOthers:(NSNumber *)insertableOthers
                        readableToOthers:(NSNumber *)readableOthers
                        writableToOthers:(NSNumber *)writableOthers
                       deletableToOthers:(NSNumber *)deletableOthers;

// Fileops List Permission
- (void)listPermissionsOfFileOpsWithRootId:(NSString *)rootId;

/*
   Chunked Upload Interface
 */

// Chunked Upload
- (void)chunkedUploadWithUploadId:(NSString *)uploadId offset:(NSNumber *)offset fromPath:(NSString *)localPath;

/*
   Trash Interface
 */

// Get Trash
- (void)getTrash:(NSString *)rootId trashId:(NSString *)trashId;

// List Trashes
- (void)listTrashes:(NSString *)rootId offset:(NSNumber *)offset limit:(NSNumber *)limit;
- (void)listTrashes:(NSString *)rootId;

// Delete Trash
- (void)deleteTrash:(NSString *)rootId trashId:(NSString *)trashId;

// Delete All Trashes
- (void)deleteAllTrashes:(NSString *)rootId;

// Restore Trash
- (void)restoreTrash:(NSString *)rootId trashId:(NSString *)trashId toPath:(NSString *)toPath;

/*
   Search Interface
 */

// Search Users
- (void)searchUsers:(NSString *)query groupId:(NSString *)groupId offset:(NSNumber *)offset limit:(NSNumber *)limit;
- (void)searchUsers:(NSString *)query groupId:(NSString *)groupId;
- (void)searchUsers:(NSString *)query;

// Search Groups
- (void)searchGroups:(NSString *)query userId:(NSString *)aUserId offset:(NSNumber *)offset limit:(NSNumber *)limit;
- (void)searchGroups:(NSString *)query userId:(NSString *)aUserId;
- (void)searchGroups:(NSString *)query;

// Search Files
- (void)searchFiles:(NSString *)query
             rootId:(NSString *)rootId
               path:(NSString *)path
             offset:(NSNumber *)offset
              limit:(NSNumber *)limit;
- (void)searchFiles:(NSString *)query rootId:(NSString *)rootId path:(NSString *)path;
- (void)searchFiles:(NSString *)query;

/*
   Rank List Interface
 */

// Top Users
- (void)topUsers:(NSString *)orderBy offset:(NSNumber *)offset limit:(NSNumber *)limit;
- (void)topUsers:(NSString *)orderBy;

// Top Groups
- (void)topGroups:(NSString *)orderBy offset:(NSNumber *)offset limit:(NSNumber *)limit;
- (void)topGroups:(NSString *)orderBy;

// Top Files
- (void)topFiles:(NSString *)orderBy rootId:(NSString *)rootId offset:(NSNumber *)offset limit:(NSNumber *)limit;
- (void)topFiles:(NSString *)orderBy rootId:(NSString *)rootId;

@property(nonatomic, weak) id<BMYRestClientDelegate> delegate;

@end

/*
   The delegate provides allows the user to get the result of the calls made on the BMYRestClient.
   Right now, the error parameter of failed calls may be nil and [error localizedDescription] does
   not contain an error message appropriate to show to the user.
 */
@protocol BMYRestClientDelegate<NSObject>

@optional

/* Sign In */
- (void)restClient:(BMYRestClient *)restClient signedIn:(BMYLink *)link;
- (void)restClient:(BMYRestClient *)restClient signInFailedWithError:(NSError *)error;

/* Sign Out */
- (void)restClient:(BMYRestClient *)restClient signedOut:(BMYLink *)link;
- (void)restClient:(BMYRestClient *)restClient signOutFailedWithError:(NSError *)error;

/* Change Password */
- (void)restClient:(BMYRestClient *)restClient changedPassword:(BMYUser *)user;
- (void)restClient:(BMYRestClient *)restClient changePasswordFailedWithError:(NSError *)error;

/* Forgot Password */
- (void)restClient:(BMYRestClient *)restClient forgottenPassword:(BMYUser *)user;
- (void)restClient:(BMYRestClient *)restClient forgotPasswordFailedWithError:(NSError *)error;

/* Reset User Password */
- (void)restClient:(BMYRestClient *)restClient resetPassword:(BMYUser *)user;
- (void)restClient:(BMYRestClient *)restClient resetPasswordFailedWithError:(NSError *)error;

/* Get User Link */
- (void)restClient:(BMYRestClient *)restClient gotUserLink:(BMYLink *)link;
- (void)restClient:(BMYRestClient *)restClient getUserLinkFailedWithError:(NSError *)error;

/* List User Links*/
- (void)restClient:(BMYRestClient *)restClient listedUserLinks:(BMYResultList *)resultList;
- (void)restClient:(BMYRestClient *)restClient listUserLinksFailedWithError:(NSError *)error;

/* Delete User Link */
- (void)restClient:(BMYRestClient *)restClient deletedUserLink:(BMYLink *)link;
- (void)restClient:(BMYRestClient *)restClient deleteUserLinkFailedWithError:(NSError *)error;

/* Delete All User Links */
- (void)restClientDeletedAllUserLinks:(BMYRestClient *)restClient;
- (void)restClient:(BMYRestClient *)restClient deleteAllUserLinksFailedWithError:(NSError *)error;

/* Exists User */
- (void)restClient:(BMYRestClient *)restClient existedUser:(BMYUser *)user;
- (void)restClient:(BMYRestClient *)restClient existsUserFailedWithError:(NSError *)error;

/* Create User */
- (void)restClient:(BMYRestClient *)restClient createdUser:(BMYUser *)user;
- (void)restClient:(BMYRestClient *)restClient createUserFailedWithError:(NSError *)error;

/* Get User */
- (void)restClient:(BMYRestClient *)restClient gotUser:(BMYUser *)user;
- (void)restClient:(BMYRestClient *)restClient getUserFailedWithError:(NSError *)error;

/* List Users */
- (void)restClient:(BMYRestClient *)restClient listedUsers:(BMYResultList *)list;
- (void)restClient:(BMYRestClient *)restClient listUsersFailedWithError:(NSError *)error;

/* Update User */
- (void)restClient:(BMYRestClient *)restClient updatedUser:(BMYUser *)user;
- (void)restClient:(BMYRestClient *)restClient updateUserFailedWithError:(NSError *)error;

/* Verify User Email */
- (void)restClient:(BMYRestClient *)restClient verifiedUserEmail:(BMYUser *)user;
- (void)restClient:(BMYRestClient *)restClient verifyUserEmailFailedWithError:(NSError *)error;

/* Set User Password */
- (void)restClient:(BMYRestClient *)restClient doneSetUserPassword:(BMYUser *)user;
- (void)restClient:(BMYRestClient *)restClient setUserPasswordFailedWithError:(NSError *)error;

/* Set User Avatar */
- (void)restClientSetUserAvatar:(BMYRestClient *)restClient;
- (void)restClient:(BMYRestClient *)restClient setUserAvatarFailedWithError:(NSError *)error;

/* Get User Avatar */
- (void)restClient:(BMYRestClient *)restClient gotUserAvatar:(NSData *)avatar;
- (void)restClient:(BMYRestClient *)restClient getUserAvatarFailedWithError:(NSError *)error;

/* Add User Group */
- (void)restClient:(BMYRestClient *)restClient addedUserGroup:(BMYGroup *)group;
- (void)restClient:(BMYRestClient *)restClient addUserGroupFailedWithError:(NSError *)error;

/* Get User Group*/
- (void)restClient:(BMYRestClient *)restClient gotUserGroup:(BMYGroup *)group;
- (void)restClient:(BMYRestClient *)restClient getUserGroupFailedWithError:(NSError *)error;

/* List User Groups */
- (void)restClient:(BMYRestClient *)restClient listedUserGroups:(BMYResultList *)groupList;
- (void)restClient:(BMYRestClient *)restClient listUserGroupsFailedWithError:(NSError *)error;

/* Update User Group */
- (void)restClient:(BMYRestClient *)restClient updatedUserGroup:(BMYGroup *)group;
- (void)restClient:(BMYRestClient *)restClient updateUserGroupFailedWithError:(NSError *)error;

/* Remove User Group */
- (void)restClient:(BMYRestClient *)restClient removedUserGroup:(BMYGroup *)group;
- (void)restClient:(BMYRestClient *)restClient removeUserGroupFailedWithError:(NSError *)error;

/* Exists Group */
- (void)restClient:(BMYRestClient *)restClient existedGroup:(BMYGroup *)group;
- (void)restClient:(BMYRestClient *)restClient existsGroupFailedWithError:(NSError *)error;

/* Create Group */
- (void)restClient:(BMYRestClient *)restClient createdGroup:(BMYGroup *)group;
- (void)restClient:(BMYRestClient *)restClient createGroupFailedWithError:(NSError *)error;

/* Get Group */
- (void)restClient:(BMYRestClient *)restClient gotGroup:(BMYGroup *)group;
- (void)restClient:(BMYRestClient *)restClient getGroupFailedWithError:(NSError *)error;

/* List Groups */
- (void)restClient:(BMYRestClient *)restClient listedGroups:(BMYResultList *)groupList;
- (void)restClient:(BMYRestClient *)restClient listGroupsFailedWithError:(NSError *)error;

/* Update Group */
- (void)restClient:(BMYRestClient *)restClient updatedGroup:(BMYGroup *)group;
- (void)restClient:(BMYRestClient *)restClient updateGroupFailedWithError:(NSError *)error;

/* Delete Group */
- (void)restClient:(BMYRestClient *)restClient deletedGroup:(BMYGroup *)group;
- (void)restClient:(BMYRestClient *)restClient deleteGroupFailedWithError:(NSError *)error;

/* Set Group Logo */
- (void)restClientDoneSetGroupLogo:(BMYRestClient *)restClient;
- (void)restClient:(BMYRestClient *)restClient setGroupLogoFailedWithError:(NSError *)error;

/* Get Group Logo */
- (void)restClient:(BMYRestClient *)restClient gotGroupLogo:(NSData *)groupLogo;
- (void)restClient:(BMYRestClient *)restClient getGroupLogoFailedWithError:(NSError *)error;

/* Add Group User */
- (void)restClient:(BMYRestClient *)restClient addedGroupUser:(BMYUser *)user;
- (void)restClient:(BMYRestClient *)restClient addGroupUserFailedWithError:(NSError *)error;

/* Get Group User */
- (void)restClient:(BMYRestClient *)restClient gotGroupUser:(BMYUser *)user;
- (void)restClient:(BMYRestClient *)restClient getGroupUserFailedWithError:(NSError *)error;

/* List Group Users*/
- (void)restClient:(BMYRestClient *)restClient listedGroupUsers:(BMYResultList *)groupUsersList;
- (void)restClient:(BMYRestClient *)restClient listGroupUsersFailedWithError:(NSError *)error;

/* Update Group User */
- (void)restClient:(BMYRestClient *)restClient updatedGroupUser:(BMYUser *)user;
- (void)restClient:(BMYRestClient *)restClient updateGroupUserFailedWithError:(NSError *)error;

/* Remove Group User */
- (void)restClient:(BMYRestClient *)restClient removedGroupUser:(BMYUser *)user;
- (void)restClient:(BMYRestClient *)restClient removeGroupUserFailedWithError:(NSError *)error;

/* Get Root */
- (void)restClient:(BMYRestClient *)restClient gotRoot:(BMYRoot *)root;
- (void)restClient:(BMYRestClient *)restClient getRootFailedWithError:(NSError *)error;

/* Set Default Permission */
- (void)restClient:(BMYRestClient *)restClient doneSetDefaultPermission:(BMYRoot *)aRoot;
- (void)restClient:(BMYRestClient *)restClient setDefaultPermissionFailedWithError:(NSError *)error;

/* Set Root Quota */
- (void)restClient:(BMYRestClient *)restClient doneSetRootQuota:(BMYRoot *)aRoot;
- (void)restClient:(BMYRestClient *)restClient setRootQuotaFailedWithError:(NSError *)error;

/* Put File by Path*/
- (void)restClient:(BMYRestClient *)restClient
        donePutFileByPathWithRootId:(NSString *)rootId
                               path:(NSString *)destPath
                           fromPath:(NSString *)srcPath
                           metadata:(BMYMetadata *)metadata;

- (void)restClient:(BMYRestClient *)restClient
        putFileProgress:(CGFloat)progress
              forRootId:(NSString *)rootId
                   path:(NSString *)destPath
               fromPath:(NSString *)srcPath;

- (void)restClient:(BMYRestClient *)restClient putFileFailedWithError:(NSError *)error;

/* Get File by Path */
- (void)restClient:(BMYRestClient *)restClient gotFileByPathToPath:(NSString *)toPath;

// Implement the following callback instead of the previous if you care about the value of the Content-Type HTTP header
// and the file metadata. Only one will be called per successful response.
- (void)restClient:(BMYRestClient *)restClient
        gotFileByPathToPath:(NSString *)toPath
                contentType:(NSString *)contentType
                   metadata:(BMYMetadata *)metadata;

- (void)restClient:(BMYRestClient *)restClient getFileByPathProgress:(CGFloat)progress forFile:(NSString *)toPath;
- (void)restClient:(BMYRestClient *)restClient getFileByPathFailedWithError:(NSError *)error;

/* Trash File by Path */
- (void)restClient:(BMYRestClient *)restClient trashedFileByPath:(BMYMetadata *)metadata;
- (void)restClient:(BMYRestClient *)restClient trashFileByPathFailedWithError:(NSError *)error;

/* Upload File by id */
- (void)restClient:(BMYRestClient *)restClient
        uploadedFileByIdForRootId:(NSString *)rootId
                           metaId:(NSString *)metaId
                         fromPath:(NSString *)srcPath
                         metadata:(BMYMetadata *)metadata;

- (void)restClient:(BMYRestClient *)restClient
        uploadFileByIdProgress:(CGFloat)progress
                     forRootId:(NSString *)metaId
                        metaId:(NSString *)metaId
                      fromPath:(NSString *)srcPath;
- (void)restClient:(BMYRestClient *)restClient uploadFileByIdFailedWithError:(NSError *)error;

/* Get File by id */
- (void)restClient:(BMYRestClient *)restClient gotFileByIdToPath:(NSString *)toPath;

// Implement the following callback instead of the previous if you care about the value of the Content-Type HTTP header
// and the file metadata. Only one will be called per successful response.
- (void)restClient:(BMYRestClient *)restClient
        gotFileByIdToPath:(NSString *)toPath
              contentType:(NSString *)contentType
                 metadata:(BMYMetadata *)metadata;

- (void)restClient:(BMYRestClient *)restClient getFileByIdProgress:(CGFloat)progress forFile:(NSString *)toPath;
- (void)restClient:(BMYRestClient *)restClient getFileByIdFailedWithError:(NSError *)error;

/* Trash File by Id */
- (void)restClient:(BMYRestClient *)restClient trashedFileById:(BMYMetadata *)metadata;
- (void)restClient:(BMYRestClient *)restClient trashFileByIdFailedWithError:(NSError *)error;

/* Get File Meta */
- (void)restClient:(BMYRestClient *)restClient gotFileMeta:(BMYMetadata *)metadata;
- (void)restClient:(BMYRestClient *)restClient getFileMetaFailedWithError:(NSError *)error;

/* Get File Thumbnail */
- (void)restClient:(BMYRestClient *)restClient gotFileThumbnail:(NSString *)destPath metadata:(BMYMetadata *)metadata;
- (void)restClient:(BMYRestClient *)restClient getFileThumbnailFailedWithError:(NSError *)error;

/* List File Revisions */
- (void)restClient:(BMYRestClient *)restClient listedFileRevisions:(BMYResultList *)revisionsList;
- (void)restClient:(BMYRestClient *)restClient listFileRevisionsFailedWithError:(NSError *)error;

/* Fileops Commit Chunked Upload */
- (void)restClient:(BMYRestClient *)restClient commitedChunkedUpload:(BMYMetadata *)metadata;
- (void)restClient:(BMYRestClient *)restClient commitChunkedUploadFailedWithError:(NSError *)error;

/* Fileops Copy */
- (void)restClient:(BMYRestClient *)restClient copiedFile:(BMYMetadata *)metadata;
- (void)restClient:(BMYRestClient *)restClient copyFileFailedWithError:(NSError *)error;

/* Fileops Create Folder */
- (void)restClient:(BMYRestClient *)restClient createdFolder:(BMYMetadata *)metadata;
- (void)restClient:(BMYRestClient *)restClient createFolderFailedWithError:(NSError *)error;

/* Fileops Get Meta */
- (void)restClient:(BMYRestClient *)restClient gotMetaOfFileOps:(BMYMetadata *)metadata;
- (void)restClient:(BMYRestClient *)restClient getMetaOfFileOpsFailedWithError:(NSError *)error;

/* Fileops List Folder */
- (void)restClient:(BMYRestClient *)restClient listedFolderOfFileOps:(NSArray *)metadataList;
- (void)restClient:(BMYRestClient *)restClient listFolderOfFileOpsFailedWithError:(NSError *)error;

/* Fileops Move */
- (void)restClient:(BMYRestClient *)restClient movedOfFileOps:(BMYMetadata *)metadata;
- (void)restClient:(BMYRestClient *)restClient moveOfFileOpsFailedWithError:(NSError *)error;

/* Fileops Rollback */
- (void)restClient:(BMYRestClient *)restClient rollbackedOfFileOps:(BMYMetadata *)metadata;
- (void)restClient:(BMYRestClient *)restClient rollbackOfFileOpsFailedWithError:(NSError *)error;

/* Fileops Thunder upload */
- (void)restClient:(BMYRestClient *)restClient thunderUploadedOfFileOps:(BMYMetadata *)metadata;
- (void)restClient:(BMYRestClient *)restClient thunderUploadOfFileOpsFailedWithError:(NSError *)error;

/* Fileops Utime Folder */
- (void)restClient:(BMYRestClient *)restClient utimedFolderOfFileOps:(BMYMetadata *)metadata;
- (void)restClient:(BMYRestClient *)restClient utimeFolderOfFileOpsFailedWithError:(NSError *)error;

/* Fileops Set Permission */
- (void)restClient:(BMYRestClient *)restClient doneSetPermissionOfFileOps:(BMYMetadata *)metadata;
- (void)restClient:(BMYRestClient *)restClient setPermissionOfFileOpsFailedWithError:(NSError *)error;

/* Fileops List Permissions */
- (void)restClient:(BMYRestClient *)restClient listedPermissionsOfFileOps:(BMYMetadata *)metadata;
- (void)restClient:(BMYRestClient *)restClient listPermissionsOfFileOpsFailedWithError:(NSError *)error;

/* Chunked Upload */
- (void)restClient:(BMYRestClient *)restClient
        chunkedUploadProgress:(CGFloat)progress
                      forFile:(NSString *)uploadId
                       offset:(long)offset
                     fromPath:(NSString *)fromPath;

- (void)restClient:(BMYRestClient *)restClient
        chunkedUpload:(NSString *)uploadId
            newOffset:(long)newOffset
             fromFile:(NSString *)localPath;

- (void)restClient:(BMYRestClient *)restClient chunkedUploadFailedWithError:(NSError *)error;

/* Create Comment */
- (void)restClient:(BMYRestClient *)restClient createdComment:(BMYComment *)comment;
- (void)restClient:(BMYRestClient *)restClient createCommentFailedWithError:(NSError *)error;

/* Get Comment */
- (void)restClient:(BMYRestClient *)restClient gotComment:(BMYComment *)comment;
- (void)restClient:(BMYRestClient *)restClient getCommentFailedWithError:(NSError *)error;

/* List Comments */
- (void)restClient:(BMYRestClient *)restClient listedComments:(BMYResultList *)commentList;
- (void)restClient:(BMYRestClient *)restClient listCommentsFailedWithError:(NSError *)error;

/* Delete Comment */
- (void)restClient:(BMYRestClient *)restClient deletedComment:(BMYComment *)comment;
- (void)restClient:(BMYRestClient *)restClient deleteCommentFailedWithError:(NSError *)error;

/* Deleta All Comments */
- (void)restClientDeletedAllComments:(BMYRestClient *)restClient;
- (void)restClient:(BMYRestClient *)restClient deleteAllCommentsFailedWithError:(NSError *)error;

/* Create Share */
- (void)restClient:(BMYRestClient *)restClient createdShare:(BMYShare *)share;
- (void)restClient:(BMYRestClient *)restClient createShareFailedWithError:(NSError *)error;

/* Get Share */
- (void)restClient:(BMYRestClient *)restClient gotShare:(BMYShare *)share;
- (void)restClient:(BMYRestClient *)restClient getShareFailedWithError:(NSError *)error;

/* List Shares */
- (void)restClient:(BMYRestClient *)restClient listedShares:(BMYResultList *)sharesList;
- (void)restClient:(BMYRestClient *)restClient listSharesFailedWithError:(NSError *)error;

/* Delete Share */
- (void)restClient:(BMYRestClient *)restClient deletedShare:(BMYShare *)share;
- (void)restClient:(BMYRestClient *)restClient deleteShareFailedWithError:(NSError *)error;

/* Delete All Shares */
- (void)restClientDeletedAllShares:(BMYRestClient *)restClient;
- (void)restClient:(BMYRestClient *)restClient deleteAllSharesFailedWithError:(NSError *)error;

/* Get Trash */
- (void)restClient:(BMYRestClient *)restClient gotTrash:(BMYTrash *)trash;
- (void)restClient:(BMYRestClient *)restClient getTrashFailedWithError:(NSError *)error;

/* List Trashes */
- (void)restClient:(BMYRestClient *)restClient listedTrashes:(BMYResultList *)trashesList;
- (void)restClient:(BMYRestClient *)restClient listTrashesFailedWithError:(NSError *)error;

/* Delete Trash */
- (void)restClient:(BMYRestClient *)restClient deletedTrash:(BMYTrash *)trash;
- (void)restClient:(BMYRestClient *)restClient deleteTrashFailedWithError:(NSError *)error;

/* Delete All Trashes */
- (void)restClientDeletedAllTrashes:(BMYRestClient *)restClient;
- (void)restClient:(BMYRestClient *)restClient deleteAllTrashesFailedWithError:(NSError *)error;

/* Restore Trash */
- (void)restClient:(BMYRestClient *)restClient restoredTrash:(BMYTrash *)trash;
- (void)restClient:(BMYRestClient *)restClient restoreTrashFailedWithError:(NSError *)error;

/* Search Users */
- (void)restClient:(BMYRestClient *)restClient searchedUsers:(BMYResultList *)usersList;
- (void)restClient:(BMYRestClient *)restClient searchUsersFailedWithError:(NSError *)error;

/* Search Groups */
- (void)restClient:(BMYRestClient *)restClient searchedGroups:(BMYResultList *)groupsList;
- (void)restClient:(BMYRestClient *)restClient searchGroupsFailedWithError:(NSError *)error;

/* Search Files */
- (void)restClient:(BMYRestClient *)restClient searchedFiles:(BMYResultList *)filesList;
- (void)restClient:(BMYRestClient *)restClient searchFilesFailedWithError:(NSError *)error;

/* Top Users */
- (void)restClient:(BMYRestClient *)restClient doneTopUsers:(BMYResultList *)usersList;
- (void)restClient:(BMYRestClient *)restClient topUsersFailedWithError:(NSError *)error;

/* Top Groups */
- (void)restClient:(BMYRestClient *)restClient doneTopGroups:(BMYResultList *)groupsList;
- (void)restClient:(BMYRestClient *)restClient topGroupsFailedWithError:(NSError *)error;

/* Top Files */
- (void)restClient:(BMYRestClient *)restClient doneTopFiles:(BMYResultList *)filesList;
- (void)restClient:(BMYRestClient *)restClient topFilesFailedWithError:(NSError *)error;

@end
