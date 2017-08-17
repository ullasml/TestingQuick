//
//  TechErrors_TestCase.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 12/10/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "URLReader.h"

@interface TechErrors_TestCase : XCTestCase
@property (nonatomic,strong)URLReader *urlReader;;

@end

@implementation TechErrors_TestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _urlReader = [[URLReader alloc] init];
    XCTAssertNotNil(_urlReader, @"Cannot create URLReader instance");
    }

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHTTPCodeResponse {
    // This is an example of a functional test case.
    
    NSHTTPURLResponse * response = [[NSHTTPURLResponse alloc]initWithURL:[NSURL URLWithString:@"http://www.google.com"] statusCode:403 HTTPVersion:@"1.1" headerFields:[NSDictionary dictionary]];
    
    NSURLConnection *connection=[[NSURLConnection alloc]init];
    
    [_urlReader connection:connection didReceiveResponse:response];
    
    XCTAssertTrue(_urlReader.testCode ==403,
                  @"HTTP CODE %d is not expected", _urlReader.testCode);
}


@end
