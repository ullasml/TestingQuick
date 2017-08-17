//
//  Dimensions-iPhone.h
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.


/////////////////////////////////////////////////
//   Generic Frame constants for iPhone    //
/////////////////////////////////////////////////
#define FullScreenFrame				CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)

/////////////////////////////////////////////////
//            HomeViewController               //
/////////////////////////////////////////////////

//#define customButtonFrame  CGRectMake(,, expImage.size.width, expImage.size.height)

#define ExpenseButtonFrame			CGRectMake(40, 220, expImage.size.width, expImage.size.height)
#define TimeSheetButtonFrame		CGRectMake(40, 60, tSimage.size.width, tSimage.size.height)
#define TimeoffButtonFrame			CGRectMake(200, 60, tOFimage.size.width, tOFimage.size.height)
#define MoreButtonFrame				CGRectMake(200, 220, moreImage.size.width, moreImage.size.height)
//#define NewTimeEntryButtonFrame	CGRectMake(15, 340, tentryImage.size.width, tentryImage.size.height)
//#define NewTimeEntryButtonFrame	CGRectMake(45, 340, timeEntryImage.size.width, timeEntryImage.size.height)
//#define NewTimeEntryButtonFrame	CGRectMake(40, 360, timeEntryImage.size.width, timeEntryImage.size.height)
#define NewTimeEntryButtonFrame		CGRectMake(40.5, 360, timeEntryImage.size.width, timeEntryImage.size.height)
//#define NewTimeEntryButtonFrame	CGRectMake(45, 320, timeEntryImage.size.width, timeEntryImage.size.height)

#define ExpenseLabelFrame			CGRectMake(40, 290, 100, 60)
#define TimeSheetLabelFrame			CGRectMake(40, 140, 100, 40)
#define TimeoffLabelFrame			CGRectMake(210, 140, 100, 40)
#define MoreLabelFrame				CGRectMake(220, 290, 100, 60)

//////////////////////////////////////////////////
//            LoginViewController               //
/////////////////////////////////////////////////
#define LoginTableViewFrame			CGRectMake(15.0, 0.0, self.view.frame.size.width-30, self.view.frame.size.height)
//#define LoginTopLabelFrame		CGRectMake(130.0,50,240,30.0)
//#define LoginTopLabelFrame		CGRectMake(130.0,70,240,30.0)
//#define LoginTopLabelFrame		CGRectMake(115.0,80,240,30.0)
#define LoginTopLabelFrame			CGRectMake(115.0,20,240,30.0)

#define WelcomeLabelFrame			CGRectMake(35.0,20,125,30.0)
//#define WelcomeLabelFrame			CGRectMake(15.0,70,125,30.0)
//#define WelcomeLabelFrame			CGRectMake(35.0,80,125,30.0)


//#define LoginButtonFrame			CGRectMake(5.0 , 50, img.size.width, img.size.height)
#define LoginButtonFrame			CGRectMake(30.0 , 50, img.size.width, img.size.height)

//#define ForgotPasswordLabelFrame	CGRectMake(10.0,0.0, 150, 30)
//#define ForgotPasswordLabelFrame	CGRectMake(112.0,0.0, 90, 30)
#define ForgotPasswordLabelFrame	CGRectMake(70.0,0.0, 150.0, 30.0)
//#define ForgotPasswordButtonFrame	CGRectMake(20.0,0.0, 150, 30)
#define ForgotPasswordButtonFrame	CGRectMake(20.0,0.0, 150.0, 40.0)

#define forgotLabelFrame			CGRectMake(forgotPswdButton.frame.size.width+8, 0, 160, 30)
//#define freeTrailLabelFrame		CGRectMake(60, 120, 180, 30)
#define freeTrailLabelFrame			CGRectMake(45.0, 120.0, 225.0, 30.0)
#define signUpButtonFrame			CGRectMake(55, 110, 180, 40)
#define signUpLabelFrame			CGRectMake(70, 140, 160, 30)

/////////////////////////////////////////////////
//     ChangePasswordViewController       //
/////////////////////////////////////////////////
#define ChangePasswordTableFrame	CGRectMake(0.0, 0.0, self.view.frame.size.width, 170.0)


/////////////////////////////////////////////////
//     ListOfExpenseSheetsViewController       //
/////////////////////////////////////////////////


/////////////////////////////////////////////////
//     ListOfExpenseEntriesViewController     //
/////////////////////////////////////////////////



/////////////////////////////////////////////////
//     AddNewExpenseSheetViewController        //
/////////////////////////////////////////////////


/////////////////////////////////////////////////
//     AddNewExpenseEntryViewController        //
/////////////////////////////////////////////////

/////////////////////////////////////////////////
//     ListOfTimeSheetsViewController        //
/////////////////////////////////////////////////


/////////////////////////////////////////////////
//    ListOfTimeEntriesViewController        //
/////////////////////////////////////////////////
//#define EntriesTopTitleViewFrame            CGRectMake(0.0, 0.0, 200.0,40.0)//CGRectMake(-55.0, 0.0, 280.0,40.0)
#define EntriesTopTitleViewFrame              CGRectMake(-55.0, 0.0, 280.0,40.0)
//#define EntriesTopToolbarlabelFrame         CGRectMake(0.0, 0.0, 200.0,20.0)//CGRectMake(-55.0, 0.0, 280.0,20.0)
#define EntriesTopToolbarlabelFrame           CGRectMake(-55.0, 0.0, 280.0,70.0)
//#define EntriesInnerTopToolbarlabelFrame    CGRectMake(0.0, 18.0, 200.0,20.0)//CGRectMake(-55.0, 18.0, 280.0,20.0)
#define EntriesInnerTopToolbarlabelFrame      CGRectMake(-55.0, 18.0, 280.0,20.0)
#define AddFirstTimeEntryButtonFrame          CGRectMake(75, 140,180 ,40)

#define G2EntriesTotalLabelFrame                CGRectMake(10.0, 0.0,100.0 ,30.0)//US4065//Juhi

#define G2EntriesTotalHoursLabelFrame           CGRectMake(103.0, 0.0,208.0 ,30.0)

/////////////////////////////////////////////////
//     AddNewTimeEntryViewController        //
/////////////////////////////////////////////////

#define TimeTopTitleViewFrame                 CGRectMake(0.0, 0.0, 210.0,40.0)
#define TimeEntryTopToolbarlabelFrame         CGRectMake(0.0, 0.0, 175.0,20.0)
#define TimeEntryInnerTopToolbarlabelFrame    CGRectMake(0.0, 0.0, 175.0,20.0)
#define NewTimeEntryTableViewFrame            CGRectMake(10.0,0.0,self.view.frame.size.width-20.0,self.view.frame.size.height)
#define SignUpforFreeTableViewFrame           CGRectMake(00.0,0.0,self.view.frame.size.width-00.0,self.view.frame.size.height)
#define ToolbarSegmentControlFrame            CGRectMake(10.0,8.0,140.0,31.0)
#define G2TimeEntryTimeLabelFrame               CGRectMake(10.0,0.0,250.0,30.0)//US4065//Juhi
#define TimeEntryProjectInfoLabelFrame        CGRectMake(10.0,0.0,250.0,30.0)//US4065//Juhi
#define TimeEntryCommentsLabelFrame           CGRectMake(10.0,0.0,250.0,30.0)//US4065//Juhi
#define TimeEntryCellButtonTextFieldFrame     CGRectMake(150.0,8.0,140.0,30.0)//US4065//Juhi
/////////////////////////////////////////////////
//     ResubmitTimeSheetViewController        //
/////////////////////////////////////////////////
#define SubmitTextViewFrame					  CGRectMake(10.0, 94.0, 300.0, 180.0)//US4275//Juhi
#define G2ReasonLabelFrame					  CGRectMake(65, 20.0, 200, 70.0)//US4275//Juhi
#define SheetLabelFrame                       CGRectMake(65, 5, 200,20)//US4275//Juhi

/////////////////////////////////////////////////
//     SubmissionErrorViewController        //
/////////////////////////////////////////////////
#define WarningImageFrame					   CGRectMake(10.0, 10.0, 40.0, 40.0)
#define WarningLabelFrame					   CGRectMake(60.0, 10.0, 260.0, 40.0)
#define TopTitleViewFrame				       CGRectMake(0.0, 0.0, 200.0,40.0)
#define TopToolbarlabelFrame				   CGRectMake(13.0, 0.0, 190.0,20.0)
#define InnerTopToolbarlabelFrame			   CGRectMake(0.0, 18.0, 200.0,20.0)

/////////////////////////////////////////////////
//    ClientProjectTaskViewController        //
/////////////////////////////////////////////////
#define ClientProjectTaskTableFrame			   CGRectMake(10.0, 0.0, self.view.frame.size.width-20.0, self.view.frame.size.height)

/////////////////////////////////////////////////
//		TaskViewController        //
/////////////////////////////////////////////////
#define TaskTableFrame						   CGRectMake(0.0, 0.0, self.view.frame.size.width,self.view.frame.size.height)

/////////////////////////////////////////////////
//		AdhocTimeOffViewController        //
/////////////////////////////////////////////////
#define AdhocTimeOffTableViewFrame				CGRectMake(10.0,0.0,self.view.frame.size.width-12.0,self.view.frame.size.height)
#define AdhocTopTitleViewFrame					CGRectMake(0.0, 0.0, 210.0,40.0)
#define AdhocTopToolbarlabelFrame				CGRectMake(0.0, 0.0, 175.0,20.0)
#define AdhocInnerTopToolbarlabelFrame			CGRectMake(0.0, 18.0, 175.0,20.0)
#define AdhocTimeLabelFrame						CGRectMake(40.05,0.0,250.0,30.0)
#define AdhocTimeOffInfoLabelFrame				CGRectMake(40.0,0.0,250.0,30.0)
#define AdhocCommentsLabelFrame					CGRectMake(40.0,0.0,250.0,30.0)
#define AdhocToolbarSegmentControlFrame			CGRectMake(10.0,8.0,140.0,31.0)
