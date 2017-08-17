//
//  repliconkit.h
//  repliconkit
//
//  Created by Anil Reddy on 3/25/16.
//  Copyright © 2016 replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for repliconkit.
FOUNDATION_EXPORT double repliconkitVersionNumber;

//! Project version string for repliconkit.
FOUNDATION_EXPORT const unsigned char repliconkitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <repliconkit/PublicHeader.h>

#import <repliconkit/FMDB.h>
#import <repliconkit/FMDBMigrationManager.h>
#import <repliconkit/LogUtil.h>
#import <repliconkit/LogUtilAbstractWrapper.h>
#import <repliconkit/CommonUtil.h>
#import <repliconkit/DDAbstractDatabaseLogger.h>
#import <repliconkit/DDASLLogCapture.h>
#import <repliconkit/DDASLLogger.h>
#import <repliconkit/DDAssertMacros.h>
#import <repliconkit/DDFileLogger.h>
#import <repliconkit/DDLegacyMacros.h>
#import <repliconkit/DDLog.h>
#import <repliconkit/DDLog+LOGV.h>
#import <repliconkit/DDLogMacros.h>
#import <repliconkit/DDTTYLogger.h>
#import <repliconkit/GAI.h>
#import <repliconkit/GAIDictionaryBuilder.h>
#import <repliconkit/GAIEcommerceFields.h>
#import <repliconkit/GAIEcommerceProduct.h>
#import <repliconkit/GAIEcommerceProductAction.h>
#import <repliconkit/GAIEcommercePromotion.h>
#import <repliconkit/GAIFields.h>
#import <repliconkit/GAILogger.h>
#import <repliconkit/GAITrackedViewController.h>
#import <repliconkit/GAITracker.h>
#import <repliconkit/GATracker.h>
#import <repliconkit/GTMDefines.h>
#import <repliconkit/GTMNSString+HTML.h>
#import <repliconkit/NetworkMonitor.h>
#import <repliconkit/NSDictionary+RCategory.h>
#import <repliconkit/NSMutableDictionary+RCategory.h>
#import <repliconkit/NSString+HTML.h>
#import <repliconkit/NSString+RCategory.h>
#import <repliconkit/TAGContainer.h>
#import <repliconkit/TAGContainerOpener.h>
#import <repliconkit/TAGDataLayer.h>
#import <repliconkit/TAGLogger.h>
#import <repliconkit/TAGManager.h>
#import <repliconkit/TestOne.h>
#import <repliconkit/RNCryptor.h>
#import <repliconkit/RNDecryptor.h>
#import <repliconkit/RNEncryptor.h>
#import <repliconkit/ReportTechnicalErrors.h>
#import <repliconkit/SDiPhoneVersion.h>
#import <repliconkit/AppConfig.h>
#import <repliconkit/AppConfigRepository.h>
#import <repliconkit/ReachabilityMonitor.h>
#import <repliconkit/NSDictionary+Validation.h>
#import <repliconkit/RepliconKitDependencyModule.h>
#import <repliconkit/FBShimmering.h>
#import <repliconkit/FBShimmeringView.h>

/*
 ReadMe:
 https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html
 http://stackoverflow.com/questions/24875745/xcode-6-beta-4-using-bridging-headers-with-framework-targets-is-unsupported
 
 - To use objective-c code in swift, in static framework target,
        1) List the header in this umbrella header file
        2) Make it public under Build Phases, header section.
 
 - To use swift in objective-c code
        1) Make the class, method public
        2) Import #import <repliconkit/repliconkit-Swift.h> in .m file
 */
