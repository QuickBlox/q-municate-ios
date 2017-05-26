//
//  QMChatModel.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 5/19/17.
//
//

#import "QMChatModel.h"

@interface QMChatModel()

@property (strong, nonatomic, readwrite) NSMutableDictionary *mutableCustomParameters;

@end


@implementation QMChatModel


+ (instancetype)modelWithID:(NSString *)modelID
                    message:(QBChatMessage *)message {
    
    QMChatModel *model = [[QMChatModel alloc] initWithID:modelID
                                                 message:message];
    return model;
}



- (instancetype)initWithID:(NSString *)modelID
                        message:(QBChatMessage *)message {
    
    if (self = [super init]) {
        
        _message = message;
        _modelID = [modelID copy];
    }
    return self;
    
}

- (id)objectForKeyedSubscript:(NSString *)key {
    return self.mutableCustomParameters[key];
}

- (void)setObject:(NSString *)obj forKeyedSubscript:(NSString *)key {
    self.mutableCustomParameters[key] = obj;
}

//MARK: - QMModelProtocol
@synthesize message = _message;
@synthesize modelID =_modelID;
@synthesize fileURLPath = _fileURLPath;
@synthesize modelContentType = _modelContentType;

@end
