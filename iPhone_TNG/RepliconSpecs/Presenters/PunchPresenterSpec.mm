#import <Cedar/Cedar.h>
#import "PunchPresenter.h"
#import "LocalPunch.h"
#import "BreakType.h"
#import <KSDeferred/KSDeferred.h>
#import "ImageFetcher.h"
#import "Activity.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "ClientType.h"
#import "Theme.h"
#import "TimelineCellAttributedTextPresenter.h"
#import "NSString+TruncateToWidth.h"
#import "OEFType.h"
#import "RepliconSpecHelper.h"
#import "RemotePunch.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchPresenterSpec)

describe(@"PunchPresenter", ^{
    __block PunchPresenter *subject;
    __block NSDateFormatter *timeOnly12HrsFormatter;
    __block NSDateFormatter *timeOnly24HrsFormatter;
    __block NSDateFormatter *amPmFormatter;
    __block NSDateFormatter *dateAndTimeFormatter;
    __block ImageFetcher *imageFetcher;
    __block id <Theme> theme;
    __block UIFont *lightFont;
    __block UIFont *regularFont;
    __block UIColor *labelBackgroundColor;



    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        imageFetcher = nice_fake_for([ImageFetcher class]);
        timeOnly12HrsFormatter = nice_fake_for([NSDateFormatter class]);
        timeOnly24HrsFormatter = nice_fake_for([NSDateFormatter class]);
        amPmFormatter = nice_fake_for([NSDateFormatter class]);
        dateAndTimeFormatter = nice_fake_for([NSDateFormatter class]);
        subject = [[PunchPresenter alloc] initWithTimeOnly12HrsFormatter:timeOnly12HrsFormatter
                                                  timeOnly24HrsFormatter:timeOnly24HrsFormatter
                                                    dateAndTimeFormatter:dateAndTimeFormatter
                                                           amPmFormatter:amPmFormatter
                                                            imageFetcher:imageFetcher
                                                                   theme:theme];

        lightFont = [UIFont systemFontOfSize:3];
        regularFont = [UIFont systemFontOfSize:4];
        labelBackgroundColor = [UIColor magentaColor];

        theme stub_method(@selector(descriptionLabelBoldFont)).and_return(regularFont);
        theme stub_method(@selector(descriptionLabelLighterFont)).and_return(lightFont);
        theme stub_method(@selector(timeLineCellDescriptionLabelTextColor)).and_return(labelBackgroundColor);



    });

    describe(@"timeLabelTextWithPunch:", ^{
        __block LocalPunch *punch;
        __block NSString *dateString;

        beforeEach(^{
            NSDate *date = [NSDate date];
            punch = nice_fake_for([LocalPunch class]);
            punch stub_method(@selector(date)).and_return(date);
            timeOnly24HrsFormatter stub_method(@selector(stringFromDate:)).with(date).and_return(@"01:00");

            dateString = [subject timeLabelTextWithPunch:punch];
        });

        it(@"should return a valid date string", ^{
            dateString should equal(@"01:00");
        });
    });
    
    describe(@"timeWithAmPmLabelTextForPunch:", ^{
        __block LocalPunch *punch;
        __block NSString *dateString;
        
        beforeEach(^{
            NSDate *date = [NSDate date];
            punch = nice_fake_for([LocalPunch class]);
            punch stub_method(@selector(date)).and_return(date);
            timeOnly12HrsFormatter stub_method(@selector(stringFromDate:)).with(date).and_return(@"01:00");
            amPmFormatter stub_method(@selector(stringFromDate:)).with(date).and_return(@"AM");

            dateString = [subject timeWithAmPmLabelTextForPunch:punch];
        });
        
        it(@"should return a valid date string", ^{
            dateString should equal(@"01:00 AM");
        });
    });


    describe(@"dateTimeLabelTextWithPunch:", ^{
        __block LocalPunch *punch;
        __block NSString *dateString;

        beforeEach(^{
            NSDate *date = [NSDate date];
            punch = nice_fake_for([LocalPunch class]);
            punch stub_method(@selector(date)).and_return(date);
            dateAndTimeFormatter stub_method(@selector(stringFromDate:)).with(date).and_return(@"Longer date and time");

            dateString = [subject dateTimeLabelTextWithPunch:punch];
        });

        it(@"should return a valid date string", ^{
            dateString should equal(@"Longer date and time");
        });
    });

    describe(@"punchActionIconImageWithPunch:", ^{
        __block LocalPunch *punch;
        __block UIImage *image;
        beforeEach(^{
            punch = nice_fake_for([LocalPunch class]);
        });

        context(@"when punching in", ^{
            beforeEach(^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                image = [subject punchActionIconImageWithPunch:punch];
            });

            it(@"should return the correct text", ^{
                image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
            });
        });

        context(@"when transferring back to work from a break", ^{
            beforeEach(^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);
                image = [subject punchActionIconImageWithPunch:punch];
            });

            it(@"should return the correct text", ^{
                image should equal([UIImage imageNamed:@"icon_timeline_clock_in"]);
            });
        });

        context(@"when punching out", ^{
            beforeEach(^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                image = [subject punchActionIconImageWithPunch:punch];
            });

            it(@"should return the correct text", ^{
                image should equal([UIImage imageNamed:@"icon_timeline_clock_out"]);
            });
        });

        context(@"when starting a break", ^{
            beforeEach(^{
                BreakType *breakType = [[BreakType alloc] initWithName:@"Smoke Break" uri:@"smoke-uri"];
                punch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
                punch stub_method(@selector(breakType)).and_return(breakType);

                image = [subject punchActionIconImageWithPunch:punch];
            });

            it(@"should return the correct text", ^{
                image should equal([UIImage imageNamed:@"icon_timeline_break"]);
            });
        });
    });

    describe(@"presentImageForPunch:inImageView:", ^{
        __block UIImageView *imageView;
        __block id<Punch> punch;

        beforeEach(^{
            punch = fake_for(@protocol(Punch));
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
        });

        context(@"When there is an image URL available", ^{
            __block KSDeferred *deferred;
            NSURL *imageURL = [NSURL URLWithString:@"https://www.example.com/image"];

            beforeEach(^{
                deferred = [KSDeferred defer];
                imageFetcher stub_method(@selector(promiseWithImageURL:)).and_do_block(^KSPromise *(NSURL *url) {
                    return deferred.promise;
                });
                punch stub_method(@selector(imageURL)).and_return(imageURL);
                [subject presentImageForPunch:punch inImageView:imageView];
            });

            it(@"should configure the image view", ^{
                imageView.clipsToBounds should be_truthy;
                imageView.layer.cornerRadius should be_close_to(6.0f);
            });

            it(@"should make a request for the given image", ^{
                imageFetcher should have_received(@selector(promiseWithImageURL:)).with(imageURL);
            });

            context(@"after the request for the image completes", ^{
                __block UIImage *expectedImage;

                beforeEach(^{
                    expectedImage = [[UIImage alloc] init];
                    [deferred resolveWithValue:expectedImage];
                });

                it(@"should present the image", ^{
                    imageView.image should equal(expectedImage);
                });
            });
        });

        context(@"When there is a UIImage available", ^{
            __block UIImage *image;

            beforeEach(^{
                image = [[UIImage alloc] init];
                punch stub_method(@selector(image)).and_return(image);
                [subject presentImageForPunch:punch inImageView:imageView];
            });

            it(@"should present the image to the user", ^{
                imageView.image should equal(image);
            });
        });

        context(@"when neither is available", ^{
            beforeEach(^{
                spy_on(imageView);
                [subject presentImageForPunch:punch inImageView:imageView];
            });

            it(@"should does nothing at all", ^{
                imageView should_not have_received(@selector(setImage:));
            });
        });
    });

    describe(@"descriptionLabelTextWithPunch:", ^{
        __block LocalPunch *punch;
        __block NSString *descriptionLabelText;
        beforeEach(^{
            punch = nice_fake_for([LocalPunch class]);
            ProjectType *project = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"My Project" uri:@"My-Project-URI"];
            TaskType *task = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"My Task" uri:@"My-Task-URI"];
            ClientType *client = [[ClientType alloc]initWithName:@"My Client" uri:@"My-Client-URI"];
            punch stub_method(@selector(project)).and_return(project);
            punch stub_method(@selector(task)).and_return(task);
            punch stub_method(@selector(client)).and_return(client);
        });

        context(@"when punching in", ^{
            beforeEach(^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                descriptionLabelText = [subject descriptionLabelTextWithPunch:punch];
            });

            it(@"should return the correct text", ^{
                descriptionLabelText should equal(RPLocalizedString(@"Clocked In", nil));
            });
        });

        context(@"when transferring back to work from a break", ^{
            beforeEach(^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);
                descriptionLabelText = [subject descriptionLabelTextWithPunch:punch];
            });

            it(@"should return the correct text", ^{
                descriptionLabelText should equal(RPLocalizedString(@"Clocked In", nil));
            });
        });

        context(@"when punching out", ^{
            beforeEach(^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                descriptionLabelText = [subject descriptionLabelTextWithPunch:punch];
            });


            it(@"should return the correct text", ^{
                descriptionLabelText should equal(RPLocalizedString(@"Clocked Out", @""));
            });
        });

        context(@"when starting a break", ^{
            beforeEach(^{
                BreakType *breakType = [[BreakType alloc] initWithName:@"Smoke Break" uri:@"smoke-uri"];
                punch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
                punch stub_method(@selector(breakType)).and_return(breakType);

                descriptionLabelText = [subject descriptionLabelTextWithPunch:punch];
            });

            it(@"should return the correct text", ^{
                descriptionLabelText should equal(RPLocalizedString(@"Started Break", nil));
            });
        });
    });

    describe(@"-descriptionLabelForTimelineCellTextWithPunch:forLabel:", ^{
        __block LocalPunch *punch;
        __block ClientType *client;
        __block ProjectType *project;
        __block TaskType *task;
        __block Activity *activity;
        __block BreakType *breakType;
        __block NSAttributedString *descriptionLabelText;

        beforeEach(^{
            punch = nice_fake_for([LocalPunch class]);

            client = nice_fake_for([ClientType class]);
            client stub_method(@selector(name)).and_return(@"My Client");
            client stub_method(@selector(uri)).and_return(@"My-Client-URI");

            project = nice_fake_for([ProjectType class]);
            project stub_method(@selector(name)).and_return(@"My Project");
            project stub_method(@selector(uri)).and_return(@"My-Project-URI");

            task = nice_fake_for([TaskType class]);
            task stub_method(@selector(name)).and_return(@"My Task");
            task stub_method(@selector(uri)).and_return(@"My-Task-URI");

            activity = nice_fake_for([Activity class]);
            activity stub_method(@selector(name)).and_return(@"My Activity");
            activity stub_method(@selector(uri)).and_return(@"My-Activity-URI");

            breakType = nice_fake_for([BreakType class]);
            breakType stub_method(@selector(name)).and_return(@"Smoke Break");
            breakType stub_method(@selector(uri)).and_return(@"smoke-uri");


        });

        context(@"when no other attributes are present", ^{

            __block NSArray *oefTypesArray;
            __block OEFType *oefTypeA;
            __block OEFType *oefTypeB;
            __block OEFType *oefTypeC;
            __block OEFType *oefTypeD;
            __block NSString *truncatedOEFA;
            __block NSString *truncatedOEFB;
            __block NSString *truncatedOEFC;
            __block NSString *truncatedOEFD;

            beforeEach(^{


                oefTypeA = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text name" punchActionType:nil numericValue:nil textValue:@"text-oef-value" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                oefTypeB = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric name" punchActionType:nil numericValue:@"numeric-oef-value" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                oefTypeC = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown name" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:@"dropdown-oef-value" collectAtTimeOfPunch:NO disabled:NO];

                 oefTypeD = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text no value" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                oefTypesArray = @[oefTypeA,oefTypeB,oefTypeC,oefTypeD];

               truncatedOEFA = [[NSString stringWithFormat:@"%@ : %@",oefTypeA.oefName,oefTypeA.oefTextValue] stringByTruncatingToWidth:400 withFont:lightFont];
               truncatedOEFB = [[NSString stringWithFormat:@"%@ : %@",oefTypeB.oefName,oefTypeB.oefNumericValue] stringByTruncatingToWidth:400 withFont:lightFont];
               truncatedOEFC = [[NSString stringWithFormat:@"%@ : %@",oefTypeC.oefName,oefTypeC.oefDropdownOptionValue] stringByTruncatingToWidth:400 withFont:lightFont];
                truncatedOEFD = [[NSString stringWithFormat:@"%@ : %@",oefTypeD.oefName,oefTypeD.oefTextValue] stringByTruncatingToWidth:400 withFont:lightFont];
            });

            beforeEach(^{
                ClientType *clientType =  [[ClientType alloc] initWithName:nil uri:nil];
                
                punch stub_method(@selector(client)).and_return(clientType);
                punch stub_method(@selector(project)).and_return(nil);
                punch stub_method(@selector(task)).and_return(nil);
                punch stub_method(@selector(activity)).and_return(nil);
                punch stub_method(@selector(breakType)).and_return(nil);
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);


            });
            context(@"when punching in", ^{

                __block NSMutableAttributedString *expectedAttributedString;

                beforeEach(^{
                    punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);


                    NSString *completelyAppendedString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",RPLocalizedString(@"Clocked In", nil),truncatedOEFA,truncatedOEFB,truncatedOEFC];

                    expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                      withHighlightedText:RPLocalizedString(@"Clocked In", nil)
                                                                                          highligthedFont:regularFont
                                                                                              defaultFont:lightFont
                                                                                                textColor:labelBackgroundColor];
                    descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                     regularFont:regularFont
                                                                                       lightFont:lightFont
                                                                                       textColor:labelBackgroundColor
                                                                                        forWidth:400];
                });

                it(@"should return the correct text", ^{
                    [descriptionLabelText isEqualToAttributedString:expectedAttributedString] should be_truthy;
                });
                
                context(@"when client and project is nil and task is not nil", ^{
                    
                    beforeEach(^{
                        punch stub_method(@selector(client)).again().and_return(nil);
                        punch stub_method(@selector(project)).again().and_return(nil);
                        TaskType *task = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"My Task" uri:@"My-Task-URI"];
                        punch stub_method(@selector(task)).again().and_return(task);
                        punch stub_method(@selector(activity)).again().and_return(nil);
                        punch stub_method(@selector(breakType)).again().and_return(nil);
                        punch stub_method(@selector(oefTypesArray)).again().and_return(nil);

                        NSString *completelyAppendedString = [NSString stringWithFormat:@"%@",punch.task.name];
                        expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                          withHighlightedText:completelyAppendedString
                                                                                              highligthedFont:regularFont
                                                                                                  defaultFont:lightFont
                                                                                                    textColor:labelBackgroundColor];
                    });
                    
                    it(@"should return the correctly configured descriptionLabelText", ^{
                        descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                         regularFont:regularFont
                                                                                           lightFont:lightFont
                                                                                           textColor:labelBackgroundColor
                                                                                            forWidth:400];
                        
                        [descriptionLabelText isEqualToAttributedString:expectedAttributedString]should be_truthy;
                    });
                    
                    afterEach(^{
                        punch stub_method(@selector(client)).again().and_return(client);
                        punch stub_method(@selector(project)).again().and_return(project);
                    });
                });
                
            });

            context(@"when transferring back to work from a break", ^{

                __block NSMutableAttributedString *expectedAttributedString;

                beforeEach(^{
                    punch stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);

                    NSString *completelyAppendedString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",RPLocalizedString(@"Clocked In", nil),truncatedOEFA,truncatedOEFB,truncatedOEFC];

                    expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                      withHighlightedText:RPLocalizedString(@"Clocked In", nil)
                                                                                          highligthedFont:regularFont
                                                                                              defaultFont:lightFont
                                                                                                textColor:labelBackgroundColor];
                    descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                     regularFont:regularFont
                                                                                       lightFont:lightFont
                                                                                       textColor:labelBackgroundColor
                                                                                        forWidth:400];
                });

                it(@"should return the correct text", ^{
                    [descriptionLabelText isEqualToAttributedString:expectedAttributedString] should be_truthy;
                });
            });

            context(@"when punching out", ^{

                __block NSMutableAttributedString *expectedAttributedString;
                beforeEach(^{
                    punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);

                    NSString *completelyAppendedString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",RPLocalizedString(@"Clocked Out", nil),truncatedOEFA,truncatedOEFB,truncatedOEFC];


                    expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                      withHighlightedText:RPLocalizedString(@"Clocked Out", nil)
                                                                                          highligthedFont:regularFont
                                                                                              defaultFont:lightFont
                                                                                                textColor:labelBackgroundColor];
                    descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                     regularFont:regularFont
                                                                                       lightFont:lightFont
                                                                                       textColor:labelBackgroundColor
                                                                                        forWidth:400];
                });


                it(@"should return the correct text", ^{
                    [descriptionLabelText isEqualToAttributedString:expectedAttributedString] should be_truthy;
                });
            });

        });
        
        context(@"when attributes are present wityh nil values", ^{
            
            __block NSArray *oefTypesArray;
            __block OEFType *oefTypeA;
            __block OEFType *oefTypeB;
            __block OEFType *oefTypeC;
            __block OEFType *oefTypeD;
            __block NSString *truncatedOEFA;
            __block NSString *truncatedOEFB;
            __block NSString *truncatedOEFC;
            __block NSString *truncatedOEFD;
            
            beforeEach(^{
                
                
                oefTypeA = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text name" punchActionType:nil numericValue:nil textValue:@"text-oef-value" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypeB = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric name" punchActionType:nil numericValue:@"numeric-oef-value" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypeC = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown name" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:@"dropdown-oef-value" collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypeD = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text no value" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypesArray = @[oefTypeA,oefTypeB,oefTypeC,oefTypeD];
                
                truncatedOEFA = [[NSString stringWithFormat:@"%@ : %@",oefTypeA.oefName,oefTypeA.oefTextValue] stringByTruncatingToWidth:400 withFont:lightFont];
                truncatedOEFB = [[NSString stringWithFormat:@"%@ : %@",oefTypeB.oefName,oefTypeB.oefNumericValue] stringByTruncatingToWidth:400 withFont:lightFont];
                truncatedOEFC = [[NSString stringWithFormat:@"%@ : %@",oefTypeC.oefName,oefTypeC.oefDropdownOptionValue] stringByTruncatingToWidth:400 withFont:lightFont];
                truncatedOEFD = [[NSString stringWithFormat:@"%@ : %@",oefTypeD.oefName,oefTypeD.oefTextValue] stringByTruncatingToWidth:400 withFont:lightFont];
            });
            
            beforeEach(^{
                ClientType *clientType =  [[ClientType alloc] initWithName:nil uri:nil];
                ProjectType *projectType =  [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:false isTimeAllocationAllowed:false projectPeriod:nil clientType:nil name:nil uri:nil];
                TaskType *taskType =  [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:nil uri:nil];
                Activity *activity =  [[Activity alloc] initWithName:nil uri:nil];
                BreakType *breakType =  [[BreakType alloc] initWithName:nil uri:nil];
                
                punch stub_method(@selector(client)).and_return(clientType);
                punch stub_method(@selector(project)).and_return(projectType);
                punch stub_method(@selector(task)).and_return(taskType);
                punch stub_method(@selector(activity)).and_return(activity);
                punch stub_method(@selector(breakType)).and_return(breakType);
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                
                
            });
            context(@"when punching in", ^{
                
                __block NSMutableAttributedString *expectedAttributedString;
                
                beforeEach(^{
                    punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchIn);
                    
                    
                    NSString *completelyAppendedString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",RPLocalizedString(@"Clocked In", nil),truncatedOEFA,truncatedOEFB,truncatedOEFC];
                    
                    expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                      withHighlightedText:RPLocalizedString(@"Clocked In", nil)
                                                                                          highligthedFont:regularFont
                                                                                              defaultFont:lightFont
                                                                                                textColor:labelBackgroundColor];
                    descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                     regularFont:regularFont
                                                                                       lightFont:lightFont
                                                                                       textColor:labelBackgroundColor
                                                                                        forWidth:400];
                });
                
                it(@"should return the correct text", ^{
                    [descriptionLabelText isEqualToAttributedString:expectedAttributedString] should be_truthy;
                });
                
                context(@"when client and project is nil and task is not nil", ^{
                    
                    beforeEach(^{
                        punch stub_method(@selector(client)).again().and_return(nil);
                        punch stub_method(@selector(project)).again().and_return(nil);
                        TaskType *task = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"My Task" uri:@"My-Task-URI"];
                        punch stub_method(@selector(task)).again().and_return(task);
                        punch stub_method(@selector(activity)).again().and_return(nil);
                        punch stub_method(@selector(breakType)).again().and_return(nil);
                        punch stub_method(@selector(oefTypesArray)).again().and_return(nil);
                        
                        NSString *completelyAppendedString = [NSString stringWithFormat:@"%@",punch.task.name];
                        expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                          withHighlightedText:completelyAppendedString
                                                                                              highligthedFont:regularFont
                                                                                                  defaultFont:lightFont
                                                                                                    textColor:labelBackgroundColor];
                    });
                    
                    it(@"should return the correctly configured descriptionLabelText", ^{
                        descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                         regularFont:regularFont
                                                                                           lightFont:lightFont
                                                                                           textColor:labelBackgroundColor
                                                                                            forWidth:400];
                        
                        [descriptionLabelText isEqualToAttributedString:expectedAttributedString]should be_truthy;
                    });
                    
                    afterEach(^{
                        punch stub_method(@selector(client)).again().and_return(client);
                        punch stub_method(@selector(project)).again().and_return(project);
                    });
                });
                
            });
            
            context(@"when transferring back to work from a break", ^{
                
                __block NSMutableAttributedString *expectedAttributedString;
                
                beforeEach(^{
                    punch stub_method(@selector(actionType)).and_return(PunchActionTypeTransfer);
                    
                    NSString *completelyAppendedString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",RPLocalizedString(@"Clocked In", nil),truncatedOEFA,truncatedOEFB,truncatedOEFC];
                    
                    expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                      withHighlightedText:RPLocalizedString(@"Clocked In", nil)
                                                                                          highligthedFont:regularFont
                                                                                              defaultFont:lightFont
                                                                                                textColor:labelBackgroundColor];
                    descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                     regularFont:regularFont
                                                                                       lightFont:lightFont
                                                                                       textColor:labelBackgroundColor
                                                                                        forWidth:400];
                });
                
                it(@"should return the correct text", ^{
                    [descriptionLabelText isEqualToAttributedString:expectedAttributedString] should be_truthy;
                });
            });
            
            context(@"when punching out", ^{
                
                __block NSMutableAttributedString *expectedAttributedString;
                beforeEach(^{
                    punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);
                    
                    NSString *completelyAppendedString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",RPLocalizedString(@"Clocked Out", nil),truncatedOEFA,truncatedOEFB,truncatedOEFC];
                    
                    
                    expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                      withHighlightedText:RPLocalizedString(@"Clocked Out", nil)
                                                                                          highligthedFont:regularFont
                                                                                              defaultFont:lightFont
                                                                                                textColor:labelBackgroundColor];
                    descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                     regularFont:regularFont
                                                                                       lightFont:lightFont
                                                                                       textColor:labelBackgroundColor
                                                                                        forWidth:400];
                });
                
                
                it(@"should return the correct text", ^{
                    [descriptionLabelText isEqualToAttributedString:expectedAttributedString] should be_truthy;
                });
            });
            
        });


        context(@"when client , project and task attributes are present", ^{

            __block NSArray *oefTypesArray;
            __block OEFType *oefTypeA;
            __block OEFType *oefTypeB;
            __block OEFType *oefTypeC;

            beforeEach(^{


                oefTypeA = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1 - It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:nil textValue:@"text-oef-value" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                oefTypeB = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1 - It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:@"numeric-oef-value" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                oefTypeC = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown 2- It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:@"dropdown-oef-value" collectAtTimeOfPunch:NO disabled:NO];

                oefTypesArray = @[oefTypeA,oefTypeB,oefTypeC];
            });
            beforeEach(^{
                punch stub_method(@selector(client)).and_return(client);
                punch stub_method(@selector(project)).and_return(project);
                punch stub_method(@selector(task)).and_return(task);
                punch stub_method(@selector(activity)).and_return(nil);
                punch stub_method(@selector(breakType)).and_return(nil);
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

            });

            __block NSMutableAttributedString *expectedAttributedString;
            beforeEach(^{

                NSString *truncatedOEFA = [[NSString stringWithFormat:@"%@ : %@",oefTypeA.oefName,oefTypeA.oefTextValue] stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedOEFB = [[NSString stringWithFormat:@"%@ : %@",oefTypeB.oefName,oefTypeB.oefNumericValue] stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedOEFC = [[NSString stringWithFormat:@"%@ : %@",oefTypeC.oefName,oefTypeC.oefDropdownOptionValue] stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *completelyAppendedString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@",punch.client.name,punch.project.name,punch.task.name,truncatedOEFA,truncatedOEFB,truncatedOEFC];

                expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                  withHighlightedText:punch.client.name
                                                                                      highligthedFont:regularFont
                                                                                          defaultFont:lightFont
                                                                                            textColor:labelBackgroundColor];
            });

            it(@"should return the correctly configured descriptionLabelText", ^{
                descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                 regularFont:regularFont
                                                                                   lightFont:lightFont
                                                                                   textColor:labelBackgroundColor
                                                                                    forWidth:400];
                [descriptionLabelText isEqualToAttributedString:expectedAttributedString]should be_truthy;
            });

        });

        context(@"when only client , project attributes are present", ^{
            beforeEach(^{
                punch stub_method(@selector(client)).and_return(client);
                punch stub_method(@selector(project)).and_return(project);
                punch stub_method(@selector(task)).and_return(nil);
                punch stub_method(@selector(activity)).and_return(nil);
                punch stub_method(@selector(breakType)).and_return(nil);


            });

            __block NSMutableAttributedString *expectedAttributedString;
            beforeEach(^{

                NSString *completelyAppendedString = [NSString stringWithFormat:@"%@\n%@",punch.client.name,punch.project.name];
                expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                  withHighlightedText:punch.client.name
                                                                                      highligthedFont:regularFont
                                                                                          defaultFont:lightFont
                                                                                            textColor:labelBackgroundColor];
            });
            it(@"should return the correctly configured descriptionLabelText", ^{
                descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                 regularFont:regularFont
                                                                                   lightFont:lightFont
                                                                                   textColor:labelBackgroundColor
                                                                                    forWidth:400];
                [descriptionLabelText isEqualToAttributedString:expectedAttributedString]should be_truthy;
            });
        });

        context(@"when only project and task attributes are present", ^{
            beforeEach(^{
                punch stub_method(@selector(client)).and_return(nil);
                punch stub_method(@selector(project)).and_return(project);
                punch stub_method(@selector(task)).and_return(task);
                punch stub_method(@selector(activity)).and_return(nil);
                punch stub_method(@selector(breakType)).and_return(nil);

            });

            __block NSMutableAttributedString *expectedAttributedString;
            beforeEach(^{

                NSString *completelyAppendedString = [NSString stringWithFormat:@"%@\n%@",punch.project.name,punch.task.name];
                expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                  withHighlightedText:punch.project.name
                                                                                      highligthedFont:regularFont
                                                                                          defaultFont:lightFont
                                                                                            textColor:labelBackgroundColor];
            });
            it(@"should return the correctly configured descriptionLabelText", ^{
                descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                 regularFont:regularFont
                                                                                   lightFont:lightFont
                                                                                   textColor:labelBackgroundColor
                                                                                    forWidth:400];
                [descriptionLabelText isEqualToAttributedString:expectedAttributedString]should be_truthy;
            });
        });

        context(@"when only project attributes are present", ^{
            beforeEach(^{
                punch stub_method(@selector(client)).and_return(nil);
                punch stub_method(@selector(project)).and_return(project);
                punch stub_method(@selector(task)).and_return(nil);
                punch stub_method(@selector(activity)).and_return(nil);
                punch stub_method(@selector(breakType)).and_return(nil);

            });

            __block NSMutableAttributedString *expectedAttributedString;
            beforeEach(^{

                NSString *completelyAppendedString = [NSString stringWithFormat:@"%@",punch.project.name];
                expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                  withHighlightedText:punch.project.name
                                                                                      highligthedFont:regularFont
                                                                                          defaultFont:lightFont
                                                                                            textColor:labelBackgroundColor];
            });
            it(@"should return the correctly configured descriptionLabelText", ^{
                descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                 regularFont:regularFont
                                                                                   lightFont:lightFont
                                                                                   textColor:labelBackgroundColor
                                                                                    forWidth:400];
                [descriptionLabelText isEqualToAttributedString:expectedAttributedString]should be_truthy;
            });
        });
        
        context(@"when only project attributes are present with regex metacharacters in project string and with OEFs", ^{
            __block NSArray *oefTypesArray;
            __block OEFType *oefTypeA;
            __block OEFType *oefTypeB;
            __block OEFType *oefTypeC;
            
            beforeEach(^{
                
                 NSString *projectString = @"!@$. project ?*% \\ |&^% /[]{}";
                
                oefTypeA = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1 - It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:nil textValue:@"text-oef-value" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypeB = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1 - It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:@"numeric-oef-value" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypeC = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown 2- It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:@"dropdown-oef-value" collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypesArray = @[oefTypeA,oefTypeB,oefTypeC];
                
                project stub_method(@selector(name)).again().and_return(projectString);
                
                punch stub_method(@selector(client)).and_return(nil);
                punch stub_method(@selector(project)).and_return(project);
                punch stub_method(@selector(task)).and_return(nil);
                punch stub_method(@selector(activity)).and_return(nil);
                punch stub_method(@selector(breakType)).and_return(nil);
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                
            });
            
            __block NSMutableAttributedString *expectedAttributedString;
            beforeEach(^{
                
                NSString *projectString = @"!@$. project ?*% \\ |&^% /[]{}";
                
                NSString *truncatedOEFA = [[NSString stringWithFormat:@"%@ : %@",oefTypeA.oefName,oefTypeA.oefTextValue] stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedOEFB = [[NSString stringWithFormat:@"%@ : %@",oefTypeB.oefName,oefTypeB.oefNumericValue] stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedOEFC = [[NSString stringWithFormat:@"%@ : %@",oefTypeC.oefName,oefTypeC.oefDropdownOptionValue] stringByTruncatingToWidth:400 withFont:lightFont];
                
                NSString *completelyAppendedString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",projectString,truncatedOEFA,truncatedOEFB,truncatedOEFC];
                
                projectString = [RepliconSpecHelper specialCharsEscapedString:projectString];
                
                expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                  withHighlightedText:projectString
                                                                                      highligthedFont:regularFont
                                                                                          defaultFont:lightFont
                                                                                            textColor:labelBackgroundColor];
            });
            it(@"should return the correctly configured descriptionLabelText", ^{
                descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                 regularFont:regularFont
                                                                                   lightFont:lightFont
                                                                                   textColor:labelBackgroundColor
                                                                                    forWidth:400];
                [descriptionLabelText isEqualToAttributedString:expectedAttributedString]should be_truthy;
            });
        });

        context(@"when only activity attributes are present", ^{

            beforeEach(^{
                punch stub_method(@selector(client)).and_return(nil);
                punch stub_method(@selector(project)).and_return(nil);
                punch stub_method(@selector(task)).and_return(nil);
                punch stub_method(@selector(activity)).and_return(activity);
                punch stub_method(@selector(breakType)).and_return(nil);

            });

            __block NSMutableAttributedString *expectedAttributedString;
            beforeEach(^{

                NSString *completelyAppendedString = [NSString stringWithFormat:@"%@",punch.activity.name];
                expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                  withHighlightedText:punch.activity.name
                                                                                      highligthedFont:regularFont
                                                                                          defaultFont:lightFont
                                                                                            textColor:labelBackgroundColor];
            });
            it(@"should return the correctly configured descriptionLabelText", ^{
                descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                 regularFont:regularFont
                                                                                   lightFont:lightFont
                                                                                   textColor:labelBackgroundColor
                                                                                    forWidth:400];
                [descriptionLabelText isEqualToAttributedString:expectedAttributedString]should be_truthy;
            });
        });
        
        context(@"when only activity attributes are present with regex metacharacters in activity string and with OEF's ", ^{
            
            __block NSArray *oefTypesArray;
            __block OEFType *oefTypeA;
            __block OEFType *oefTypeB;
            __block OEFType *oefTypeC;
            beforeEach(^{
                
                NSString *activityString = @"!@$. activity ?*% \\ |&^% /[]{}";
                
                oefTypeA = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1 - It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:nil textValue:@"text-oef-value" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypeB = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1 - It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:@"numeric-oef-value" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypeC = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown 2- It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:@"dropdown-oef-value" collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypesArray = @[oefTypeA,oefTypeB,oefTypeC];
                
                 activity stub_method(@selector(name)).again().and_return(activityString);
                
                punch stub_method(@selector(client)).and_return(nil);
                punch stub_method(@selector(project)).and_return(nil);
                punch stub_method(@selector(task)).and_return(nil);
                punch stub_method(@selector(activity)).and_return(activity);
                punch stub_method(@selector(breakType)).and_return(nil);
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                
            });
            
            __block NSMutableAttributedString *expectedAttributedString;
            beforeEach(^{
                
               NSString *activityString = @"!@$. activity ?*% \\ |&^% /[]{}";
                
                NSString *truncatedOEFA = [[NSString stringWithFormat:@"%@ : %@",oefTypeA.oefName,oefTypeA.oefTextValue] stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedOEFB = [[NSString stringWithFormat:@"%@ : %@",oefTypeB.oefName,oefTypeB.oefNumericValue] stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedOEFC = [[NSString stringWithFormat:@"%@ : %@",oefTypeC.oefName,oefTypeC.oefDropdownOptionValue] stringByTruncatingToWidth:400 withFont:lightFont];
                
            
                NSString *completelyAppendedString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",activityString,truncatedOEFA,truncatedOEFB,truncatedOEFC];
                
                activityString = [RepliconSpecHelper specialCharsEscapedString:activityString];
            
                
                expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                  withHighlightedText:activityString
                                                                                      highligthedFont:regularFont
                                                                                          defaultFont:lightFont
                                                                                            textColor:labelBackgroundColor];
            });
            it(@"should return the correctly configured descriptionLabelText", ^{
                descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                 regularFont:regularFont
                                                                                   lightFont:lightFont
                                                                                   textColor:labelBackgroundColor
                                                                                    forWidth:400];
                [descriptionLabelText isEqualToAttributedString:expectedAttributedString]should be_truthy;
            });
        });

        context(@"when only break attributes are present", ^{

            beforeEach(^{
                punch stub_method(@selector(client)).and_return(nil);
                punch stub_method(@selector(project)).and_return(nil);
                punch stub_method(@selector(task)).and_return(nil);
                punch stub_method(@selector(activity)).and_return(nil);
                punch stub_method(@selector(breakType)).and_return(breakType);
                punch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);


            });

            __block NSMutableAttributedString *expectedAttributedString;
            beforeEach(^{

                NSString *completelyAppendedString = [NSString stringWithFormat:@"%@",punch.breakType.name];
                expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                  withHighlightedText:punch.breakType.name
                                                                                      highligthedFont:regularFont
                                                                                          defaultFont:lightFont
                                                                                            textColor:labelBackgroundColor];
            });
            it(@"should return the correctly configured descriptionLabelText", ^{
                descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                 regularFont:regularFont
                                                                                   lightFont:lightFont
                                                                                   textColor:labelBackgroundColor
                                                                                    forWidth:400];
                [descriptionLabelText isEqualToAttributedString:expectedAttributedString]should be_truthy;
            });
        });

        
        context(@"when only break attributes are present and a long OEF's attributes are present", ^{
            __block NSArray *oefTypesArray;
            __block OEFType *oefTypeA;
            __block OEFType *oefTypeB;
            __block OEFType *oefTypeC;
            beforeEach(^{
                
                oefTypeA = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1 - It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:nil textValue:@"text-oef-value" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypeB = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1 - It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:@"numeric-oef-value" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypeC = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown 2- It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:@"dropdown-oef-value" collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypesArray = @[oefTypeA,oefTypeB,oefTypeC];

                punch stub_method(@selector(client)).and_return(nil);
                punch stub_method(@selector(project)).and_return(nil);
                punch stub_method(@selector(task)).and_return(nil);
                punch stub_method(@selector(activity)).and_return(nil);
                punch stub_method(@selector(breakType)).and_return(breakType);
                punch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
            });
            
            __block NSMutableAttributedString *expectedAttributedString;
            beforeEach(^{
                
                NSString *breakString = [NSString stringWithFormat:@"%@",punch.breakType.name];
                NSString *truncatedOEFA = [[NSString stringWithFormat:@"%@ : %@",oefTypeA.oefName,oefTypeA.oefTextValue] stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedOEFB = [[NSString stringWithFormat:@"%@ : %@",oefTypeB.oefName,oefTypeB.oefNumericValue] stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedOEFC = [[NSString stringWithFormat:@"%@ : %@",oefTypeC.oefName,oefTypeC.oefDropdownOptionValue] stringByTruncatingToWidth:400 withFont:lightFont];
                
                
                NSString *completelyAppendedString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",breakString,truncatedOEFA,truncatedOEFB,truncatedOEFC];
                expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                  withHighlightedText:breakString
                                                                                      highligthedFont:regularFont
                                                                                          defaultFont:lightFont
                                                                                            textColor:labelBackgroundColor];
            });
            
            it(@"should return the correctly configured descriptionLabelText", ^{
                descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                 regularFont:regularFont
                                                                                   lightFont:lightFont
                                                                                   textColor:labelBackgroundColor
                                                                                    forWidth:400];
                [descriptionLabelText isEqualToAttributedString:expectedAttributedString]should be_truthy;
            });

        });
        
        context(@"when only break attributes are present with special chars in break string and a long OEF's attributes are present", ^{
            __block NSArray *oefTypesArray;
            __block OEFType *oefTypeA;
            __block OEFType *oefTypeB;
            __block OEFType *oefTypeC;
            beforeEach(^{
                NSString *breakString = @"!@$. break ?*% \\ |&^% /[]{}";
                
                oefTypeA = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1 - It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:nil textValue:@"text-oef-value" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypeB = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1 - It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:@"numeric-oef-value" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypeC = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown 2- It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:@"dropdown-oef-value" collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypesArray = @[oefTypeA,oefTypeB,oefTypeC];
                
                breakType stub_method(@selector(name)).again().and_return(breakString);
                
                punch stub_method(@selector(client)).and_return(nil);
                punch stub_method(@selector(project)).and_return(nil);
                punch stub_method(@selector(task)).and_return(nil);
                punch stub_method(@selector(activity)).and_return(nil);
                punch stub_method(@selector(breakType)).and_return(breakType);
                punch stub_method(@selector(actionType)).and_return(PunchActionTypeStartBreak);
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
            });
            
            __block NSMutableAttributedString *expectedAttributedString;
            beforeEach(^{
                
                NSString *breakString = @"!@$. break ?*% \\ |&^% /[]{}";
                NSString *truncatedOEFA = [[NSString stringWithFormat:@"%@ : %@",oefTypeA.oefName,oefTypeA.oefTextValue] stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedOEFB = [[NSString stringWithFormat:@"%@ : %@",oefTypeB.oefName,oefTypeB.oefNumericValue] stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedOEFC = [[NSString stringWithFormat:@"%@ : %@",oefTypeC.oefName,oefTypeC.oefDropdownOptionValue] stringByTruncatingToWidth:400 withFont:lightFont];
                
                
                NSString *completelyAppendedString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",breakString,truncatedOEFA,truncatedOEFB,truncatedOEFC];
                
                breakString = [RepliconSpecHelper specialCharsEscapedString:breakString];
                
                expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                  withHighlightedText:breakString
                                                                                      highligthedFont:regularFont
                                                                                          defaultFont:lightFont
                                                                                            textColor:labelBackgroundColor];
            });
            
            it(@"should return the correctly configured descriptionLabelText", ^{
                descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                 regularFont:regularFont
                                                                                   lightFont:lightFont
                                                                                   textColor:labelBackgroundColor
                                                                                    forWidth:400];
                [descriptionLabelText isEqualToAttributedString:expectedAttributedString]should be_truthy;
            });
            
        });

        context(@"when a very long client , a very long project and a long task attributes are present", ^{

            beforeEach(^{
                NSString *clientString = @"It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout";
                NSString *projectString = @"It is a long project established fact that a reader will be distracted by the readable content of a page when looking at its layout";
                NSString *taskString = @"It is a long task established fact that a reader will be distracted by the readable content of a page when looking at its layout";

                client stub_method(@selector(name)).again().and_return(clientString);
                project stub_method(@selector(name)).again().and_return(projectString);
                task stub_method(@selector(name)).again().and_return(taskString);

                punch stub_method(@selector(client)).and_return(client);
                punch stub_method(@selector(project)).and_return(project);
                punch stub_method(@selector(task)).and_return(task);
                punch stub_method(@selector(activity)).and_return(nil);
                punch stub_method(@selector(breakType)).and_return(nil);

            });
            __block NSMutableAttributedString *expectedAttributedString;
            beforeEach(^{

                NSString *truncatedClient = [punch.client.name stringByTruncatingToWidth:400 withFont:regularFont];
                NSString *truncatedProject = [punch.project.name stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedTask = [punch.task.name stringByTruncatingToWidth:400 withFont:lightFont];

                NSString *completelyAppendedString = [NSString stringWithFormat:@"%@\n%@\n%@",truncatedClient,truncatedProject,truncatedTask];
                expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                  withHighlightedText:truncatedClient
                                                                                      highligthedFont:regularFont
                                                                                          defaultFont:lightFont
                                                                                            textColor:labelBackgroundColor];
            });
            
            it(@"should return the correctly configured descriptionLabelText", ^{
                descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                 regularFont:regularFont
                                                                                   lightFont:lightFont
                                                                                   textColor:labelBackgroundColor
                                                                                    forWidth:400];
                [descriptionLabelText isEqualToAttributedString:expectedAttributedString]should be_truthy;
            });
            
        });

        context(@"when a very long client , a very long project and a long task and a long OEF's attributes are present", ^{

            __block NSArray *oefTypesArray;
            __block OEFType *oefTypeA;
            __block OEFType *oefTypeB;
            __block OEFType *oefTypeC;


            beforeEach(^{


                oefTypeA = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1 - It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:nil textValue:@"text-oef-value" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                oefTypeB = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1 - It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:@"numeric-oef-value" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                oefTypeC = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown 2- It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:@"dropdown-oef-value" collectAtTimeOfPunch:NO disabled:NO];

                oefTypesArray = @[oefTypeA,oefTypeB,oefTypeC];

                NSString *clientString = @"It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout";
                NSString *projectString = @"It is a long project established fact that a reader will be distracted by the readable content of a page when looking at its layout";
                NSString *taskString = @"It is a long task established fact that a reader will be distracted by the readable content of a page when looking at its layout";

                client stub_method(@selector(name)).again().and_return(clientString);
                project stub_method(@selector(name)).again().and_return(projectString);
                task stub_method(@selector(name)).again().and_return(taskString);

                punch stub_method(@selector(client)).and_return(client);
                punch stub_method(@selector(project)).and_return(project);
                punch stub_method(@selector(task)).and_return(task);
                punch stub_method(@selector(activity)).and_return(nil);
                punch stub_method(@selector(breakType)).and_return(nil);
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);


            });
            __block NSMutableAttributedString *expectedAttributedString;
            beforeEach(^{

                NSString *truncatedClient = [punch.client.name stringByTruncatingToWidth:400 withFont:regularFont];
                NSString *truncatedProject = [punch.project.name stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedTask = [punch.task.name stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedOEFA = [[NSString stringWithFormat:@"%@ : %@",oefTypeA.oefName,oefTypeA.oefTextValue] stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedOEFB = [[NSString stringWithFormat:@"%@ : %@",oefTypeB.oefName,oefTypeB.oefNumericValue] stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedOEFC = [[NSString stringWithFormat:@"%@ : %@",oefTypeC.oefName,oefTypeC.oefDropdownOptionValue] stringByTruncatingToWidth:400 withFont:lightFont];


                NSString *completelyAppendedString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@",truncatedClient,truncatedProject,truncatedTask,truncatedOEFA,truncatedOEFB,truncatedOEFC];
                expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                  withHighlightedText:truncatedClient
                                                                                      highligthedFont:regularFont
                                                                                          defaultFont:lightFont
                                                                                            textColor:labelBackgroundColor];
            });

            it(@"should return the correctly configured descriptionLabelText", ^{
                descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                 regularFont:regularFont
                                                                                   lightFont:lightFont
                                                                                   textColor:labelBackgroundColor
                                                                                    forWidth:400];
                [descriptionLabelText isEqualToAttributedString:expectedAttributedString]should be_truthy;
            });
            
        });
        
        context(@"when a client has regex metacharacters, a very long project and a long task and a long OEF's attributes are present", ^{
            
            __block NSArray *oefTypesArray;
            __block OEFType *oefTypeA;
            __block OEFType *oefTypeB;
            __block OEFType *oefTypeC;
            
            
            beforeEach(^{
                
                
                oefTypeA = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1 - It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:nil textValue:@"text-oef-value$" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypeB = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1 - It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:@"numeric-oef-value" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypeC = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown 2- It is a long client established fact that a reader will be distracted by the readable content of a page when looking at its layout" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:@"dropdown-oef-value" collectAtTimeOfPunch:NO disabled:NO];
                
                oefTypesArray = @[oefTypeA,oefTypeB,oefTypeC];
                
                NSString *clientString = @"$20 is acceptable. is it not?$!@$. break ?*% \\ |&^% /[]{}";
                NSString *projectString = @"It is a long project established fact that a reader will be distracted by the readable content of a page when looking at its layout";
                NSString *taskString = @"It is a long task established fact that a reader will be distracted by the readable content of a page when looking at its layout";
                
                client stub_method(@selector(name)).again().and_return(clientString);
                project stub_method(@selector(name)).again().and_return(projectString);
                task stub_method(@selector(name)).again().and_return(taskString);
                
                punch stub_method(@selector(client)).and_return(client);
                punch stub_method(@selector(project)).and_return(project);
                punch stub_method(@selector(task)).and_return(task);
                punch stub_method(@selector(activity)).and_return(nil);
                punch stub_method(@selector(breakType)).and_return(nil);
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);
                
                
            });
            __block NSMutableAttributedString *expectedAttributedString;
             __block NSMutableAttributedString *actualAttributedString;
            
            beforeEach(^{
                
                NSString *clientString_ = @"$20 is acceptable. is it not?$!@$. break ?*% \\ |&^% /[]{}";
                NSString *projectString_ = @"It is a long project established fact that a reader will be distracted by the readable content of a page when looking at its layout";
                NSString *taskString_ = @"It is a long task established fact that a reader will be distracted by the readable content of a page when looking at its layout";
                
                NSString *truncatedClient = [clientString_ stringByTruncatingToWidth:400 withFont:regularFont];
                NSString *truncatedProject = [projectString_ stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedTask = [taskString_ stringByTruncatingToWidth:400 withFont:lightFont];
                
                NSString *truncatedOEFA = [[NSString stringWithFormat:@"%@ : %@",oefTypeA.oefName,oefTypeA.oefTextValue] stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedOEFB = [[NSString stringWithFormat:@"%@ : %@",oefTypeB.oefName,oefTypeB.oefNumericValue] stringByTruncatingToWidth:400 withFont:lightFont];
                NSString *truncatedOEFC = [[NSString stringWithFormat:@"%@ : %@",oefTypeC.oefName,oefTypeC.oefDropdownOptionValue] stringByTruncatingToWidth:400 withFont:lightFont];
                
                
                NSString *completelyAppendedString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@",truncatedClient,truncatedProject,truncatedTask,truncatedOEFA,truncatedOEFB,truncatedOEFC];
                
                truncatedClient = [RepliconSpecHelper specialCharsEscapedString:truncatedClient];
                
                actualAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                  withHighlightedText:truncatedClient
                                                                                      highligthedFont:regularFont
                                                                                          defaultFont:lightFont
                                                                                            textColor:labelBackgroundColor];
                
            });
            
            it(@"should return the correctly configured descriptionLabelText", ^{
                expectedAttributedString = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                          regularFont:regularFont
                                                            lightFont:lightFont
                                                            textColor:labelBackgroundColor
                                                             forWidth:400];
                
                [actualAttributedString isEqualToAttributedString:expectedAttributedString]should be_truthy;
            });
            
        });

        context(@"when OEF's numeric and text value is empty string and no punch attributes", ^{

            __block NSArray *oefTypesArray;
            __block OEFType *oefTypeA;
            __block OEFType *oefTypeB;

            beforeEach(^{

                oefTypeA = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                oefTypeB = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                oefTypesArray = @[oefTypeA,oefTypeB];


                punch stub_method(@selector(client)).and_return(nil);
                punch stub_method(@selector(project)).and_return(nil);
                punch stub_method(@selector(task)).and_return(nil);
                punch stub_method(@selector(activity)).and_return(nil);
                punch stub_method(@selector(breakType)).and_return(nil);
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

            });

            __block NSMutableAttributedString *expectedAttributedString;
            beforeEach(^{
                punch stub_method(@selector(actionType)).and_return(PunchActionTypePunchOut);


                NSString *completelyAppendedString = [NSString stringWithFormat:@"%@",RPLocalizedString(@"Clocked Out", nil)];


                expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                  withHighlightedText:RPLocalizedString(@"Clocked Out", nil)
                                                                                      highligthedFont:regularFont
                                                                                          defaultFont:lightFont
                                                                                            textColor:labelBackgroundColor];
            });
            it(@"should return the correctly configured descriptionLabelText", ^{
                descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                 regularFont:regularFont
                                                                                   lightFont:lightFont
                                                                                   textColor:labelBackgroundColor
                                                                                    forWidth:400];
                [descriptionLabelText isEqualToAttributedString:expectedAttributedString]should be_truthy;
            });
        });

        context(@"when OEF's numeric and text value is empty string with punch attributes", ^{

            __block NSArray *oefTypesArray;
            __block OEFType *oefTypeA;
            __block OEFType *oefTypeB;

            beforeEach(^{

                oefTypeA = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                oefTypeB = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                oefTypesArray = @[oefTypeA,oefTypeB];


                punch stub_method(@selector(client)).and_return(nil);
                punch stub_method(@selector(project)).and_return(nil);
                punch stub_method(@selector(task)).and_return(nil);
                punch stub_method(@selector(activity)).and_return(activity);
                punch stub_method(@selector(breakType)).and_return(nil);
                punch stub_method(@selector(oefTypesArray)).and_return(oefTypesArray);

            });

            __block NSMutableAttributedString *expectedAttributedString;
            beforeEach(^{

                NSString *completelyAppendedString = [NSString stringWithFormat:@"My Activity"];


                expectedAttributedString = [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                                                  withHighlightedText:@"My Activity"
                                                                                      highligthedFont:regularFont
                                                                                          defaultFont:lightFont
                                                                                            textColor:labelBackgroundColor];
            });
            it(@"should return the correctly configured descriptionLabelText", ^{
                descriptionLabelText = [subject descriptionLabelForTimelineCellTextWithPunch:punch
                                                                                 regularFont:regularFont
                                                                                   lightFont:lightFont
                                                                                   textColor:labelBackgroundColor
                                                                                    forWidth:400];
                [descriptionLabelText isEqualToAttributedString:expectedAttributedString]should be_truthy;
            });
        });
        
    });
    
    
    describe(@"sourceOfPunchLabelTextWithPunch:", ^{
        __block RemotePunch *punch;
        __block NSString *sourceOfPunchLabelText;
        beforeEach(^{
            punch = nice_fake_for([RemotePunch class]);
        });
        
        context(@"when source is mobile", ^{
            beforeEach(^{
                punch stub_method(@selector(sourceOfPunch)).and_return(Mobile);
                sourceOfPunchLabelText = [subject sourceOfPunchLabelTextWithPunch:punch];
            });
            
            it(@"should return the correct text", ^{
                sourceOfPunchLabelText should equal(RPLocalizedString(@"Via Mobile", nil));
            });
        });
        
        context(@"when source is web", ^{
            beforeEach(^{
                punch stub_method(@selector(sourceOfPunch)).and_return(Web);
                sourceOfPunchLabelText = [subject sourceOfPunchLabelTextWithPunch:punch];
            });
            
            it(@"should return the correct text", ^{
                sourceOfPunchLabelText should equal(RPLocalizedString(@"Via Web", nil));
            });
        });
        
        context(@"when source is cloudclock", ^{
            beforeEach(^{
                punch stub_method(@selector(sourceOfPunch)).and_return(CloudClock);
                sourceOfPunchLabelText = [subject sourceOfPunchLabelTextWithPunch:punch];
            });
            
            
            it(@"should return the correct text", ^{
                sourceOfPunchLabelText should equal(RPLocalizedString(@"Via CloudClock", @""));
            });
        });
        
        context(@"when source is unknown", ^{
            beforeEach(^{
                punch stub_method(@selector(sourceOfPunch)).and_return(UnknownSourceOfPunch);
                sourceOfPunchLabelText = [subject sourceOfPunchLabelTextWithPunch:punch];
            });
            
            it(@"should return the correct text", ^{
                sourceOfPunchLabelText should equal(RPLocalizedString(@"Unknown", nil));
            });
        });
    });
});



SPEC_END
