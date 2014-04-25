#import <Foundation/Foundation.h>

@class BMYSize;
@class BMYTime;
@class BMYUser;
@class BMYPermission;

@interface BMYMetadata : NSObject<NSCoding> {
    NSString *fileId;             // id of the file or directory
    NSString *root_id;            // id of the space
    NSString *name;               // name of the file or directory
    NSString *path;               // file path
    NSString *md5;                // hex value of file's content md5
    BMYSize *size;                // file size
    long version;                 // file version
    NSString *icon;               // file icon
    BOOL is_dir;                  // is a directory or not
    BOOL thumb_exists;            // is thumbnail existed or not
    BOOL insertable;              // can new file or folder be created or not under this folder
    BOOL readable;                // can the  file's content be read or not
    BOOL writable;                // can the file's content be modified or not
    BOOL deletable;               // can be deleted or not
    NSInteger comment_count;      // comments count
    NSInteger share_count;        // shares count
    BMYTime *created_at;          // created time
    BMYUser *created_by;          // creator info
    BMYTime *modified_at;         // the last modified time
    BMYUser *modified_by;         // the last modified user's info
    BMYTime *client_modified_at;  // file's modified time provided by the client
    BMYPermission *permission;    // permission info
    NSArray *contents;            // sub-items of this directory(each item is a metadata)
}

- (id)initWithDictionary:(NSDictionary *)dict;

@property(nonatomic, readonly) NSString *fileId;
@property(nonatomic, readonly) NSString *root_id;
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSString *path;
@property(nonatomic, readonly) NSString *md5;
@property(nonatomic, readonly) BMYSize *size;
@property(nonatomic, readonly) long version;
@property(nonatomic, readonly) NSString *icon;
@property(nonatomic, readonly) BOOL is_dir;
@property(nonatomic, readonly) BOOL thumb_exists;
@property(nonatomic, readonly) BOOL insertable;
@property(nonatomic, readonly) BOOL readable;
@property(nonatomic, readonly) BOOL writable;
@property(nonatomic, readonly) BOOL deletable;
@property(nonatomic) NSInteger comment_count;
@property(nonatomic) NSInteger share_count;
@property(nonatomic, readonly) BMYTime *created_at;
@property(nonatomic, readonly) BMYUser *created_by;
@property(nonatomic, readonly) BMYTime *modified_at;
@property(nonatomic, readonly) BMYUser *modified_by;
@property(nonatomic) BMYTime *client_modified_at;
@property(nonatomic, readonly) BMYPermission *permission;
@property(nonatomic, readonly) NSArray *contents;

@end
