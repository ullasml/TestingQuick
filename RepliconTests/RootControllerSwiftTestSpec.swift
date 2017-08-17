//
//import Foundation
//import Nimble
//
//@testable import Replicon
//
///*
// This is a swift test class .
// 
// - Matcher framework - Nimble
// - Assertions framework - Cedar
// - Mocks/Stubs: Build your own
// - Issues : For complex classes and use cases , fake classes adopting to protocols may have to be written. This can lead to bolier plate code
//
//*/
//
//class FakeUserSessionClient: URLSessionClientProtocol {
//    func addListener(_ observer: URLSessionClientObserver) {
//        
//    }
//
//    
//    let deferred : KSDeferred<AnyObject>!
//    init(deferred: KSDeferred<AnyObject>) {
//        self.deferred = deferred
//    }
//    
//    func requestWithURL(_ url: String) -> KSPromise<AnyObject>?{
//        if url == "http://jsonplaceholder.typicode.com/users" {
//            return self.deferred.promise
//        }
//        return nil
//    }
//}
//
//class RootControllerSwiftTestSpec: CDRSpec {
//    override func declareBehaviors() {
//        var subject : RootController!
//        var deferred : KSDeferred<AnyObject>!
//
//        beforeEach {
//            deferred = KSDeferred<AnyObject>.init()
//            subject = RootController(coder: FakeUserSessionClient(deferred: deferred))
//            expect(subject.view).toNot(beNil())
//        }
//        
//        describe("When the promise resolves") {
//            
//            beforeEach {
//                deferred.resolve(withValue: NSData() as AnyObject)
//            }
//            
//            it("it should set the test success status correctly") {
//                expect(subject.testResultsStatus.text).to(equal("Success"))
//            }
//        }
//        
//        describe("When the promise fails") {
//            
//            beforeEach {
//                deferred.rejectWithError(nil)
//            }
//            
//            it("it should set the failure status correctly") {
//                expect(subject.testResultsStatus.text).to(equal("Failure"))
//            }
//        }
//
//        describe("When the view loads intially") {
//            
//            beforeEach {
//                expect(subject.view).toNot(beNil())
//            }
//            
//            it("it should set the test results status correctly") {
//                expect(subject.testResultsStatus.text).to(equal("Getting Results..."))
//            }
//        }
//    }
//}
