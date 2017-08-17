
#import <Foundation/Foundation.h>
#import "PunchActionTypes.h"

@interface OEFType : NSObject<NSCoding, NSCopying>

@property (nonatomic,readonly,copy) NSString *oefUri;
@property (nonatomic,readonly,copy) NSString *oefDefinitionTypeUri;
@property (nonatomic,readonly,copy) NSString *oefName;
@property (nonatomic,readonly,copy) NSString *oefPunchActionType;
@property (nonatomic,readonly,copy) NSString *oefNumericValue;
@property (nonatomic,readonly,copy) NSString *oefTextValue;
@property (nonatomic,readonly,copy) NSString *oefDropdownOptionUri;
@property (nonatomic,readonly,copy) NSString *oefDropdownOptionValue;
@property (nonatomic,readonly,assign) BOOL collectAtTimeOfPunch;
@property (nonatomic,readonly,assign) BOOL disabled;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUri:(NSString *)oefUri definitionTypeUri:(NSString *)oefDefinitionTypeUri name:(NSString *)oefName punchActionType:(NSString *)oefPunchActionType numericValue:(NSString *)oefNumericValue textValue:(NSString *)oefTextValue dropdownOptionUri:(NSString *)oefDropdownOptionUri dropdownOptionValue:(NSString *)oefDropdownOptionValue collectAtTimeOfPunch:(BOOL)collectAtTimeOfPunch disabled:(BOOL)disabled NS_DESIGNATED_INITIALIZER;;

@end
