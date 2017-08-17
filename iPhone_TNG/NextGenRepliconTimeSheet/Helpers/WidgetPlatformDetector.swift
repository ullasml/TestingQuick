
import UIKit

var supportedWidgetUris:[String]  = [TimesheetWidgetType.PunchWidget.rawValue,
                                     TimesheetWidgetType.PayWidget.rawValue,
                                     TimesheetWidgetType.NoticeWidget.rawValue,
                                     TimesheetWidgetType.AttestationWidget.rawValue]


class WidgetPlatformDetector: NSObject {
    
    var appConfig: AppConfig
    private var userConfiguredWidgetUris = [String]()

    init(appConfig:AppConfig){
        self.appConfig = appConfig
        super.init()
    }

    func setup(userConfiguredWidgetUris:[String]) {
        self.userConfiguredWidgetUris =  userConfiguredWidgetUris
    }
    
    func isWidgetPlatformSupported() -> Bool {
        let isWidgetPlatformFlagEnabled =  self.appConfig.getTimesheetWidgetPlatform()
        if isWidgetPlatformFlagEnabled{
            return checkForSupportedWidgets()
        }
        return false
    }
    
    private func checkForSupportedWidgets() -> Bool{
        var areOnlySupportedWidgetsPresent = false
        for widgetUri in self.userConfiguredWidgetUris {
            areOnlySupportedWidgetsPresent = supportedWidgetUris.contains(widgetUri)
            if areOnlySupportedWidgetsPresent {
                break;
            }
        }
        return areOnlySupportedWidgetsPresent
    }
}



