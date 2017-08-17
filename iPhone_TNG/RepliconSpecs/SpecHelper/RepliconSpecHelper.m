#import "RepliconSpecHelper.h"

@implementation RepliconSpecHelper

+ (NSDictionary *)jsonWithFixture:(NSString *)fixtureResourceFilename
{
    NSBundle *specsBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [specsBundle pathForResource:fixtureResourceFilename ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    NSError *error;

    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                       options:0
                                                                         error:&error];


    return  responseDictionary;
}

+ (NSArray *)jsonArrayWithFixture:(NSString *)fixtureResourceFilename
{
    NSBundle *specsBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [specsBundle pathForResource:fixtureResourceFilename ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    NSError *error;
    
    NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                       options:0
                                                                         error:&error];
    
    
    return  responseArray;
}

+(NSString *)specialCharsEscapedString:(NSString *)string {
    NSError *error;
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"[+$?{}()\\]\\[^*\\\\|]"
                                                                                options:0
                                                                                  error:&error];
    
    NSString *cleanedString = [expression stringByReplacingMatchesInString:string
                                                                   options:0
                                                                     range:NSMakeRange(0, string.length)
                                                              withTemplate:@"\\\\$0"];
    return cleanedString;
}

@end
