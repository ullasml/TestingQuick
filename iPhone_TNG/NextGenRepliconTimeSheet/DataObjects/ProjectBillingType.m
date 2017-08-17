//
//  ProjectBillingType.m
//  NextGenRepliconTimeSheet
//
//  Created by Prakashini Pattabiraman on 15/12/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "ProjectBillingType.h"

@interface ProjectBillingType()

@property (nonatomic) NSString *displayText;
@property (nonatomic) NSString *projectBillingTypeUri;

@end

@implementation ProjectBillingType

- (instancetype)initWithUri:(NSString *)uri displayText:(NSString *)displayText {
    if (self = [super init]) {
        self.displayText = displayText;
        self.projectBillingTypeUri = uri;
    }
    
    return self;
}


#pragma mark - <NSCoding>

- (id)initWithCoder:(NSCoder *)decoder
{
    NSString *displayText = [decoder decodeObjectForKey:@"displayText"];
    NSString *uri = [decoder decodeObjectForKey:@"projectBillingTypeUri"];
    
    return [self initWithUri:uri displayText:displayText];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.displayText forKey:@"displayText"];
    [coder encodeObject:self.projectBillingTypeUri forKey:@"projectBillingTypeUri"];
}

#pragma mark - <NSCopying>

- (id)copy
{
    return [self copyWithZone:NULL];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSString *displayTextCopy = [self.displayText copy];
    NSString *uriCopy = [self.projectBillingTypeUri copy];
    return [[ProjectBillingType alloc] initWithUri:uriCopy displayText:displayTextCopy];
}

@end
