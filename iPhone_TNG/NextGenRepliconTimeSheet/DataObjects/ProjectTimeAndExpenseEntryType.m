//
//  ProjectTimeAndExpenseEntryType.m
//  NextGenRepliconTimeSheet
//
//  Created by Prakashini Pattabiraman on 15/12/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "ProjectTimeAndExpenseEntryType.h"

@interface ProjectTimeAndExpenseEntryType()

@property (nonatomic) NSString *displayText;
@property (nonatomic) NSString *projectTimeAndExpenseEntryTypeUri;

@end

@implementation ProjectTimeAndExpenseEntryType

- (instancetype)initWithUri:(NSString *)uri displayText:(NSString *)displayText {
    if (self = [super init]) {
        self.displayText = displayText;
        self.projectTimeAndExpenseEntryTypeUri = uri;
    }
    
    return self;
}


#pragma mark - <NSCoding>

- (id)initWithCoder:(NSCoder *)decoder
{
    NSString *displayText = [decoder decodeObjectForKey:@"displayText"];
    NSString *uri = [decoder decodeObjectForKey:@"projectTimeAndExpenseEntryTypeUri"];
    
    return [self initWithUri:uri displayText:displayText];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.displayText forKey:@"displayText"];
    [coder encodeObject:self.projectTimeAndExpenseEntryTypeUri forKey:@"projectTimeAndExpenseEntryTypeUri"];
}

#pragma mark - <NSCopying>

- (id)copy
{
    return [self copyWithZone:NULL];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSString *displayTextCopy = [self.displayText copy];
    NSString *uriCopy = [self.projectTimeAndExpenseEntryTypeUri copy];
    return [[ProjectTimeAndExpenseEntryType alloc] initWithUri:uriCopy displayText:displayTextCopy];
}

@end
