#import <Cedar/Cedar.h>
#import "AstroUserDetector.h"
#import "RepliconSpecHelper.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;



SPEC_BEGIN(AstroUserDetectorSpec)

describe(@"AstroUserDetector", ^{
    __block AstroUserDetector *subject;
    __block BOOL isAstroUser;
    __block NSDictionary *widgetTimesheetCapabilities;
    beforeEach(^{
        subject = [[AstroUserDetector alloc] init];
    });
    
    describe(@"-isAstroUserWithUserSummary:", ^{
        
        context(@"When widget platform is not supported", ^{
            
            context(@"when the timePunchCapabilities dictionary exists", ^{
                
                context(@"when the widgetTimesheetCapabilities dictionary does not exists", ^{
                    
                    __block NSDictionary *nullWidgetTimesheetCapabilities;
                    beforeEach(^{
                        nullWidgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"widgetTimesheetCapabilities"];
                    });
                    
                    it(@"should negatively identify an astro user when "
                       @"the user has time punch access, "
                       @"the user has client access, "
                       @"the user has project access, "
                       @"the user has activity access, "
                       @"and there are no custom punch extension fields", ^{
                           
                           NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                           timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                           timePunchCapabilities[@"hasProjectAccess"] = @1;
                           timePunchCapabilities[@"hasClientAccess"] = @1;
                           timePunchCapabilities[@"hasActivityAccess"] = @1;
                           timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                           
                           
                           [subject isAstroUserWithCapabilities:nullWidgetTimesheetCapabilities
                                          timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO] should be_truthy;
                       });
                    
                    it(@"should positively identify an astro user when "
                       @"the user has time punch access, "
                       @"does not have activity access, "
                       @"and there are no custom punch extension fields", ^{
                           
                           NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                           timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                           timePunchCapabilities[@"hasActivityAccess"] = @0;
                           timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                           
                           
                           [subject isAstroUserWithCapabilities:nullWidgetTimesheetCapabilities
                                          timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO] should be_truthy;
                       });
                    
                    it(@"should positively identify an astro user when "
                       @"the user has time punch access, "
                       @"does not have activity access, "
                       @"and there are no custom punch extension fields", ^{
                           NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                           timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                           timePunchCapabilities[@"hasActivityAccess"] = @0;
                           timePunchCapabilities[@"timePunchExtensionFields"] = [NSNull null];
                           
                           [subject isAstroUserWithCapabilities:nullWidgetTimesheetCapabilities
                                          timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO] should be_truthy;
                       });
                    
                    it(@"should negatively identify an astro user when "
                       @"the user does not have both time punch access and manual time punch access",
                       ^{
                           
                           NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                           timePunchCapabilities[@"hasTimePunchAccess"] = @0;
                           timePunchCapabilities[@"hasManualTimePunchAccess"] = @0;
                           
                           [subject isAstroUserWithCapabilities:nullWidgetTimesheetCapabilities
                                          timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO] should be_falsy;
                       });
                    
                    it(@"should positively identify an astro user when "
                       @"the user has manual time punch access but not time punch access ",
                       ^{
                           
                           NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                           timePunchCapabilities[@"hasTimePunchAccess"] = @0;
                           timePunchCapabilities[@"hasManualTimePunchAccess"] = @1;
                           
                           [subject isAstroUserWithCapabilities:nullWidgetTimesheetCapabilities
                                          timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO] should be_truthy;
                       });
                    
                    it(@"should positively identify an astro user when "
                       @"does have activity access ",
                       ^{
                           NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                           timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                           timePunchCapabilities[@"hasActivityAccess"] = @1;
                           
                           [subject isAstroUserWithCapabilities:nullWidgetTimesheetCapabilities
                                          timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO] should be_truthy;
                       });
                    
                    it(@"should negatively identify an astro user when "
                       @"there are custom punch extension fields",
                       ^{
                           NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                           timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                           timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@{}]};
                           
                           [subject isAstroUserWithCapabilities:nullWidgetTimesheetCapabilities
                                          timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO] should be_truthy;
                           
                       });
                    
                });
                
                context(@"when the widgetTimesheetCapabilities dictionary exists", ^{
                    __block BOOL isAstroUser ;
                    __block NSDictionary *widgetTimesheetCapabilities;
                    context(@"When user has only punch widget "
                            @"and the user has time punch access, "
                            @"does not have activity access, "
                            @"and there are no custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 }];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should positively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When user has only punch widget "
                            @"and the user does not have both manual time punch access and time punch access, "
                            @"does not have activity access, "
                            @"and there are no custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 }];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @0;
                                    timePunchCapabilities[@"hasManualTimePunchAccess"] = @0;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should negatively identify an astro user", ^{
                                    isAstroUser should be_falsy;
                                });
                            });
                    
                    context(@"When user has only punch widget "
                            @"and the user has manual time punch access but not time punch access, "
                            @"does not have activity access, "
                            @"and there are no custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 }];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @0;
                                    timePunchCapabilities[@"hasManualTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should negatively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When user has other widget along with punch widget "
                            @"and the user has time punch access, "
                            @"does not have activity access, "
                            @"does have notice widget,"
                            @"and there are no custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"text": @"this is title",
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                                     },
                                                                                 @{
                                                                                     @"text": @"this is text",
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                                     }
                                                                                 ],
                                                                         @"number": @3,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 }];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @1;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should negatively identify an astro user", ^{
                                    isAstroUser should be_falsy;
                                });
                            });
                    
                    context(@"When user has other widget along with punch widget "
                            @"and the user has time punch access, "
                            @"does not have activity access, "
                            @"does have notice widget,"
                            @"and there are custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"text": @"this is title",
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                                     },
                                                                                 @{
                                                                                     @"text": @"this is text",
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                                     }
                                                                                 ],
                                                                         @"number": @3,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 }];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @1;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@{}]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should negatively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When user has other widget along with punch widget "
                            @"and the user has time punch access, "
                            @"does not have activity access, "
                            @"does have attestation and notice widget,"
                            @"and there are no custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue" :     @{
                                                                         @"bool" : @1,
                                                                         @"collection" :         @[
                                                                                 @{
                                                                                     @"text" : @"attestation title",
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-title"
                                                                                     },
                                                                                 @{
                                                                                     @"text" : @"attestation text",
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-text"
                                                                                     }
                                                                                 ],
                                                                         @"number" : @2,
                                                                         @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"text": @"this is title",
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                                     },
                                                                                 @{
                                                                                     @"text": @"this is text",
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                                     }
                                                                                 ],
                                                                         @"number": @3,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 }];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @1;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should negatively identify an astro user", ^{
                                    isAstroUser should be_falsy;
                                });
                            });
                    
                    context(@"When user has other widget along with punch widget "
                            @"and the user has time punch access, "
                            @"does not have activity access, "
                            @"does have attestation and notice widget,"
                            @"and there are custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue" :     @{
                                                                         @"bool" : @1,
                                                                         @"collection" :         @[
                                                                                 @{
                                                                                     @"text" : @"attestation title",
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-title"
                                                                                     },
                                                                                 @{
                                                                                     @"text" : @"attestation text",
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-text"
                                                                                     }
                                                                                 ],
                                                                         @"number" : @2,
                                                                         @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"text": @"this is title",
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                                     },
                                                                                 @{
                                                                                     @"text": @"this is text",
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                                     }
                                                                                 ],
                                                                         @"number": @3,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 }];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @1;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@{}]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should negatively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When user has only punch widget and payroll widget "
                            @"and the user has time punch access, "
                            @"does not have activity access, "
                            @"and there are no custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                                     },
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                                     }
                                                                                 ],
                                                                         @"number": @2.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                         }
                                                                 }
                                                             
                                                             ];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @1;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should positively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When user has punch widget and payroll widget and also any other widget "
                            @"and the user has time punch access, "
                            @"does not have activity access, "
                            @"and there are no custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"text": @"this is title",
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                                     },
                                                                                 @{
                                                                                     @"text": @"this is text",
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                                     }
                                                                                 ],
                                                                         @"number": @3,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                                     },
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                                     }
                                                                                 ],
                                                                         @"number": @2.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                         }
                                                                 }
                                                             
                                                             ];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should negatively identify an astro user", ^{
                                    isAstroUser should be_falsy;
                                });
                            });
                    
                    context(@"When no widget enabled "
                            @"and the user has time punch access, "
                            @"does not have activity access, "
                            @"and there are no custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 }
                                                             
                                                             ];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should negatively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When no widget enabled "
                            @"and the user has time punch access, "
                            @"does not have activity or project or client access, "
                            @"and there are notice and attestation and time distribution widget,"
                            @"and there are no custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"text": @"this is title",
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-title"
                                                                                     }                                                                     ],
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue" :     @{
                                                                         @"bool" : @1,
                                                                         @"collection" :         @[
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:filter-projects-by"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:filter-projects-by:clients"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:snap-time-to-nearest"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:snap-time-to-nearest:do-not-snap"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:projects-and-tasks"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:projects-and-tasks:allow-projects-and-tasks"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:billing-options"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:billing-options:allow-billing-options"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:activities"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:activities:allow-activities"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:time-entry-comments"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:time-entry-comments:allow-time-entry-comments"
                                                                                     }
                                                                                 ],
                                                                         @"number" : @3,
                                                                         @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"text": @"this is title",
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                                     },
                                                                                 @{
                                                                                     @"text": @"this is text",
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                                     }
                                                                                 ],
                                                                         @"number": @3,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue" :     @{
                                                                         @"bool" : @1,
                                                                         @"number" : @4,
                                                                         @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:approval-history"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 }
                                                             
                                                             ];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should negatively identify an astro user", ^{
                                    isAstroUser should be_falsy;
                                });
                            });
                    
                    context(@"When no widget enabled "
                            @"and the user has time punch access, "
                            @"does not have activity or project or client access, "
                            @"and there are notice and attestation and time distribution widget,"
                            @"and there are no custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"text": @"this is title",
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-title"
                                                                                     }                                                                     ],
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"text": @"this is title",
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                                     },
                                                                                 @{
                                                                                     @"text": @"this is text",
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                                     }
                                                                                 ],
                                                                         @"number": @3,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue" :     @{
                                                                         @"bool" : @1,
                                                                         @"number" : @4,
                                                                         @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:approval-history"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 }
                                                             
                                                             ];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@"oef1",@"oef2"]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When no widget enabled "
                            @"and the user has time punch access, "
                            @"does not have activity access, "
                            @"and there are custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 }
                                                             
                                                             ];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@"oef1",@"oef2"]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should negatively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When user has only punch widget and payroll widget "
                            @"and the user has time punch access, "
                            @"does have activity access, "
                            @"and there are  custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                                     },
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                                     }
                                                                                 ],
                                                                         @"number": @2.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                         }
                                                                 }
                                                             
                                                             ];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @1;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@"oef1",@"oef2"]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should positively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When user has only punch widget and payroll widget "
                            @"and the user has time punch access, "
                            @"does not have activity access, "
                            @"does have project access, "
                            @"and there are  custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                                     },
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                                     }
                                                                                 ],
                                                                         @"number": @2.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                         }
                                                                 }
                                                             
                                                             ];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"hasProjectAccess"] = @1;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@"oef1",@"oef2"]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should positively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When user has only punch widget and payroll widget "
                            @"and the user has time punch access, "
                            @"does not have activity access, "
                            @"does have client access, "
                            @"and there are  custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                                     },
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                                     }
                                                                                 ],
                                                                         @"number": @2.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                         }
                                                                 }
                                                             
                                                             ];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"hasClientAccess"] = @1;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@"oef1",@"oef2"]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should positively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When user has only punch widget and payroll widget "
                            @"and the user has time punch access, "
                            @"does not have activity access, "
                            @"does have Project access, "
                            @"does have client access, "
                            @"and there are  custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                                     },
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                                     }
                                                                                 ],
                                                                         @"number": @2.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                         }
                                                                 }
                                                             
                                                             ];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"hasProjectAccess"] = @1;
                                    timePunchCapabilities[@"hasClientAccess"] = @1;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@"oef1",@"oef2"]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should positively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When user has only punch widget and payroll widget "
                            @"and the user has time punch access, "
                            @"does not have activity access, "
                            @"does not have project access, "
                            @"and there are  custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                                     },
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                                     }
                                                                                 ],
                                                                         @"number": @2.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                         }
                                                                 }
                                                             
                                                             ];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"hasProjectAccess"] = @0;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@"oef1",@"oef2"]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should positively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When user has only punch widget and payroll widget "
                            @"and the user has time punch access, "
                            @"does have activity access, "
                            @"does have project access, "
                            @"does have client access, "
                            @"and there are  custom punch extension fields", ^{
                                beforeEach(^{
                                    
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                                     },
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                                     }
                                                                                 ],
                                                                         @"number": @2.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                         }
                                                                 }
                                                             
                                                             ];
                                    NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @1;
                                    timePunchCapabilities[@"hasProjectAccess"] = @1;
                                    timePunchCapabilities[@"hasClientAccess"] = @1;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@"oef1",@"oef2"]};
                                    
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                                 timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should positively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When attestation widget along"
                            @"with punch widget is configured"
                            @"with no activity"
                            @"with no OEF", ^{
                                
                                beforeEach(^{
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                                     },
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                                     }
                                                                                 ],
                                                                         @"number": @2.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"text": @"this is title",
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-title"
                                                                                     }                                                                     ],
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 }];
                                    
                                    widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasProjectAccess"] = @1;
                                    timePunchCapabilities[@"hasClientAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = [NSNull null];
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should negatively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When in out widget along"
                            @"with punch widget is configured"
                            @"with no activity"
                            @"with no OEF", ^{
                                
                                beforeEach(^{
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                                     },
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                                     }
                                                                                 ],
                                                                         @"number": @2.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         @"bool" : @1,
                                                                         @"collection" :         @[
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:track-breaks"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:track-breaks:allow-track-breaks"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:time-entry-comments"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:time-entry-comments:allow-time-entry-comments"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:snap-time-to-nearest"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:snap-time-to-nearest:do-not-snap-times"
                                                                                     }
                                                                                 ],
                                                                         @"number" : @8,
                                                                         @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 }];
                                    
                                    widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasProjectAccess"] = @1;
                                    timePunchCapabilities[@"hasClientAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = [NSNull null];
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should negatively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When schedule widget along"
                            @"with punch widget is configured"
                            @"with no activity"
                            @"with no OEF", ^{
                                
                                beforeEach(^{
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                                     },
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                                     }
                                                                                 ],
                                                                         @"number": @2.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         @"bool" : @1,
                                                                         @"number" : @5,
                                                                         @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:schedule"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 }];
                                    
                                    widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasProjectAccess"] = @1;
                                    timePunchCapabilities[@"hasClientAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = [NSNull null];
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should negatively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When approvals history widget along"
                            @"with punch widget is configured"
                            @"with no activity"
                            @"with no OEF", ^{
                                
                                beforeEach(^{
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                                     },
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                                     }
                                                                                 ],
                                                                         @"number": @2.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         @"bool" : @1,
                                                                         @"number" : @5,
                                                                         @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:schedule"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         @"bool" : @1,
                                                                         @"number" : @1,
                                                                         @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:approval-history"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 }];
                                    
                                    widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasProjectAccess"] = @1;
                                    timePunchCapabilities[@"hasClientAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = [NSNull null];
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should negatively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When allocation entry widget along"
                            @"with punch widget is configured"
                            @"with no activity"
                            @"with no OEF", ^{
                                
                                beforeEach(^{
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         @"bool" : @1,
                                                                         @"collection" :         @[
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:filter-projects-by"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:filter-projects-by:clients"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:snap-time-to-nearest"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:snap-time-to-nearest:do-not-snap"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:projects-and-tasks"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:projects-and-tasks:allow-projects-and-tasks"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:billing-options"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:billing-options:allow-billing-options"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:activities"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:activities:allow-activities"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:time-entry-comments"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:time-entry-comments:allow-time-entry-comments"
                                                                                     }
                                                                                 ],
                                                                         @"number" : @3,
                                                                         @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                                     },
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                                     }
                                                                                 ],
                                                                         @"number": @2.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         @"bool" : @1,
                                                                         @"number" : @5,
                                                                         @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:schedule"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         @"bool" : @1,
                                                                         @"number" : @1,
                                                                         @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:approval-history"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 }];
                                    
                                    widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasProjectAccess"] = @1;
                                    timePunchCapabilities[@"hasClientAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = [NSNull null];
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should negatively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                    
                    context(@"When in-out-time-entry widget along"
                            @"with punch widget is configured"
                            @"with no activity"
                            @"with no OEF", ^{
                                
                                beforeEach(^{
                                    NSArray *widgetArray = @[
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                                 @"policyValue": @{
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"collection": @[
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                                     },
                                                                                 @{
                                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                                     }
                                                                                 ],
                                                                         @"number": @2.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                                 @"policyValue": @{
                                                                         
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                                 @"policyValue": @{
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                                 @"policyValue": @{
                                                                         @"bool" : @1,
                                                                         @"collection" :       @[
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:track-breaks"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:track-breaks:allow-track-breaks"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:time-entry-comments"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:time-entry-comments:allow-time-entry-comments"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:snap-time-to-nearest"
                                                                                     },
                                                                                 @{
                                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:snap-time-to-nearest:do-not-snap-times"
                                                                                     }
                                                                                 ],
                                                                         @"number" : @8,
                                                                         @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                                 @"policyValue": @{
                                                                         @"bool" : @1,
                                                                         @"number" : @1,
                                                                         @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:approval-history"
                                                                         }
                                                                 },
                                                             @{
                                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                                 @"policyValue": @{
                                                                         @"bool": @1,
                                                                         @"number": @1.0000,
                                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                         }
                                                                 }];
                                    
                                    widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                                    timePunchCapabilities[@"hasProjectAccess"] = @1;
                                    timePunchCapabilities[@"hasClientAccess"] = @1;
                                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                                    timePunchCapabilities[@"timePunchExtensionFields"] = [NSNull null];
                                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                                });
                                
                                it(@"should negatively identify an astro user", ^{
                                    isAstroUser should be_truthy;
                                });
                            });
                });
            });
            context(@"When the timePunchCapabilities dictionary does not exists", ^{
                
                context(@"When the widgetTimesheetCapabilities dictionary exists", ^{
                    __block BOOL isAstroUser ;
                    __block NSDictionary *widgetTimesheetCapabilities;
                    context(@"When only punch Widget is configured", ^{
                        beforeEach(^{
                            NSArray *widgetArray = @[
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"number": @1.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                 }
                                                         }];
                            widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                            isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:(id)[NSNull null] isWidgetPlatformSupported:NO];
                        });
                        
                        it(@"should negatively identify an astro user", ^{
                            isAstroUser should be_falsy;
                        });
                    });
                    
                    context(@"When any other widget along with punch widget is configured with activity without notice or attestation widget", ^{
                        
                        beforeEach(^{
                            NSArray *widgetArray = @[
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                             },
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                             }
                                                                         ],
                                                                 @"number": @2.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"number": @1.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                 }
                                                         }];
                            
                            widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                            NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                            timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                            timePunchCapabilities[@"hasActivityAccess"] = @1;
                            timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                            isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                        });
                        
                        it(@"should  identify an astro user", ^{
                            isAstroUser should be_truthy;
                        });
                    });
                    
                    context(@"When any other widget along with punch widget is configured with activity and notice and attestation widget", ^{
                        
                        beforeEach(^{
                            NSArray *widgetArray = @[
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                         @"policyValue" :     @{
                                                                 @"bool" : @1,
                                                                 @"collection" :         @[
                                                                         @{
                                                                             @"text" : @"attestation title",
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-title"
                                                                             },
                                                                         @{
                                                                             @"text" : @"attestation text",
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-text"
                                                                             }
                                                                         ],
                                                                 @"number" : @2,
                                                                 @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                             },
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                             }
                                                                         ],
                                                                 @"number": @2.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"text": @"this is title",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                             },
                                                                         @{
                                                                             @"text": @"this is text",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                             }
                                                                         ],
                                                                 @"number": @3,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"number": @1.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                 }
                                                         }];
                            
                            widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                            NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                            timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                            timePunchCapabilities[@"hasActivityAccess"] = @1;
                            timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                            isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                        });
                        
                        it(@"should negatively identify an astro user", ^{
                            isAstroUser should be_falsy;
                        });
                    });
                    
                    context(@"When any other widget along with punch widget is configured with no activity and no OEF", ^{
                        
                        beforeEach(^{
                            NSArray *widgetArray = @[
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                             },
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                             }
                                                                         ],
                                                                 @"number": @2.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"text": @"this is title",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                             },
                                                                         @{
                                                                             @"text": @"this is text",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                             }
                                                                         ],
                                                                 @"number": @3,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"number": @1.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                 }
                                                         }];
                            
                            widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                            NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                            timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                            timePunchCapabilities[@"hasProjectAccess"] = @1;
                            timePunchCapabilities[@"hasClientAccess"] = @1;
                            timePunchCapabilities[@"hasActivityAccess"] = @0;
                            timePunchCapabilities[@"timePunchExtensionFields"] = [NSNull null];
                            isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                        });
                        
                        it(@"should negatively identify an astro user", ^{
                            isAstroUser should be_truthy;
                        });
                    });
                    
                    context(@"When any other widget along with punch widget is configured with activity and with OEF and have notice widget", ^{
                        
                        beforeEach(^{
                            NSArray *widgetArray = @[
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                             },
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                             }
                                                                         ],
                                                                 @"number": @2.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"text": @"this is title",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                             },
                                                                         @{
                                                                             @"text": @"this is text",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                             }
                                                                         ],
                                                                 @"number": @3,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"number": @1.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                 }
                                                         }];
                            
                            widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                            NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                            timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                            timePunchCapabilities[@"hasProjectAccess"] = @1;
                            timePunchCapabilities[@"hasClientAccess"] = @1;
                            timePunchCapabilities[@"hasActivityAccess"] = @1;
                            timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@{}]};
                            isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                        });
                        
                        it(@"should negatively identify an astro user", ^{
                            isAstroUser should be_truthy;
                        });
                    });
                    
                    context(@"When any other widget along with punch widget is configured with activity and with OEF and have notice and attestation widget", ^{
                        
                        beforeEach(^{
                            NSArray *widgetArray = @[
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                         @"policyValue" :     @{
                                                                 @"bool" : @1,
                                                                 @"collection" :         @[
                                                                         @{
                                                                             @"text" : @"attestation title",
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-title"
                                                                             },
                                                                         @{
                                                                             @"text" : @"attestation text",
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-text"
                                                                             }
                                                                         ],
                                                                 @"number" : @2,
                                                                 @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                             },
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                             }
                                                                         ],
                                                                 @"number": @2.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"text": @"this is title",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                             },
                                                                         @{
                                                                             @"text": @"this is text",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                             }
                                                                         ],
                                                                 @"number": @3,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"number": @1.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                 }
                                                         }];
                            
                            widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                            NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                            timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                            timePunchCapabilities[@"hasProjectAccess"] = @1;
                            timePunchCapabilities[@"hasClientAccess"] = @1;
                            timePunchCapabilities[@"hasActivityAccess"] = @1;
                            timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@{}]};
                            isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                        });
                        
                        it(@"should negatively identify an astro user", ^{
                            isAstroUser should be_truthy;
                        });
                    });
                    
                    
                    context(@"When any other widget along with punch widget is configured with activity and with OEF", ^{
                        
                        beforeEach(^{
                            NSArray *widgetArray = @[
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                             },
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                             }
                                                                         ],
                                                                 @"number": @2.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"number": @1.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                 }
                                                         }];
                            
                            widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                            NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                            timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                            timePunchCapabilities[@"hasProjectAccess"] = @1;
                            timePunchCapabilities[@"hasClientAccess"] = @1;
                            timePunchCapabilities[@"hasActivityAccess"] = @1;
                            timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                            isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                        });
                        
                        it(@"should negatively identify an astro user", ^{
                            isAstroUser should be_truthy;
                        });
                    });
                    
                    context(@"When any other widget along with punch widget is configured with activity and with OEF", ^{
                        
                        beforeEach(^{
                            NSArray *widgetArray = @[
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                             },
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                             }
                                                                         ],
                                                                 @"number": @2.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"text": @"this is title",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                             },
                                                                         @{
                                                                             @"text": @"this is text",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                             }
                                                                         ],
                                                                 @"number": @3,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"number": @1.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                 }
                                                         }];
                            
                            widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                            NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                            timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                            timePunchCapabilities[@"hasProjectAccess"] = @1;
                            timePunchCapabilities[@"hasClientAccess"] = @1;
                            timePunchCapabilities[@"hasActivityAccess"] = @0;
                            timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                            isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                        });
                        
                        it(@"should negatively identify an astro user", ^{
                            isAstroUser should be_truthy;
                        });
                    });
                    
                    context(@"When any other widget along with punch widget is configured with activity and with OEF", ^{
                        
                        beforeEach(^{
                            NSArray *widgetArray = @[
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                             },
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                             }
                                                                         ],
                                                                 @"number": @2.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"text": @"this is title",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                             },
                                                                         @{
                                                                             @"text": @"this is text",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                             }
                                                                         ],
                                                                 @"number": @3,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"number": @1.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                 }
                                                         }];
                            
                            widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                            NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                            timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                            timePunchCapabilities[@"hasProjectAccess"] = @1;
                            timePunchCapabilities[@"hasClientAccess"] = @1;
                            timePunchCapabilities[@"hasActivityAccess"] = @0;
                            timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@{@"oef1":@"value1"}]};
                            isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:NO];
                        });
                        
                        it(@"should positively identify an astro user", ^{
                            isAstroUser should be_truthy;
                        });
                    });
                    
                    context(@"When only punch widget and payroll widget is configured ", ^{
                        
                        beforeEach(^{
                            NSArray *widgetArray = @[
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"number": @1.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                             },
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                             }
                                                                         ],
                                                                 @"number": @2.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         }
                                                     ];
                            
                            widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                            isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:(id)[NSNull null] isWidgetPlatformSupported:NO];
                        });
                        
                        it(@"should negatively identify an astro user", ^{
                            isAstroUser should be_falsy;
                        });
                    });
                    
                });
                
                
                
                context(@"when the widgetTimesheetCapabilities dictionary does not exists", ^{
                    __block BOOL isAstroUser ;
                    beforeEach(^{
                        NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"widgetTimesheetCapabilities"];
                        isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities
                                                     timePunchCapabilities:(id)[NSNull null] isWidgetPlatformSupported:NO];
                    });
                    
                    it(@"should negatively identify an astro user", ^{
                        isAstroUser should be_falsy;
                    });
                });
            });
        });
        
        context(@"When widget platform is  supported", ^{
            
            
            context(@"When user has other widget along with punch widget "
                    @"and the user has time punch access, "
                    @"does not have activity access, "
                    @"does have notice widget,"
                    @"and there are no custom punch extension fields", ^{
                        beforeEach(^{
                            
                            NSArray *widgetArray = @[
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"text": @"this is title",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                             },
                                                                         @{
                                                                             @"text": @"this is text",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                             }
                                                                         ],
                                                                 @"number": @3,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"number": @1.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                 }
                                                         }];
                            NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                            
                            NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                            timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                            timePunchCapabilities[@"hasActivityAccess"] = @1;
                            timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                            
                            isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:YES];
                        });
                        
                        it(@"should negatively identify an astro user", ^{
                            isAstroUser should be_truthy;
                        });
                    });
            
            context(@"When user has other widget along with punch widget "
                    @"and the user has time punch access, "
                    @"does not have activity access, "
                    @"does have notice widget,"
                    @"and there are custom punch extension fields", ^{
                        beforeEach(^{
                            
                            NSArray *widgetArray = @[
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"text": @"this is title",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                             },
                                                                         @{
                                                                             @"text": @"this is text",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                             }
                                                                         ],
                                                                 @"number": @3,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"number": @1.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                 }
                                                         }];
                            NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                            
                            NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                            timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                            timePunchCapabilities[@"hasActivityAccess"] = @1;
                            timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@{}]};
                            
                            isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:YES];
                        });
                        
                        it(@"should negatively identify an astro user", ^{
                            isAstroUser should be_truthy;
                        });
                    });
            
            
            context(@"When user has other widget along with punch widget "
                    @"and the user has time punch access, "
                    @"does not have activity access, "
                    @"does have attestation and notice widget,"
                    @"and there are custom punch extension fields", ^{
                        beforeEach(^{
                            
                            NSArray *widgetArray = @[
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                         @"policyValue" :     @{
                                                                 @"bool" : @1,
                                                                 @"collection" :         @[
                                                                         @{
                                                                             @"text" : @"attestation title",
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-title"
                                                                             },
                                                                         @{
                                                                             @"text" : @"attestation text",
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-text"
                                                                             }
                                                                         ],
                                                                 @"number" : @2,
                                                                 @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"text": @"this is title",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                             },
                                                                         @{
                                                                             @"text": @"this is text",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                             }
                                                                         ],
                                                                 @"number": @3,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"number": @1.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                 }
                                                         }];
                            NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                            
                            NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                            timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                            timePunchCapabilities[@"hasActivityAccess"] = @1;
                            timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@{}]};
                            
                            isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:YES];
                        });
                        
                        it(@"should negatively identify an astro user", ^{
                            isAstroUser should be_truthy;
                        });
                    });
            
            context(@"When user has punch widget and payroll widget and also any other widget "
                    @"and the user has time punch access, "
                    @"does not have activity access, "
                    @"and there are no custom punch extension fields", ^{
                        beforeEach(^{
                            
                            NSArray *widgetArray = @[
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"number": @1.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"text": @"this is title",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                             },
                                                                         @{
                                                                             @"text": @"this is text",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                             }
                                                                         ],
                                                                 @"number": @3,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                             },
                                                                         @{
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                             }
                                                                         ],
                                                                 @"number": @2.0000,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                                 }
                                                         }
                                                     
                                                     ];
                            NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                            
                            NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                            timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                            timePunchCapabilities[@"hasActivityAccess"] = @0;
                            timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                            
                            isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:YES];
                        });
                        
                        it(@"should negatively identify an astro user", ^{
                            isAstroUser should be_truthy;
                        });
                    });
            
            context(@"When notice and attestation and time distribution widget"
                    @"and the user has time punch access, "
                    @"does not have activity or project or client access, "
                    @"and there are no custom punch extension fields", ^{
                        beforeEach(^{
                            
                            NSArray *widgetArray = @[
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"text": @"this is title",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-title"
                                                                             }                                                                     ],
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                         @"policyValue" :     @{
                                                                 @"bool" : @1,
                                                                 @"collection" :         @[
                                                                         @{
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:filter-projects-by"
                                                                             },
                                                                         @{
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:filter-projects-by:clients"
                                                                             },
                                                                         @{
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:snap-time-to-nearest"
                                                                             },
                                                                         @{
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:snap-time-to-nearest:do-not-snap"
                                                                             },
                                                                         @{
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:projects-and-tasks"
                                                                             },
                                                                         @{
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:projects-and-tasks:allow-projects-and-tasks"
                                                                             },
                                                                         @{
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:billing-options"
                                                                             },
                                                                         @{
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:billing-options:allow-billing-options"
                                                                             },
                                                                         @{
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:activities"
                                                                             },
                                                                         @{
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry:activities:allow-activities"
                                                                             },
                                                                         @{
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:time-entry-comments"
                                                                             },
                                                                         @{
                                                                             @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:time-entry-comments:allow-time-entry-comments"
                                                                             }
                                                                         ],
                                                                 @"number" : @3,
                                                                 @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                         @"policyValue": @{
                                                                 @"bool": @1,
                                                                 @"collection": @[
                                                                         @{
                                                                             @"text": @"this is title",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                             },
                                                                         @{
                                                                             @"text": @"this is text",
                                                                             @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                             }
                                                                         ],
                                                                 @"number": @3,
                                                                 @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                         @"policyValue" :     @{
                                                                 @"bool" : @1,
                                                                 @"number" : @4,
                                                                 @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:approval-history"
                                                                 }
                                                         },
                                                     @{
                                                         @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                         @"policyValue": @{
                                                                 
                                                                 }
                                                         }
                                                     
                                                     ];
                            NSDictionary *widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                            
                            NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                            timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                            timePunchCapabilities[@"hasActivityAccess"] = @0;
                            timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                            
                            isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:YES];
                        });
                        
                        it(@"should negatively identify an astro user", ^{
                            isAstroUser should be_falsy;
                        });
                    });
            
            
            context(@"When any other widget along with punch widget is configured with activity and notice and attestation widget", ^{
                
                beforeEach(^{
                    NSArray *widgetArray = @[
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                 @"policyValue" :     @{
                                                         @"bool" : @1,
                                                         @"collection" :         @[
                                                                 @{
                                                                     @"text" : @"attestation title",
                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-title"
                                                                     },
                                                                 @{
                                                                     @"text" : @"attestation text",
                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-text"
                                                                     }
                                                                 ],
                                                         @"number" : @2,
                                                         @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation"
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                 @"policyValue": @{
                                                         @"bool": @1,
                                                         @"collection": @[
                                                                 @{
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                     },
                                                                 @{
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                     }
                                                                 ],
                                                         @"number": @2.0000,
                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                 @"policyValue": @{
                                                         @"bool": @1,
                                                         @"collection": @[
                                                                 @{
                                                                     @"text": @"this is title",
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                     },
                                                                 @{
                                                                     @"text": @"this is text",
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                     }
                                                                 ],
                                                         @"number": @3,
                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                 @"policyValue": @{
                                                         @"bool": @1,
                                                         @"number": @1.0000,
                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                         }
                                                 }];
                    
                    widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                    timePunchCapabilities[@"hasActivityAccess"] = @1;
                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:YES];
                });
                
                it(@"should postively identify an astro user", ^{
                    isAstroUser should be_truthy;
                });
            });
            
            context(@"When any other widget along with punch widget is configured with no activity and no OEF", ^{
                
                beforeEach(^{
                    NSArray *widgetArray = @[
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                 @"policyValue": @{
                                                         @"bool": @1,
                                                         @"collection": @[
                                                                 @{
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                     },
                                                                 @{
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                     }
                                                                 ],
                                                         @"number": @2.0000,
                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                 @"policyValue": @{
                                                         @"bool": @1,
                                                         @"collection": @[
                                                                 @{
                                                                     @"text": @"this is title",
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                     },
                                                                 @{
                                                                     @"text": @"this is text",
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                     }
                                                                 ],
                                                         @"number": @3,
                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                 @"policyValue": @{
                                                         @"bool": @1,
                                                         @"number": @1.0000,
                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                         }
                                                 }];
                    
                    widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                    timePunchCapabilities[@"hasProjectAccess"] = @1;
                    timePunchCapabilities[@"hasClientAccess"] = @1;
                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                    timePunchCapabilities[@"timePunchExtensionFields"] = [NSNull null];
                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:YES];
                });
                
                it(@"should negatively identify an astro user", ^{
                    isAstroUser should be_truthy;
                });
            });
            
            context(@"When any other widget along with punch widget is configured with activity and with OEF and have notice widget", ^{
                beforeEach(^{
                    NSArray *widgetArray = @[
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                 @"policyValue": @{
                                                         @"bool": @1,
                                                         @"collection": @[
                                                                 @{
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                     },
                                                                 @{
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                     }
                                                                 ],
                                                         @"number": @2.0000,
                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                 @"policyValue": @{
                                                         @"bool": @1,
                                                         @"collection": @[
                                                                 @{
                                                                     @"text": @"this is title",
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                     },
                                                                 @{
                                                                     @"text": @"this is text",
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                     }
                                                                 ],
                                                         @"number": @3,
                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                 @"policyValue": @{
                                                         @"bool": @1,
                                                         @"number": @1.0000,
                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                         }
                                                 }];
                    
                    widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                    timePunchCapabilities[@"hasProjectAccess"] = @1;
                    timePunchCapabilities[@"hasClientAccess"] = @1;
                    timePunchCapabilities[@"hasActivityAccess"] = @1;
                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@{}]};
                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:YES];
                });
                
                it(@"should negatively identify an astro user", ^{
                    isAstroUser should be_truthy;
                });
            });
            
            context(@"When any other widget along with punch widget is configured with activity and with OEF and have notice and attestation widget", ^{
                
                beforeEach(^{
                    NSArray *widgetArray = @[
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                 @"policyValue" :     @{
                                                         @"bool" : @1,
                                                         @"collection" :         @[
                                                                 @{
                                                                     @"text" : @"attestation title",
                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-title"
                                                                     },
                                                                 @{
                                                                     @"text" : @"attestation text",
                                                                     @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation:attestation-text"
                                                                     }
                                                                 ],
                                                         @"number" : @2,
                                                         @"uri" : @"urn:replicon:policy:timesheet:widget-timesheet:attestation"
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                 @"policyValue": @{
                                                         @"bool": @1,
                                                         @"collection": @[
                                                                 @{
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                     },
                                                                 @{
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                     }
                                                                 ],
                                                         @"number": @2.0000,
                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                 @"policyValue": @{
                                                         @"bool": @1,
                                                         @"collection": @[
                                                                 @{
                                                                     @"text": @"this is title",
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                     },
                                                                 @{
                                                                     @"text": @"this is text",
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                     }
                                                                 ],
                                                         @"number": @3,
                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                 @"policyValue": @{
                                                         @"bool": @1,
                                                         @"number": @1.0000,
                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                         }
                                                 }];
                    
                    widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                    timePunchCapabilities[@"hasProjectAccess"] = @1;
                    timePunchCapabilities[@"hasClientAccess"] = @1;
                    timePunchCapabilities[@"hasActivityAccess"] = @1;
                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@{}]};
                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:YES];
                });
                
                it(@"should negatively identify an astro user", ^{
                    isAstroUser should be_truthy;
                });
            });
            
            context(@"When any other widget along with punch widget is configured with activity and with OEF", ^{
                
                beforeEach(^{
                    NSArray *widgetArray = @[
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:attestation",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:extended-in-out-time-and-allocation-entry",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary",
                                                 @"policyValue": @{
                                                         @"bool": @1,
                                                         @"collection": @[
                                                                 @{
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount"
                                                                     },
                                                                 @{
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry:display-pay-amount:allow-display-pay-amount"
                                                                     }
                                                                 ],
                                                         @"number": @2.0000,
                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary"
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-off",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:schedule",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:notice",
                                                 @"policyValue": @{
                                                         @"bool": @1,
                                                         @"collection": @[
                                                                 @{
                                                                     @"text": @"this is title",
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-title"
                                                                     },
                                                                 @{
                                                                     @"text": @"this is text",
                                                                     @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice:notice-text"
                                                                     }
                                                                 ],
                                                         @"number": @3,
                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:notice"
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:approval-history",
                                                 @"policyValue": @{
                                                         
                                                         }
                                                 },
                                             @{
                                                 @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                                 @"policyValue": @{
                                                         @"bool": @1,
                                                         @"number": @1.0000,
                                                         @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry"
                                                         }
                                                 }];
                    
                    widgetTimesheetCapabilities = [NSDictionary dictionaryWithObject:widgetArray forKey:@"widgetTimesheetCapabilities"];
                    NSMutableDictionary *timePunchCapabilities = [[NSMutableDictionary alloc]init];
                    timePunchCapabilities[@"hasTimePunchAccess"] = @1;
                    timePunchCapabilities[@"hasProjectAccess"] = @1;
                    timePunchCapabilities[@"hasClientAccess"] = @1;
                    timePunchCapabilities[@"hasActivityAccess"] = @0;
                    timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
                    isAstroUser = [subject isAstroUserWithCapabilities:widgetTimesheetCapabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:YES];
                });
                
                it(@"should negatively identify an astro user", ^{
                    isAstroUser should be_truthy;
                });
            });
            
        });
        
        
    });
});

SPEC_END
