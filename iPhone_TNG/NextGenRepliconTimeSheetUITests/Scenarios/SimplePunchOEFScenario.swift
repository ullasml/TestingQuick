
import XCTest

class SimplePunchOEFScenario: BaseScenario {
        
    var scenarioModel:SimplePunchOEFScenarioModel?
    
    override func setUp() {
        super.setUp()
        
        scenarioModel = SimplePunchOEFScenarioService().setup();
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
        tabBarTestStep.tapOnSettings()
        logoutTestStep.logout()
        SimplePunchOEFScenarioService().tearDown((scenarioModel?.company)!)
    }
    
    func testSimplePunchOEFScenario() {
        
        let company = scenarioModel!.companyLoginField!;
        
        let user = scenarioModel!.user!;
        
        let selectedBreakIndex = 2
        
        let selectedBreakType  = scenarioModel!.breakTypeArray[selectedBreakIndex]
        
        let punchActions = scenarioModel!.punchActions
        
        /*All this steps belong to the user authentic punch actions*/
        
        welcomeTestStep.tapSignInButton()
        loginTestStep.loginWithNormalUser(user,company: company)
        baseTestStep.allowAppToUseLocation()
        
        let punchCount = punchActions.count
        
        for i in 0...punchCount-1 {
            let punchType : PunchType = punchActions[i]
            if (punchType == PunchType.ClockIn)
            {
                punchInOEFTestStep.tapOnOefCellAndFillValues((scenarioModel?.clockInOEFsArray)!)
                punchInOEFTestStep.tapOnClockInButton();
                baseTestStep.allowAppToUsePhoto()
                imageSelectionTestStep.selectAnImage();
                addressTestStep.verifyAddress()
                punchOutOEFTestStep.verifyPunchStateDetails((scenarioModel?.clockInOEFsArray)!, punchAction: PunchType.ClockIn.rawValue)
                baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
                timeLineTestStep.verifyTimeLinePunchEntrySubStrings((scenarioModel?.clockInOEFsArray)!, punchAction: PunchType.ClockIn.rawValue, index: 0);
            }
            else if(punchType == PunchType.TakeBreak)
            {
                punchOutOEFTestStep.tapOnTakeABreakButton();
                oefCardTestStep.tapOnBreakEntry()
                breakTypeSelectTestStep.selectBreakTypeFromList(selectedBreakType);
                oefCardTestStep.tapOnOefCellAndFillValues((scenarioModel?.breakOEFsArray)!, isBreakEntry: 1)
                oefCardTestStep.tapOnPunchActionButton()
                imageSelectionTestStep.selectAnImage();
                addressTestStep.verifyAddress()
                breakOEFTestStep.verifyPunchStateDetails((scenarioModel?.breakOEFsArray)!, punchAction: selectedBreakType)
                baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
                timeLineTestStep.verifyTimeLinePunchEntrySubStrings((scenarioModel?.breakOEFsArray)!, punchAction: selectedBreakType, index: 1);
            }
            else if(punchType == PunchType.ResumeWork)
            {
                breakOEFTestStep.tapOnResumeButton();
                oefCardTestStep.tapOnOefCellAndFillValues((scenarioModel?.resumeOEFsArray)! , isBreakEntry: 0)
                oefCardTestStep.tapOnPunchActionButton()
                imageSelectionTestStep.selectAnImage();
                addressTestStep.verifyAddress()
                punchOutOEFTestStep.verifyPunchStateDetails((scenarioModel?.resumeOEFsArray)!, punchAction: PunchType.ClockIn.rawValue)
                baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
                baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
                timeLineTestStep.verifyTimeLinePunchEntrySubStrings((scenarioModel?.resumeOEFsArray)!, punchAction: PunchType.ClockIn.rawValue, index: 2);
            }
            else if(punchType == PunchType.ClockOut)
            {
                let previouspunchType : PunchType = punchActions[i-1]
                timeLineTestStep.scrollToCellOnIndex(0)
                if(previouspunchType == PunchType.TakeBreak){
                    breakOEFTestStep.tapOnClockOutButton();
                }
                else {
                    punchOutOEFTestStep.tapOnClockOutButton();
                }
                oefCardTestStep.tapOnOefCellAndFillValues((scenarioModel?.clockOutOEFsArray)! , isBreakEntry: 0)
                oefCardTestStep.tapOnPunchActionButton()
                imageSelectionTestStep.selectAnImage();
                baseTestStep.scrollViewUpAction(withName: Constants.punch_flow_scroll_view_identifier)
                timeLineTestStep.verifyTimeLinePunchEntrySubStrings((scenarioModel?.clockOutOEFsArray)!, punchAction: PunchType.ClockOut.rawValue, index: 3);
            }
        }
    }
}
