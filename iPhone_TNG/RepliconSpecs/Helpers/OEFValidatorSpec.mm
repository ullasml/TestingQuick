//  OEFValidatorSpec.m
//  NextGenRepliconTimeSheet
//

#import <Cedar/Cedar.h>
#import "OEFValidator.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorProvider.h"
#import "Constants.h"
#import "OEFType.h"
#import "InjectorKeys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(OEFValidatorSpec)

describe(@"OEFValidator", ^{
    __block OEFValidator *subject;
    __block id<BSBinder, BSInjector> injector;
    __block NSUserDefaults *userDefaults;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        
        userDefaults = nice_fake_for([NSUserDefaults class]);
        [injector bind:InjectorKeyStandardUserDefaults toInstance:userDefaults];
        
        subject = [injector getInstance:[OEFValidator class]];
        
    });
    
    context(@"Validate number OEFType ", ^{
          __block OEFType *numericOEFType;
    
        context(@"When max precision and max scale in user defaults is nil", ^{

            beforeEach(^{
                subject.userDefaults stub_method(@selector(objectForKey:)).with(OEFMaxPrecisionKey).and_return(nil);
                subject.userDefaults stub_method(@selector(objectForKey:)).with(OEFMaxScaleKey).and_return(nil);
                
            });
            
            context(@"When numeric value is positive", ^{
                
                context(@"When numeric value is valid and positive integer", ^{
                    
                    beforeEach(^{
                        
                        numericOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    });
                    
                    it(@"Should not throw error when numeric value is valid ", ^{
                        NSError *error = [subject validateOEF:numericOEFType];
                        error.localizedDescription should be_nil;
                    });
                    
                });
                
                context(@"When numeric value is valid", ^{
                    beforeEach(^{
                        
                        numericOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    });
                    
                    it(@"Should not throw error when numeric value is valid ", ^{
                        NSError *error = [subject validateOEF:numericOEFType];
                        error.localizedDescription should be_nil;
                    });
                    
                });
                
                context(@"When Whole number is within range and decimal value crosses the range", ^{
                    beforeEach(^{
                        
                        numericOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"9999999999.99999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    });
                    
                    it(@"Should not throw error when numeric value is valid ", ^{
                        NSError *error = [subject validateOEF:numericOEFType];
                        NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFNumericFieldValueLimitExceededError, nil), @"9999999999.9999", @"9999999999.9999"];
                        error.localizedDescription should equal(localizedString);
                    });
                    
                });
                
                context(@"When Whole number crosses range and decimal value within the range", ^{
                    beforeEach(^{
                        
                        numericOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"99999999999.99999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    });
                    
                    it(@"Should not throw error when numeric value is valid ", ^{
                        NSError *error = [subject validateOEF:numericOEFType];
                        NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFNumericFieldValueLimitExceededError, nil), @"9999999999.9999", @"9999999999.9999"];
                        error.localizedDescription should equal(localizedString);
                    });
                    
                });
            });
            
            context(@"When numeric value is negative", ^{
                
                context(@"When numeric value is valid and negative integer", ^{
                    beforeEach(^{
                        
                        numericOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"-230" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    });
                    
                    it(@"Should not throw error when numeric value is valid ", ^{
                        NSError *error = [subject validateOEF:numericOEFType];
                        error.localizedDescription should be_nil;
                    });
                });
                
                context(@"When numeric value is valid", ^{
                    beforeEach(^{
                        
                        numericOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"230.89" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    });
                    
                    it(@"Should not throw error when numeric value is valid ", ^{
                        NSError *error = [subject validateOEF:numericOEFType];
                        error.localizedDescription should be_nil;
                    });
                    
                });
                
                context(@"When Whole number is within range and decimal value crosses the range", ^{
                    beforeEach(^{
                        
                        numericOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"-9999999999.99999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    });
                    
                    it(@"Should not throw error when numeric value is valid ", ^{
                        NSError *error = [subject validateOEF:numericOEFType];
                        NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFNumericFieldValueLimitExceededError, nil), @"9999999999.9999", @"9999999999.9999"];
                        error.localizedDescription should equal(localizedString);
                    });
                    
                });
                
                context(@"When Whole number crosses range and decimal value within the range", ^{
                    beforeEach(^{
                        
                        numericOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"-99999999999.99999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    });
                    
                    it(@"Should not throw error when numeric value is valid ", ^{
                        NSError *error = [subject validateOEF:numericOEFType];
                        NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFNumericFieldValueLimitExceededError, nil), @"9999999999.9999", @"9999999999.9999"];
                        error.localizedDescription should equal(localizedString);
                    });
                    
                });
            });
            
        });
        
        context(@"When max precision and max scale in user defaults is not nil", ^{
            beforeEach(^{
                NSNumber *maxPrecision = [NSNumber numberWithInt:5];
                NSNumber *maxScale = [NSNumber numberWithInt:3];
                subject.userDefaults stub_method(@selector(objectForKey:)).with(OEFMaxPrecisionKey).and_return(maxPrecision);
                subject.userDefaults stub_method(@selector(objectForKey:)).with(OEFMaxScaleKey).and_return(maxScale);
                
            });
            
            context(@"When numeric value is positive", ^{
                
                context(@"When numeric value is valid", ^{
                    beforeEach(^{
                        
                        numericOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"23.999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    });
                    
                    it(@"Should not throw error when numeric value is valid ", ^{
                        NSError *error = [subject validateOEF:numericOEFType];
                        error.localizedDescription should be_nil;
                    });
                    
                });
                
                context(@"When Whole number is within range and decimal value crosses the range", ^{
                    beforeEach(^{
                        
                        numericOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"9999999999.99999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    });
                    
                    it(@"Should not throw error when numeric value is valid ", ^{
                        NSError *error = [subject validateOEF:numericOEFType];
                        NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFNumericFieldValueLimitExceededError, nil), @"99.999", @"99.999"];
                        error.localizedDescription should equal(localizedString);
                    });
                    
                });
                
                context(@"When Whole number crosses range and decimal value within the range", ^{
                    beforeEach(^{
                        
                        numericOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"99999999999.99999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    });
                    
                    it(@"Should not throw error when numeric value is valid ", ^{
                        NSError *error = [subject validateOEF:numericOEFType];
                        NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFNumericFieldValueLimitExceededError, nil), @"99.999", @"99.999"];
                        error.localizedDescription should equal(localizedString);
                    });
                    
                });
            });
            
            context(@"When numeric value is negative", ^{
                
                context(@"When numeric value is valid", ^{
                    beforeEach(^{
                        
                        numericOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"-99.999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    });
                    
                    it(@"Should not throw error when numeric value is valid ", ^{
                        NSError *error = [subject validateOEF:numericOEFType];
                        error.localizedDescription should be_nil;
                    });
                    
                });
                
                context(@"When Whole number is within range and decimal value crosses the range", ^{
                    beforeEach(^{
                        
                        numericOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"-9999999999.99999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    });
                    
                    it(@"Should not throw error when numeric value is valid ", ^{
                        NSError *error = [subject validateOEF:numericOEFType];
                        NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFNumericFieldValueLimitExceededError, nil), @"99.999", @"99.999"];
                        error.localizedDescription should equal(localizedString);
                    });
                    
                });
                
                context(@"When Whole number crosses range and decimal value within the range", ^{
                    beforeEach(^{
                        
                        numericOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"-99999999999.99999" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    });
                    
                    it(@"Should not throw error when numeric value is valid ", ^{
                        NSError *error = [subject validateOEF:numericOEFType];
                        NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFNumericFieldValueLimitExceededError, nil), @"99.999", @"99.999"];
                        error.localizedDescription should equal(localizedString);
                    });
                    
                });
            });
        });
        
    });
    
    context(@"Validate Text OEFType", ^{
       __block OEFType *textOEFType;
        
        context(@"When max char limit in user defaults is nil", ^{
            beforeEach(^{
                
                subject.userDefaults stub_method(@selector(objectForKey:)).with(OEFMaxTextCharLimitKey).and_return(nil);
            });
            
            context(@"When text value is valid and within default Max range", ^{
                beforeEach(^{
                    
                textOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                });
                
                it(@"Should not throw error when numeric value is valid ", ^{
                    NSError *error = [subject validateOEF:textOEFType];
                    error.localizedDescription should be_nil;
                });
                
            });
            
            context(@"When text value is valid and  text length equals default Max range", ^{
                beforeEach(^{
                    
                    textOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmno$%^&*1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                });
                
                it(@"Should not throw error when numeric value is valid ", ^{
                    NSError *error = [subject validateOEF:textOEFType];
                    error.localizedDescription should be_nil;
                });
                
            });
            
            context(@"When text value is valid and text length exceeds default Max range", ^{
                beforeEach(^{
                    
                    textOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmno$%^&*1pqrstubwxyz" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                });
                
                it(@"Should not throw error when numeric value is valid ", ^{
                    NSError *error = [subject validateOEF:textOEFType];
                    NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFTextFieldValueLimitExceededError, nil), @"255"];
                    error.localizedDescription should equal(localizedString);
                });
                
            });
        });
        
        context(@"When max char limit in user defaults is not nil", ^{
            beforeEach(^{
                
                NSNumber *maxTextLimit = [NSNumber numberWithInt:10];
                subject.userDefaults stub_method(@selector(objectForKey:)).with(OEFMaxTextCharLimitKey).and_return(maxTextLimit);
            });
            
            context(@"When text value is valid and within default Max range", ^{
                beforeEach(^{
                    
                    textOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"sample$" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                });
                
                it(@"Should not throw error when numeric value is valid ", ^{
                    NSError *error = [subject validateOEF:textOEFType];
                    error.localizedDescription should be_nil;
                });
                
            });
            
            context(@"When text value is valid and  text length equals default Max range", ^{
                beforeEach(^{
                    
                    textOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"123abcde h" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                });
                
                it(@"Should not throw error when numeric value is valid ", ^{
                    NSError *error = [subject validateOEF:textOEFType];
                    error.localizedDescription should be_nil;
                });
                
            });
            
            context(@"When text value is valid and text length exceeds default Max range", ^{
                beforeEach(^{
                    
                    textOEFType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmno$%^&*1pqrstubwxyz" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                });
                
                it(@"Should not throw error when numeric value is valid ", ^{
                    NSError *error = [subject validateOEF:textOEFType];
                    NSString *localizedString = [NSString stringWithFormat:RPLocalizedString(OEFTextFieldValueLimitExceededError, nil), @"10"];
                    error.localizedDescription should equal(localizedString);
                });
                
            });
        });
        
    });

});

SPEC_END
