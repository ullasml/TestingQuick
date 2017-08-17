#import "PunchSerializer.h"
#import "Punch.h"
#import "Util.h"
#import "Constants.h"
#import "BreakType.h"
#import "Activity.h"
#import "ProjectType.h"
#import "ClientType.h"
#import "TaskType.h"
#import "OEFType.h"


@implementation PunchSerializer

- (NSDictionary *)timePunchDictionaryForPunch:(id<Punch>)punch
{
    NSDictionary *userURIDictionary = @{@"uri": punch.userURI};

    NSDictionary *dateDict = [Util convertDateToApiTimeDateDictionary:punch.date];

    NSDictionary *locationDictionary = (id)[NSNull null];
    NSString *addressString = punch.address ? : @"address unavailable";
    if (punch.location) {
        locationDictionary= @{
                             @"gps": @{
                                     @"latitudeInDegrees": @(punch.location.coordinate.latitude),
                                     @"longitudeInDegrees": @(punch.location.coordinate.longitude),
                                     @"accuracyInMeters": @(punch.location.horizontalAccuracy)
                                     },
                             @"address": addressString
                             };
    }

    NSString *actionUri = @{@(PunchActionTypePunchIn): PUNCH_ACTION_URI_IN,
                            @(PunchActionTypePunchOut): PUNCH_ACTION_URI_OUT,
                            @(PunchActionTypeStartBreak): PUNCH_ACTION_URI_BREAK,
                            @(PunchActionTypeTransfer): PUNCH_ACTION_URI_TRANSFER,
                            }[@(punch.actionType)];

    NSDictionary *auditImageDictionary = (id)[NSNull null];
    NSString *auditImageProvisioningIntentUri = @"urn:replicon:time-punch-audit-image-provisioning-intent:no-image";

    if ([punch respondsToSelector:@selector(image)] && punch.image)
    {
        auditImageDictionary = @{@"image": @{
                                         @"base64ImageData": [UIImageJPEGRepresentation(punch.image, 1.0) base64EncodedStringWithOptions:0],
                                         @"mimeType": @"image/jpeg"
                                         },
                                 @"imageUri": [NSNull null]};
        auditImageProvisioningIntentUri = @"urn:replicon:time-punch-audit-image-provisioning-intent:image-provided";
    }

    NSDictionary *auditDictionary = @{@"timePunchAgent": [NSNull null],
                                      @"geolocation": locationDictionary,
                                      @"auditImageProvisioningIntentUri": auditImageProvisioningIntentUri,
                                      @"auditImage": auditImageDictionary};


    NSMutableDictionary *timePunchContentsDictionary = [@{
                                                          @"user": userURIDictionary,
                                                          @"punchTime": dateDict,
                                                          @"actionUri": actionUri
                                                          } mutableCopy];

    if (punch.actionType == PunchActionTypeStartBreak)
    {
        if ( punch.breakType.uri != nil && ![ punch.breakType.uri isKindOfClass:[NSNull class]] &&  punch.breakType.uri.length > 0 ) {
             timePunchContentsDictionary[@"punchStartBreakAttributes"] = @{@"breakType": @{@"uri": punch.breakType.uri}};
        }

    }

    NSMutableDictionary *punchInAttributes = [[NSMutableDictionary alloc]init];

    NSString *activityUri = punch.activity.uri;
    if (activityUri != nil && ![activityUri isKindOfClass:[NSNull class]] && activityUri.length > 0 ) {
        [punchInAttributes setObject:@{@"uri": activityUri} forKey:@"activity"];
    }

    NSString *projectUri = punch.project.uri;
    if (projectUri != nil && ![projectUri isKindOfClass:[NSNull class]] &&  projectUri.length > 0) {
        [punchInAttributes setObject:@{@"uri": projectUri, @"displayText":punch.project.name} forKey:@"project"];
    }

    NSString *taskUri = punch.task.uri;
    if (taskUri != nil&& ![taskUri isKindOfClass:[NSNull class]]  && taskUri.length > 0 ) {
        [punchInAttributes setObject:@{@"uri": taskUri, @"displayText":punch.task.name} forKey:@"task"];
    }

    if (punchInAttributes != nil && punchInAttributes != (id) [NSNull null] && punchInAttributes.allKeys.count > 0) {
        timePunchContentsDictionary[@"punchInAttributes"] = punchInAttributes;
    }

    NSMutableArray *extensionFieldValues = [[NSMutableArray alloc]init];
    for (OEFType *oefType in punch.oefTypesArray)
    {
        NSMutableDictionary *extensionFieldValuesDict =[NSMutableDictionary dictionary];
        [extensionFieldValuesDict setObject:@{@"uri" : oefType.oefUri} forKey:@"definition"];
        if ([oefType.oefDefinitionTypeUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI]) {
            if (oefType.oefNumericValue != nil && ![oefType.oefNumericValue isKindOfClass:[NSNull class]])
            {
                if (oefType.oefNumericValue.length > 0)
                {
                    [extensionFieldValuesDict setObject:oefType.oefNumericValue forKey:@"numericValue"];
                    [extensionFieldValues addObject:extensionFieldValuesDict];
                }
            }

        }
        else if ([oefType.oefDefinitionTypeUri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI]){
            if (oefType.oefTextValue != nil && ![oefType.oefTextValue isKindOfClass:[NSNull class]])
            {
                if (oefType.oefTextValue.length > 0)
                {
                    [extensionFieldValuesDict setObject:oefType.oefTextValue forKey:@"textValue"];
                    [extensionFieldValues addObject:extensionFieldValuesDict];
                }
            }

        }
        else if ([oefType.oefDefinitionTypeUri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI]){
            if (oefType.oefDropdownOptionUri != nil && ![oefType.oefDropdownOptionUri isKindOfClass:[NSNull class]])
            {
                [extensionFieldValuesDict setObject:@{@"uri": oefType.oefDropdownOptionUri} forKey:@"tag"];
                [extensionFieldValues addObject:extensionFieldValuesDict];
            }

        }

    }

    if (extensionFieldValues.count>0)
    {
        timePunchContentsDictionary[@"extensionFieldValues"] = extensionFieldValues;
    }


    NSString *connectivityString = @"urn:replicon:device-connectivity-status:online";

    if ([punch respondsToSelector:@selector(offline)] && punch.offline)
    {
        connectivityString = @"urn:replicon:device-connectivity-status:offline";
    }

    BOOL isAuthenticPunch = NO;
    if ([punch respondsToSelector:@selector(authentic)] && punch.authentic)
    {
        isAuthenticPunch = YES;
    }

    id uuidString = [NSNull null];
    if (punch.requestID)
    {
        uuidString = punch.requestID;
    }


    NSDictionary *timePunchDictionary = @{@"timePunch": timePunchContentsDictionary,
                                          @"audit": auditDictionary,
                                          @"deviceConnectivityStatusUri": connectivityString,
                                          @"isAuthenticTimePunch":@(isAuthenticPunch),
                                          @"parameterCorrelationId":uuidString
                                          };

    return timePunchDictionary;
}

@end
