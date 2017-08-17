#import <Cedar/Cedar.h>
#import "TimeSheetPermittedActionsDeserializer.h"
#import "TimeSheetPermittedActions.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimeSheetPermittedActionsDeserializerSpec)

describe(@"TimeSheetPermittedActionsDeserializer", ^{
    __block TimeSheetPermittedActionsDeserializer *subject;
    __block NSMutableDictionary *jsonDictionary;
    
    beforeEach(^{
        subject = [[TimeSheetPermittedActionsDeserializer alloc]init];
    });

    context(@"deserialize:", ^{
        
        beforeEach(^{
            jsonDictionary = [@{@"permittedActions":@{
                                        @"canAutoSubmitOnDueDate":@1
                                        },
                                @"permittedApprovalActions":@{
                                        @"canSubmit":@1,
                                        @"canReopen":@1,
                                        @"canUnsubmit":@1,
                                        @"displayResubmit":@1
                                        }
                                }mutableCopy];
        });
        __block TimeSheetPermittedActions *timeSheetPermittedActions;
        context(@"should correctly deserialize and set canSubmitOnDueDate", ^{
            
            context(@"when canAutoSubmitOnDueDate is true", ^{
                beforeEach(^{
                    timeSheetPermittedActions = [subject deserialize:jsonDictionary];
                });
                
                it(@"should correctly set canSubmitOnDueDate", ^{
                    timeSheetPermittedActions.canAutoSubmitOnDueDate should be_falsy;
                });
            });
            
            context(@"when canAutoSubmitOnDueDate is false and canReSubmit is true", ^{
                beforeEach(^{
                    jsonDictionary = [@{@"permittedActions":@{
                                                @"canAutoSubmitOnDueDate":@0
                                                },
                                        @"permittedApprovalActions":@{
                                                @"canSubmit":@0,
                                                @"canReopen":@1,
                                                @"canUnsubmit":@1,
                                                @"displayResubmit":@1
                                                }
                                        }mutableCopy];
                    timeSheetPermittedActions = [subject deserialize:jsonDictionary];
                });
                
                it(@"should correctly set canSubmitOnDueDate", ^{
                    timeSheetPermittedActions.canAutoSubmitOnDueDate should be_falsy;
                });
            });
            
            context(@"when canAutoSubmitOnDueDate is false and canReSubmit is false", ^{
                beforeEach(^{
                    jsonDictionary = [@{@"permittedActions":@{
                                                @"canAutoSubmitOnDueDate":@0
                                                },
                                        @"permittedApprovalActions":@{
                                                @"canSubmit":@1,
                                                @"canReopen":@1,
                                                @"canUnsubmit":@1,
                                                @"displayResubmit":@0
                                                }
                                        }mutableCopy];
                    timeSheetPermittedActions = [subject deserialize:jsonDictionary];
                });
                
                it(@"should correctly set canSubmitOnDueDate", ^{
                    timeSheetPermittedActions.canAutoSubmitOnDueDate should be_truthy;
                });
            });
            
        });
        
        context(@"should correctly deserialize and set canReOpenSubmittedTimeSheet", ^{
            
            
            context(@"when canReopen is enabled", ^{
                beforeEach(^{
                    jsonDictionary = [@{@"permittedActions":@{
                                                @"canAutoSubmitOnDueDate":@0
                                                },
                                        @"permittedApprovalActions":@{
                                                @"canSubmit":@1,
                                                @"canReopen":@1,
                                                @"canUnsubmit":@1,
                                                @"displayResubmit":@0
                                                }
                                        }mutableCopy];
                    timeSheetPermittedActions = [subject deserialize:jsonDictionary];
                });
                
                it(@"should correctly set canReOpenSubmittedTimeSheet", ^{
                    timeSheetPermittedActions.canReOpenSubmittedTimeSheet should be_truthy;
                });
            });
            
            context(@"when canUnsubmit is enabled", ^{
                beforeEach(^{
                    jsonDictionary = [@{@"permittedActions":@{
                                                @"canAutoSubmitOnDueDate":@0
                                                },
                                        @"permittedApprovalActions":@{
                                                @"canSubmit":@1,
                                                @"canReopen":@1,
                                                @"canUnsubmit":@1,
                                                @"displayResubmit":@0
                                                }
                                        }mutableCopy];
                    timeSheetPermittedActions = [subject deserialize:jsonDictionary];
                });
                
                it(@"should correctly set canReOpenSubmittedTimeSheet", ^{
                    timeSheetPermittedActions.canReOpenSubmittedTimeSheet should be_truthy;
                });
            });
            
            context(@"when both canUnsubmit and canReopen  is disabled", ^{
                beforeEach(^{
                    jsonDictionary = [@{@"permittedActions":@{
                                                @"canAutoSubmitOnDueDate":@0
                                                },
                                        @"permittedApprovalActions":@{
                                                @"canSubmit":@1,
                                                @"canReopen":@0,
                                                @"canUnsubmit":@0,
                                                @"displayResubmit":@0
                                                }
                                        }mutableCopy];
                    timeSheetPermittedActions = [subject deserialize:jsonDictionary];
                });
                
                it(@"should correctly set canReOpenSubmittedTimeSheet", ^{
                    timeSheetPermittedActions.canReOpenSubmittedTimeSheet should be_falsy;
                });
            });
            
        });
        
        context(@"should correctly deserialize and set canReSubmitTimeSheet", ^{
            
            
            context(@"when canSubmit is enabled and displayResubmit is disabled", ^{
                beforeEach(^{
                    jsonDictionary = [@{@"permittedActions":@{
                                                @"canAutoSubmitOnDueDate":@0
                                                },
                                        @"permittedApprovalActions":@{
                                                @"canSubmit":@1,
                                                @"canReopen":@1,
                                                @"canUnsubmit":@1,
                                                @"displayResubmit":@0
                                                }
                                        }mutableCopy];
                    timeSheetPermittedActions = [subject deserialize:jsonDictionary];
                });
                
                it(@"should correctly set canReOpenSubmittedTimeSheet", ^{
                    timeSheetPermittedActions.canReSubmitTimeSheet should be_falsy;
                });
            });
            
            context(@"when displayResubmit is enabled and canSubmit is disabled", ^{
                beforeEach(^{
                    jsonDictionary = [@{@"permittedActions":@{
                                                @"canAutoSubmitOnDueDate":@0,
                                                @"displayResubmit":@1
                                                },
                                        @"permittedApprovalActions":@{
                                                @"canSubmit":@0,
                                                @"canReopen":@1,
                                                @"canUnsubmit":@1
                                                }
                                        }mutableCopy];
                    timeSheetPermittedActions = [subject deserialize:jsonDictionary];
                });
                
                it(@"should correctly set canReOpenSubmittedTimeSheet", ^{
                    timeSheetPermittedActions.canReSubmitTimeSheet should be_falsy;
                });
            });
            
            context(@"when both displayResubmit and canSubmit is enabled", ^{
                beforeEach(^{
                    jsonDictionary = [@{@"permittedActions":@{
                                                @"canAutoSubmitOnDueDate":@0,
                                                @"displayResubmit":@1
                                                },
                                        @"permittedApprovalActions":@{
                                                @"canSubmit":@1,
                                                @"canReopen":@1,
                                                @"canUnsubmit":@1
                                                }
                                        }mutableCopy];
                    timeSheetPermittedActions = [subject deserialize:jsonDictionary];
                });
                
                it(@"should correctly set canReOpenSubmittedTimeSheet", ^{
                    timeSheetPermittedActions.canReSubmitTimeSheet should be_truthy;
                });
            });
        });
    });
    
    context(@"deserializeForWidgetTimesheet:isAutoSubmitEnabled:", ^{
        __block TimeSheetPermittedActions *timeSheetPermittedActions;
        beforeEach(^{
            jsonDictionary = [@{@"permittedApprovalActions":@{
                                        @"canSubmit":@1,
                                        @"canReopen":@1,
                                        @"canUnsubmit":@1,
                                        @"displayResubmit":@1
                                        }
                                }mutableCopy];
        });
        context(@"should correctly deserialize and set canSubmitOnDueDate", ^{
            
            context(@"when canAutoSubmitOnDueDate is true", ^{
                beforeEach(^{
                    timeSheetPermittedActions = [subject deserializeForWidgetTimesheet:jsonDictionary isAutoSubmitEnabled:false];
                });
                
                it(@"should correctly set canSubmitOnDueDate", ^{
                    timeSheetPermittedActions.canAutoSubmitOnDueDate should be_falsy;
                });
            });
            
            context(@"when canAutoSubmitOnDueDate is false and canReSubmit is true", ^{
                beforeEach(^{
                    jsonDictionary = [@{@"permittedApprovalActions":@{
                                                @"canSubmit":@0,
                                                @"canReopen":@1,
                                                @"canUnsubmit":@1,
                                                @"displayResubmit":@1
                                                }
                                        }mutableCopy];
                    timeSheetPermittedActions = [subject deserializeForWidgetTimesheet:jsonDictionary isAutoSubmitEnabled:false];
                });
                
                it(@"should correctly set canSubmitOnDueDate", ^{
                    timeSheetPermittedActions.canAutoSubmitOnDueDate should be_falsy;
                });
            });
            
            context(@"when canAutoSubmitOnDueDate is false and canReSubmit is false", ^{
                beforeEach(^{
                    jsonDictionary = [@{@"permittedApprovalActions":@{
                                                @"canSubmit":@1,
                                                @"canReopen":@1,
                                                @"canUnsubmit":@1,
                                                @"displayResubmit":@0
                                                }
                                        }mutableCopy];
                    timeSheetPermittedActions = [subject deserializeForWidgetTimesheet:jsonDictionary isAutoSubmitEnabled:false];
                });
                
                it(@"should correctly set canSubmitOnDueDate", ^{
                    timeSheetPermittedActions.canAutoSubmitOnDueDate should be_truthy;
                });
            });
            
            context(@"when canAutoSubmitOnDueDate is true and canReSubmit is false", ^{
                beforeEach(^{
                    jsonDictionary = [@{@"permittedApprovalActions":@{
                                                @"canSubmit":@1,
                                                @"canReopen":@1,
                                                @"canUnsubmit":@1,
                                                @"displayResubmit":@0
                                                }
                                        }mutableCopy];
                    timeSheetPermittedActions = [subject deserializeForWidgetTimesheet:jsonDictionary isAutoSubmitEnabled:true];
                });
                
                it(@"should correctly set canSubmitOnDueDate", ^{
                    timeSheetPermittedActions.canAutoSubmitOnDueDate should be_falsy;
                });
            });
            
        });
        
        context(@"should correctly deserialize and set canReOpenSubmittedTimeSheet", ^{
            
            
            context(@"when canReopen is enabled", ^{
                beforeEach(^{
                    jsonDictionary = [@{@"permittedApprovalActions":@{
                                                @"canSubmit":@1,
                                                @"canReopen":@1,
                                                @"canUnsubmit":@1,
                                                @"displayResubmit":@0
                                                }
                                        }mutableCopy];
                    timeSheetPermittedActions = [subject deserializeForWidgetTimesheet:jsonDictionary isAutoSubmitEnabled:false];
                });
                
                it(@"should correctly set canReOpenSubmittedTimeSheet", ^{
                    timeSheetPermittedActions.canReOpenSubmittedTimeSheet should be_truthy;
                });
            });
            
            context(@"when canUnsubmit is enabled", ^{
                beforeEach(^{
                    jsonDictionary = [@{@"permittedApprovalActions":@{
                                                @"canSubmit":@1,
                                                @"canReopen":@1,
                                                @"canUnsubmit":@1,
                                                @"displayResubmit":@0
                                                }
                                        }mutableCopy];
                    timeSheetPermittedActions = [subject deserializeForWidgetTimesheet:jsonDictionary isAutoSubmitEnabled:false];
                });
                
                it(@"should correctly set canReOpenSubmittedTimeSheet", ^{
                    timeSheetPermittedActions.canReOpenSubmittedTimeSheet should be_truthy;
                });
            });
            
            context(@"when both canUnsubmit and canReopen  is disabled", ^{
                beforeEach(^{
                    jsonDictionary = [@{@"permittedApprovalActions":@{
                                                @"canSubmit":@1,
                                                @"canReopen":@0,
                                                @"canUnsubmit":@0,
                                                @"displayResubmit":@0
                                                }
                                        }mutableCopy];
                    timeSheetPermittedActions = [subject deserializeForWidgetTimesheet:jsonDictionary isAutoSubmitEnabled:false];
                });
                
                it(@"should correctly set canReOpenSubmittedTimeSheet", ^{
                    timeSheetPermittedActions.canReOpenSubmittedTimeSheet should be_falsy;
                });
            });
            
        });
        
        context(@"should correctly deserialize and set canReSubmitTimeSheet", ^{
            
            
            context(@"when canSubmit is enabled and displayResubmit is disabled", ^{
                beforeEach(^{
                    jsonDictionary = [@{@"permittedApprovalActions":@{
                                                @"canSubmit":@1,
                                                @"canReopen":@1,
                                                @"canUnsubmit":@1,
                                                @"displayResubmit":@0
                                                }
                                        }mutableCopy];
                    timeSheetPermittedActions = [subject deserializeForWidgetTimesheet:jsonDictionary isAutoSubmitEnabled:false];
                });
                
                it(@"should correctly set canReOpenSubmittedTimeSheet", ^{
                    timeSheetPermittedActions.canReSubmitTimeSheet should be_falsy;
                });
            });
            
            context(@"when displayResubmit is enabled and canSubmit is disabled", ^{
                beforeEach(^{
                    jsonDictionary = [@{@"permittedApprovalActions":@{
                                                @"canSubmit":@0,
                                                @"canReopen":@1,
                                                @"canUnsubmit":@1,
                                                @"displayResubmit":@1
                                                }
                                        }mutableCopy];
                    timeSheetPermittedActions = [subject deserializeForWidgetTimesheet:jsonDictionary isAutoSubmitEnabled:false];
                });
                
                it(@"should correctly set canReOpenSubmittedTimeSheet", ^{
                    timeSheetPermittedActions.canReSubmitTimeSheet should be_falsy;
                });
            });
            
            context(@"when both displayResubmit and canSubmit is enabled", ^{
                beforeEach(^{
                    jsonDictionary = [@{@"permittedApprovalActions":@{
                                                @"canSubmit":@1,
                                                @"canReopen":@1,
                                                @"canUnsubmit":@1,
                                                @"displayResubmit":@1
                                                }
                                        }mutableCopy];
                    timeSheetPermittedActions = [subject deserializeForWidgetTimesheet:jsonDictionary isAutoSubmitEnabled:false];
                });
                
                it(@"should correctly set canReOpenSubmittedTimeSheet", ^{
                    timeSheetPermittedActions.canReSubmitTimeSheet should be_truthy;
                });
            });
        });
    });
});

SPEC_END
