//
//  NNCodeCoverageManager.h
//  CodeCoverage
//
//  Created by NeroXie on 2021/5/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(CodeCoverageFileUploadDelegate)
@protocol NNCodeCoverageFileUploadDelegate <NSObject>

- (void)uploadProfrawFileWithPath:(NSString *)path;

@end

NS_SWIFT_NAME(CodeCoverageManager)
@interface NNCodeCoverageManager : NSObject

@property (class, nonatomic, readonly, strong) NNCodeCoverageManager *sharedInstance NS_SWIFT_NAME(shared);

@property (nonatomic, weak) id<NNCodeCoverageFileUploadDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;

- (void)uploadLastProfrawFileIfNeed;

@end

NS_ASSUME_NONNULL_END
