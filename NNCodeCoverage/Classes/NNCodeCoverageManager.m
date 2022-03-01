//
//  NNCodeCoverageManager.m
//  CodeCoverage
//
//  Created by NeroXie on 2021/5/16.
//

#import "NNCodeCoverageManager.h"

@interface NNCodeCoverageManager ()

@property (nonatomic, copy) NSString *profrawPath;

@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation NNCodeCoverageManager

void __llvm_profile_initialize_file(void);
void __llvm_profile_set_filename(const char *);
const char *__llvm_profile_get_filename(void);
int __llvm_profile_write_file(void);
int __llvm_profile_register_write_file_atexit(void);

#pragma mark - Lifecycle Method

+ (void)load {
    [NNCodeCoverageManager sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        self.serialQueue = dispatch_queue_create("com.nero.www", DISPATCH_QUEUE_SERIAL);
        
        // profile initialize
        NSString *targetName = NSBundle.mainBundle.infoDictionary[@"CFBundleExecutable"];
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        self.profrawPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.profraw", targetName]];
        NSLog(@"profraw file path: [%@]", self.profrawPath);
        
        __llvm_profile_register_write_file_atexit();
        __llvm_profile_set_filename(self.profrawPath.UTF8String);
        NSString *tmpFileName = [NSString stringWithUTF8String:__llvm_profile_get_filename()];
        NSParameterAssert([tmpFileName isEqualToString:self.profrawPath]);
        __llvm_profile_initialize_file();
        
        // add listener
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(_applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification
                                                 object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Public Method

- (void)uploadLastProfrawFileIfNeed {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.serialQueue, ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf _uploadProfrawFile];
    });
}

#pragma mark - Private Method

- (void)_applicationDidEnterBackground:(NSNotification *)notification {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(self.serialQueue, ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (__llvm_profile_write_file() == 0) [strongSelf _uploadProfrawFile];
    });
}

- (void)_uploadProfrawFile {
    NSLog(@"profraw file path: [%@]", self.profrawPath);
    if (self.delegate) [self.delegate uploadProfrawFileWithPath:self.profrawPath];
}

#pragma mark - Setter & Getter

+ (NNCodeCoverageManager *)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

@end
