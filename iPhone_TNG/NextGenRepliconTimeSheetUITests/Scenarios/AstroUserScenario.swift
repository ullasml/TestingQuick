
import XCTest


class AstroUserScenario: BaseScenario {
        
    var scenarioModel:AstroUserScenarioModel?
    
    override func setUp() {
        super.setUp()
        
        scenarioModel = AstroUserScenarioService().setup();
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
        tabBarTestStep.tapOnSettings()
        logoutTestStep.logout()
        AstroUserScenarioService().tearDown((scenarioModel?.company)!)
    }
    
    func testAstroUserScenario() {
        
        let company = scenarioModel!.companyLoginField!;
        
        let user = scenarioModel!.user!;
        
        let selectedBreakIndex = 2

        let selectedBreakType  = scenarioModel!.breakTypeArray[selectedBreakIndex]
        
        let punchActions = scenarioModel!.punchActions
        
        var numberOfPunchesOnTimeline : Int = punchActions.count
        
        /*All this steps belong to the user authentic punch actions*/

        welcomeTestStep.tapSignInButton()
        loginTestStep.loginWithNormalUser(user,company: company)
        baseTestStep.allowAppToUseLocation()
        let punchCount = punchActions.count
        
         for i in 0...punchCount-1 {
            let punchType : PunchType = punchActions[i]
            if (punchType == PunchType.ClockIn)
            {
                punchInTestStep.tapOnClockInButton();
                baseTestStep.allowAppToUsePhoto()
                imageSelectionTestStep.selectAnImage();
                punchInTestStep.verifyPunchStateDetails(PunchType.ClockIn.rawValue);
                addressTestStep.verifyAddress()
                baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
                timeLineTestStep.verifyTimeLinePunchEntry(PunchType.ClockIn.rawValue, index: 0);

            }
            else if(punchType == PunchType.TakeBreak)
            {
                punchOutTestStep.tapOnStartBreakButton();
                breakTypeSelectTestStep.selectBreakTypeFromList(selectedBreakType);
                imageSelectionTestStep.selectAnImage();
                punchOutTestStep.verifySelectedBreakType(selectedBreakType);
                addressTestStep.verifyAddress()
                baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
                timeLineTestStep.verifyTimeLinePunchEntry(selectedBreakType, index: 1);
            }
            else if(punchType == PunchType.ClockOut)
            {
                let previouspunchType : PunchType = punchActions[i-1]
                if(previouspunchType == PunchType.TakeBreak){
                    startBreakTestStep.tapOnClockOutButton();
                }
                else if(previouspunchType == PunchType.ClockIn){
                    punchOutTestStep.tapOnClockOutButton();
                }
                imageSelectionTestStep.selectAnImage();
                baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
                timeLineTestStep.verifyTimeLinePunchEntry(PunchType.ClockOut.rawValue, index: 2);
            }
        }

        /*All this steps belong to the user manual punch actions*/
        

        /*Manual punch in action*/

        let indexOfAddPunchOnTimelineBeforePunchInAction : Int = numberOfPunchesOnTimeline
        baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
        timeLineTestStep.tapToAddManualPunch(UInt(indexOfAddPunchOnTimelineBeforePunchInAction))
        manualPunchTestStep.addClockInMissingPunch();
        let clockInTime = scenarioModel!.getFormattedPunchTime()
        manualPunchTestStep.selectTimeToAddPunch(clockInTime);
        manualPunchTestStep.saveManualPunch();
        let indexOfPunchInOnTimeline = numberOfPunchesOnTimeline;
        baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
        timeLineTestStep.verifyTimeLinePunchEntry(PunchType.ClockIn.rawValue, index: UInt(indexOfPunchInOnTimeline));
        timeLineTestStep.verifyPunchTime(clockInTime, index: UInt(indexOfPunchInOnTimeline));
        punchInTestStep.verifyPunchStateDetails(PunchType.ClockIn.rawValue);
        
        numberOfPunchesOnTimeline += 1
        
        /*Manual Start Break action*/

        let indexOfAddPunchOnTimelineBeforeStartBreakAction : Int = numberOfPunchesOnTimeline
        baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
        timeLineTestStep.tapToAddManualPunch(UInt(indexOfAddPunchOnTimelineBeforeStartBreakAction))
        manualPunchTestStep.addBreakMissingPunch();
        let breakTime = scenarioModel!.getFormattedPunchTime()
        manualPunchTestStep.tapOnBreakCell();
        breakTypeSelectTestStep.selectBreakTypeFromList(selectedBreakType);
        manualPunchTestStep.selectTimeToAddPunch(breakTime);
        manualPunchTestStep.saveManualPunch();
        let indexOfBreakOnTimeline = numberOfPunchesOnTimeline;
        baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
        timeLineTestStep.verifyTimeLinePunchEntry(selectedBreakType, index: UInt(indexOfBreakOnTimeline));
        timeLineTestStep.verifyPunchTime(breakTime, index: UInt(indexOfBreakOnTimeline));
        punchOutTestStep.verifySelectedBreakType(selectedBreakType);
        
        numberOfPunchesOnTimeline += 1

        /*Manual Clock Out action*/

        let indexOfAddPunchOnTimelineBeforePunchOutAction : Int = numberOfPunchesOnTimeline
        baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
        timeLineTestStep.tapToAddManualPunch(UInt(indexOfAddPunchOnTimelineBeforePunchOutAction))
        manualPunchTestStep.addClockOutMissingPunch();
        let clockOutTime = scenarioModel!.getFormattedPunchTime()
        manualPunchTestStep.selectTimeToAddPunch(clockOutTime);
        manualPunchTestStep.saveManualPunch();
        let indexOfPunchOutOnTimeline = numberOfPunchesOnTimeline;
        baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
        timeLineTestStep.verifyTimeLinePunchEntry(PunchType.ClockOut.rawValue, index: UInt(indexOfPunchOutOnTimeline));
        timeLineTestStep.verifyPunchTime(clockOutTime, index: UInt(indexOfPunchOutOnTimeline));
        

        /*Manual Edit Punch action*/

        let indexOfPunchOnTimeLineToEdit = numberOfPunchesOnTimeline;
        let editPunchTime = scenarioModel!.getFormattedPunchTime()
        baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
        timeLineTestStep.tapOnTimelinePunchWithIndex(UInt(indexOfPunchOnTimeLineToEdit))
        punchOverViewTestStep.editPunchTime(editPunchTime);
        punchOverViewTestStep.savePunch();
        let indexOfLastPunchTimeline = numberOfPunchesOnTimeline;
        baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
        timeLineTestStep.verifyTimeLinePunchEntry(PunchType.ClockOut.rawValue, index: UInt(indexOfLastPunchTimeline));
        timeLineTestStep.verifyPunchTime(editPunchTime, index: UInt(indexOfLastPunchTimeline));
        

        /*Manual Delete Punch action*/

        let indexOfPunchToDeleteFromTimeLine = numberOfPunchesOnTimeline;
        baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
        timeLineTestStep.tapOnTimelinePunchWithIndex(UInt(indexOfPunchToDeleteFromTimeLine))
        punchOverViewTestStep.deletePunch();
        baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
        timeLineTestStep.verifyTimeLinePunchEntry(selectedBreakType, index: UInt(indexOfPunchToDeleteFromTimeLine-1));
        punchOutTestStep.verifySelectedBreakType(selectedBreakType);
    }
}
