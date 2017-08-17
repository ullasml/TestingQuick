#import <Cedar/Cedar.h>
#import "IndexCursor.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(IndexCursorSpec)

describe(@"IndexCursor", ^{
    /*__block IndexCursor *subject;

    beforeEach(^{
        NSArray *timesheets = @[@"Some-Object1",
                                @"Some-Object2",
                                @"Some-Object3",
                                @"Some-Object4"];
        subject = [[IndexCursor alloc] initWithTimesheets:timesheets position:0];
    });

    describe(@"-count", ^{
        it(@"should equal 4", ^{
            subject.count should equal(4);
        });
    });

    describe(@"-position", ^{
        it(@"should initially be at the zero-indexed end", ^{
            subject.position should equal(0);
        });

        describe(@"when the cursor cannot move forward", ^{
            beforeEach(^{
                [subject moveForwards];
            });

            it(@"should not change its position", ^{
                subject.position should equal(0);
            });
        });

        describe(@"when the cursor moves to the beginning", ^{
            beforeEach(^{
                [subject moveBackwards];
                [subject moveBackwards];
                [subject moveBackwards];
            });

            it(@"should be at the end", ^{
                subject.position should equal(3);
            });

            describe(@"when the cursor is moved again", ^{
                beforeEach(^{
                    [subject moveBackwards];
                });

                it(@"should still be at the end", ^{
                    subject.position should equal(3);
                });
            });
        });

        describe(@"when the cursor moves backward", ^{
            beforeEach(^{
                [subject moveBackwards];
            });

            it(@"should update its position", ^{
                subject.position should equal(1);
            });

            describe(@"and it moves backwards again", ^{
                beforeEach(^{
                    [subject moveBackwards];
                });

                it(@"should update its position", ^{
                    subject.position should equal(2);
                });
            });

            describe(@"when it moves forward", ^{
                beforeEach(^{
                    [subject moveForwards];
                });

                it(@"should update its position", ^{
                    subject.position should equal(0);
                });
            });
        });
    });

    describe(@"-canMoveForwards", ^{
        it(@"should initially return false", ^{
            [subject canMoveForwards] should be_falsy;
        });

        context(@"after moving backwards", ^{
            beforeEach(^{
                [subject moveBackwards];
            });

            it(@"should return true", ^{
                [subject canMoveForwards] should be_truthy;
            });
        });
    });

    describe(@"-canMoveBackwards", ^{
        it(@"should initially return true", ^{
            [subject canMoveBackwards] should be_truthy;
        });

        describe(@"when the cursor moves back once", ^{
            beforeEach(^{
                [subject moveBackwards];
            });

            it(@"should still be true", ^{
                [subject canMoveBackwards] should be_truthy;
            });

            describe(@"when the cursor moves to the beginning", ^{
                beforeEach(^{
                    [subject moveBackwards];
                    [subject moveBackwards];
                });

                it(@"should be false", ^{
                    [subject canMoveBackwards] should be_falsy;
                });
            });
        });
    });*/
});

SPEC_END
