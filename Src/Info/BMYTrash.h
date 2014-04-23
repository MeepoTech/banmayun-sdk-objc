#import <Foundation/Foundation.h>


@class BMYTime;
@class BMYUser;
@class BMYMetadata;

@interface BMYTrash : NSObject<NSCoding>
{
    NSString *trashedFileId;                // id of file or directory
    NSString *root_id;                      // root id of the space
    NSString *meta_id;                      // id of the metadata
    BMYTime *created_at;                    // created time
    BMYUser *created_by;                    // creator info
    BMYMetadata *meta;                      // metadata info
}


@property (nonatomic, readonly) NSString *trashedFileId;
@property (nonatomic, readonly) NSString *root_id;
@property (nonatomic, readonly) NSString *meta_id;
@property (nonatomic, readonly) BMYTime *created_at;
@property (nonatomic, readonly) BMYUser *created_by;
@property (nonatomic, readonly) BMYMetadata *meta;


- (id)initWithDictionary:(NSDictionary *)dict;

@end
