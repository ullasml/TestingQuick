//
//  ExpensesService.m
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2ExpensesService.h"
#import "G2RepliconServiceManager.h"
#import "FrameworkImport.h"
#import "RepliconAppDelegate.h"

@implementation G2ExpensesService

static int totalRequestsSent = 0;
static int totalRequestsServed = 0;
//static int connectionFailedCount=0;

- (id) init
{
	self = [super init];
	if (self != nil) {
		if (expensesModel == nil) {
			expensesModel = [[G2ExpensesModel alloc]init];
		}
		if (supportDataModel==nil) {
			supportDataModel=[[G2SupportDataModel alloc]init];
		}
		
	}
	return self;
}


-(void)sendRequestToGetExpensesByUserWithDelegate:(id)delegate
{
	
	/*
	 "Action": "Query",
	 "QueryType": "ExpenseByUser",
	 "DomainType": "Replicon.Expense.Domain.Expense",
	 "Args": [
	 "_type": "Replicon.Domain.User",
	 "Identity":3
	 ],
	 "Load": [
	 {
	 "Relationship": "Entries",
	 "Load": [
	 {
	 "Relationship": "Currency"
	 },
	 {
	 "Relationship": "ExpenseType"
	 },
	 {
	 "Relationship": "Project"
	 },
	 {
	 "Relationship": "ExpenseReceipt"
	 },
	 {
	 "Relationship": "PaymentMethod"
	 }
	 
	 ]
	 }
	 ]
	 }*/
	
	
	NSMutableArray *loadArray=[NSMutableArray array];
	NSMutableArray *inLoadArray=[NSMutableArray array];
	NSMutableDictionary *currencyDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Currency",@"Relationship",nil];
	NSMutableDictionary *expTypeDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"ExpenseType",@"Relationship",nil];
	NSMutableDictionary *projectDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Project",@"Relationship",nil];
	NSMutableDictionary *receiptDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"ExpenseReceipt",@"Relationship",nil];
	NSMutableDictionary *paymentMethodDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"PaymentMethod",@"Relationship",nil];
	
	[inLoadArray addObject:currencyDict];
	[inLoadArray addObject:expTypeDict];
	[inLoadArray addObject:projectDict];
	[inLoadArray addObject:receiptDict];
	[inLoadArray addObject:paymentMethodDict];	
	
	NSMutableArray *argArray=[NSMutableArray array];
	NSDictionary *argDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Domain.User",@"__type",[[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"],@"Identity",nil]; 
	[argArray addObject:argDict];
	NSMutableDictionary *inLoadDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Entries",@"Relationship",inLoadArray,@"Load",nil];	 
	[loadArray addObject:inLoadDict];
	NSMutableDictionary *dictExp=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
								  @"ExpenseByUser",@"QueryType",
								  @"Replicon.Expense.Domain.Expense",@"DomainType",
								  argArray,@"Args",
								  loadArray,@"Load",nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:dictExp error:&err];
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ExpenseByUser"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
	
	
}

-(void)sendRequestToGetExpenseTypesByProjects:(id)delegate{
	
    NSDictionary *relationshipDict = [NSDictionary dictionaryWithObjectsAndKeys:@"ExpenseTypes",@"Relationship",nil];
	NSArray *loadArray = [NSArray arrayWithObjects:relationshipDict,nil]; 
	NSArray *argsArray = [NSArray array];
	NSDictionary *mainDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action"
							  ,@"ExpenseProjects",@"QueryType"
							  ,@"Replicon.Project.Domain.Project",@"DomainType"
							  ,argsArray,@"Args"
							  ,loadArray,@"Load"
							  ,nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:mainDict error:&err];
#ifdef DEV_DEBUG
	//DLog(@"sendRequestToGetExpenseTypesByProjects %@",str);
#endif
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ExpenseTypesByProjects"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
	
	
}
-(void)sendRequestToGetExpenseClients:(id)delegate{
	
	NSArray *argsArray = [NSArray array];
	NSDictionary *mainDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action"
							  ,@"ExpenseClients",@"QueryType"
							  ,@"Replicon.Domain.Client",@"DomainType"
							  ,argsArray,@"Args"
							  ,nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:mainDict error:&err];
#ifdef DEV_DEBUG
	//DLog(@"sendRequestToGetExpenseClients %@",str);
#endif
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ExpenseClients"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
	
	
}

-(void)sendRequestToGetExpenseProjects:(id)delegate{
	
	NSArray *argsArray = [NSArray array];
	NSDictionary *mainDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action"
							  ,@"ExpenseProjects",@"QueryType"
							  ,@"Replicon.Project.Domain.Project",@"DomainType"
							  ,argsArray,@"Args"
							  ,nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:mainDict error:&err];
#ifdef DEV_DEBUG
	//DLog(@"sendRequestToGetExpenseProjects %@",str);
#endif
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ExpenseProjects"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
	
}

-(void)sendRequestTogetExpenseProjectsWithProjectRelatedClients:(id)delegate withProjectIds:(NSMutableArray *)projectIdsArr
{
	/*
	 {
	 "Action": "Query",
	 "Args": [],
	 "QueryType": "ExpenseProjects",
	 "Load": [
	 {
	 "Relationship": "ProjectClients",
	 "Load": [
	 {
	 "Relationship": "Client"
	 }
	 ]
	 }
	 ],
	 "DomainType": "Replicon.Project.Domain.Project"
	 }
	 */
	
	NSMutableArray *argsArray = [NSMutableArray array];
    if (projectIdsArr!=nil)
    {
      
        [argsArray addObject:projectIdsArr];
        
    }
    NSMutableArray *sortArray=[NSMutableArray arrayWithObjects:@"Name", nil];
   
    
	NSMutableArray *firstLoadArray=[NSMutableArray array];
	NSMutableArray *secondLoadArray=[NSMutableArray array];
	NSDictionary*clientDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil];
	[secondLoadArray addObject:clientDict];
	NSMutableDictionary *firstLoadDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"ProjectClients",@"Relationship",secondLoadArray,@"Load",nil];
	NSDictionary *rootTaskDict = [NSDictionary dictionaryWithObjectsAndKeys:@"RootTask",@"Relationship",nil];
	[firstLoadArray addObject:firstLoadDict];
	[firstLoadArray addObject:rootTaskDict];
	NSDictionary *mainDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action"
							  ,@"ProjectByIds",@"QueryType",firstLoadArray,@"Load",
							  @"Replicon.Project.Domain.Project",@"DomainType"
							  ,argsArray,@"Args",sortArray,@"SortBy"
							  ,nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:mainDict error:&err];
#ifdef DEV_DEBUG
	//DLog(@"sendRequestToGetExpenseProjects %@",str);
#endif
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ExpenseProjects"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
	
}



-(void)sendRequestToGetExpenseProjectsByClient:(id)client_ID withDelegate:(id)delegate{
	totalRequestsSent++;
    
    int countInt= [[[G2AppProperties getInstance]getAppPropertyFor:@"PaginatedProjectsClients"]intValue];
    NSNumber *count= [NSNumber numberWithInt:countInt];
    int index=0;
    NSDictionary *clientTableDict=[expensesModel fetchQueryHandlerAndStartIndexForClientID:client_ID];
    if ([clientTableDict objectForKey:@"expenses_StartIndex"]!=nil && ![[clientTableDict objectForKey:@"expenses_StartIndex"]isKindOfClass:[NSNull class]]) {
        index=[[clientTableDict objectForKey:@"expenses_StartIndex"]intValue];
        if (index>0)
        {
            index=index-1;
        }
    }
    
	NSNumber *startIndex=[NSNumber numberWithInt:index];
    NSDictionary *argsDict =nil;
    
    if (![client_ID isEqualToString:@"null"])
    {
        argsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Domain.Client",@"__type",
                    client_ID,@"Identity",
                    nil];
    }
	
	
    NSMutableArray *firstLoadArray=[NSMutableArray array];
	NSMutableArray *secondLoadArray=[NSMutableArray array];
	NSDictionary*clientDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil];
	[secondLoadArray addObject:clientDict];
	NSMutableDictionary *firstLoadDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"ProjectClients",@"Relationship",secondLoadArray,@"Load",nil];
	NSDictionary *rootTaskDict = [NSDictionary dictionaryWithObjectsAndKeys:@"RootTask",@"Relationship",nil];
	[firstLoadArray addObject:firstLoadDict];
	[firstLoadArray addObject:rootTaskDict];

     NSMutableArray *sortArray=[NSMutableArray arrayWithObjects:@"Name", nil];
    
    NSArray *argsArray =nil;
    if (argsDict!=nil)
    {
        argsArray = [NSArray arrayWithObjects:argsDict,nil];
    }
    else
    {
        argsArray = [NSArray arrayWithObjects:[NSNull null],nil];
    }
	
	NSDictionary *mainDict = [NSDictionary dictionaryWithObjectsAndKeys:count,@"Count",@"Query",@"Action"
							  ,@"ExpenseProjectsByClient",@"QueryType",firstLoadArray,@"Load"
							  ,@"Replicon.Project.Domain.Project",@"DomainType"
							  ,argsArray,@"Args",sortArray,@"SortBy",startIndex,@"StartIndex"
							  ,nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:mainDict error:&err];
#ifdef DEV_DEBUG
	//DLog(@"Expense Projects Request %@",str);
#endif
	
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ExpenseProjectsByClient"]];
	[self setServiceDelegate:delegate];
	[self executeRequest:[NSDictionary dictionaryWithObjectsAndKeys:client_ID,@"ClientID",startIndex,@"startIndex", nil]];
	
}

-(void)sendRequestToGetExpenseTypeAll:(id)delegate{
	NSArray *argsArray = [NSArray array];
	NSDictionary *queryDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action"
							   ,@"ExpenseTypeAll",@"QueryType"
							   ,@"Replicon.Expense.Domain.ExpenseType",@"DomainType"
							   ,argsArray,@"Args"
							   ,nil];
	
	NSMutableArray *arrayQuery=[NSMutableArray array];
	[arrayQuery addObject:queryDict];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:arrayQuery error:&err];
#ifdef DEV_DEBUG
	//DLog(@"sendRequestToGetExpenseTypeAll %@",str);
#endif
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ExpenseTypeAll"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
	
}



-(void)sendRequestToUnsubmitExpenseSheetWithID:(NSString *)sheet_ID withDelegate:(id)delegate{
	
	NSMutableDictionary *operationDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Unsubmit",@"__operation",nil];
	NSMutableDictionary *submitDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Edit",@"Action",
									   sheet_ID,@"Identity",
									   @"Replicon.Expense.Domain.Expense",@"Type", 
									   [NSArray arrayWithObjects:operationDict,nil],@"Operations",nil];
	
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:submitDict error:&err];
#ifdef DEV_DEBUG
	//DLog(@"sendRequestToUnsubmitExpenseSheetWithID %@",str);
#endif
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"Unsubmit"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
	
}
//US2669//Juhi
//-(void)sendRequestToSubmitExpenseSheetWithID:(NSString *)sheet_ID withDelegate:(id)delegate{
//	
//	NSMutableDictionary *operationDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Submit",@"__operation",nil];
-(void)sendRequestToSubmitExpenseSheetWithID:(NSString *)sheet_ID  comments:(NSString *)comments withDelegate:(id)delegate{
	
	NSMutableDictionary *operationDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Submit",@"__operation",comments,@"Comment",nil];
	NSMutableDictionary *submitDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Edit",@"Action",
									   sheet_ID,@"Identity",
									   @"Replicon.Expense.Domain.Expense",@"Type", 
									   [NSArray arrayWithObjects:operationDict,nil],@"Operations",nil];
	
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:submitDict error:&err];
#ifdef DEV_DEBUG
	//DLog(@"sendRequestToSubmitExpenseSheetWithID %@",str);
#endif
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"Submit"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
	
}

-(void)sendRequestToGetExpenseById:(NSString *)sheet_ID withDelegate:(id)delegate{
	
	
	NSMutableArray *loadArray;
	loadArray=[NSMutableArray array];
	NSArray *insideArgumentsArray=[NSArray arrayWithObjects:sheet_ID,nil];
	NSMutableArray *argArray=[NSMutableArray array];
	[argArray addObject:insideArgumentsArray];
	
	NSMutableArray *inLoadArray=[NSMutableArray array];
	
	NSMutableDictionary *load1Dict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil]; 
	NSMutableArray *load1Arr = [NSMutableArray array];
	[load1Arr addObject:load1Dict];
	NSMutableArray *load2Arr = [NSMutableArray array];
	NSMutableDictionary *load2Dict =[NSMutableDictionary dictionaryWithObjectsAndKeys:
									 @"ProjectClients",@"Relationship",
									 load1Arr,@"Load",nil];
	[load2Arr addObject:load2Dict];
	
	
	[inLoadArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Currency",@"Relationship",nil]];
	[inLoadArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"ExpenseType",@"Relationship",nil]];
	[inLoadArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
							@"Project",@"Relationship",
							load2Arr,@"Load",nil]];
	[inLoadArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"PaymentMethod",@"Relationship",nil]];
	
	NSMutableDictionary *taxCode1Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode1",@"Relationship",nil];
	NSMutableDictionary *taxCode2Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode2",@"Relationship",nil];
	NSMutableDictionary *taxCode3Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode3",@"Relationship",nil];
	NSMutableDictionary *taxCode4Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode4",@"Relationship",nil];
	NSMutableDictionary *taxCode5Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode5",@"Relationship",nil];
	//ADDED TAXCODES TO QUERY
	[inLoadArray addObject:taxCode1Dict];
	[inLoadArray addObject:taxCode2Dict];
	[inLoadArray addObject:taxCode3Dict];
	[inLoadArray addObject:taxCode4Dict];
	[inLoadArray addObject:taxCode5Dict];
	
	
	[inLoadArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"ExpenseReceipt",@"CountOf",nil]];
	[loadArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Entries",@"Relationship",inLoadArray,@"Load",nil]];
	[loadArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"ReimbursementCurrency",@"Relationship",nil]];
	[loadArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"RemainingApprovers",@"Relationship",nil]];
	
	NSDictionary *approvalActionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Type",@"Relationship",nil];
	NSArray *approvalLoadArray = [NSArray arrayWithObjects:approvalActionDict,nil];
	NSDictionary *filteredHistoryDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"FilteredHistory",@"Relationship",
										 approvalLoadArray,@"Load",
										 nil];
	[loadArray addObject:filteredHistoryDict];
	
	NSMutableDictionary *dictExp=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
								  @"ExpenseById",@"QueryType",
								  @"Replicon.Expense.Domain.Expense",@"DomainType",
								  argArray,@"Args",
								  loadArray,@"Load",nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:dictExp error:&err];
#ifdef DEV_DEBUG
	//DLog(@"lineItemQuery %@",str);
	
#endif
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ExpenseById"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
	
	
}

-(void)sendRequestToGetExpenseTypesByIds:(NSArray *)expenseIdsArr WithDelegate:(id)delegate
{
    NSMutableArray *firstLoadArray=[NSMutableArray array];
    
    NSMutableArray *thirdLoadArray=[NSMutableArray array];//
    
    NSDictionary *currencyDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Currency",@"Relationship",nil];
    
    [thirdLoadArray addObject:currencyDict];
    
    NSDictionary *entryInDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Entries",@"Relationship",thirdLoadArray,@"Load", nil];
    
    
    NSMutableArray *seconLoadArray=[NSMutableArray array];
    
    [seconLoadArray addObject:entryInDict];
    
    
    NSDictionary *tskDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TskRate",@"Relationship",seconLoadArray,@"Load",nil];
    
    
    
    [firstLoadArray addObject:tskDict];
    
    //NSMutableArray *loadArray=[NSMutableArray array];
    
    NSDictionary *taxDict1=[NSDictionary dictionaryWithObjectsAndKeys:@"TaxCode1",@"Relationship",nil];
    
    NSDictionary *taxDict2=[NSDictionary dictionaryWithObjectsAndKeys:@"TaxCode2",@"Relationship",nil];
    
    NSDictionary *taxDict3=[NSDictionary dictionaryWithObjectsAndKeys:@"TaxCode3",@"Relationship",nil];
    
    NSDictionary *taxDict4=[NSDictionary dictionaryWithObjectsAndKeys:@"TaxCode4",@"Relationship",nil];
    
    NSDictionary *taxDict5=[NSDictionary dictionaryWithObjectsAndKeys:@"TaxCode5",@"Relationship",nil];
    
    [firstLoadArray addObject:taxDict1];
    
    [firstLoadArray addObject:taxDict2];
    
    [firstLoadArray addObject:taxDict3];
    
    [firstLoadArray addObject:taxDict4];
    
    [firstLoadArray addObject:taxDict5];
    
    NSMutableArray *argsArray = [NSMutableArray array];
    
    if ([expenseIdsArr count]>0)
    {
        [argsArray addObject:expenseIdsArr];
    }
    
    NSDictionary *queryDict;

    queryDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
                 
                 @"ExpenseTypeById",@"QueryType",firstLoadArray,@"Load"  //@"ExpenseTypeById"
                 
                 ,@"Replicon.Expense.Domain.ExpenseType",@"DomainType" //@"Replicon.Expense.Domain.ExpenseType"
                 
                 ,argsArray,@"Args"
                 
                 ,nil];
    
    NSMutableArray *arrayQuery=[NSMutableArray array];
	
	[arrayQuery addObject:queryDict];
	
	NSError *err = nil;
	
	NSString *str = [JsonWrapper writeJson:arrayQuery error:&err];
	
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	
    [self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ExpenseTypesByID"]];
	
	
	[self setServiceDelegate:delegate];
	[self executeRequest];

}


-(void)sendRequestToGetExpenseTypesWithTaxCodesWithQueryType:(NSString *)queryType WithDomain:(NSString *)domainType withProjectIDs:(NSMutableArray *)projectIds WithDelegate:(id)delegate{
    
    NSMutableArray *firstLoadArray=[NSMutableArray array];
    
if([queryType isEqualToString:@"ExpenseTypeAll"])
{

    NSMutableArray *thirdLoadArray=[NSMutableArray array];//
    
    NSDictionary *currencyDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Currency",@"Relationship",nil];
    
    [thirdLoadArray addObject:currencyDict];
    
    NSDictionary *entryInDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Entries",@"Relationship",thirdLoadArray,@"Load", nil];
    
    
    NSMutableArray *seconLoadArray=[NSMutableArray array];
    
    [seconLoadArray addObject:entryInDict];
    
    
    NSDictionary *tskDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TskRate",@"Relationship",seconLoadArray,@"Load",nil];
    
    
    
    [firstLoadArray addObject:tskDict];
    
    //NSMutableArray *loadArray=[NSMutableArray array];
    
    NSDictionary *taxDict1=[NSDictionary dictionaryWithObjectsAndKeys:@"TaxCode1",@"Relationship",nil];
    
    NSDictionary *taxDict2=[NSDictionary dictionaryWithObjectsAndKeys:@"TaxCode2",@"Relationship",nil];
    
    NSDictionary *taxDict3=[NSDictionary dictionaryWithObjectsAndKeys:@"TaxCode3",@"Relationship",nil];
    
    NSDictionary *taxDict4=[NSDictionary dictionaryWithObjectsAndKeys:@"TaxCode4",@"Relationship",nil];
    
    NSDictionary *taxDict5=[NSDictionary dictionaryWithObjectsAndKeys:@"TaxCode5",@"Relationship",nil];
    
    [firstLoadArray addObject:taxDict1];
    
    [firstLoadArray addObject:taxDict2];
    
    [firstLoadArray addObject:taxDict3];
    
    [firstLoadArray addObject:taxDict4];
    
    [firstLoadArray addObject:taxDict5];
}


    

	
	NSMutableArray *argsArray = [NSMutableArray array];

    if ([projectIds count]>0)
    {
         [argsArray addObject:projectIds];
    }
   
    
	NSDictionary *queryDict;
	NSMutableArray *topLoadArray=[NSMutableArray array];
	if(![queryType isEqualToString:@"ExpenseTypeAll"]){
//		NSDictionary *topDict=[NSDictionary dictionaryWithObjectsAndKeys:@"ExpenseTypes",@"Relationship",firstLoadArray,@"Load",nil];
        NSDictionary *topDict=[NSDictionary dictionaryWithObjectsAndKeys:@"ExpenseTypes",@"Relationship",@"true",@"IdentityOnly",firstLoadArray,@"Load",nil];
		[topLoadArray addObject:topDict];
		queryDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
					 
					 queryType,@"QueryType",topLoadArray,@"Load"  //@"ExpenseProjects"
					 
					 ,domainType,@"DomainType" //@"Replicon.Project.Domain.Project"
					 
					 ,argsArray,@"Args"
					 
					 ,nil];	
	}
    
    else {
		
		
		queryDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
					 
					 queryType,@"QueryType",firstLoadArray,@"Load"  //@"ExpenseProjects"
					 
					 ,domainType,@"DomainType" //@"Replicon.Project.Domain.Project"
					 
					 ,argsArray,@"Args"
					 
					 ,nil];
	}	
	
	
	NSMutableArray *arrayQuery=[NSMutableArray array];
	
	[arrayQuery addObject:queryDict];
	
	NSError *err = nil;
	
	NSString *str = [JsonWrapper writeJson:arrayQuery error:&err];
	/* ExpensesService ------   sendRequestToGetExpenseTypesWithTaxCodesWithQueryType*/
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	if(![queryType isEqualToString:@"ExpenseTypeAll"]){
		[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ExpenseProjectsTypesWithTaxs"]];
	}else {
		
		[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ExpenseAllTypesWithTaxs"]];
	}
	
	[self setServiceDelegate:delegate];
	[self executeRequest];
	
}




-(void)sendRequestToGetRecieptImages:(NSString*)idSheet _delegate:(id)delegate
{
	/*
	 {
	 "Action": "LoadIdentity",
	 "DomainType": "Replicon.Expense.Domain.Expense",
	 "Identity": "234",
	 "Load": [
	 {
	 "Relationship":"Entries",
	 "Load": [
	 {
	 "Relationship": "ExpenseReceipt"
	 }
	 ]
	 }
	 ]
	 }
	 */
	
	NSDictionary *receiptDict=[NSDictionary dictionaryWithObjectsAndKeys:@"ExpenseReceipt",@"Relationship",nil];
	NSMutableArray *secondLoadArray=[NSMutableArray array];
	[secondLoadArray addObject:receiptDict];
	
	NSDictionary *firstLoadDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Entries",@"Relationship",secondLoadArray,@"Load",nil];
	NSMutableArray *firstLoadArray=[NSMutableArray array];
	[firstLoadArray addObject:firstLoadDict];
	NSMutableDictionary *queryDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"LoadIdentity",@"Action",@"Replicon.Expense.Domain.Expense",@"DomainType"
									,idSheet,@"Identity",firstLoadArray,@"Load",nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
#ifdef DEV_DEBUG
	//DLog(@"getRecieptImagesQuery %@",str);
#endif
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"GetReceiptImages"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
	
}
-(void)sendRequestToUploadReceiptImage:(NSDictionary *)_dict withDelegate:(id)delegate{
	/*
	 {
	 "Action": "Edit",
	 "Type":"Replicon.Expense.Domain.Expense",
	 "Identity": "234",
	 "Operations":[
	 {
	 "__operation":"CollectionEdit",
	 "Collection":"Entries",
	 "Identity": "432",
	 "Operations": [
	 {
	 "__operation":"SetExpenseReceipt",
	 "Image":{
	 "_type":"Image",
	 "Value":" //string of base64 encoded byte array of image here //"
	 },
	 "ContentType":"image/png",
	 "FileName":"logo.png"
	 }
	 ]
	 }
	 ]
	 }
	 */
	
	NSMutableArray *secondOperationsArray=[NSMutableArray array];
	NSDictionary *imageDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Image",@"_type",[_dict objectForKey:@"base64ImageString"],@"Value",nil];
	NSMutableDictionary *secondOperDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"SetExpenseReceipt",@"__operation",imageDict,@"Image",
										 [_dict objectForKey:@"imgType"],@"ContentType",[_dict objectForKey:@"imgName"],@"FileName",nil];
	[secondOperationsArray addObject:secondOperDict];
	
	NSMutableDictionary *firstOperDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"CollectionEdit",@"__operation",@"Entries",@"Collection",
										[_dict objectForKey:@"entryId"],@"Identity",secondOperationsArray,@"Operations",nil];
	NSMutableArray *firstOperArray=[NSMutableArray array];
	[firstOperArray addObject:firstOperDict];
	
	
}


-(void)sendRequestToSaveNewExpenseWithReciept:(NSDictionary *)dict withDelegate:(id)delegate
{
	
	//send request to server to save Expense with receipt
	/*
	 {
	 "Action": "Edit",
	 "Type": "Replicon.Expense.Domain.Expense",
	 "Identity": "93",
	 "Operations": [
	 {
	 "__operation": "SetProperties",
	 "User": {
	 "__type": "Replicon.Domain.User",
	 "Identity": "2"
	 },
	 "Description": "test edited"
	 "Net AMount":
	 },
	 {
	 "__operation": "CollectionAdd",
	 "Collection": "Entries",
	 "Operations": [
	 {
	 "__operation": "SetProperties",
	 "ExpenseType": {
	 "__type": "Replicon.Expense.Domain.ExpenseType",
	 "Identity": "2"
	 },
	 "Currency": {
	 "__type": "Replicon.Domain.Currency",
	 "Identity": "2"
	 }
	 },
	 {
	 "__operation": "SetExpenseReceipt",
	 "Image": {
	 "_type": "Image",
	 "Value": "/9j/4AAQSkZJRgABAQAAAQABAAD/4QBYRXhpZgAATU0AKgAAAAgAAgESAAMAAAABAAEAAIdpAAQAAAABAAAAJgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAQaADAAQAAAABAAAAHwAAAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/2wBDAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/wAARCAAfAEEDAREAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD9ov2kP2pfjd8RfjJ8TLPR/iT4r8BeCvA/j7xj8OvD3hzwbeW+jTyzfD7xJqvg/Xtc1vWks31m/udX8Q6PqtzYWCXtvo+maMNNgisJNQ+36le+9l+WUa9CNes5S53Llim0lGMnDW1m25J9bWt5nBiMVOnUcIJLltdtXu2k9OySf3ngv/C0fjX/ANF3+Mn/AIXWo/8AxNd39kYP+WX/AIHP/wCSMPrlbvH/AMBQf8LR+NX/AEXf4yf+F1qP/wATR/ZGD/ll/wCBz/8Akg+uVu8f/AUH/C0fjV/0Xf4yf+F1qP8A8TR/ZGD/AJZf+Bz/APkg+uVu8f8AwFB/wtH41f8ARd/jJ/4XWo//ABNH9kYP+WX/AIHP/wCSD65W7x/8BQf8LR+NX/Rd/jJ/4XWo/wDxNH9kYP8All/4HP8A+SD65W7x/wDAUH/C0fjV/wBF3+Mn/hdaj/8AE0f2Rg/5Zf8Agc//AJIPrlbvH/wFHT+Fv2rPjz8FdUg+Ia/Fjxz4v0Lww/8AbPizwj4w1SHxBp/iLwtYK9xr+n2d1eWb6noesNpaXUujappN5b+VqcdqupW2paY93YXHNi8poQoValJyjOnCVSzk2pKCcpJ3bd3FOzVtbX0uaUsXUlUjGaTUmo6KzTbsn9+67H9On9tar6Qf9+j/APFV84ekfypeP3CfFr49px8v7Sf7So6H/ovXxF9K+wyr/cKH/cX/ANPVDx8V/vFT/tz/ANIic15w9vyNegc57p8M/gE3xH8DeJviRqvib4rHSdA8Y6T4Og8E/s//AA20r4m/EWCG90iLVLjx14o0jU4tTu4vB4nmk0izg0XRTdXF7pt+91q2nwbZI/MxmLq0a0aUJUqUZU3NVK3NyTd+X2aajJKV9W3ZKNmzpo0ozg5NTk1KzjC10rX5rNptdNNbo5bTPgp8S/Euva1ovwvuvBnxW0Ow8Z33gnwz4vvvF3hn4S6h481a3E0kek6T4E8d6tZ+IrbxPbCMadq+n3UNrpFvrYksLXWJpElSGvr3s6cHVpTcnT9pUdK1WFON+VylOm5Rt10e2tkJUOaUlGcUubljz+7KTteyjKzuttVvocvceAfi9ZFY9Q+Fut2Vz/wqfWfjZNA+reHJvsnw+8O6rPoGuXdxPbatNb/2/p/iCGPQ38J28s/iK41O+06Cz0+4F9bPJp9fo9p83tVSUbauUoqS/wC3eV35n7ttb6Ml0Jrtbkc221ay0evrpbe/TYm8S/D74s+BdPg1nx78NdU8K6NLq1loF3eN4k8B+I7vw3r2qWc2o6PonjrQfCHivX/EPgDVNYsreWbT7TxhpejvJMo0+byNTYWRqjjaNaahFTTkm6bnFxjVjFtN027KST3tfcU6M4R5ny6NKSTTcW9lJLa61VzlvOHt+RrrMjiPibKD8N/iCOOfBHisdD30G/rnxf8AumK/7B63/puRpR/i0v8Ar5D/ANKR/Yr9nHt+n/xNfDnuH8dvxouvJ+PP7RcRbBT9pX9o0Een/F7/AB8fX3r6/K1/sFDV/wDL3t/z+qeR4+K/3ip/25/6RE86+3/7f+fzr0LPu/w/yOc93+FfxS+GvhHRJNM8V+CfF8ev2viuPxZovxN+EfxAT4bfEWH/AIl9vp914U1nUr3w34s03WPCl19lt722iXTrHVdH1AT3dhqHmXCG348RhatSfPSr8l1yzp1Kaq0pb2lyOyU0nZuzurbNNvanUhFWlDm1upRk4TXlzJXt5aH1Fp/7fHhmLx1d/FC4+D15onjiX4qxfEK6uvAHjTQvC48baRbeGPDfhPTvB/xO1zUvhv4m8UeI7HTNO8MWl0ZtG1Tw1BrGq3NxealYGKS8tdQ5JZVLlVONdcnsuSXtKXO4ycpSlOnFTjGHM5W2bikkpM1WKV+Z09ebmXLLlvolaT5W2la++r3TPLJf2z9dT4Ran8NdO8LW1nrU/j3Vtf0fx5NrTXepaP4E1jxlpfxFu/hu2n/2TbrfWU3jnR7TWrjVBqFnBNC97YLocSahezT9P1CHt1Wc20qUYSp8qSlUjB0lV5ruz9m3FRte9pc7skZ+3fs3Dl15rqV3dRclPla6+8lq+mltbjPjr+1xN8YdG8UW1vF8SdJvfiBruieIPFWh6z8SoNc+HGiTaNAzSab4D8Jad4R8O31vpuqayRrzHxr4h8aXuizr/Z+iXNrZsWpYbAvDzUnOnKMIuNNxoxjUtLS86jcm3y+6+VRUt32HVr+0i1yyTk05e+3HTXSNkt+97dO58efb/wDb/wA/nXfZ93+H+RznL+OL3f4L8Xrvzu8L+IFx/vaTdj19658Wn9VxOr/3et2/59y8jSj/ABaX/XyH/pSP7j/s7+h/L/69fEHuH8tv7dP7I/xb+EXx0+JHjK00OPxJ8OPix8QvGXxE8LeJLHWfDtvcwah451288X+JPDesaPqesWGqW15omva5qFvZXltbXemX+jHTbkXkN+17p1n72X5nQoYdUK3NF03LllGLkpKUnJ3tqmnJ9LNW1vocGIws6lRzg0+ZK6bs00ktNNrJed7nxP8A8IX49/6FS9/8Gfhj/wCX1d/9r4L+ef8A4Ll/kYfU63aP/gSD/hC/Hv8A0Kl7/wCDPwx/8vqP7XwX88//AAXL/IPqdbtH/wACQf8ACF+Pf+hUvf8AwZ+GP/l9R/a+C/nn/wCC5f5B9Trdo/8AgSD/AIQvx7/0Kl7/AODPwx/8vqP7XwX88/8AwXL/ACD6nW7R/wDAkH/CF+Pf+hUvf/Bn4Y/+X1H9r4L+ef8A4Ll/kH1Ot2j/AOBIP+EL8e/9Cpe/+DPwx/8AL6j+18F/PP8A8Fy/yD6nW7R/8CR7R8Df2QPjF+0v4ytfh9pXh1dE8N3skMXjzxbqWueGFg8MeELqaO11vUbXTrXW7nVtX1drGaa30XT7Cxkin1Sa1GoXem6eLm+g5sXmuHnh6tOjzTnVhKnrFxUVNOMpNveybskt97I0pYSpGpGU3FKMlLR3bad0tu+/kf2N182ekf/Z"
	 },
	 "ContentType": "jpeg/png",
	 "FileName": "manoj.png"
	 }
	 ]
	 }
	 ]
	 }
	 */
	
	
	
	NSDictionary *imageDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Image",@"_type",[dict objectForKey:@"base64ImageString"],@"Value",nil];
	NSMutableDictionary *recieptDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"SetExpenseReceipt",@"__operation",imageDict,@"Image",
									  @"jpeg/png",@"ContentType",@"receipt.jpg",@"FileName",nil];
	
	
	NSMutableDictionary *subOperationsDict;
	subOperationsDict=[NSMutableDictionary dictionary];
	[subOperationsDict setObject:[dict objectForKey:@"lineItemDesc"] forKey:@"Description"];
	NSDictionary *userDict;
	userDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Domain.User",@"__type",[[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"],@"Identity",nil];
	
	NSDictionary *firstOperDict;
	firstOperDict=[NSDictionary dictionaryWithObjectsAndKeys:@"SetProperties",@"__operation",userDict,@"User",[dict objectForKey:@"expenseSheetTitle"],@"Description",nil];
	
	unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
	NSDate *date = [dict objectForKey:@"dateCreated"];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *comps = [calendar components:reqFields fromDate:date];
	
	
	NSInteger year = [comps year];
	NSInteger month = [comps month];
	NSInteger day = [comps day];
	//int hour = [comps hour];
	//		int minute = [comps minute];
	//        int second = [comps second];
	
	
	
	
	NSMutableDictionary *entryDateDict;
	entryDateDict=[NSMutableDictionary dictionary];
	[entryDateDict setObject:[NSString stringWithFormat:@"%ld",(long)year] forKey:@"Year"];
	[entryDateDict setObject:[NSString stringWithFormat:@"%ld",(long)month] forKey:@"Month"];
	[entryDateDict setObject:[NSString stringWithFormat:@"%ld",(long)day] forKey:@"Day"];
	[entryDateDict setObject:@"Date" forKey:@"__type"];
	
	NSMutableDictionary *projectDict;
	projectDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Replicon.Project.Domain.Project",@"__type",
				 [dict objectForKey:@"projectId"],@"Identity",nil];
	
	NSDictionary *currencyDict;
	currencyDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Domain.Currency",@"__type",[dict objectForKey:@"currencyId"],@"Identity",nil];
	
	NSDictionary *expDict;
	expDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Expense.Domain.ExpenseType",@"__type",[dict objectForKey:@"expenseTypeId"],@"Identity",nil];
	
	
	
	[subOperationsDict  setObject:@"SetProperties" forKey:@"__operation"];
	[subOperationsDict setObject:projectDict forKey:@"Project"];
	[subOperationsDict setObject:currencyDict forKey:@"Currency"];
	[subOperationsDict setObject:expDict forKey:@"ExpenseType"];
	[subOperationsDict setObject:entryDateDict forKey:@"EntryDate"];
	
	NSMutableArray *operarionArray;
	operarionArray=[NSMutableArray array];
	[operarionArray addObject:subOperationsDict];
	[operarionArray addObject:recieptDict];
	
	NSDictionary *secondDictAllDetails;
	secondDictAllDetails=[NSDictionary dictionaryWithObjectsAndKeys:@"CollectionAdd",@"__operation",@"Entries",@"Collection",
						  operarionArray,@"Operations",nil];
	
	
	NSMutableArray *firstOperArray;
	firstOperArray=[NSMutableArray array];
	[firstOperArray addObject:firstOperDict];
	[firstOperArray addObject:secondDictAllDetails];
	
	
	NSDictionary *finalDetailsDict;
	finalDetailsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Edit",@"Action",@"Replicon.Expense.Domain.Expense",@"Type",[dict objectForKey:@"expSheetId"],@"Identity",
					  firstOperArray,@"Operations",nil];
	
	NSArray *detailsArray;
	detailsArray=[NSArray arrayWithObjects:finalDetailsDict,nil];
	
	
	//  DLog(@"detailedarr %@",detailsArray);
	NSString *queryString=	[JsonWrapper writeJson:detailsArray error:nil];
#ifdef DEV_DEBUG
	//DLog(@"jsonQuery %@",queryString);
#endif
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:queryString forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"SaveExpenseEntryWithReceipt"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
	
	
}


-(void)sendRequestToDeleteExpenseSheetWithIdentity:(NSString*)sheetID WithDelegate:(id)delegate{
	
	/*{
	 "Action": "Delete",
	 "Type": "Replicon.Expense.Domain.Expense",
	 "Identity": "7"
	 }*/
	NSDictionary *deleteDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Delete",@"Action",
							  @"Replicon.Expense.Domain.Expense",@"Type",
							  sheetID,@"Identity",nil];
	
	NSString *queryString=	[JsonWrapper writeJson:deleteDict error:nil];
#ifdef DEV_DEBUG
	//DLog(@"jsonQuery %@",queryString);
#endif
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:queryString forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"DeleteExpenseSheet"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
	
}

-(void)sendRequestForMergedExpenseAPIWithDelegate:(id)delegate
{
    BOOL expenseDataCanRun = [G2Util shallExecuteQuery:EXPENSES_DATA_SERVICE_SECTION];
    BOOL expenseSupportDataCanRun = [G2Util shallExecuteQuery:EXPENSES_SUPPORT_DATA_SECTION];
    NSMutableArray *mergedRequestArr=[NSMutableArray array];
    NSMutableArray *userExpenseSheets = [expensesModel getExpenseSheetsFromDataBase];
    
    
    if (expenseDataCanRun|| [userExpenseSheets count] == 0)
    {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:EXPENSE_DATA_CAN_RUN];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSArray *enumArr = [NSArray arrayWithObjects:@"Approved",nil];
        NSDictionary *sortDict1=[NSDictionary dictionaryWithObjectsAndKeys:@"ApproveStatus",@"Property",
                                 enumArr,@"EnumOrder",
                                 [NSNumber numberWithBool:YES],@"Descending",nil];
        NSDictionary *sortDict2=[NSDictionary dictionaryWithObjectsAndKeys:@"TrackingNumber",@"Property",
                                 [NSNumber numberWithBool:YES],@"Descending",nil];
        
        
        NSMutableArray *sortArray=[NSMutableArray array];
        [sortArray addObject:sortDict1];
        [sortArray addObject:sortDict2];
        
        NSMutableArray *loadArray=[NSMutableArray array];
        NSMutableArray *inLoadArray=[NSMutableArray array];
        NSMutableDictionary *currencyDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Currency",@"Relationship",nil];
        NSMutableDictionary *expTypeDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"ExpenseType",@"Relationship",nil];
        
        NSMutableDictionary *load1Dict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil];
        NSMutableArray *load1Arr = [NSMutableArray array];
        
        [load1Arr addObject:load1Dict];
        
        NSMutableArray *load2Arr = [NSMutableArray array];
        NSMutableDictionary *load2Dict =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         @"ProjectClients",@"Relationship",
                                         load1Arr,@"Load",nil];
        [load2Arr addObject:load2Dict];
        
        NSMutableDictionary *projectDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          @"Project",@"Relationship",
                                          load2Arr,@"Load",nil];
        
        //NSMutableDictionary *receiptDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"ExpenseReceipt",@"Relationship",nil];
        NSMutableDictionary *receiptFlagDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"ExpenseReceipt",@"CountOf",nil];
        NSMutableDictionary *paymentMethodDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"PaymentMethod",@"Relationship",nil];
        
        NSMutableDictionary *taxCode1Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode1",@"Relationship",nil];
        NSMutableDictionary *taxCode2Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode2",@"Relationship",nil];
        NSMutableDictionary *taxCode3Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode3",@"Relationship",nil];
        NSMutableDictionary *taxCode4Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode4",@"Relationship",nil];
        NSMutableDictionary *taxCode5Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode5",@"Relationship",nil];
        
        //[inLoadArray addObject:load1Dict];
        [inLoadArray addObject:currencyDict];
        [inLoadArray addObject:expTypeDict];
        [inLoadArray addObject:projectDict];
        //[inLoadArray addObject:receiptDict];
        [inLoadArray addObject:receiptFlagDict];
        [inLoadArray addObject:paymentMethodDict];
        
        //ADDED TAXCODES TO QUERY
        [inLoadArray addObject:taxCode1Dict];
        [inLoadArray addObject:taxCode2Dict];
        [inLoadArray addObject:taxCode3Dict];
        [inLoadArray addObject:taxCode4Dict];
        [inLoadArray addObject:taxCode5Dict];
        
        NSMutableArray *argArray=[NSMutableArray array];
        
        NSString *_userId = [[NSUserDefaults standardUserDefaults]objectForKey: @"UserID"];
        if(_userId == nil || [_userId isEqualToString: @""])
        {
            //DLog(@"Error: Fetching expense sheets: UserId is null");
            //return;
        }
        NSDictionary *argDict=[NSDictionary dictionaryWithObjectsAndKeys: @"Replicon.Domain.User", @"__type",
                               [[NSUserDefaults standardUserDefaults]objectForKey: @"UserID"], @"Identity", nil];
        
        [argArray addObject: argDict];
        
        
        NSMutableDictionary *inLoadDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Entries",@"Relationship",inLoadArray,@"Load",nil];
        NSDictionary *reimbursementCurrencydict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   @"ReimbursementCurrency",@"Relationship",
                                                   nil];
        NSDictionary *remainingApproversDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                @"RemainingApprovers",@"Relationship",
                                                nil];
        NSDictionary *approvalActionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Type",@"Relationship",nil];
        NSArray *approvalLoadArray = [NSArray arrayWithObjects:approvalActionDict,nil];
        NSDictionary *filteredHistoryDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @"FilteredHistory",@"Relationship",
                                             approvalLoadArray,@"Load",
                                             nil];
        [loadArray addObject:filteredHistoryDict];
        
        [loadArray addObject:remainingApproversDict];
        [loadArray addObject:reimbursementCurrencydict];
        [loadArray addObject:filteredHistoryDict];
        [loadArray addObject:inLoadDict];
        
        NSMutableDictionary *dictExp=[NSMutableDictionary dictionaryWithObjectsAndKeys: @"Query", @"Action",
                                      @"ExpenseByUser", @"QueryType",
                                      @"Replicon.Expense.Domain.Expense", @"DomainType",
                                      argArray, @"Args",
                                      // [NSNumber numberWithInt: 0], @"StartIndex",
                                      [NSNumber numberWithInt:0], @"StartIndex",
                                      [[G2AppProperties getInstance]getAppPropertyFor:@"MostRecentExpenseSheetsCount"], @"Count",
                                      loadArray, @"Load",
                                      sortArray, @"SortBy", nil];
        
        
        [mergedRequestArr addObject:dictExp];

    }
    
    else if (!expenseDataCanRun && [userExpenseSheets count]>0)
    {
		id lastSuccefullDataDownloadedTime = [G2SupportDataModel getLastSyncDateForServiceId:EXPENSES_DATA_SERVICE_SECTION];
		NSDate*updatedDate = [NSDate dateWithTimeIntervalSince1970:[lastSuccefullDataDownloadedTime longValue]];
        NSMutableArray *loadArray=[NSMutableArray array];
        NSMutableArray *inLoadArray=[NSMutableArray array];
        NSMutableDictionary *currencyDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Currency",@"Relationship",nil];
        NSMutableDictionary *expTypeDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"ExpenseType",@"Relationship",nil];
        
        NSMutableDictionary *load1Dict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil];
        NSMutableArray *load1Arr = [NSMutableArray array];
        
        [load1Arr addObject:load1Dict];
        
        NSMutableArray *load2Arr = [NSMutableArray array];
        NSMutableDictionary *load2Dict =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         @"ProjectClients",@"Relationship",
                                         load1Arr,@"Load",nil];
        [load2Arr addObject:load2Dict];
        
        NSMutableDictionary *projectDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          @"Project",@"Relationship",
                                          load2Arr,@"Load",nil];
        
        NSMutableDictionary *receiptFlagDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"ExpenseReceipt",@"CountOf",nil];
        NSMutableDictionary *paymentMethodDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"PaymentMethod",@"Relationship",nil];
        
        NSMutableDictionary *taxCode1Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode1",@"Relationship",nil];
        NSMutableDictionary *taxCode2Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode2",@"Relationship",nil];
        NSMutableDictionary *taxCode3Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode3",@"Relationship",nil];
        NSMutableDictionary *taxCode4Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode4",@"Relationship",nil];
        NSMutableDictionary *taxCode5Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode5",@"Relationship",nil];
        
        [inLoadArray addObject:currencyDict];
        [inLoadArray addObject:expTypeDict];
        [inLoadArray addObject:projectDict];
        [inLoadArray addObject:receiptFlagDict];
        [inLoadArray addObject:paymentMethodDict];
        
        //ADDED TAXCODES TO QUERY
        [inLoadArray addObject:taxCode1Dict];
        [inLoadArray addObject:taxCode2Dict];
        [inLoadArray addObject:taxCode3Dict];
        [inLoadArray addObject:taxCode4Dict];
        [inLoadArray addObject:taxCode5Dict];
        
        NSMutableDictionary *inLoadDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Entries",@"Relationship",inLoadArray,@"Load",nil];
        NSDictionary *reimbursementCurrencydict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   @"ReimbursementCurrency",@"Relationship",
                                                   nil];
        NSDictionary *remainingApproversDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                @"RemainingApprovers",@"Relationship",
                                                nil];
        NSDictionary *approvalActionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Type",@"Relationship",nil];
        NSArray *approvalLoadArray = [NSArray arrayWithObjects:approvalActionDict,nil];
        NSDictionary *filteredHistoryDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @"FilteredHistory",@"Relationship",
                                             approvalLoadArray,@"Load",
                                             nil];
        [loadArray addObject:filteredHistoryDict];
        [loadArray addObject:reimbursementCurrencydict];
        [loadArray addObject:remainingApproversDict];
        [loadArray addObject:inLoadDict];
        
        NSMutableArray *argArray=[NSMutableArray array];
        
        NSDictionary *argDict=[NSDictionary dictionaryWithObjectsAndKeys: @"Replicon.Domain.User", @"__type",
                               [[NSUserDefaults standardUserDefaults]objectForKey: @"UserID"], @"Identity", nil];
        [argArray addObject: argDict];
        
        
        NSMutableDictionary * dateDetailsDict = [G2Util getDateDictionaryforTimeZoneWith:@"UTC" forDate:updatedDate];
        //DLog(@"Date details %@",dateDetailsDict);
        if (dateDetailsDict != nil) {
            [dateDetailsDict setObject:@"DateTime" forKey:@"__type"];
            [argArray addObject:dateDetailsDict];
        }
        
        
        NSMutableDictionary *dictExp=[NSMutableDictionary dictionaryWithObjectsAndKeys: @"Query", @"Action",
                                      @"ExpenseByUserModifiedSince", @"QueryType",
                                      @"Replicon.Expense.Domain.Expense", @"DomainType",
                                      argArray, @"Args",
                                      loadArray, @"Load", nil];

        
        [mergedRequestArr addObject:dictExp];
	}

    
    if (expenseSupportDataCanRun)
    {
        
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:EXPENSE_SUPPORT_DATA_CAN_RUN];
        [[NSUserDefaults standardUserDefaults] synchronize];

        
       // UDF REQUEST
        
        NSMutableArray *firstLoadArray1;
        firstLoadArray1=[NSMutableArray array];
        NSArray *insideArgumentsArray=[NSArray arrayWithObjects:@"ExpenseEntry",nil];
        
        NSMutableArray *secondLoadArray=[NSMutableArray array];
        NSMutableDictionary *udfFieldsDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"DropDownOptions",@"Relationship",nil];
        [secondLoadArray addObject:udfFieldsDict];
        
        NSMutableDictionary *firstLoadDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Fields",@"Relationship",secondLoadArray,@"Load",nil];
        [firstLoadArray1 addObject:firstLoadDict];
        NSMutableDictionary *dictUdf=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
                                      @"UdfGroupByName",@"QueryType",
                                      @"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup",@"DomainType",
                                      insideArgumentsArray,@"Args",
                                      firstLoadArray1,@"Load",nil];
        
        
       
        [mergedRequestArr addObject:dictUdf];
        
        //GET PAYMENT METHOD ALL
      
        NSArray *argsArray1 = [NSArray array];
        NSDictionary *paymentDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action"
                                     ,@"PaymentMethodAll",@"QueryType"
                                     ,@"Replicon.Expense.Domain.PaymentMethod",@"DomainType"
                                     ,argsArray1,@"Args"
                                     ,nil];
        
        
      
        
        
        [mergedRequestArr addObject:paymentDict];
        
        
        //GET SYSTEM CURRENCIES
      
        NSArray *argsArray2 = [NSArray array];
        NSDictionary *currencyDict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action"
                                      ,@"CurrencyAll",@"QueryType"
                                      ,@"Replicon.Domain.Currency",@"DomainType"
                                      ,argsArray2,@"Args"
                                      ,nil];
        
       
    
        [mergedRequestArr addObject:currencyDict2];
        

        //GET BASE CURRENCY
        
        NSArray *argsArray = [NSArray array];
        NSDictionary *baseCurrencyDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action"
                                          ,@"BaseCurrency",@"QueryType"
                                          ,@"Replicon.Domain.Currency",@"DomainType"
                                          ,argsArray,@"Args"
                                          ,nil];
        
       
        
         [mergedRequestArr addObject:baseCurrencyDict];
        
        
        //GET ALL TAX CODES
        
       
        NSArray *argsArray5 = [NSArray array];
        NSDictionary *taxDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action"
                                 ,@"TaxCodeAll",@"QueryType"
                                 ,@"Replicon.Expense.Domain.TaxCode",@"DomainType"
                                 ,argsArray5,@"Args"
                                 ,nil];
        
                
               
        [mergedRequestArr addObject:taxDict];
        
        
        //GET ALL EXPENSE CLIENTS
        
        NSArray *argsArray6 = [NSArray array];
        NSDictionary *mainDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action"
                                  ,@"ExpenseClients",@"QueryType"
                                  ,@"Replicon.Domain.Client",@"DomainType"
                                  ,argsArray6,@"Args"
                                  ,nil];
        
        
        [mergedRequestArr addObject:mainDict];
        
        //EXPENSE TYPE ALL
        
        NSMutableArray *firstLoadArray7=[NSMutableArray array];
        

            
            NSMutableArray *thirdLoadArray=[NSMutableArray array];//
            
            NSDictionary *currencyDict7=[NSDictionary dictionaryWithObjectsAndKeys:@"Currency",@"Relationship",nil];
            
            [thirdLoadArray addObject:currencyDict7];
            
            NSDictionary *entryInDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Entries",@"Relationship",thirdLoadArray,@"Load", nil];
            
            
            NSMutableArray *seconLoadArray=[NSMutableArray array];
            
            [seconLoadArray addObject:entryInDict];
            
            
            NSDictionary *tskDict=[NSDictionary dictionaryWithObjectsAndKeys:@"TskRate",@"Relationship",seconLoadArray,@"Load",nil];
            
            
            
            [firstLoadArray7 addObject:tskDict];
            
            //NSMutableArray *loadArray=[NSMutableArray array];
            
            NSDictionary *taxDict1=[NSDictionary dictionaryWithObjectsAndKeys:@"TaxCode1",@"Relationship",nil];
            
            NSDictionary *taxDict2=[NSDictionary dictionaryWithObjectsAndKeys:@"TaxCode2",@"Relationship",nil];
            
            NSDictionary *taxDict3=[NSDictionary dictionaryWithObjectsAndKeys:@"TaxCode3",@"Relationship",nil];
            
            NSDictionary *taxDict4=[NSDictionary dictionaryWithObjectsAndKeys:@"TaxCode4",@"Relationship",nil];
            
            NSDictionary *taxDict5=[NSDictionary dictionaryWithObjectsAndKeys:@"TaxCode5",@"Relationship",nil];
            
            [firstLoadArray7 addObject:taxDict1];
            
            [firstLoadArray7 addObject:taxDict2];
            
            [firstLoadArray7 addObject:taxDict3];
            
            [firstLoadArray7 addObject:taxDict4];
            
            [firstLoadArray7 addObject:taxDict5];
        
 
        
        
        
        NSDictionary *queryDict=nil;

            
            
        queryDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
                         
                         @"ExpenseTypeAll",@"QueryType",firstLoadArray7,@"Load" 
                         
                         ,@"Replicon.Expense.Domain.ExpenseType",@"DomainType" 
                         
                         ,argsArray,@"Args"
                         
                         ,nil];
        
        
        
       
        
       
        
        [mergedRequestArr addObject:queryDict];
    }
    
    
    NSError *err = nil;
    
    NSString *str = [JsonWrapper writeJson:mergedRequestArr error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"MergedExpensesAPI"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
    
    [userExpenseSheets removeAllObjects];
    
    [[G2RepliconServiceManager expensesService] addObserverForExpensesAction];
}

#pragma mark ExpenseSheetRelatedRequests

-(void)sendRequestToGetModifiedExpenseSheetsFromDate:(NSDate*)lastUpdatedDate withDelegate:(id)delegate
{
	/*[
	 {
	 "Action": "Query",
	 "QueryType": "ExpenseByUserModifiedSince",
	 "DomainType": "Replicon.Expense.Domain.Expense",
	 "Args": [
	 {
	 "__type": "Replicon.Domain.User",
	 "Identity": "81"
	 },
	 {
	 "__type": "DateTime",
	 "Year": 2010,
	 "Month": 10,
	 "Day": 1,
	 "Hour": 10,
	 "Minute": 0,
	 "Second": 0
	 }
	 ],
	 "Load": [
	 {
	 "Relationship": "ReimbursementCurrency"
	 },
	 {
	 "Relationship": "Entries",
	 "Load": [
	 {
	 "Relationship": "Currency"
	 },
	 {
	 "Relationship": "ExpenseType"
	 },
	 {
	 "Relationship": "Project",
	 "Load": [
	 {
	 "Relationship": "ProjectClients",
	 "Load": [
	 {
	 "Relationship": "Client"
	 }
	 ]
	 }
	 ]
	 },
	 {
	 "CountOf": "ExpenseReceipt"
	 },
	 {
	 "Relationship": "PaymentMethod"
	 },
	 {
	 "Relationship": "TaxCode1"
	 },
	 {
	 "Relationship": "TaxCode2"
	 },
	 {
	 "Relationship": "TaxCode3"
	 },
	 {
	 "Relationship": "TaxCode4"
	 },
	 {
	 "Relationship": "TaxCode5"
	 }
	 ]
	 }
	 ]
	 }
	 ]*/
	
	
	NSMutableArray *loadArray=[NSMutableArray array];
	NSMutableArray *inLoadArray=[NSMutableArray array];
	NSMutableDictionary *currencyDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Currency",@"Relationship",nil];
	NSMutableDictionary *expTypeDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"ExpenseType",@"Relationship",nil];
	
	NSMutableDictionary *load1Dict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil]; 
	NSMutableArray *load1Arr = [NSMutableArray array];
	
	[load1Arr addObject:load1Dict];
	
	NSMutableArray *load2Arr = [NSMutableArray array];
	NSMutableDictionary *load2Dict =[NSMutableDictionary dictionaryWithObjectsAndKeys:
									 @"ProjectClients",@"Relationship",
									 load1Arr,@"Load",nil];
	[load2Arr addObject:load2Dict];
	
	NSMutableDictionary *projectDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
									  @"Project",@"Relationship",
									  load2Arr,@"Load",nil];
	
	NSMutableDictionary *receiptFlagDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"ExpenseReceipt",@"CountOf",nil];
	NSMutableDictionary *paymentMethodDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"PaymentMethod",@"Relationship",nil];
	
	NSMutableDictionary *taxCode1Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode1",@"Relationship",nil];
	NSMutableDictionary *taxCode2Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode2",@"Relationship",nil];
	NSMutableDictionary *taxCode3Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode3",@"Relationship",nil];
	NSMutableDictionary *taxCode4Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode4",@"Relationship",nil];
	NSMutableDictionary *taxCode5Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode5",@"Relationship",nil];
	
	[inLoadArray addObject:currencyDict];
	[inLoadArray addObject:expTypeDict];
	[inLoadArray addObject:projectDict];
	[inLoadArray addObject:receiptFlagDict];
	[inLoadArray addObject:paymentMethodDict];
	
	//ADDED TAXCODES TO QUERY
	[inLoadArray addObject:taxCode1Dict];
	[inLoadArray addObject:taxCode2Dict];
	[inLoadArray addObject:taxCode3Dict];
	[inLoadArray addObject:taxCode4Dict];
	[inLoadArray addObject:taxCode5Dict];
	
	NSMutableDictionary *inLoadDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Entries",@"Relationship",inLoadArray,@"Load",nil];	 
	NSDictionary *reimbursementCurrencydict = [NSDictionary dictionaryWithObjectsAndKeys:
											   @"ReimbursementCurrency",@"Relationship",
											   nil];
	NSDictionary *remainingApproversDict = [NSDictionary dictionaryWithObjectsAndKeys:
											   @"RemainingApprovers",@"Relationship",
											   nil];
	NSDictionary *approvalActionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Type",@"Relationship",nil];
	NSArray *approvalLoadArray = [NSArray arrayWithObjects:approvalActionDict,nil];
	NSDictionary *filteredHistoryDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"FilteredHistory",@"Relationship",
										 approvalLoadArray,@"Load",
										 nil];
	[loadArray addObject:filteredHistoryDict];
	[loadArray addObject:reimbursementCurrencydict];
	[loadArray addObject:remainingApproversDict];
	[loadArray addObject:inLoadDict];
	
	NSMutableArray *argArray=[NSMutableArray array];

	NSDictionary *argDict=[NSDictionary dictionaryWithObjectsAndKeys: @"Replicon.Domain.User", @"__type",
	[[NSUserDefaults standardUserDefaults]objectForKey: @"UserID"], @"Identity", nil];
	[argArray addObject: argDict];

	
	NSMutableDictionary * dateDetailsDict = [G2Util getDateDictionaryforTimeZoneWith:@"UTC" forDate:lastUpdatedDate];
	//DLog(@"Date details %@",dateDetailsDict);
	if (dateDetailsDict != nil) {
		[dateDetailsDict setObject:@"DateTime" forKey:@"__type"];
		[argArray addObject:dateDetailsDict];
	}
	
	
	NSMutableDictionary *dictExp=[NSMutableDictionary dictionaryWithObjectsAndKeys: @"Query", @"Action",
								  @"ExpenseByUserModifiedSince", @"QueryType",
								  @"Replicon.Expense.Domain.Expense", @"DomainType",
								  argArray, @"Args",
								  loadArray, @"Load", nil];
	NSMutableArray *queryArray=[NSMutableArray array];
	[queryArray addObject:dictExp];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryArray error:&err];
	DLog(@"GET MODIFIED SHEETS OF USER QUERY %@",str);
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ExpenseSheetsModifiedFromLastUpdatedTime"]];
	[self setServiceDelegate:delegate];
	[self executeRequest];
}

-(void)sendRequestToGetMostRecentExpenseSheets:(NSNumber*)limitedCount :(NSNumber*)startIndex WithDelegate:(id)delegate{
	
	//TODO: Add Project
	
	
	
	//FetchMostRecentExpenseSheets
	/*{
	 "Action": "Query",
	 "QueryType": "ExpenseByUser",
	 "DomainType": "Replicon.Expense.Domain.Expense",
	 "StartIndex": 0,
	 "Count": 5,
	 "Args": [
	 {
	 "Identity": "2",
	 "__type": "Replicon.Domain.User"
	 }
	 ],
	 "Load": [
	 {
	 "Relationship": "Entries",
	 "Load": [
	 {
	 "Relationship": "Currency"
	 },
	 {
	 "Relationship": "ExpenseType"
	 },
	 {
	 "Relationship": "Project"
	 },
	 {
	 "Relationship": "PaymentMethod"
	 }
	 ]
	 }
	 ],
	 
	 "SortBy": [
	 {
	 "Property": "ApproveStatus",
	 "EnumOrder": [
	 "Approved"
	 ],
	 "Descending": true
	 },
	 {
	 "Property": "TrackingNumber",
	 "Descending": true
	 }
	 ]
	 }	*/
	
	//id isManualSync = [[NSUserDefaults standardUserDefaults] objectForKey: @"isManualSync"];
	//serviceID = [ServiceUtil getServiceIDForServiceName:@"ExpenseByUser"];
	//if (isManualSync != nil && ![isManualSync boolValue] && ![Util shallExecuteQuery: EXPENSES_DATA_SERVICE_SECTION]) {
	//	return;
	//}
	
	NSArray *enumArr = [NSArray arrayWithObjects:@"Approved",nil];
	NSDictionary *sortDict1=[NSDictionary dictionaryWithObjectsAndKeys:@"ApproveStatus",@"Property",
				             enumArr,@"EnumOrder",		  
							 [NSNumber numberWithBool:YES],@"Descending",nil]; 
	NSDictionary *sortDict2=[NSDictionary dictionaryWithObjectsAndKeys:@"TrackingNumber",@"Property",
							 [NSNumber numberWithBool:YES],@"Descending",nil]; 
	
	
	NSMutableArray *sortArray=[NSMutableArray array];
	[sortArray addObject:sortDict1];
	[sortArray addObject:sortDict2];
	
	NSMutableArray *loadArray=[NSMutableArray array];
	NSMutableArray *inLoadArray=[NSMutableArray array];
	NSMutableDictionary *currencyDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Currency",@"Relationship",nil];
	NSMutableDictionary *expTypeDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"ExpenseType",@"Relationship",nil];
	
	NSMutableDictionary *load1Dict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Client",@"Relationship",nil]; 
	NSMutableArray *load1Arr = [NSMutableArray array];
	
	[load1Arr addObject:load1Dict];
	
	NSMutableArray *load2Arr = [NSMutableArray array];
	NSMutableDictionary *load2Dict =[NSMutableDictionary dictionaryWithObjectsAndKeys:
									 @"ProjectClients",@"Relationship",
									 load1Arr,@"Load",nil];
	[load2Arr addObject:load2Dict];
	
	NSMutableDictionary *projectDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
									  @"Project",@"Relationship",
									  load2Arr,@"Load",nil];
	
	//NSMutableDictionary *receiptDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"ExpenseReceipt",@"Relationship",nil];
	NSMutableDictionary *receiptFlagDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"ExpenseReceipt",@"CountOf",nil];
	NSMutableDictionary *paymentMethodDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"PaymentMethod",@"Relationship",nil];
	
	NSMutableDictionary *taxCode1Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode1",@"Relationship",nil];
	NSMutableDictionary *taxCode2Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode2",@"Relationship",nil];
	NSMutableDictionary *taxCode3Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode3",@"Relationship",nil];
	NSMutableDictionary *taxCode4Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode4",@"Relationship",nil];
	NSMutableDictionary *taxCode5Dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"TaxCode5",@"Relationship",nil];
	
	//[inLoadArray addObject:load1Dict];
	[inLoadArray addObject:currencyDict];
	[inLoadArray addObject:expTypeDict];
	[inLoadArray addObject:projectDict];
	//[inLoadArray addObject:receiptDict];
	[inLoadArray addObject:receiptFlagDict];
	[inLoadArray addObject:paymentMethodDict];
	
	//ADDED TAXCODES TO QUERY
	[inLoadArray addObject:taxCode1Dict];
	[inLoadArray addObject:taxCode2Dict];
	[inLoadArray addObject:taxCode3Dict];
	[inLoadArray addObject:taxCode4Dict];
	[inLoadArray addObject:taxCode5Dict];
	
	NSMutableArray *argArray=[NSMutableArray array];
	
	NSString *_userId = [[NSUserDefaults standardUserDefaults]objectForKey: @"UserID"];
	if(_userId == nil || [_userId isEqualToString: @""])
	{
		//DLog(@"Error: Fetching expense sheets: UserId is null");
		//return;
	}
	NSDictionary *argDict=[NSDictionary dictionaryWithObjectsAndKeys: @"Replicon.Domain.User", @"__type",
						   [[NSUserDefaults standardUserDefaults]objectForKey: @"UserID"], @"Identity", nil];
	
	[argArray addObject: argDict];
	
	
	NSMutableDictionary *inLoadDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Entries",@"Relationship",inLoadArray,@"Load",nil];	 
	NSDictionary *reimbursementCurrencydict = [NSDictionary dictionaryWithObjectsAndKeys:
											   @"ReimbursementCurrency",@"Relationship",
											   nil];
	NSDictionary *remainingApproversDict = [NSDictionary dictionaryWithObjectsAndKeys:
											   @"RemainingApprovers",@"Relationship",
											   nil];
	NSDictionary *approvalActionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Type",@"Relationship",nil];
	NSArray *approvalLoadArray = [NSArray arrayWithObjects:approvalActionDict,nil];
	NSDictionary *filteredHistoryDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"FilteredHistory",@"Relationship",
										 approvalLoadArray,@"Load",
										 nil];
	[loadArray addObject:filteredHistoryDict];
	
	[loadArray addObject:remainingApproversDict];
	[loadArray addObject:reimbursementCurrencydict];
	[loadArray addObject:filteredHistoryDict];
	[loadArray addObject:inLoadDict];
	
	NSMutableDictionary *dictExp=[NSMutableDictionary dictionaryWithObjectsAndKeys: @"Query", @"Action",
								  @"ExpenseByUser", @"QueryType",
								  @"Replicon.Expense.Domain.Expense", @"DomainType",
								  argArray, @"Args",
								 // [NSNumber numberWithInt: 0], @"StartIndex",
								 startIndex, @"StartIndex",
								  limitedCount, @"Count",
								  loadArray, @"Load",
								  sortArray, @"SortBy", nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:dictExp error:&err];
	
	DLog(@"*****sendRequestToGetMostRecentExpenseSheets****** %@",str);
	NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
	
	NSString *_serviceURL = [[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"];
	if(_serviceURL == nil || [_serviceURL isEqualToString: @""])
	{
		//DLog(@"Error: Fetching the expenses: serviceURL is null");
	}
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	
	NSMutableDictionary *refDict1 =[[NSMutableDictionary alloc] initWithObjectsAndKeys:limitedCount,@"limitedCount",
									@"MostRecentExpenseSheets",@"refrenceName",
									nil]; 
	[self setRequest: [G2RequestBuilder buildPOSTRequestWithParamDict: paramDict]];
	[self setServiceID: [G2ServiceUtil getServiceIDForServiceName: @"ExpenseByUser"]];
	if ([startIndex intValue] > 0) 
	{
		[self setServiceID: [G2ServiceUtil getServiceIDForServiceName: @"FetchNextRecentExpenseSheets"]];
	}
	[self setServiceDelegate: delegate];
	[self executeRequest: refDict1];
	
}

-(void)sendRequestForExistedSheets:(id)delegate
{
	/*{
	 "Action": "Exists",
	 "Type": "Replicon.Domain.Expense",
	 "Identities": [ "1", "2", "3" ]
	 }*/
	
	G2ExpensesModel *expModel = [[G2ExpensesModel alloc] init];
	NSMutableArray *identitiesArray = [expModel getAllSheetIdentitiesFromDB];
	
	NSMutableDictionary *queryDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Exists",@"Action",
									  @"Replicon.Expense.Domain.Expense",@"Type",identitiesArray,@"Identities",nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	[self setRequest: [G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID: [G2ServiceUtil getServiceIDForServiceName: @"ExpenseSheetsExisted"]];
	[self setServiceDelegate: delegate];
	[self executeRequest];
	
}



-(void)sendRequestTogetExpenseSheetInfo:(NSString *)sheetIdentity :(id)delegate {
	/*
	 {
	 "Action": "Query",
	 "QueryType": "ExpenseById",
	 "DomainType": "Replicon.Expense.Domain.Expense",
	 "Args": [
	 [
	 "2",
	 "3"
	 ]
	 ]
	 }
	 */
	NSArray *innerArgsArray = [NSArray arrayWithObject:sheetIdentity];
	NSArray *argArray = [NSArray arrayWithObject:innerArgsArray];
	NSMutableDictionary *dictExp=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
								  @"ExpenseById",@"QueryType",
								  @"Replicon.Expense.Domain.Expense",@"DomainType",
								  argArray,@"Args",
								  nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:dictExp error:&err];
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	[self setRequest: [G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID: [G2ServiceUtil getServiceIDForServiceName: @"ExpenseById"]];
	[self setServiceDelegate: delegate];
	[self executeRequest];
}


-(void)sendRequestToFetchNextRecentExpenseSheets:(NSString *)handleIdentity withStartIndex:(NSNumber*)_startIndex withLimitCount:(NSNumber*)limitedCount withDelegate:(id)delegate{
	/*{
	 "Action": "Query",
	 "QueryHandle": "8EA58ED9-3E01-4cf1-A98D-A21BB36AAB3C",
	 "StartIndex": 5,
	 "Count": 5,
	 }*/
	if(handleIdentity == nil || [handleIdentity isEqualToString: @""])
	{
		//DLog(@"Error: handleIdentity is null");
		return;
	}
	
	NSDictionary *recentExpSheetsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Query",@"Action",
									   handleIdentity,@"QueryHandle",
									   _startIndex,@"StartIndex",
									   limitedCount,@"Count",nil];
	
	NSString *queryString=	[JsonWrapper writeJson:recentExpSheetsDict error:nil];
#ifdef DEV_DEBUG
	//DLog(@"jsonQuery %@",queryString);
#endif
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:queryString forKey:@"PayLoadStr"];
	
	
	NSMutableDictionary *refDict1 =[NSMutableDictionary dictionaryWithObjectsAndKeys:limitedCount,@"limitedCount",
									@"NextRecentExpenseSheets",@"refrenceName",
									nil]; 
	[self setRequest: [G2RequestBuilder buildPOSTRequestWithParamDict: paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"FetchNextRecentExpenseSheets"]];
	[self setServiceDelegate: delegate];
	[self executeRequest: refDict1];
}

-(void)sendRequestToDeleteExpenseReceiptForExpenseSheetID:(NSString*)sheetId forEntryId:(NSString*)entryId
{	
	/*
	 [
	 {
	 "Action": "Edit",
	 "Type": "Replicon.Expense.Domain.Expense",
	 "Identity": "1",
	 "Operations": [
	 {
	 "__operation": "SetProperties",
	 "User": {
	 "__type": "Replicon.Domain.User",
	 "Identity": "2"
	 }
	 },
	 {
	 "__operation": "CollectionEdit",
	 "Collection": "Entries",
	 "Identity": "1",
	 "Operations": [
	 {
	 "__operation": "CollectionClear",
	 "Collection": "ExpenseReceipt"
	 }
	 ]
	 }
	 ]
	 }
	 ]*/
	
	NSDictionary *collectionDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"CollectionClear",@"__operation",@"ExpenseReceipt",@"Collection",nil];
	NSMutableArray *lastOperationArray=[NSMutableArray array];
	[lastOperationArray addObject:collectionDict];
	
	NSMutableDictionary *collectionEditDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:lastOperationArray,@"Operations",entryId,@"Identity",@"Entries",@"Collection",
											 @"CollectionEdit",@"__operation",nil];
	
	NSDictionary *userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"],@"Identity",@"Replicon.Domain.User",@"__type",nil];
	NSDictionary *propertiesDict=[NSDictionary dictionaryWithObjectsAndKeys:userDict,@"User",@"SetProperties",@"__operation",nil];
	NSMutableArray *mainOperationArray=[NSMutableArray array];
	[mainOperationArray addObject:propertiesDict];
	[mainOperationArray addObject:collectionEditDict];
	
	NSDictionary *firstEditDict=[NSDictionary dictionaryWithObjectsAndKeys:mainOperationArray,@"Operations",sheetId,@"Identity",@"Replicon.Expense.Domain.Expense",@"Type",
								 @"Edit",@"Action",nil];
	NSMutableArray *queryArray=[NSMutableArray array];
	[queryArray addObject:firstEditDict];
	
}

-(void)sendRequestToCreateNewExpenseSheet:(NSDictionary *)expenseDict delegate:(id)_delegate{
	
	NSDictionary * expenseDateDict = [NSDictionary dictionaryWithObjectsAndKeys:
									  @"Date",@"Type",
									  [expenseDict objectForKey:@"YEAR"],@"Year",
									  [expenseDict objectForKey:@"MONTH"],@"Month",		// [[NSNumber numberWithInt:[Util getMonthValueInInt:month]]stringValue]
									  [expenseDict objectForKey:@"DAY"],@"Day",nil];
	
	
	NSDictionary * userDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Domain.User",@"__type",
							   [[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"],@"Identity",nil];
	
	NSDictionary *reimburseCurrencyDict = [NSDictionary dictionaryWithObjectsAndKeys:
										   @"Replicon.Domain.Currency",@"Type",
										   [expenseDict objectForKey:@"identity"],@"Identity",nil];
	
	
	NSMutableDictionary *inOperationsDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"SetProperties",@"__operation",
										   userDict,@"User",
										   [expenseDict objectForKey:@"description"],@"Description",
										   expenseDateDict,@"ExpenseDate",
										   reimburseCurrencyDict,@"ReimbursementCurrency",
										   nil];
	

	
	
	
	NSMutableDictionary *reqDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Create",@"Action",
									@"Replicon.Expense.Domain.Expense",@"Type",
									[NSMutableArray arrayWithObject:inOperationsDict],@"Operations",nil];
	
	NSMutableArray * reqArr = [NSMutableArray array];
	[reqArr addObject:reqDict];
	
#ifdef DEV_DEBUG
	//DLog(@"inOperationsDictinOperationsDictinOperationsDict::::::%@",inOperationsDict);
#endif
	
	NSError *err = nil;
	NSString *queryString = [JsonWrapper writeJson:reqArr error:&err];
#ifdef DEV_DEBUG
	//DLog(@"jsonQuery %@",queryString);
#endif
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:queryString forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"SaveExpenseSheet"]];
	[self setServiceDelegate:_delegate];
	[self executeRequest];
	
}

-(void)sendRequestToAddNewExpenseWithUserEnteredData:(NSDictionary*)expenseDict withDelegate:(id)_delegate
{
	
	NSMutableDictionary *subOperationsDict;
	subOperationsDict=[NSMutableDictionary dictionary];
	if ([expenseDict objectForKey:@"Description"]!=nil) 
		[subOperationsDict setObject:[expenseDict objectForKey:@"Description"] forKey:@"Description"];
	
	for (int x=1; x<6; x++) {
		if([expenseDict objectForKey:[NSString stringWithFormat:@"taxAmount%d",x]]!=nil){
			[subOperationsDict setObject:[NSNumber numberWithDouble:[G2Util getValueFromFormattedDoubleWithDecimalPlaces:[expenseDict objectForKey:[NSString stringWithFormat:@"taxAmount%d",x]]]]
								  forKey:[NSString stringWithFormat:@"TaxAmount%d",x]];
		}
		
	}
	
	
	
	NSDictionary *userDict;
	userDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Domain.User",@"__type",[[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"],@"Identity",nil];
	
	NSDictionary *firstOperDict;
	firstOperDict=[NSDictionary dictionaryWithObjectsAndKeys:@"SetProperties",@"__operation",userDict,@"User",nil];
	
	
	//int hour = [comps hour];
	//		int minute = [comps minute];
	//        int second = [comps second];
	
	NSDictionary *imageDict=nil;
	if ([expenseDict objectForKey:@"base64ImageString"]!=nil) 
		imageDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Image",@"_type",[expenseDict objectForKey:@"base64ImageString"],@"Value",nil];
	
	NSMutableDictionary *recieptDict=nil;
	if (imageDict!=nil) {
		recieptDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"SetExpenseReceipt",@"__operation",imageDict,@"Image",
					 @"image/jpeg",@"ContentType",@"receipt.jpg",@"FileName",nil];
	}
	
	NSDate *entryDate=nil;
	if ([expenseDict objectForKey:RPLocalizedString(@"Date", @"") ]!=nil) 
		entryDate = [G2Util convertStringToDate1:[expenseDict objectForKey:RPLocalizedString(@"Date", @"")]];
	
	unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
	//NSDate *date = [entryDict objectForKey:@"Date"];
	//NSCalendar *calendar = [NSCalendar currentCalendar];//DE3171
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; //DE3171  
	NSDateComponents *comps=nil;
	NSMutableDictionary *entryDateDict=nil;
	if (entryDate!=nil) 
		comps = [calendar components:reqFields fromDate:entryDate];
	
	if (comps!=nil) {
		NSInteger year = [comps year];
		NSInteger month = [comps month];
		NSInteger day = [comps day];
		//int hour = [comps hour];
		//  int minute = [comps minute];
		//        int second = [comps second];
		
		
		entryDateDict=[NSMutableDictionary dictionary];
		[entryDateDict setObject:[NSString stringWithFormat:@"%ld",(long)year] forKey:@"Year"];
		[entryDateDict setObject:[NSString stringWithFormat:@"%ld",(long)month] forKey:@"Month"];
		[entryDateDict setObject:[NSString stringWithFormat:@"%ld",(long)day] forKey:@"Day"];
		[entryDateDict setObject:@"Date" forKey:@"__type"];
	}
	
	NSString *projectId=nil;
	if ( [expenseDict objectForKey:@"projectIdentity"]!=nil) 
		projectId = [expenseDict objectForKey:@"projectIdentity"];
	
	NSMutableDictionary *projectDict;
	if ([projectId isEqualToString:@"null"] || projectId==nil) {
		
	}else {
		projectDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Replicon.Project.Domain.Project",@"__type",projectId,@"Identity",nil];
		[subOperationsDict setObject:projectDict forKey:@"Project"];
		
		if (expensesModel==nil) {
			expensesModel=[[G2ExpensesModel alloc]init];
		}
		NSString *clientId = [expenseDict objectForKey:@"clientIdentity"];
		NSMutableArray *clientsArray=nil;
		if(projectId!=nil)
			clientsArray=[expensesModel getClientsForBucketProjects:projectId];
		
		NSString *allocationMethodId=nil;
		if (clientsArray!=nil && [clientsArray count]>=1) {
			allocationMethodId=[[clientsArray objectAtIndex:0] objectForKey:@"allocationMethodId"];
		}
		
		NSMutableDictionary *clientDict=nil;
		//Bucket Projects have multiple clients..........
		if (clientsArray!=nil && [clientsArray count]>=1) {
			if (allocationMethodId !=nil && ![allocationMethodId isKindOfClass:[NSNull class]] && [allocationMethodId isEqualToString:@"Bucket"]) {
				if ([clientId isEqualToString:@"null"]) {
				}else if (clientId!=nil) {
					clientDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Replicon.Project.Domain.Client",@"__type",clientId,@"Identity",nil];
					[subOperationsDict setObject:clientDict forKey:@"Client"];
				}
			}else {
				[subOperationsDict setObject:[NSNull null] forKey:@"Client"];
			}
			
		}else {
			[subOperationsDict setObject:[NSNull null] forKey:@"Client"];
		}
	}
	
	
	
	
	
	NSDictionary *currencyDict;
	NSString *currencyId=nil;
	
	if ([expenseDict objectForKey:@"currencyIdentity"]!=nil) 
		currencyId = [expenseDict objectForKey:@"currencyIdentity"];
	
	if (currencyId!=nil)
		currencyDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Domain.Currency",@"__type",currencyId,@"Identity",nil];
	
	NSString *typeIdentity=nil;
	if ([expenseDict objectForKey:@"typeIdentity"]!=nil) {
		typeIdentity=[expenseDict objectForKey:@"typeIdentity"];
	}
	
	NSDictionary *expDict;
	if (typeIdentity!=nil) 
		expDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Expense.Domain.ExpenseType",@"__type",typeIdentity,@"Identity",nil];
	
	
	if([expenseDict objectForKey:@"NumberOfUnits"]!=nil)
	{
		if ([expenseDict objectForKey:@"ExpenseRate"]!=nil){
			[subOperationsDict setObject:[expenseDict objectForKey:@"ExpenseRate"] forKey:@"ExpenseRate"];
		}
		if ([expenseDict objectForKey:@"NumberOfUnits"]!=nil) {
			[subOperationsDict setObject:[expenseDict objectForKey:@"NumberOfUnits"] forKey:@"NumberOfUnits"];
		}
		
	}else {
		if ([expenseDict objectForKey:@"NetAmount"]!=nil) 
			[subOperationsDict setObject:[expenseDict objectForKey:@"NetAmount"] forKey:@"NetAmount"];
	}
	
	
	NSMutableDictionary *udfsDict = nil;
	NSMutableArray *udfsArray = [expenseDict objectForKey:@"UserDefinedFields"];
	if(udfsArray != nil && [udfsArray count] > 0) {
		udfsDict = [NSMutableDictionary dictionary];
		NSUInteger i, count = [udfsArray count];
		for (i = 0; i < count; i++) {
			NSDictionary * udf = [udfsArray objectAtIndex:i];
			//[udfsDict setObject:[udf objectForKey:@"udfValue"] forKey:[udf objectForKey:@"udf_name"]];
			NSNumber *udfRequired = [udf objectForKey:@"required"];
			id udfValue = [udf objectForKey:@"udfValue"];
			if ([[udf objectForKey:@"udf_type"] isEqualToString:@"Date"] && ![[udf objectForKey:@"udfValue"] isEqualToString:RPLocalizedString(@"Select", @"") ]) {
				NSDate *udfDate = [G2Util convertStringToDate1:[udf objectForKey:@"udfValue"]];
				NSDateComponents *comps = [calendar components:reqFields fromDate:udfDate];
				NSDictionary *udfDateDict = [NSDictionary dictionaryWithObjectsAndKeys:
											 [NSNumber numberWithInteger:[comps year]],@"Year",
											 [NSNumber numberWithInteger:[comps month]],@"Month",
											 [NSNumber numberWithInteger:[comps day]],@"Day",
											 nil];
				[udfsDict setObject:udfDateDict forKey:[udf objectForKey:@"udf_name"]];
			}else if(![[udf objectForKey:@"udf_type"] isEqualToString:@"Date"]){
				if ([udfValue isKindOfClass:[NSString class]]) {
					if (([udfRequired intValue]== 0 || [udfRequired intValue] == 1)&&  [udfValue isEqualToString:RPLocalizedString(@"Select", @"")]) {
						continue;
					}
				}
				[udfsDict setObject:[udf objectForKey:@"udfValue"] forKey:[udf objectForKey:@"udf_name"]];
			}
			
			//}
		}
		[udfsDict setObject:@"SetUdfValues" forKey:@"__operation"];
		//[operarionArray addObject:udfsDict];
	}
#ifdef DEV_DEBUG
	//DLog(@"udfsDict ---------- %@------------ %@",udfsDict,udfsArray);
#endif	
	[subOperationsDict  setObject:@"SetProperties" forKey:@"__operation"];
	
	if (currencyDict!=nil) 
		[subOperationsDict setObject:currencyDict forKey:@"Currency"];
	
	if (expDict!=nil)
		[subOperationsDict setObject:expDict forKey:@"ExpenseType"];
	
	if (entryDateDict!=nil)
		[subOperationsDict setObject:entryDateDict forKey:@"EntryDate"];
	
	NSDictionary *paymentMethodDict=nil;
	NSString *paymentMethodId=nil;
	if ([expenseDict objectForKey:@"paymentMethodId"]!=nil) {
		paymentMethodId= [expenseDict objectForKey:@"paymentMethodId"];
	}
	
	if (paymentMethodId!=nil && ![paymentMethodId isEqualToString:@""] && ![paymentMethodId isKindOfClass:[NSNull class]]){
		paymentMethodDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Expense.Domain.PaymentMethod",@"__type",
						   paymentMethodId,@"Identity",nil];	
	}
	
	if (paymentMethodDict!=nil) 
		[subOperationsDict setObject:paymentMethodDict forKey:@"PaymentMethod"];	
	
	if ([expenseDict objectForKey:RPLocalizedString(@"BillClient", @"") ]!=nil) {
		if ([[expenseDict objectForKey:RPLocalizedString(@"BillClient", @"")] intValue] == 1) {
			[subOperationsDict setObject:@"true" forKey:@"BillToClient"];
		}else {
			[subOperationsDict setObject:@"false" forKey:@"BillToClient"];
		}
	}
	
	
	if ([expenseDict objectForKey:@"Reimburse"]!=nil) {
		if ([[expenseDict objectForKey:@"Reimburse"] intValue] == 1) {
			[subOperationsDict setObject:@"true" forKey:@"RequestReimbursement"];
		}else {
			[subOperationsDict setObject:@"false" forKey:@"RequestReimbursement"];
		}
	}
	
	
	NSMutableArray *operarionArray;
	operarionArray=[NSMutableArray array];
	
	if (subOperationsDict!=nil)
		[operarionArray addObject:subOperationsDict];
	
	if (udfsDict!=nil) 
		[operarionArray addObject:udfsDict];
	
	if ([expenseDict objectForKey:@"base64ImageString"]!=nil) {
		if ([[expenseDict objectForKey:@"base64ImageString"] isEqualToString:@""]) {
		}else {
			[operarionArray addObject:recieptDict];
		}
	}
	
	NSDictionary *secondDictAllDetails;
	secondDictAllDetails=[NSDictionary dictionaryWithObjectsAndKeys:@"CollectionAdd",@"__operation",@"Entries",@"Collection",
						  operarionArray,@"Operations",nil];
	
	
	NSMutableArray *firstOperArray;
	firstOperArray=[NSMutableArray array];
	
	if (firstOperDict!=nil)
		[firstOperArray addObject:firstOperDict];
	
	if(secondDictAllDetails!=nil)
		[firstOperArray addObject:secondDictAllDetails];
	
	
	NSDictionary *finalDetailsDict;
	finalDetailsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Edit",@"Action",@"Replicon.Expense.Domain.Expense",@"Type",[expenseDict objectForKey:@"ExpenseSheetID"],@"Identity",
					  firstOperArray,@"Operations",nil];
	
	NSArray *detailsArray;
	detailsArray=[NSArray arrayWithObjects:finalDetailsDict,nil];
	
	
	NSError *err = nil;
	NSString *queryString = [JsonWrapper writeJson:detailsArray error:&err];
#ifdef DEV_DEBUG
	//DLog(@"jsonQuery addingNewEntry%@",queryString);
#endif
    
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:queryString forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"SaveNewExpenseEntry"]];
	[self setServiceDelegate:_delegate];
	[self executeRequest];
	
	
}



-(void)sendRequestToCreateNewExpenseEntry:(NSDictionary *)expenseDict delegate:(id)_delegate{
	NSMutableDictionary *subOperationsDict;
	subOperationsDict=[NSMutableDictionary dictionary];
	[subOperationsDict setObject:[expenseDict objectForKey:@"Description"] forKey:@"Description"];
	[subOperationsDict setObject:[expenseDict objectForKey:@"NetAmount"] forKey:@"NetAmount"];
	NSDictionary *userDict;
	userDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Domain.User",@"__type",[[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"],@"Identity",nil];
	
	NSDictionary *firstOperDict;
	firstOperDict=[NSDictionary dictionaryWithObjectsAndKeys:@"SetProperties",@"__operation",userDict,@"User",nil];
	
	
	//int hour = [comps hour];
	//		int minute = [comps minute];
	//        int second = [comps second];
	
	NSArray *dateArray  = [[expenseDict objectForKey:@"EntryDate"] componentsSeparatedByString:@" "];
	
	NSString *day   =[[dateArray objectAtIndex:1] stringByReplacingOccurrencesOfString:@","withString:@""];
	NSString *month =[[dateArray objectAtIndex:0] stringByReplacingOccurrencesOfString:@","withString:@""];
	NSString *year  =[dateArray objectAtIndex:2];
	
	
	NSMutableDictionary *entryDateDict;
	entryDateDict=[NSMutableDictionary dictionary];
	[entryDateDict setObject: year forKey:@"Year"];
	[entryDateDict setObject:[NSNumber numberWithInteger:[G2Util getMonthIdForMonthName:month]] forKey:@"Month"];
	[entryDateDict setObject:day forKey:@"Day"];
	[entryDateDict setObject:@"Date" forKey:@"__type"];
	
	NSString *projectId = [expenseDict objectForKey:@"projectIdentity"];
	if (projectId==nil || [projectId isEqualToString:@"null"]) {
		projectId = @"2";
	}
	
	NSMutableDictionary *projectDict;
	projectDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Replicon.Project.Domain.Project",@"__type",projectId,@"Identity",nil];
	
	NSDictionary *currencyDict;
	NSString *currencyId = [expenseDict objectForKey:@"currencyIdentity"];
	if (currencyId==nil) {
		currencyId = @"1";
	}
	currencyDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Domain.Currency",@"__type",currencyId,@"Identity",nil];
	NSDictionary *expDict;
	expDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Expense.Domain.ExpenseType",@"__type",[expenseDict objectForKey:@"typeIdentity"],@"Identity",nil];
	
	
	
	[subOperationsDict  setObject:@"SetProperties" forKey:@"__operation"];
	[subOperationsDict setObject:projectDict forKey:@"Project"];
	[subOperationsDict setObject:currencyDict forKey:@"Currency"];
	[subOperationsDict setObject:expDict forKey:@"ExpenseType"];
	[subOperationsDict setObject:entryDateDict forKey:@"EntryDate"];
	
	if (supportDataModel==nil) {
		supportDataModel=[[G2SupportDataModel alloc]init];
	}
	
	
	NSMutableArray *operarionArray;
	operarionArray=[NSMutableArray array];
	[operarionArray addObject:subOperationsDict];
	
	NSDictionary *secondDictAllDetails;
	secondDictAllDetails=[NSDictionary dictionaryWithObjectsAndKeys:@"CollectionAdd",@"__operation",@"Entries",@"Collection",
						  operarionArray,@"Operations",nil];
	
	
	NSMutableArray *firstOperArray;
	firstOperArray=[NSMutableArray array];
	[firstOperArray addObject:firstOperDict];
	[firstOperArray addObject:secondDictAllDetails];
	
	
	NSDictionary *finalDetailsDict;
	finalDetailsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Edit",@"Action",@"Replicon.Expense.Domain.Expense",@"Type",[expenseDict objectForKey:@"ExpenseSheetID"],@"Identity",
					  firstOperArray,@"Operations",nil];
	
	NSArray *detailsArray;
	detailsArray=[NSArray arrayWithObjects:finalDetailsDict,nil];
	
	
	NSError *err = nil;
	NSString *queryString = [JsonWrapper writeJson:detailsArray error:&err];
#ifdef DEV_DEBUG
	//DLog(@"jsonQuery %@",queryString);
#endif
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:queryString forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"SaveNewExpenseEntry"]];
	[self setServiceDelegate:_delegate];
	[self executeRequest];
	//Handling Leaks
	
	
	
	
}

-(void) sendRequestToEditEntryForSheet: (NSMutableArray *)entries sheetId: (NSString *)_sheetId delegate: (id)_delegate {
	/*
	 {
	 "Identity": "55",
	 "Action": "Edit",
	 "Operations": [
	 {
	 "User": {
	 "Identity": "2",
	 "__type": "Replicon.Domain.User"
	 },
	 "__operation": "SetProperties"
	 },
	 {
	 "Collection": "Entries",
	 "Operations": [
	 {
	 "Currency": {
	 "Identity": "1",
	 "__type": "Replicon.Domain.Currency"
	 },
	 "ExpenseType": {
	 "__type": "Replicon.Expense.Domain.ExpenseType",
	 "Identity": "10"
	 },
	 "EntryDate": {
	 "Day": "05",
	 "Year": "2011",
	 "Month": 4,
	 "__type": "Date"
	 },
	 "Description": "Add",
	 "ExpenseRate": "75",
	 "NumberOfUnits": "5",
	 "__operation": "SetProperties"
	 },
	 {
	 "testExpenseUDF": "gfhgf",
	 "testExpenseUDF1": "test",
	 "Numeric": 34,
	 "__operation": "SetUdfValues"
	 }
	 ],
	 "__operation": "CollectionEdit"
	 }
	 ],
	 "Type": "Replicon.Expense.Domain.Expense"
	 }
	 */ 
	
	NSDictionary *userDict;
	userDict=[NSDictionary dictionaryWithObjectsAndKeys:
			  @"Replicon.Domain.User",@"__type",
			  [[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"],@"Identity",nil];
	
	NSDictionary *firstOperDict;
	firstOperDict=[NSDictionary dictionaryWithObjectsAndKeys:@"SetProperties",@"__operation",userDict,@"User",nil];
	
	
	NSMutableArray *firstOperArray;
	firstOperArray=[NSMutableArray array];
	[firstOperArray addObject:firstOperDict];
	
	NSString *entryDateStr=nil;
	NSMutableDictionary *entryDateDict=nil;
	for (NSDictionary *entryDict in entries) {
		if ([entryDict objectForKey:RPLocalizedString(@"Date", @"")]!=nil) {
			entryDateStr=[entryDict objectForKey:RPLocalizedString(@"Date", @"")];
		}
		NSDate *entryDate=nil;
		if (entryDateStr!=nil) {
			entryDate = [G2Util convertStringToDate1:entryDateStr];
		}
		
		unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
		//NSCalendar *calendar = [NSCalendar currentCalendar];
        NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; //DE3171
		NSDateComponents *comps=nil;
		if (entryDate!=nil) {
			comps = [calendar components:reqFields fromDate:entryDate];
			
			NSInteger year = [comps year];
			NSInteger month = [comps month];
			NSInteger day = [comps day];
			//int hour = [comps hour];
			//  int minute = [comps minute];
			//        int second = [comps second];
			
			
			entryDateDict=[NSMutableDictionary dictionary];
			[entryDateDict setObject:[NSString stringWithFormat:@"%ld",(long)year] forKey:@"Year"];
			[entryDateDict setObject:[NSString stringWithFormat:@"%ld",(long)month] forKey:@"Month"];
			[entryDateDict setObject:[NSString stringWithFormat:@"%ld",(long)day] forKey:@"Day"];
			[entryDateDict setObject:@"Date" forKey:@"__type"];
		}
		
		
		
		
		NSDictionary *currencyDict;
		NSString *currencyId = [entryDict objectForKey:@"currencyIdentity"];
		
		currencyDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Domain.Currency",@"__type",currencyId,@"Identity",nil];
		
		NSString *expenseTypeIdentity=[entryDict objectForKey:@"expenseTypeIdentity"];
		NSDictionary *expDict;
		expDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Expense.Domain.ExpenseType",@"__type",
				 expenseTypeIdentity,@"Identity",nil];
		
		
		NSString *paymentMethodId=[entryDict objectForKey:@"paymentMethodId"];
		NSDictionary *paymentMethodDict;
		paymentMethodDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Expense.Domain.PaymentMethod",@"__type",
						   paymentMethodId,@"Identity",nil];
		
		
		NSMutableDictionary *subOperationsDict;
		subOperationsDict=[NSMutableDictionary dictionary];
		
		NSString *description=[entryDict objectForKey:RPLocalizedString(@"Description", @"")];
		if (description!=nil) 
			[subOperationsDict setObject:description forKey:@"Description"];
		
		if ([entryDict objectForKey:@"BillClient"]!=nil) {
			if ([[entryDict objectForKey:@"BillClient"] intValue] == 1) {
				[subOperationsDict setObject:@"true" forKey:@"BillToClient"];
			}else {
				[subOperationsDict setObject:@"false" forKey:@"BillToClient"];
			}
		}
		
		if ([entryDict objectForKey:@"Reimburse"]!=nil) {
			if ([[entryDict objectForKey:@"Reimburse"] intValue] == 1) {
				[subOperationsDict setObject:@"true" forKey:@"RequestReimbursement"];
			}else {
				[subOperationsDict setObject:@"false" forKey:@"RequestReimbursement"];
			}
		}
		
		if ([entryDict objectForKey:@"isRated"]!=nil) {
			if([[entryDict objectForKey:@"isRated"] intValue ] == 1) {
				[subOperationsDict setObject:[entryDict objectForKey:@"ExpenseRate"] forKey:@"ExpenseRate"];
				[subOperationsDict setObject:[entryDict objectForKey:@"NumberOfUnits"] forKey:@"NumberOfUnits"];
			}else {
				[subOperationsDict setObject:[entryDict objectForKey:@"NetAmount"] forKey:@"NetAmount"];
			}
		}
		
		//adding taxamounts
		for (int x=1; x<6; x++) {
			if([entryDict objectForKey:[NSString stringWithFormat:@"taxAmount%d",x]]!=nil && ![[entryDict objectForKey:[NSString stringWithFormat:@"taxAmount%d",x]] isEqualToString:@""]){
				[subOperationsDict setObject:[NSNumber numberWithDouble:[G2Util getValueFromFormattedDoubleWithDecimalPlaces:[entryDict objectForKey:[NSString stringWithFormat:@"taxAmount%d",x]]]]
									  forKey:[NSString stringWithFormat:@"TaxAmount%d",x]];
			}else if ([[entryDict objectForKey:[NSString stringWithFormat:@"taxAmount%d",x]] isEqualToString:@""]) {
				[subOperationsDict setObject:[NSNull null] forKey:[NSString stringWithFormat:@"TaxCode%d",x]];
				//[subOperationsDict setObject:[NSNull null] forKey:[NSString stringWithFormat:@"TaxAmount%d",x]];
			}

			
		}
		
		//[subOperationsDict setObject:[entryDict objectForKey:@"NetAmount"] forKey:@"NetAmount"];
		[subOperationsDict  setObject:@"SetProperties" forKey:@"__operation"];
		if (currencyId!=nil) 
			[subOperationsDict setObject:currencyDict forKey:@"Currency"];
		
		if(expenseTypeIdentity!=nil)
			[subOperationsDict setObject:expDict forKey:@"ExpenseType"];
		
		if(paymentMethodId!=nil && ![paymentMethodId isEqualToString:@""] && ![paymentMethodId isKindOfClass:[NSNull class]])
			[subOperationsDict setObject:paymentMethodDict forKey:@"PaymentMethod"];
		
		if(entryDateDict!=nil)
			[subOperationsDict setObject:entryDateDict forKey:@"EntryDate"];
		
		NSString *projectId = [entryDict objectForKey:@"projectIdentity"];
		NSString *clientId = [entryDict objectForKey:@"clientIdentity"];
		NSMutableDictionary *projectDict;
		if(projectId != nil&& !([projectId isEqualToString:@"null"]) ) {
			projectDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Replicon.Project.Domain.Project",@"__type",projectId,@"Identity",nil];
			[subOperationsDict setObject:projectDict forKey:@"Project"];
			
			if (expensesModel==nil) {
				expensesModel=[[G2ExpensesModel alloc]init];
			}
			
			
			NSMutableArray *clientsArray=[expensesModel getClientsForBucketProjects:projectId];
			
			NSString *allocationMethodId=nil;
			allocationMethodId = [entryDict objectForKey:@"allocationMethodId"];

			
			NSMutableDictionary *clientDict=nil;
			
			
			//Bucket Projects have multiple clients..........
			if (clientsArray!=nil && [clientsArray count]>=1) {
				if (allocationMethodId !=nil  && ![allocationMethodId isKindOfClass:[NSNull class]]&& [allocationMethodId isEqualToString:@"Bucket"]) {
					if ([clientId isEqualToString:@"null"]) {
						[subOperationsDict setObject:[NSNull null] forKey:@"Client"];
					}else if (clientId!=nil) {
						clientDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Replicon.Project.Domain.Client",@"__type",clientId,@"Identity",nil];
						[subOperationsDict setObject:clientDict forKey:@"Client"];
					}
				}else {
					[subOperationsDict setObject:[NSNull null] forKey:@"Client"];
				}
				
			}else {
				if (![allocationMethodId isEqualToString:@"Bucket"]) 
					[subOperationsDict setObject:[NSNull null] forKey:@"Client"];
			}
			
		}else if (projectId != nil && [projectId isEqualToString:@"null"]) {
			[subOperationsDict setObject:[NSNull null] forKey:@"Project"];
			[subOperationsDict setObject:[NSNull null] forKey:@"Client"];
		}
		
		NSMutableArray *operarionArray;
		operarionArray=[NSMutableArray array];
		[operarionArray addObject:subOperationsDict];
		
		NSMutableDictionary *udfsDict = nil;
		NSMutableArray *udfsArray = [entryDict objectForKey:@"UserDefinedFields"];
		if(udfsArray != nil && [udfsArray count] > 0) {
			udfsDict = [NSMutableDictionary dictionary];
			NSUInteger i, count = [udfsArray count];
			for (i = 0; i < count; i++) {
				NSDictionary * udf = [udfsArray objectAtIndex:i];
				//[udfsDict setObject:[udf objectForKey:@"udfValue"] forKey:[udf objectForKey:@"udf_name"]];
				NSNumber *udfRequired = [udf objectForKey:@"required"];
				id udfValue = [udf objectForKey:@"udfValue"];
 				if ([[udf objectForKey:@"udf_type"] isEqualToString:@"Date"] && ![[udf objectForKey:@"udfValue"] isEqualToString:RPLocalizedString(@"Select", @"")]) {
					NSDate *udfDate = [G2Util convertStringToDate1:[udf objectForKey:@"udfValue"]];
					NSDateComponents *comps = [calendar components:reqFields fromDate:udfDate];
					NSDictionary *udfDateDict = [NSDictionary dictionaryWithObjectsAndKeys:
												 [NSNumber numberWithInteger:[comps year]],@"Year",
												 [NSNumber numberWithInteger:[comps month]],@"Month",
												 [NSNumber numberWithInteger:[comps day]],@"Day",
												 nil];
					[udfsDict setObject:udfDateDict forKey:[udf objectForKey:@"udf_name"]];
				}else if(![[udf objectForKey:@"udf_type"] isEqualToString:@"Date"]){
					if ([udfValue isKindOfClass:[NSString class]]) {
						if (([udfRequired intValue]== 0 || [udfRequired intValue] == 1)&&  [udfValue isEqualToString:RPLocalizedString(@"Select", @"")]) {
							continue;
						}
					}
					[udfsDict setObject:[udf objectForKey:@"udfValue"] forKey:[udf objectForKey:@"udf_name"]];
				}
				
				//}
 			}
			[udfsDict setObject:@"SetUdfValues" forKey:@"__operation"];
			[operarionArray addObject:udfsDict];
		}
		
		NSMutableDictionary *expenseReceiptDict;
		NSString *imageString = [entryDict objectForKey:@"Base64ImageString"];
		NSString *imageReplace=[entryDict objectForKey:@"imageFlag"];
		if(imageString != nil && !([imageString isEqualToString:@""])) {
			
			if (imageReplace!=nil) {
				NSDictionary *receiptDelDict=[NSDictionary dictionaryWithObjectsAndKeys:@"CollectionClear",@"__operation",@"ExpenseReceipt",@"Collection",nil];
				
				[operarionArray addObject:receiptDelDict];
			}
			NSDictionary *imageDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Image",@"_type",imageString,@"Value",nil];
			expenseReceiptDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"SetExpenseReceipt",@"__operation",
								  @"image/jpeg",@"ContentType",
								  imageDict,@"Image",
								  nil];
			
 			[expenseReceiptDict setObject:@"SetExpenseReceipt" forKey:@"__operation"];
			[expenseReceiptDict setObject:@"receipt.jpg" forKey:@"FileName"];
			[operarionArray addObject:expenseReceiptDict];
		}else if ([imageString isEqualToString:@""]) {
			
		}else {
			
			/*
			 {
			 "__operation": "CollectionClear",
			 "Collection": "ExpenseReceipt"
			 }
			 */
			
			NSDictionary *receiptDelDict=[NSDictionary dictionaryWithObjectsAndKeys:@"CollectionClear",@"__operation",@"ExpenseReceipt",@"Collection",nil];
			
			[operarionArray addObject:receiptDelDict];
			
		}
		
		if (imageString!=nil) {
			imageString=nil;
		}
		
		NSDictionary *secondDictAllDetails;
		secondDictAllDetails=[NSDictionary dictionaryWithObjectsAndKeys:@"CollectionEdit",@"__operation",[entryDict objectForKey:@"identity"],@"Identity",@"Entries",@"Collection",operarionArray,@"Operations",nil];
		
		[firstOperArray addObject:secondDictAllDetails];
	 
    }
	
	NSDictionary *finalDetailsDict;
	finalDetailsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Edit",@"Action",@"Replicon.Expense.Domain.Expense",@"Type",_sheetId,@"Identity",
					  firstOperArray,@"Operations",nil];
	
	NSArray *detailsArray;
	detailsArray=[NSArray arrayWithObjects:finalDetailsDict,nil];

	NSError *err = nil;
	NSString *queryString = [JsonWrapper writeJson:detailsArray error:&err];
#ifdef DEV_DEBUG
	//DLog(@"QUERY FOR EDITING EXPENSE ENTRY %@",queryString);
#endif
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:queryString forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"EditExpenseEntries"]];
	[self setServiceDelegate:_delegate];
	[self executeRequest];
}

-(void) sendRequestToSyncOfflineCreatedEntriesForSheet: (NSMutableArray *)entries sheetId: (NSString *)_sheetId delegate: (id)_delegate {
	/*
	 {
	 "Identity": "55",
	 "Action": "Edit",
	 "Operations": [
	 {
	 "User": {
	 "Identity": "2",
	 "__type": "Replicon.Domain.User"
	 },
	 "__operation": "SetProperties"
	 },
	 {
	 "Collection": "Entries",
	 "Operations": [
	 {
	 "Currency": {
	 "Identity": "1",
	 "__type": "Replicon.Domain.Currency"
	 },
	 "ExpenseType": {
	 "__type": "Replicon.Expense.Domain.ExpenseType",
	 "Identity": "10"
	 },
	 "EntryDate": {
	 "Day": "05",
	 "Year": "2011",
	 "Month": 4,
	 "__type": "Date"
	 },
	 "Description": "Add",
	 "ExpenseRate": "75",
	 "NumberOfUnits": "5",
	 "__operation": "SetProperties"
	 },
	 {
	 "testExpenseUDF": "gfhgf",
	 "testExpenseUDF1": "test",
	 "Numeric": 34,
	 "__operation": "SetUdfValues"
	 }
	 ],
	 "__operation": "CollectionAdd"
	 }
	 ],
	 "Type": "Replicon.Expense.Domain.Expense"
	 }
	 */ 
	NSDictionary *userDict;
	userDict=[NSDictionary dictionaryWithObjectsAndKeys:
			  @"Replicon.Domain.User",@"__type",
			  [[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"],@"Identity",nil];
	
	NSDictionary *firstOperDict;
	firstOperDict=[NSDictionary dictionaryWithObjectsAndKeys:@"SetProperties",@"__operation",userDict,@"User",nil];
	
	
	NSMutableArray *firstOperArray;
	firstOperArray=[NSMutableArray array];
	[firstOperArray addObject:firstOperDict];
	
	//changes done according to new requirements
	NSString *entryDateStr=nil;
	NSMutableDictionary *entryDateDict=nil;
	for (NSDictionary *entryDict in entries) {
		if ([entryDict objectForKey:@"Date"]!=nil) {
			entryDateStr=[entryDict objectForKey:@"Date"];
		}
		NSDate *entryDate=nil;
		if (entryDateStr!=nil) {
			entryDate = [G2Util convertStringToDate1:entryDateStr];
		}
		
		unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *comps=nil;
		if (entryDate!=nil) {
			comps = [calendar components:reqFields fromDate:entryDate];
			
			NSInteger year = [comps year];
			NSInteger month = [comps month];
			NSInteger day = [comps day];
			//int hour = [comps hour];
			//  int minute = [comps minute];
			//        int second = [comps second];
			
			
			entryDateDict=[NSMutableDictionary dictionary];
			[entryDateDict setObject:[NSString stringWithFormat:@"%ld",(long)year] forKey:@"Year"];
			[entryDateDict setObject:[NSString stringWithFormat:@"%ld",(long)month] forKey:@"Month"];
			[entryDateDict setObject:[NSString stringWithFormat:@"%ld",(long)day] forKey:@"Day"];
			[entryDateDict setObject:@"Date" forKey:@"__type"];
		}
		
		
		NSDictionary *currencyDict;
		NSString *currencyId = [entryDict objectForKey:@"currencyIdentity"];
		
		currencyDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Domain.Currency",@"__type",currencyId,@"Identity",nil];
		
		NSString *expenseTypeIdentity=[entryDict objectForKey:@"expenseTypeIdentity"];
		
		NSDictionary *expDict;
		expDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Expense.Domain.ExpenseType",@"__type",
				 expenseTypeIdentity,@"Identity",nil];
		
		NSString *paymentMethodId=[entryDict objectForKey:@"paymentMethodId"];
		NSDictionary *paymentMethodDict;
		paymentMethodDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Expense.Domain.PaymentMethod",@"__type",
						   paymentMethodId,@"Identity",nil];
		
		NSMutableDictionary *subOperationsDict;
		subOperationsDict=[NSMutableDictionary dictionary];
		
		NSString *description=[entryDict objectForKey:@"Description"];
		if (description!=nil) 
			[subOperationsDict setObject:description forKey:@"Description"];
		
		if ([entryDict objectForKey:@"BillClient"]!=nil) {
			if ([[entryDict objectForKey:@"BillClient"] intValue] == 1) {
				[subOperationsDict setObject:@"true" forKey:@"BillToClient"];
			}else {
				[subOperationsDict setObject:@"false" forKey:@"BillToClient"];
			}
		}
		
		if ([entryDict objectForKey:@"Reimburse"]!=nil) {
			if ([[entryDict objectForKey:@"Reimburse"] intValue] == 1) {
				[subOperationsDict setObject:@"true" forKey:@"RequestReimbursement"];
			}else {
				[subOperationsDict setObject:@"false" forKey:@"RequestReimbursement"];
			}
		}
		
		if ([entryDict objectForKey:@"isRated"]!=nil) {
			if([[entryDict objectForKey:@"isRated"] intValue ] == 1) {
				[subOperationsDict setObject:[entryDict objectForKey:@"ExpenseRate"] forKey:@"ExpenseRate"];
				[subOperationsDict setObject:[entryDict objectForKey:@"NumberOfUnits"] forKey:@"NumberOfUnits"];
			}else {
				[subOperationsDict setObject:[entryDict objectForKey:@"NetAmount"] forKey:@"NetAmount"];
			}
		}
		
		//adding taxamounts
		for (int x=1; x<6; x++) {
			if([entryDict objectForKey:[NSString stringWithFormat:@"taxAmount%d",x]]!=nil){
				[subOperationsDict setObject:[NSNumber numberWithDouble:[G2Util getValueFromFormattedDoubleWithDecimalPlaces:[entryDict objectForKey:[NSString stringWithFormat:@"taxAmount%d",x]]]]
									  forKey:[NSString stringWithFormat:@"TaxAmount%d",x]];
			}
			
		}
		
		
		//[subOperationsDict setObject:[entryDict objectForKey:@"NetAmount"] forKey:@"NetAmount"];
		[subOperationsDict  setObject:@"SetProperties" forKey:@"__operation"];
		if (currencyId!=nil)
			[subOperationsDict setObject:currencyDict forKey:@"Currency"];
		
		if(expenseTypeIdentity!=nil)
			[subOperationsDict setObject:expDict forKey:@"ExpenseType"];
		
		if (paymentMethodId!=nil && ![paymentMethodId isEqualToString:@""] && ![paymentMethodId isKindOfClass:[NSNull class]]) 
			[subOperationsDict setObject:paymentMethodDict forKey:@"PaymentMethod"];
		
		if(entryDateDict!=nil)
			[subOperationsDict setObject:entryDateDict forKey:@"EntryDate"];
		
		NSString *projectId = [entryDict objectForKey:@"projectIdentity"];
		NSMutableDictionary *projectDict;
		if(projectId != nil&& !([projectId isEqualToString:@"null"]) ) {
			projectDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Replicon.Project.Domain.Project",@"__type",projectId,@"Identity",nil];
			[subOperationsDict setObject:projectDict forKey:@"Project"];
			
			if (expensesModel==nil) {
				expensesModel=[[G2ExpensesModel alloc]init];
			}
			
			NSString *clientId = [entryDict objectForKey:@"clientIdentity"];
			
			NSMutableArray *clientsArray=nil;
			if (projectId!=nil) 
				clientsArray=[expensesModel getClientsForBucketProjects:projectId];
			
			NSString *allocationMethodId=nil;
			if (clientsArray!=nil && [clientsArray count]>1) {
				allocationMethodId=[[clientsArray objectAtIndex:0] objectForKey:@"allocationMethodId"];
			}
			
			NSMutableDictionary *clientDict=nil;
			//Bucket Projects have multiple clients..........
			if (clientsArray!=nil && [clientsArray count]>1) {
				if (allocationMethodId !=nil && ![allocationMethodId isKindOfClass:[NSNull class]] && [allocationMethodId isEqualToString:@"Bucket"]) {
					if ([clientId isEqualToString:@"null"]) {
						
					}else if (clientId != nil) {
						clientDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Replicon.Project.Domain.Client",@"__type",clientId,@"Identity",nil];
						[subOperationsDict setObject:clientDict forKey:@"Client"];
					}
				}else {
					[subOperationsDict setObject:[NSNull null] forKey:@"Client"];
				}
				
			}else {
				[subOperationsDict setObject:[NSNull null] forKey:@"Client"];
			}
		}
		
		NSMutableArray *operarionArray;
		operarionArray=[NSMutableArray array];
		[operarionArray addObject:subOperationsDict];
		
		NSMutableDictionary *udfsDict;
		NSMutableArray *udfsArray = [entryDict objectForKey:@"UserDefinedFields"];
		if(udfsArray != nil && [udfsArray count] > 0) {
			udfsDict = [NSMutableDictionary dictionary];
			NSUInteger i, count = [udfsArray count];
			for (i = 0; i < count; i++) {
				NSDictionary * udf = [udfsArray objectAtIndex:i];
				//[udfsDict setObject:[udf objectForKey:@"udfValue"] forKey:[udf objectForKey:@"udf_name"]];
				NSNumber *udfRequired = [udf objectForKey:@"required"];
				id udfValue = [udf objectForKey:@"udfValue"];
 				if ([[udf objectForKey:@"udf_type"] isEqualToString:@"Date"] && ![[udf objectForKey:@"udfValue"] isEqualToString:RPLocalizedString(@"Select", @"")]) {
					NSDate *udfDate = [G2Util convertStringToDate1:[udf objectForKey:@"udfValue"]];
					NSDateComponents *comps = [calendar components:reqFields fromDate:udfDate];
					NSDictionary *udfDateDict = [NSDictionary dictionaryWithObjectsAndKeys:
												 [NSNumber numberWithInteger:[comps year]],@"Year",
												 [NSNumber numberWithInteger:[comps month]],@"Month",
												 [NSNumber numberWithInteger:[comps day]],@"Day",
												 nil];
					[udfsDict setObject:udfDateDict forKey:[udf objectForKey:@"udf_name"]];
				}else if(![[udf objectForKey:@"udf_type"] isEqualToString:@"Date"]){
					if ([udfValue isKindOfClass:[NSString class]]) {
						if (([udfRequired intValue]== 0 || [udfRequired intValue]== 1) &&  [udfValue isEqualToString:RPLocalizedString(@"Select", @"")]) {
							continue;
						}
					}
					[udfsDict setObject:[udf objectForKey:@"udfValue"] forKey:[udf objectForKey:@"udf_name"]];
				}
				
				//}
 			}
			[udfsDict setObject:@"SetUdfValues" forKey:@"__operation"];
			[operarionArray addObject:udfsDict];
		}
		
		
		NSMutableDictionary *expenseReceiptDict;
		NSString *imageString = [entryDict objectForKey:@"Base64ImageString"];
		if(imageString != nil  && ![imageString isEqualToString:@""]) {
			NSDictionary *imageDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Image",@"_type",imageString,@"Value",nil];
			expenseReceiptDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"SetExpenseReceipt",@"__operation",
								  @"image/jpeg",@"ContentType",
								  imageDict,@"Image",
								  nil];
			
 			[expenseReceiptDict setObject:@"SetExpenseReceipt" forKey:@"__operation"];
			[expenseReceiptDict setObject:@"receipt.jpg" forKey:@"FileName"];
			[operarionArray addObject:expenseReceiptDict];
		}
		
		NSDictionary *secondDictAllDetails;
		secondDictAllDetails=[NSDictionary dictionaryWithObjectsAndKeys:@"CollectionAdd",@"__operation",@"Entries",@"Collection",
							  operarionArray,@"Operations",nil];
		
		[firstOperArray addObject:secondDictAllDetails];
	}
	
	
	NSDictionary *finalDetailsDict;
	finalDetailsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Edit",@"Action",@"Replicon.Expense.Domain.Expense",@"Type",_sheetId,@"Identity",
					  firstOperArray,@"Operations",nil];
	
	NSArray *detailsArray;
	detailsArray=[NSArray arrayWithObjects:finalDetailsDict,nil];
	
	NSError *err = nil;
	NSString *queryString = [JsonWrapper writeJson:detailsArray error:&err];
#ifdef DEV_DEBUG
	//DLog(@"jsonQuery %@",queryString);
#endif
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:queryString forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"SyncOfflineCreatedEntries"]];
	[self setServiceDelegate:_delegate];
	[self executeRequest];
} 

-(void) sendRequestToDeleteExpenseEntriesForSheet: (NSMutableArray *)entries sheetId: (NSString *)_sheetId delegate: (id)_delegate {
	
	/*
	 [
	 {
	 "Action": "Edit",
	 "Type": "Replicon.Expense.Domain.Expense",
	 "Identity": "1",
	 "Operations":
	 [
	 {
	 "__operation": "SetProperties",
	 "User":
	 {
	 "__type": "Replicon.Domain.User",
	 "Identity": "2"
	 }
	 },
	 {
	 "__operation": "CollectionRemove",
	 "Collection": "Entries",
	 "Identity": "1"
	 }
	 ]
	 }
	 ]*/
	
	NSDictionary *userDict;
	userDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Domain.User",@"__type",[[ NSUserDefaults standardUserDefaults]objectForKey:@"UserID"],@"Identity",nil];
	
	NSDictionary *setPropertiesOperationsDict;
	setPropertiesOperationsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"SetProperties",@"__operation",userDict,@"User",nil];
	
	NSMutableArray *mainOperationArray=[[NSMutableArray alloc] init];
	[mainOperationArray addObject:setPropertiesOperationsDict];
	
	for (NSDictionary *entryIdDict in entries) {
		
		NSDictionary *collectionOperationDict = [NSDictionary dictionaryWithObjectsAndKeys:@"CollectionRemove",@"__operation",@"Entries",@"Collection"
												 ,[entryIdDict objectForKey:@"identity"],@"Identity",nil];
		[mainOperationArray addObject:collectionOperationDict];
		
	}
	
	NSDictionary *firstEditDict=[NSDictionary dictionaryWithObjectsAndKeys:mainOperationArray,@"Operations",_sheetId,@"Identity",@"Replicon.Expense.Domain.Expense",@"Type",
								 @"Edit",@"Action",nil];
	NSMutableArray *queryArray=[NSMutableArray array];
	[queryArray addObject:firstEditDict];
	
	
	NSError *err = nil;
	NSString *queryString = [JsonWrapper writeJson:queryArray error:&err];
	//#ifdef DEV_DEBUG
	//DLog(@"jsonQuery %@",queryString);
	//#endif
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:queryString forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"DeleteExpenseEntry"]];
	[self setServiceDelegate:_delegate];
	[self executeRequest];
	
}



-(void)sendRequestToGetApproversForUnsubmittedExpenseSheet:(NSString*)sheetIdentity delegate:(id)_delegate
{
	/*
	 {
	 "Action": "LoadIdentity",
	 "DomainType": "Replicon.Expense.Domain.Expense",
	 "Identity": "55",
	 "Load": [
	 {
	 "Relationship": "History",
	 "Load": [
	 {
	 "Relationship": "Approver"
	 }
	 ]
	 }
	 ]
	 }
	 */
	
	
	NSDictionary *approverDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Approver",@"Relationship",nil];
	NSMutableArray *secondLoadArray=[NSMutableArray array];
	[secondLoadArray addObject:approverDict];
	NSDictionary *historyDict=[NSDictionary dictionaryWithObjectsAndKeys:@"History",@"Relationship",secondLoadArray,@"Load",nil];
	NSMutableArray *firstLoadArray=[NSMutableArray array];
	[firstLoadArray addObject:historyDict];
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:@"LoadIdentity",@"Action",@"Replicon.Expense.Domain.Expense",@"DomainType",
							 sheetIdentity,@"Identity",firstLoadArray,@"Load",nil];
	
	NSError *err = nil;
	NSString *queryString = [JsonWrapper writeJson:queryDict error:&err];
#ifdef DEV_DEBUG
	//DLog(@"jsonQueryForApproversUnsubmit %@",queryString);
#endif
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:queryString forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ApprovalsDetailsOnUnsubmit"]];
	[self setServiceDelegate:_delegate];
	[self executeRequest];
}

-(void)sendRequestToGetRemainingApproversForSubmittedExpenseSheetWithId:(NSString*)sheetIdentity delegate:(id)_delegate
{
	/*{
	 "Action": "LoadIdentity",
	 "DomainType": "Replicon.Expense.Domain.Expense",
	 "Identity": "2",
	 "Load": [
	 {
	 "Relationship": "History",
	 "Load": [
	 {
	 "Relationship": "Approver"
	 }
	 ]
	 },
	 {
	 "Relationship": "RemainingApprovers"
	 },
	 {
	 "Relationship": "WaitingOnApprovers"
	 }
	 ]
	 }*/
	NSDictionary *approverDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Approver",@"Relationship",nil];
	NSMutableArray *secondLoadArray=[NSMutableArray array];
	[secondLoadArray addObject:approverDict];
	NSDictionary *historyDict=[NSDictionary dictionaryWithObjectsAndKeys:@"History",@"Relationship",secondLoadArray,@"Load",nil];
	NSDictionary *remainingApproversDict=[NSDictionary dictionaryWithObjectsAndKeys:@"RemainingApprovers",@"Relationship",nil];
	NSDictionary *waitingApproversDict=[NSDictionary dictionaryWithObjectsAndKeys:@"WaitingOnApprovers",@"Relationship",nil];
	
	NSMutableArray *firstLoadArray=[NSMutableArray array];
	[firstLoadArray addObject:historyDict];
	[firstLoadArray addObject:remainingApproversDict];
	[firstLoadArray addObject:waitingApproversDict];
	
	NSDictionary *queryDict=[NSDictionary dictionaryWithObjectsAndKeys:@"LoadIdentity",@"Action",@"Replicon.Expense.Domain.Expense",@"DomainType",
							 sheetIdentity,@"Identity",firstLoadArray,@"Load",nil];
	NSError *err = nil;
	NSString *queryString = [JsonWrapper writeJson:queryDict error:&err];
#ifdef DEV_DEBUG
	//DLog(@"jsonQueryForApproversSubmitted %@",queryString);
#endif
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:queryString forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	//[self setServiceID:[ServiceUtil getServiceIDForServiceName:@"ApprovalsDetailsForSubmittedSheet"]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ApprovalsDetailsOnUnsubmit"]];
	[self setServiceDelegate:_delegate];
	[self executeRequest];
}
-(void)sendRequestToGetRecieptForSelectedExpense:(id)expenseIdentity delegate:(id)_delegate{
	/*{
	 "Action": "Query",
	 "QueryType": "ExpenseEntryById",
	 "DomainType": "Replicon.Expense.Domain.ExpenseEntry",
	 "Args": [
	 [
	 "2"
	 ]
	 ],
	 "Load": [
	 {
	 "Relationship": "ExpenseReceipt"
	 }
	 ]
	 }*/
	
	NSDictionary *receiptDict=[NSDictionary dictionaryWithObjectsAndKeys:@"ExpenseReceipt",@"Relationship",nil];
	NSMutableArray *loadArray=[NSMutableArray array];
	[loadArray addObject:receiptDict];
	NSArray *identityArr = [NSArray arrayWithObject:expenseIdentity];
	NSMutableArray *argsArray = [NSMutableArray array];
	[argsArray addObject:identityArr];
	
	NSMutableDictionary *queryDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
									@"Query",@"Action",
									@"ExpenseEntryById",@"QueryType",
									@"Replicon.Expense.Domain.ExpenseEntry",@"DomainType",
									argsArray,@"Args",
									loadArray,@"Load",nil];
	
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];
	//#ifdef DEV_DEBUG
	//DLog(@"**********sendRequestToGetRecieptForSelectedExpense************ %@",str);
	//#endif
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"ExpenseReceiptImage"]];
	[self setServiceDelegate:_delegate];
	//[self executeRequest];
	[self executeRequestWithTimeOut:60];
	
}

-(void)sendRequestToSyncOfflineCreatedSheet:(NSMutableDictionary *)sheetInfoDict delegate:(id)_delegate {
	
	/*
	 
	 {
	 "Action": "Create",
	 "Type": "Replicon.Expense.Domain.Expense",
	 "Operations": [
	 {
	 "__operation": "SetProperties",
	 "User": {
	 "__type": "Replicon.Domain.User",
	 "Identity": "2"
	 },
	 "Description": "created via RepliConnect with entries"
	 },
	 {
	 "__operation": "CollectionAdd",
	 "Collection": "Entries",
	 "Operations": [
	 {
	 "__operation": "SetProperties",
	 "ExpenseType": {
	 "__type": "Replicon.Expense.Domain.ExpenseType",
	 "Identity": "2"
	 },
	 "Currency": {
	 "__type": "Replicon.Domain.Currency",
	 "Identity": "2"
	 }
	 }
	 ]
	 }
	 ]
	 }
	 ]	 */
	
	NSString *_sheetId = [sheetInfoDict objectForKey:@"identity"];
	NSDictionary *userDict;
	userDict=[NSDictionary dictionaryWithObjectsAndKeys:
			  @"Replicon.Domain.User",@"__type",
			  [[NSUserDefaults standardUserDefaults]objectForKey:@"UserID"],@"Identity",nil];
	
	NSDictionary *reimbursementCurrencyDict = [NSDictionary dictionaryWithObjectsAndKeys:
											   @"Replicon.Domain.Currency",@"__type",
											   [sheetInfoDict objectForKey:@"ReimbursementCurrency"],@"Identity",
											   nil];
	
	NSDate *expenseDate = [G2Util convertStringToDate1:[sheetInfoDict objectForKey:@"ExpenseDate"]];	
	unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
	//NSDate *date = [entryDict objectForKey:@"Date"];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *comps = [calendar components:reqFields fromDate:expenseDate];
	
	NSInteger year = [comps year];
	NSInteger month = [comps month];
	NSInteger day = [comps day];
	
	NSMutableDictionary *expenseDateDict;
	expenseDateDict=[NSMutableDictionary dictionary];
	[expenseDateDict setObject:[NSString stringWithFormat:@"%ld",(long)year] forKey:@"Year"];
	[expenseDateDict setObject:[NSString stringWithFormat:@"%ld",(long)month] forKey:@"Month"];
	[expenseDateDict setObject:[NSString stringWithFormat:@"%ld",(long)day] forKey:@"Day"];
	[expenseDateDict setObject:@"Date" forKey:@"__type"];
	
	NSDictionary *firstOperDict;
	firstOperDict=[NSDictionary dictionaryWithObjectsAndKeys:@"SetProperties",@"__operation",userDict,@"User",
				   [sheetInfoDict objectForKey:@"Description"],@"Description",
				   reimbursementCurrencyDict,@"ReimbursementCurrency",
				   expenseDateDict,@"ExpenseDate",
				   nil];
	
	NSMutableArray *firstOperArray;
	firstOperArray=[NSMutableArray array];
	[firstOperArray addObject:firstOperDict];
	
	NSMutableArray *entries = [sheetInfoDict objectForKey:@"sheetEntries"];
	
	if (entries != nil) {
		//changes done according to new requirements
		NSString *entryDateStr=nil;
		NSMutableDictionary *entryDateDict=nil;
		for (NSDictionary *entryDict in entries) {
			if ([entryDict objectForKey:@"Date"]!=nil) {
				entryDateStr=[entryDict objectForKey:@"Date"];
			}
			NSDate *entryDate=nil;
			if (entryDateStr!=nil) {
				entryDate = [G2Util convertStringToDate1:entryDateStr];
			}
			
			unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
			NSCalendar *calendar = [NSCalendar currentCalendar];
			NSDateComponents *comps=nil;
			if (entryDate!=nil) {
				comps = [calendar components:reqFields fromDate:entryDate];
				
				NSInteger year = [comps year];
				NSInteger month = [comps month];
				NSInteger day = [comps day];
				//int hour = [comps hour];
				//  int minute = [comps minute];
				//        int second = [comps second];
				
				
				entryDateDict=[NSMutableDictionary dictionary];
				[entryDateDict setObject:[NSString stringWithFormat:@"%ld",(long)year] forKey:@"Year"];
				[entryDateDict setObject:[NSString stringWithFormat:@"%ld",(long)month] forKey:@"Month"];
				[entryDateDict setObject:[NSString stringWithFormat:@"%ld",(long)day] forKey:@"Day"];
				[entryDateDict setObject:@"Date" forKey:@"__type"];
			}
			
			NSDictionary *currencyDict;
			NSString *currencyId = [entryDict objectForKey:@"currencyIdentity"];
			
			currencyDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Domain.Currency",@"__type",currencyId,@"Identity",nil];
			
			NSString *expenseTypeIdentity=[entryDict objectForKey:@"expenseTypeIdentity"];
			
			NSDictionary *expDict;
			expDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Expense.Domain.ExpenseType",@"__type",
					 expenseTypeIdentity,@"Identity",nil];
			
			NSString *paymentMethodId=[entryDict objectForKey:@"paymentMethodId"];
			NSDictionary *paymentMethodDict;
			paymentMethodDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Replicon.Expense.Domain.PaymentMethod",@"__type",
							   paymentMethodId,@"Identity",nil];
			
			NSMutableDictionary *subOperationsDict;
			subOperationsDict=[NSMutableDictionary dictionary];
			
			NSString *description=[entryDict objectForKey:@"Description"];
			if (description!=nil) 
				[subOperationsDict setObject:description forKey:@"Description"];
			
			if ([entryDict objectForKey:@"BillClient"]!=nil) {
				if ([[entryDict objectForKey:@"BillClient"] intValue] == 1) {
					[subOperationsDict setObject:@"true" forKey:@"BillToClient"];
				}else {
					[subOperationsDict setObject:@"false" forKey:@"BillToClient"];
				}
			}
			
			if ([entryDict objectForKey:@"Reimburse"]!=nil) {
				if ([[entryDict objectForKey:@"Reimburse"] intValue] == 1) {
					[subOperationsDict setObject:@"true" forKey:@"RequestReimbursement"];
				}else {
					[subOperationsDict setObject:@"false" forKey:@"RequestReimbursement"];
				}
			}
			
			if ([entryDict objectForKey:@"isRated"]!=nil) {
				if([[entryDict objectForKey:@"isRated"] intValue ] == 1) {
					[subOperationsDict setObject:[entryDict objectForKey:@"ExpenseRate"] forKey:@"ExpenseRate"];
					[subOperationsDict setObject:[entryDict objectForKey:@"NumberOfUnits"] forKey:@"NumberOfUnits"];
				}else {
					[subOperationsDict setObject:[entryDict objectForKey:@"NetAmount"] forKey:@"NetAmount"];
				}
			}
			
			//adding taxamounts
			for (int x=1; x<6; x++) {
				if([entryDict objectForKey:[NSString stringWithFormat:@"taxAmount%d",x]]!=nil){
					[subOperationsDict setObject:[NSNumber numberWithDouble:[G2Util getValueFromFormattedDoubleWithDecimalPlaces:[entryDict objectForKey:[NSString stringWithFormat:@"taxAmount%d",x]]]]
										  forKey:[NSString stringWithFormat:@"TaxAmount%d",x]];
				}
				
			}
			
			
			//[subOperationsDict setObject:[entryDict objectForKey:@"NetAmount"] forKey:@"NetAmount"];
			[subOperationsDict  setObject:@"SetProperties" forKey:@"__operation"];
			if (currencyId!=nil)
				[subOperationsDict setObject:currencyDict forKey:@"Currency"];
			
			if(expenseTypeIdentity!=nil)
				[subOperationsDict setObject:expDict forKey:@"ExpenseType"];
			
			if (paymentMethodId!=nil && ![paymentMethodId isEqualToString:@""] && ![paymentMethodId isKindOfClass:[NSNull class]]) 
				[subOperationsDict setObject:paymentMethodDict forKey:@"PaymentMethod"];
			
			if(entryDateDict!=nil)
				[subOperationsDict setObject:entryDateDict forKey:@"EntryDate"];
			
			NSString *projectId = [entryDict objectForKey:@"projectIdentity"];
			NSMutableDictionary *projectDict;
			if(projectId != nil&& !([projectId isEqualToString:@"null"]) ) {
				projectDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Replicon.Project.Domain.Project",@"__type",projectId,@"Identity",nil];
				[subOperationsDict setObject:projectDict forKey:@"Project"];
				
				if (expensesModel==nil) {
					expensesModel=[[G2ExpensesModel alloc]init];
				}
				
				NSString *clientId = [entryDict objectForKey:@"clientIdentity"];
				NSMutableArray *clientsArray=[expensesModel getClientsForBucketProjects:projectId];
				
				NSString *allocationMethodId=nil;
				if (clientsArray!=nil && [clientsArray count]>1) {
					allocationMethodId=[[clientsArray objectAtIndex:0] objectForKey:@"allocationMethodId"];
				}
				
				NSMutableDictionary *clientDict=nil;
				//Bucket Projects have multiple clients..........
				if (clientsArray!=nil && [clientsArray count]>1) {
					if (allocationMethodId !=nil  && ![allocationMethodId isKindOfClass:[NSNull class]]&& [allocationMethodId isEqualToString:@"Bucket"]) {
						if ([clientId isEqualToString:@"null"]) {
						}else if (clientId!=nil) {
							clientDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Replicon.Project.Domain.Client",@"__type",clientId,@"Identity",nil];
							[subOperationsDict setObject:clientDict forKey:@"Client"];
						}
					}else {
						[subOperationsDict setObject:[NSNull null] forKey:@"Client"];
					}
					
				}else {
					[subOperationsDict setObject:[NSNull null] forKey:@"Client"];
				}
			}
			
			NSMutableArray *operarionArray;
			operarionArray=[NSMutableArray array];
			[operarionArray addObject:subOperationsDict];
			
			NSMutableDictionary *udfsDict;
			NSMutableArray *udfsArray = [entryDict objectForKey:@"UserDefinedFields"];
			if(udfsArray != nil && [udfsArray count] > 0) {
				udfsDict = [NSMutableDictionary dictionary];
				NSUInteger i, count = [udfsArray count];
				for (i = 0; i < count; i++) {
					NSDictionary * udf = [udfsArray objectAtIndex:i];
					//[udfsDict setObject:[udf objectForKey:@"udfValue"] forKey:[udf objectForKey:@"udf_name"]];
					NSNumber *udfRequired = [udf objectForKey:@"required"];
					id udfValue = [udf objectForKey:@"udfValue"];
					if ([[udf objectForKey:@"udf_type"] isEqualToString:@"Date"] && ![[udf objectForKey:@"udfValue"] isEqualToString:RPLocalizedString(@"Select", @"")]) {
						NSDate *udfDate = [G2Util convertStringToDate1:[udf objectForKey:@"udfValue"]];
						NSDateComponents *comps = [calendar components:reqFields fromDate:udfDate];
						NSDictionary *udfDateDict = [NSDictionary dictionaryWithObjectsAndKeys:
													 [NSNumber numberWithInteger:[comps year]],@"Year",
													 [NSNumber numberWithInteger:[comps month]],@"Month",
													 [NSNumber numberWithInteger:[comps day]],@"Day",
													 nil];
						[udfsDict setObject:udfDateDict forKey:[udf objectForKey:@"udf_name"]];
					}else if(![[udf objectForKey:@"udf_type"] isEqualToString:@"Date"]){
						if ([udfValue isKindOfClass:[NSString class]]) {
							if (([udfRequired intValue]== 0 || [udfRequired intValue]== 1) &&  [udfValue isEqualToString:RPLocalizedString(@"Select", @"")]) {
								continue;
							}
						}
						[udfsDict setObject:[udf objectForKey:@"udfValue"] forKey:[udf objectForKey:@"udf_name"]];
					}
					
					//}
				}
				[udfsDict setObject:@"SetUdfValues" forKey:@"__operation"];
				[operarionArray addObject:udfsDict];
			}
			
			
			NSMutableDictionary *expenseReceiptDict;
			NSString *imageString = [entryDict objectForKey:@"Base64ImageString"];
			if(imageString != nil  && ![imageString isEqualToString:@""]) {
				NSDictionary *imageDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Image",@"_type",imageString,@"Value",nil];
				expenseReceiptDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"SetExpenseReceipt",@"__operation",
									  @"image/jpeg",@"ContentType",
									  imageDict,@"Image",
									  nil];
				
				[expenseReceiptDict setObject:@"SetExpenseReceipt" forKey:@"__operation"];
				[expenseReceiptDict setObject:@"receipt.jpg" forKey:@"FileName"];
				[operarionArray addObject:expenseReceiptDict];
			}
			
			NSDictionary *secondDictAllDetails;
			secondDictAllDetails=[NSDictionary dictionaryWithObjectsAndKeys:@"CollectionAdd",@"__operation",@"Entries",@"Collection",
								  operarionArray,@"Operations",nil];
			
			[firstOperArray addObject:secondDictAllDetails];
		}
	}
	
	
	NSDictionary *finalDetailsDict;
	finalDetailsDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Create",@"Action",@"Replicon.Expense.Domain.Expense",@"Type",
					  firstOperArray,@"Operations",nil];
	
	NSArray *detailsArray;
	detailsArray=[NSArray arrayWithObjects:finalDetailsDict,nil];
	
	NSError *err = nil;
	NSString *queryString = [JsonWrapper writeJson:detailsArray error:&err];
#ifdef DEV_DEBUG
	//DLog(@"jsonQuery %@",queryString);
#endif
	
	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
	[paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"] forKey:@"URLString"];
	[paramDict setObject:queryString forKey:@"PayLoadStr"];
	[self setRequest:[G2RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
	[self setServiceID:[G2ServiceUtil getServiceIDForServiceName:@"SyncOfflineCreatedSheet"]];
	[self setServiceDelegate:_delegate];
	[self executeRequest:_sheetId];
}


-(void)sendRequestToFetchExpensesSupportData
{
	[[G2RepliconServiceManager supportDataService]sendRequestForUDFSetting: self];
	[[G2RepliconServiceManager supportDataService]sendRequestToGetPaymentMethodAllWithDelegate: self];
	[[G2RepliconServiceManager supportDataService]sendRequestToGetSystemCurrenciesWithDelegate: self];
	[[G2RepliconServiceManager supportDataService]sendRequestToGetBaseCurrencyWithDelegate: self];
	[[G2RepliconServiceManager supportDataService]sendRequestToGetAllTaxeCodesWithDelegate: self];
	
	
	totalRequestsSent+=5;
//	ProjectPermissionType projPermissionType = [PermissionsModel getProjectPermissionType];
//	if (projPermissionType == PermType_Both || projPermissionType == PermType_ProjectSpecific)
//	{
//		[[RepliconServiceManager expensesService] sendRequestTogetExpenseProjectsWithProjectRelatedClients:self];
//		totalRequestsSent++;
//	}
	
	//if (projPermissionType != PermType_ProjectSpecific) {
		totalRequestsSent++;
		[[G2RepliconServiceManager expensesService]sendRequestToGetExpenseTypesWithTaxCodesWithQueryType:@"ExpenseTypeAll" WithDomain:@"Replicon.Expense.Domain.ExpenseType"  withProjectIDs:nil WithDelegate:self];
	//}
}

-(void)addObserverForExpensesAction
{
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(showListOfExpenseSheets) 
												 name: @"allRequestsServed"
											   object: nil];
}

-(void)removeObserverForExpensesAction
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"allRequestsServed" object:nil];
}

-(void)requestModifiedSheetsFromLastSuccessfulDownloadDate:(NSDate*)lastUpdatedDate
{
	[self sendRequestToGetModifiedExpenseSheetsFromDate:lastUpdatedDate withDelegate:self];
    //FIX FOR DE3601
/*    NSMutableArray *clientsArr= [expensesModel getExpenseClientsFromDatabase];
    NSString *clientName =[[clientsArr objectAtIndex:0] objectForKey:@"name"];
    if (([clientsArr count] == 1 && [clientName isEqualToString:NONE_STRING])||[clientsArr count]==0) {
        [[RepliconServiceManager expensesService]sendRequestToGetExpenseClients:self];
//        ProjectPermissionType projPermissionType = [PermissionsModel getProjectPermissionType];
//        if (projPermissionType == PermType_Both || projPermissionType == PermType_ProjectSpecific)
//        {
//            [[RepliconServiceManager expensesService] sendRequestTogetExpenseProjectsWithProjectRelatedClients:self];
//            totalRequestsSent+=1;
//        }
        
        totalRequestsSent +=1;
    }
*/
	totalRequestsSent ++;
}
//ravi - Moving the request and response handling from HomeViewController to ExpenseService
-(void) fetchExpenseSheetData
{
	totalRequestsSent++;
	[[G2RepliconServiceManager expensesService]sendRequestForMergedExpenseAPIWithDelegate:self];
	

	
}


-(void)showListOfExpenseSheets {
    @autoreleasepool {
     //[NSThread sleepForTimeInterval:1];
		NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [G2SupportDataModel updateLastSyncDateForServiceId:EXPENSES_DATA_SERVICE_SECTION];
		if ([standardUserDefaults objectForKey:EXPENSE_DATA_CAN_RUN]!=nil && [[standardUserDefaults objectForKey:EXPENSE_DATA_CAN_RUN] intValue]==1) {
			
			[standardUserDefaults removeObjectForKey:EXPENSE_DATA_CAN_RUN];
		}
		
		if ([standardUserDefaults objectForKey:EXPENSE_SUPPORT_DATA_CAN_RUN]!=nil && [[standardUserDefaults objectForKey:EXPENSE_SUPPORT_DATA_CAN_RUN] intValue]==1) {
			[G2SupportDataModel updateLastSyncDateForServiceId:EXPENSES_SUPPORT_DATA_SECTION];
			[standardUserDefaults removeObjectForKey:EXPENSE_SUPPORT_DATA_CAN_RUN];
		}
		
		
		[self removeObserverForExpensesAction];
		//NSNumber *expenseTabIndex = [[[NSUserDefaults standardUserDefaults] objectForKey: @"SupportedModules"] objectForKey: @"Expenses_Module"];
    NSMutableArray *modulesArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"TabBarModulesArray"];
		NSUInteger tabIndex = [modulesArray indexOfObject:@"Expenses_Module"];
		[[[UIApplication sharedApplication] delegate] 
					performSelector: @selector(flipToTabbarController:) 
					withObject: [NSNumber numberWithUnsignedInteger:tabIndex]];
		//[[[UIApplication sharedApplication]delegate]performSelector:@selector(flipToTabbarController)];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	}
}

- (void) serverDidRespondWithResponse:(id) response {
	totalRequestsServed++;	
	
	if (response!=nil) {
		NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
		
		if ([status isEqualToString:@"OK"]) {
			NSNumber *_serviceId=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
			
			if ([_serviceId intValue]== ExpenseByUser_ServiceID_3) {
				[self processExpenseByUserResponse: response];
				
			}else if ([_serviceId intValue] == ExpenseProjectsTypesWithTaxs_ServiceID_22) {
				NSArray *responseArray = [[response objectForKey: @"response"]objectForKey: @"Value"];
				if (responseArray != nil && [responseArray count] != 0) {
					[self handlesExpenseProjectTypesWithTaxsResponse: responseArray];					
				}
			}else if ([_serviceId intValue] == ExpenseAllTypesWithTaxes_ServiceID_23) {
				NSArray *responseArray = [[response objectForKey: @"response"] objectForKey: @"Value"];
				if (responseArray != nil && [responseArray count] != 0) {
					[self handlesExpenseAllTypesWithTaxsResponse: responseArray];
				}
			}else if ([_serviceId intValue] == ExpenseClients_ServiceID_5) {
				NSArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
				if (responseArray!=nil && [responseArray count]!=0) {
					[self handleExpenseClientsResponse:responseArray];
				}else {
					[expensesModel insertExpenseClientsInToDatabase:responseArray];					
				}
                               
                [[NSNotificationCenter defaultCenter] postNotificationName:PROJECTSBYCLIENTS_FINSIHED_DOWNLOADING object:nil];
			}
			else if ([_serviceId intValue] == ExpenseProjects_ServiceID_6) {
				totalRequestsServed--;
				NSArray *responseArray = [[response objectForKey: @"response"]objectForKey: @"Value"];
				if (responseArray != nil && [responseArray count] != 0) {
					[self handleExpenseProjectsResponseForRecent:responseArray];
					
				}else {
					[self handleExpenseProjectsResponseForRecent:responseArray];
				}
                return;
			}else if ([_serviceId intValue] == ExpenseProjectsByClient_ServiceID_7) {
                
                
                 [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:IS_NO_MORE_PROJECTS_AVAILABLE_KEY];
                
				NSMutableArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
				if (responseArray!=nil && [responseArray count]!=0) {
//					[self handleExpenseProjectsByClientID: [[response objectForKey:@"refDict"]objectForKey:@"params"] withResponse:responseArray];
                        
                    
                    NSDictionary *responseDict=[responseArray objectAtIndex:0];
                    
                    NSString *queryhandler=[NSString stringWithFormat:@"%@",[responseDict objectForKey:@"Identity"] ];
                    
                    NSString *clientID=nil;
                    NSString *startIndex=nil;
                    if (queryhandler!=nil)
                    {
                        [responseArray removeObjectAtIndex:0];
                        
                        clientID=[NSString stringWithFormat:@"%@",[[[response objectForKey:@"refDict"]objectForKey:@"params"]objectForKey:@"ClientID"]];
                       startIndex=[NSString stringWithFormat:@"%@",[[[response objectForKey:@"refDict"]objectForKey:@"params"]objectForKey:@"startIndex"]];
                        
                    }
                    
                   if (responseArray!=nil && [responseArray count]!=0)
                   {
                       NSUInteger index = [startIndex intValue]+[responseArray count];
                       [self handleExpenseProjectsResponse:responseArray];
                       [expensesModel updateQueryHandleByClientId:clientID andQueryHandle:queryhandler andStartIndex:[NSString stringWithFormat:@"%d",(int)index]];
                       
                       if ([responseArray count]<[[[G2AppProperties getInstance]getAppPropertyFor:@"PaginatedProjectsClients"]intValue])
                       {
                           [[NSNotificationCenter defaultCenter] postNotificationName:PROJECTSBYCLIENTS_FINSIHED_DOWNLOADING object:[NSNumber numberWithBool:TRUE]];
                       }
                       else
                       {
                          [[NSNotificationCenter defaultCenter] postNotificationName:PROJECTSBYCLIENTS_FINSIHED_DOWNLOADING object:[NSNumber numberWithBool:FALSE]];
                       }
                   }

                   else
                   {
                      
                      [[NSNotificationCenter defaultCenter] postNotificationName:PROJECTSBYCLIENTS_FINSIHED_DOWNLOADING object:[NSNumber numberWithBool:TRUE]];
                    
                   }
                    
                    
				}
                
               
                
                return;
			}
			else if ([_serviceId intValue] == TaxCodeAll_ServiceID_13) {
				
				NSArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
				if (responseArray!=nil && [responseArray count]!=0) {
					[self handleTaxCodeAllResponse:responseArray];
				}
				
			}else if ([_serviceId intValue] == SystemPaymentMethods_ServiceID_21) {
				
				NSArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
				if (responseArray!=nil && [responseArray count]!=0) {
					[self handleSystemPayMethodsResponse:responseArray];
				}
			}
			else if ([_serviceId intValue] == ReimbursementCurrencies_17) {
				
				NSArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
				if (responseArray!=nil && [responseArray count]!=0) {
					[self handleSystemCurrenciesResponse:responseArray];
				}
			}
			else if ([_serviceId intValue] == BaseCurrencies_ServiceID_18) {
				NSArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
				if (responseArray!=nil && [responseArray count]!=0) {
					[self handleBaseCurrenciesResponse:responseArray];
				}		
			}else if ([_serviceId intValue] == FetchNextRecentExpenseSheets_26) {
				NSArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
				if (responseArray!=nil && [responseArray count]!=0) {
					[self handleNextRecentExpenseSheetsResponse:responseArray];
				}
			}else if ([_serviceId intValue] == ExpenseSheetsExisted_Service_Id_64) {
				NSArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
				if (responseArray!=nil && [responseArray count]!=0) {
					[self handleExistedSheetsResponse:responseArray];
				}
			}
			else if ([_serviceId intValue] == ExpenseSheetsModifiedFromLastUpdatedTime_Service_Id_60) {
				
				[self sendRequestForExistedSheets:self];
				totalRequestsSent++;
					NSArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
					if (responseArray!=nil && [responseArray count]!=0) 
						[self handleModifiedSheetsResponse:responseArray];
			}else if ([_serviceId intValue] == UDF_ServiceID_16) {
				NSArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
				if (responseArray!=nil && [responseArray count]!=0) {
					[self handleUDFSettingsResponse:responseArray];
				}else {
					[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
				}
			}
            else if ([_serviceId intValue] == ExpenseTypesByID_94) {
				NSArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
				if (responseArray!=nil && [responseArray count]!=0) {
					[self handlesExpenseTypesIDResponse:responseArray];
				}else {
					[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
				}
			}
            
            else if ([_serviceId intValue] == MergedExpensesAPI_95) {
				NSArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
				if (responseArray!=nil && [responseArray count]!=0)
                {
					
                    [self handleExpenseMergedResponseWithObject:responseArray];
                    
                    
				}else {
                    [self sendRequestForExistedSheets:self];
                    totalRequestsSent++;
					//[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
				}
                //return;
			}
		}else {
			NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
//			[Util errorAlert:status errorMessage:message];
			[G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
            
			if ([[NSUserDefaults standardUserDefaults]objectForKey:@"isExpensesDataFailed"]!=nil) {
				[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:EXPENSE_SUPPORT_DATA_CAN_RUN];
                [[NSUserDefaults standardUserDefaults] synchronize];
				[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isExpensesDataFailed"];
			}else {
				[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:EXPENSE_SUPPORT_DATA_CAN_RUN];
                [[NSUserDefaults standardUserDefaults] synchronize];
			}
		}
	}
	
	//added below condition to check if all requests are served
	if (totalRequestsServed == totalRequestsSent)
    {
       
        
		[[NSNotificationCenter defaultCenter] postNotificationName:@"allRequestsServed" object:nil];
	}
}

///ended by
- (void) serverDidFailWithError:(NSError *) error {
	totalRequestsServed++;
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
	}
	//connectionFailedCount+1;
//	if (connectionFailedCount==1)//To show failed error only once regardless of how many requests failed....
		if (totalRequestsServed == totalRequestsSent)
		{
			if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
				[G2Util showOfflineAlert];
				return;
			}
            [self showErrorAlert:error];
			
            return;
		}
	
     [self showErrorAlert:error];
    
if ([[NSUserDefaults standardUserDefaults]objectForKey:@"isExpensesDataFailed"]!=nil) {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:EXPENSE_DATA_CAN_RUN];
    [[NSUserDefaults standardUserDefaults]  synchronize];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isExpensesDataFailed"];
}else {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:EXPENSE_SUPPORT_DATA_CAN_RUN];
    [[NSUserDefaults standardUserDefaults] synchronize]; 
}

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==SAML_SESSION_TIMEOUT_TAG)
    {
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(launchWebViewController)];
    }
}

-(void)showErrorAlert:(NSError *) error
{
    RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (!appdelegate.isAlertOn) 
    {
        if ([appdelegate.errorMessageForLogging isEqualToString:SESSION_EXPIRED]) {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
            {
                UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED)
                                                                          delegate:self cancelButtonTitle:RPLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
                [confirmAlertView setDelegate:self];
                [confirmAlertView setTag:SAML_SESSION_TIMEOUT_TAG];
                [confirmAlertView show];
                
            }
            else 
            {
                            [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED) ];
            }

        }
        else  if ([appdelegate.errorMessageForLogging isEqualToString:G2PASSWORD_EXPIRED]) {
            [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(G2PASSWORD_EXPIRED, G2PASSWORD_EXPIRED) ];
            [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
        }
        else
        {
            [G2Util errorAlert:RPLocalizedString( @"Connection failed",@"") errorMessage:[error localizedDescription]];
        }
        
    }
    //US1132 Issue 4:
    if ([appdelegate.errorMessageForLogging isEqualToString:SESSION_EXPIRED] ||  [appdelegate.errorMessageForLogging isEqualToString:G2PASSWORD_EXPIRED]) 
    {
        appdelegate.isAlertOn=TRUE;
    }
    else
    {
        appdelegate.isAlertOn=FALSE;
    }
    
}


-(void) processExpenseByUserResponse: (NSMutableArray *)expensesArray
{
	@try {
		
		
		G2SQLiteDB *myDB =[G2SQLiteDB getInstance];
		
		
		NSString *queryUdfs=[NSString stringWithFormat:@"delete from entry_udfs where entry_id not in(select identity from expense_entries where isModified=1) and entry_type = 'Expense'  "];
		[myDB executeQuery:queryUdfs];
		
		NSString *queryEntries=[NSString stringWithFormat:@"delete from expense_entries where expense_sheet_identity in(select identity from expense_sheets where isModified = 0)"];
		[myDB executeQuery:queryEntries];
		
		NSString *query=[NSString stringWithFormat:@"delete from expense_sheets where isModified = 0 "];
		[myDB executeQuery:query];
		

		NSArray *_expensesFromDB = [expensesModel getExpenseSheetsFromDataBase];
		NSMutableArray *_entriesFromDB = [expensesModel getExpenseEntriesFromDatabase];
		
		if(_expensesFromDB == nil)	{
			DLog(@"Error: There are no expenses in DB");
		}
		[[NSUserDefaults standardUserDefaults] setObject: _expensesFromDB forKey: @"expenseSheetsArray"];
		[[NSUserDefaults standardUserDefaults] setObject: _entriesFromDB forKey: @"expenseEntriesArray"];
		 [[NSUserDefaults standardUserDefaults] synchronize]; 
		if (expensesArray != nil && [expensesArray count] > 1) {
			NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
			[standardUserDefaults setObject:[expensesArray objectAtIndex:0] forKey:@"QueryHandler"];
			 [standardUserDefaults synchronize]; 
			[expensesArray removeObjectAtIndex:0];
			
			//Added this in jocata sprint to remove entries and sheets fro multi user login.............
			
			
			[expensesModel insertExpenseSheetsInToDataBase:expensesArray];
            [expensesModel insertExpenseEntriesInToDataBase:expensesArray];
            [expensesModel insertUdfsforEntryIntoDatabase:expensesArray];
            
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"allRequestsServed" object:nil];
            [standardUserDefaults setObject:[NSNumber numberWithUnsignedInteger:[expensesArray count]] forKey:@"nextRecentResponseCount"];
			[standardUserDefaults synchronize];
            
			NSArray *_expensesFromDB = [expensesModel getExpenseSheetsFromDataBase];
			
			if(_expensesFromDB == nil)	{
				DLog(@"Error: There are no expenses in DB");
			}
			[standardUserDefaults setObject: _expensesFromDB forKey: @"expenseSheetsArray"];
			[standardUserDefaults synchronize];
			if ([expensesArray count]>=1) {
				[self handleExpenseByUserResponse:expensesArray];
			}
            
          [NSThread detachNewThreadSelector: @selector(showListOfExpenseSheets) toTarget:self withObject:nil];
            
            ProjectPermissionType projPermissionType = [G2PermissionsModel getProjectPermissionType];
            if (projPermissionType == PermType_Both || projPermissionType == PermType_ProjectSpecific)
            {
                NSMutableArray *projectIdsArr=[NSMutableArray array];
                for (int i=0; i<[expensesArray count]; i++) {
                    NSDictionary *_expense = [expensesArray objectAtIndex:i];
                    NSArray *_expEntries = [[_expense objectForKey:@"Relationships"]objectForKey:@"Entries"];
                    for (int j=0; j<[_expEntries count]; j++) {
                        
                        NSDictionary *_entry = [_expEntries objectAtIndex: j];
                        id projectsDict = [[_entry objectForKey:@"Relationships"]objectForKey:@"Project"];
                        if([projectsDict isKindOfClass:[NSDictionary class]])
                        {
                            NSString *projectIdentity=[projectsDict objectForKey:@"Identity"];
                            [projectIdsArr addObject:projectIdentity];
                        }
                    }
                }
            
                
                if (projectIdsArr!=nil)
                {
                    if ([projectIdsArr count]>0)
                    {
                        [[G2RepliconServiceManager expensesService] sendRequestTogetExpenseProjectsWithProjectRelatedClients:self withProjectIds:projectIdsArr];
//                        totalRequestsSent++;
                    }
                }
                
                
            }
			
			
/*			if ([expensesModel isApprovedExpenseSheetsAvailable] == NO) {
				//ravi - We can get the details from the _expensesFromDB instead of reading from the userdefaults
				if([_expensesFromDB count] == [[[[response objectForKey:@"refDict"]objectForKey:@"params"]objectForKey:@"limitedCount"]intValue])
				{
					totalRequestsSent++;
					NSDictionary *_queryHandler = [standardUserDefaults objectForKey:@"QueryHandler"];
					
					if (_queryHandler == nil) {
						DLog(@"Error: Query Handler is nil");
					}
					[[RepliconServiceManager expensesService]sendRequestToFetchNextRecentExpenseSheets:[_queryHandler objectForKey:@"Identity"]
																						withStartIndex:[NSNumber numberWithInt: [_expensesFromDB count]]
																						withLimitCount:[[AppProperties getInstance]getAppPropertyFor:@"NextRecentExpenseSheetsCount"]
																						  withDelegate:self];
				}
			}
*/
            
		}
        else {
			[self handleExpenseByUserResponse:expensesArray];
		}
	}
	@catch (NSException * e) {
		DLog(@"Exception processing ExpenseByUser Response: %@", e);
	}
	@finally {
		
	}
}


-(void)handleExpenseMergedResponseWithObject:(NSArray *)responseArray
{
    
    NSMutableArray *expenseByUserResponseArr=[NSMutableArray array];
    NSMutableArray *udfsResponseArr=[NSMutableArray array];
    NSMutableArray *paymentMethodResponseArr=[NSMutableArray array];
    NSMutableArray *currencyResponseArr=[NSMutableArray array];
    NSMutableArray *taxCodeResponseArr=[NSMutableArray array];
    NSMutableArray *clientResponseArr=[NSMutableArray array];
     NSMutableArray *expenseTypeResponseArr=[NSMutableArray array];
  
    for (int i=0; i<[responseArray count]; i++)
    {
        NSDictionary *responseDict=[responseArray objectAtIndex:i];
        NSString *responseType=[responseDict objectForKey:@"Type"];
        
        if ([responseType isEqualToString:@"Replicon.Expense.Domain.Expense"] || [responseType isEqualToString:@"QueryHandle"])
        {
            [expenseByUserResponseArr addObject:responseDict];
        }
        else if ([responseType isEqualToString:@"Replicon.Domain.UserDefinedFields.Definition.UserDefinedFieldGroup"])
        {
            [udfsResponseArr addObject:responseDict];
        }
        else if ([responseType isEqualToString:@"Replicon.Expense.Domain.PaymentMethod"])
        {
            [paymentMethodResponseArr addObject:responseDict];
        }
        else if ([responseType isEqualToString:@"Replicon.Domain.Currency"])
        {
            [currencyResponseArr addObject:responseDict];
        }
        else if ([responseType isEqualToString:@"Replicon.Domain.Currency"])
        {
            [currencyResponseArr addObject:responseDict];
        }
        else if ([responseType isEqualToString:@"Replicon.Expense.Domain.TaxCode"])
        {
            [taxCodeResponseArr addObject:responseDict];
        }
        else if ([responseType isEqualToString:@"Replicon.Domain.Client"])
        {
            [clientResponseArr addObject:responseDict];
        }
        else if ([responseType isEqualToString:@"Replicon.Expense.Domain.ExpenseType"])
        {
            [expenseTypeResponseArr addObject:responseDict];
        }

    }
    if([udfsResponseArr count]>0)
    {
        [self performSelector:@selector(handleUDFSettingsResponse:) withObject:udfsResponseArr];
    }
    if(![[NSUserDefaults standardUserDefaults] objectForKey:EXPENSE_DATA_CAN_RUN])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:EXPENSE_DATA_CAN_RUN];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self sendRequestForExistedSheets:self];
        totalRequestsSent++;
        [self performSelector:@selector(handleModifiedSheetsResponse:) withObject:expenseByUserResponseArr];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"allRequestsServed" object:nil];
         //[NSThread detachNewThreadSelector: @selector(showListOfExpenseSheets) toTarget:self withObject:nil];
    }
    
    else if([[NSUserDefaults standardUserDefaults] objectForKey:EXPENSE_DATA_CAN_RUN])
    {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:EXPENSE_DATA_CAN_RUN];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self performSelector:@selector(processExpenseByUserResponse:) withObject:expenseByUserResponseArr];
       // [[NSNotificationCenter defaultCenter] postNotificationName:@"allRequestsServed" object:nil];
         
    }
    else
    {
        [self sendRequestForExistedSheets:self];
        totalRequestsSent++;
    }
   
    if([paymentMethodResponseArr count]>0)
    {
        [self performSelector:@selector(handleSystemPayMethodsResponse:) withObject:paymentMethodResponseArr];
    }
    if([currencyResponseArr count]>0)
    {
        [self performSelector:@selector(handleBaseCurrenciesResponse:) withObject:[currencyResponseArr objectAtIndex:[currencyResponseArr count]-1]];
        [currencyResponseArr removeLastObject];
        if([currencyResponseArr count]>0)
        {
            [self performSelector:@selector(handleSystemCurrenciesResponse:) withObject:currencyResponseArr];
        }
       
    }
    if([taxCodeResponseArr count]>0)
    {
         [self performSelector:@selector(handleTaxCodeAllResponse:) withObject:taxCodeResponseArr];
    }
    if([clientResponseArr count]>0)
    {
        [self performSelector:@selector(handleExpenseClientsResponse:) withObject:clientResponseArr];
    }
    if([expenseTypeResponseArr count]>0)
    {
        [self performSelector:@selector(handlesExpenseAllTypesWithTaxsResponse:) withObject:expenseTypeResponseArr];
    }
   
    
    
}

-(void)handleExpenseByUserResponse:(id) response {
	
	/*ProjectPermissionType projPermissionType = [PermissionsModel getProjectPermissionType];
	
	if (projPermissionType == PermType_NonProjectSpecific) {
		totalRequestsSent++;
		[[RepliconServiceManager expensesService]sendRequestToGetExpenseTypesWithTaxCodesWithQueryType:@"ExpenseTypeAll" WithDomain:@"Replicon.Expense.Domain.ExpenseType" WithDelegate:self];
	}else if (projPermissionType == PermType_Both){
		totalRequestsSent++;
		[[RepliconServiceManager expensesService]sendRequestToGetExpenseTypesWithTaxCodesWithQueryType:@"ExpenseTypeAll" WithDomain:@"Replicon.Expense.Domain.ExpenseType" WithDelegate:self];
	}*/
}

-(void)handlesExpenseProjectTypesWithTaxsResponse:(id)response{
//	ProjectPermissionType projPermissionType = [PermissionsModel getProjectPermissionType];
	
	[expensesModel insertExpenseProjectSpecificTypesWithTaxCodesInToDatabase:response];
    
    G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
	NSString *identity = @"null";
    NSMutableArray *expenseTypesIdsArr=[NSMutableArray array];
    for (int i = 0; i<[(NSMutableArray *)response count]; i++)
    {
        NSArray *expenseTypeArray = [NSArray arrayWithArray:[[[response objectAtIndex:i] objectForKey:@"Relationships"] objectForKey:@"ExpenseTypes"]];
        for (int j = 0; j<[expenseTypeArray count]; j++) {
            identity = [[expenseTypeArray objectAtIndex:j] objectForKey:@"Identity"];
            NSString *placeString=[NSString stringWithFormat:@"identity='%@'",identity];
            NSMutableArray *expenseArr = [myDB select:@"*" from: @"expenseTypes" where:placeString intoDatabase:@""];
            if ([expenseArr count]==0)
            {
                [expenseTypesIdsArr addObject:identity];
            }
        }
        
       
    }
    
//     BOOL expenseSupportDataCanRun = [Util shallExecuteQuery:EXPENSES_SUPPORT_DATA_SECTION];
    
    if ([expenseTypesIdsArr count]>0)
    {
        [self sendRequestToGetExpenseTypesByIds:expenseTypesIdsArr WithDelegate:self];
        totalRequestsSent++;
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:EXPENSETYPES_FINSIHED_DOWNLOADING object:nil];
    }
/*    else if (projPermissionType == PermType_ProjectSpecific)
    {
        
        if(!expenseSupportDataCanRun)
        {
             [[NSNotificationCenter defaultCenter] postNotificationName:PROJECTSBYCLIENTS_FINSIHED_DOWNLOADING object:[NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:IS_NO_MORE_PROJECTS_AVAILABLE_KEY]]];
            [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:IS_NO_MORE_PROJECTS_AVAILABLE_KEY];
        }
       
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:PROJECTSBYCLIENTS_FINSIHED_DOWNLOADING object:[NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:IS_NO_MORE_PROJECTS_AVAILABLE_KEY]]];
         [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:IS_NO_MORE_PROJECTS_AVAILABLE_KEY];
    }
*/	 

}

-(void)handlesExpenseTypesIDResponse:(id)response
{
    if ([(NSMutableArray *)response count]>0 && response!=nil)
    {
         [expensesModel insertExpenseTypesWithTaxCodesInToDatabase:response];
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:PROJECTSBYCLIENTS_FINSIHED_DOWNLOADING object:[NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:IS_NO_MORE_PROJECTS_AVAILABLE_KEY]]];
//    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:IS_NO_MORE_PROJECTS_AVAILABLE_KEY];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EXPENSETYPES_FINSIHED_DOWNLOADING object:nil];

}

-(void)handlesExpenseAllTypesWithTaxsResponse:(id)response{
	
	//DLog(@"RESPONSE FOR TYPES %@",response);
//	ProjectPermissionType projPermissionType = [PermissionsModel getProjectPermissionType];
	[expensesModel insertExpenseNonProjectSpecificTypesWithTaxCodesInToDatabase:response];
//	if (projPermissionType == PermType_Both || projPermissionType == PermType_ProjectSpecific) {
//		totalRequestsSent++;
//		[[RepliconServiceManager expensesService]sendRequestToGetExpenseClients:self];
//	}
}

-(void)handleExpenseClientsResponse:(id)response{
	[expensesModel insertExpenseClientsInToDatabase:response];

	NSArray *clientsArray=[expensesModel getExpenseClientsFromDatabase];

	if (clientsArray!=nil && [clientsArray count]!=0) {
		for (int i=0; i<[clientsArray count]; i++) {
			NSString *clientId=[[clientsArray objectAtIndex:i] objectForKey:@"identity"];
			if (![clientId isEqualToString:@"null"]) {
				//[[RepliconServiceManager expensesService]sendRequestToGetExpenseProjectsByClient:clientId withDelegate:self];
			}
		}
	}
}

-(void)handleExpenseProjectsResponseForRecent:(id)response{
    [expensesModel insertExpenseProjectsInToDatabase:response withBoolValue:TRUE];
   

}

-(void)handleExpenseProjectsResponse:(id)response{
//	ProjectPermissionType projPermissionType = [PermissionsModel getProjectPermissionType];

	[expensesModel insertExpenseProjectsInToDatabase:response withBoolValue:FALSE];
    
    
    /*
	if (projPermissionType == PermType_ProjectSpecific || projPermissionType == PermType_Both)	{
		//NSMutableArray *projectsArray=[expensesModel getExpenseProjectsFromDatabase];//if projects available then fetch project expenseTypes......
		if ( response!=nil  && [response count]>0) {
			totalRequestsSent++;
            NSMutableArray *projIdsArr=[NSMutableArray array];
            
            for (int i=0; i<[response count]; i++)
            {
                NSString *projectIdentity=[[response objectAtIndex:i]objectForKey:@"Identity"];
                if(projectIdentity!=nil && ![projectIdentity isKindOfClass:[NSNull class]] && ![projectIdentity isEqualToString:NULL_STRING] & ![projectIdentity isEqualToString:@"null"])
                {
                    [projIdsArr addObject:[[response objectAtIndex:i]objectForKey:@"Identity"]];
                }
                                             
            }
                
            
            if ([projIdsArr count]>0)
            {
                
                if ([response count]<[[[AppProperties getInstance]getAppPropertyFor:@"PaginatedProjectsClients"]intValue])
                {
                    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:IS_NO_MORE_PROJECTS_AVAILABLE_KEY];
                }
                else
                {
                     [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:IS_NO_MORE_PROJECTS_AVAILABLE_KEY];
                }

                
                
                [[RepliconServiceManager expensesService]sendRequestToGetExpenseTypesWithTaxCodesWithQueryType:@"ProjectByIds" WithDomain:@"Replicon.Project.Domain.Project"  withProjectIDs:projIdsArr  WithDelegate:self];
            }
            else
            {
                
              
                
                if ([response count]<[[[AppProperties getInstance]getAppPropertyFor:@"PaginatedProjectsClients"]intValue])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:PROJECTSBYCLIENTS_FINSIHED_DOWNLOADING object:[NSNumber numberWithBool:TRUE]];
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:PROJECTSBYCLIENTS_FINSIHED_DOWNLOADING object:nil];
                }

                
            }
			
		}
	}
     
     */
}

-(void)handleExpenseProjectsByClientID:(NSString*)clientID  withResponse:(id)response{	
	[expensesModel insertExpenseProjectsByClient:response clientID:clientID];
}

-(void)handleTaxCodeAllResponse:(id)response{	
	[supportDataModel insertTaxCodesAllInToDatabase:response];
}

-(void)handleSystemPayMethodsResponse:(id) response{
	[supportDataModel insertPaymentMethodsAll:response];	
}

-(void)handleSystemCurrenciesResponse:(id) response{
	[supportDataModel insertSystemCurrenciesToDatabase:response];
}

-(void)handleBaseCurrenciesResponse:(id) response {
	[supportDataModel insertBaseCurrencyToDatabase:response];
}

-(void)handleNextRecentExpenseSheetsResponse:(id)response{
	[expensesModel insertExpenseSheetsInToDataBase:response];
	[expensesModel insertExpenseEntriesInToDataBase:response];
    [expensesModel insertUdfsforEntryIntoDatabase:response];//DE8266 Ullas M L
	NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
	[standardUserDefaults setObject:[NSNumber numberWithUnsignedInteger:[(NSMutableArray *)response count]] forKey:@"nextRecentResponseCount"];
	[standardUserDefaults setObject:[expensesModel getExpenseSheetsFromDataBase] forKey:@"expenseSheetsArray"];
	[standardUserDefaults setObject:[expensesModel getExpenseEntriesFromDatabase] forKey:@"expenseEntriesArray"];
     [standardUserDefaults synchronize];
    
    ProjectPermissionType projPermissionType = [G2PermissionsModel getProjectPermissionType];
	if (projPermissionType == PermType_Both || projPermissionType == PermType_ProjectSpecific)
	{
        
        
        ProjectPermissionType projPermissionType = [G2PermissionsModel getProjectPermissionType];
        if (projPermissionType == PermType_Both || projPermissionType == PermType_ProjectSpecific)
        {
            NSMutableArray *projectIdsArr=[NSMutableArray array];
            for (int i=0; i<[(NSMutableArray *)response count]; i++) {
                NSDictionary *_expense = [response objectAtIndex:i];
                NSArray *_expEntries = [[_expense objectForKey:@"Relationships"]objectForKey:@"Entries"];
                for (int j=0; j<[_expEntries count]; j++) {
                    
                    NSDictionary *_entry = [_expEntries objectAtIndex: j];
                    id projectsDict = [[_entry objectForKey:@"Relationships"]objectForKey:@"Project"];
                    if([projectsDict isKindOfClass:[NSDictionary class]])
                    {
                        NSString *projectIdentity=[projectsDict objectForKey:@"Identity"];
                        [projectIdsArr addObject:projectIdentity];
                    }
                }
            }
            if (projectIdsArr!=nil)
            {
                if ([projectIdsArr count]>0)
                {
                    [[G2RepliconServiceManager expensesService] sendRequestTogetExpenseProjectsWithProjectRelatedClients:self withProjectIds:projectIdsArr];
                   // totalRequestsSent++;
                }
            }

        }
        
               

	}
}

-(void)handleModifiedSheetsResponse:(id)response{  
		[expensesModel insertExpenseSheetsInToDataBase:response];
		[expensesModel insertExpenseEntriesInToDataBase:response];
		[expensesModel insertUdfsforEntryIntoDatabase:response];
		NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
		[standardUserDefaults setObject:[expensesModel getExpenseSheetsFromDataBase] forKey:@"expenseSheetsArray"];
		[standardUserDefaults setObject:[expensesModel getExpenseEntriesFromDatabase] forKey:@"expenseEntriesArray"];
     [standardUserDefaults synchronize];
    
    [NSThread detachNewThreadSelector: @selector(showListOfExpenseSheets) toTarget:self withObject:nil];
    
    ProjectPermissionType projPermissionType = [G2PermissionsModel getProjectPermissionType];
	if (projPermissionType == PermType_Both || projPermissionType == PermType_ProjectSpecific)
	{
        
        

            NSMutableArray *projectIdsArr=[NSMutableArray array];
            for (int i=0; i<[(NSMutableArray *)response count]; i++) {
                NSDictionary *_expense = [response objectAtIndex:i];
                NSArray *_expEntries = [[_expense objectForKey:@"Relationships"]objectForKey:@"Entries"];
                for (int j=0; j<[_expEntries count]; j++) {
                    
                    NSDictionary *_entry = [_expEntries objectAtIndex: j];
                    id projectsDict = [[_entry objectForKey:@"Relationships"]objectForKey:@"Project"];
                    if([projectsDict isKindOfClass:[NSDictionary class]])
                    {
                        NSString *projectIdentity=[projectsDict objectForKey:@"Identity"];
                        [projectIdsArr addObject:projectIdentity];
                    }
                }
            }
            if (projectIdsArr!=nil)
            {
                if ([projectIdsArr count]>0)
                {
                    [[G2RepliconServiceManager expensesService] sendRequestTogetExpenseProjectsWithProjectRelatedClients:self withProjectIds:projectIdsArr];
                   // totalRequestsSent++;
                }
            }
            
        
        
        
        
	}
}	
	
-(void)handleUDFSettingsResponse:(id)response {
	[supportDataModel insertUserDefinedFieldsToDatabase:response moduleName:@"Expense"];
	[supportDataModel insertDropDownOptionsToDatabase:response];
	
}

-(void)handleExistedSheetsResponse:(id)responseArray
{
	[expensesModel removeWtsDeletedSheetsFromDB:responseArray];
	NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
	[standardUserDefaults setObject:[expensesModel getExpenseSheetsFromDataBase] forKey:@"expenseSheetsArray"];
	[standardUserDefaults setObject:[expensesModel getExpenseEntriesFromDatabase] forKey:@"expenseEntriesArray"];
    [standardUserDefaults synchronize]; 
}

-(void)terminateService
{
	[self terminateAsyncronousService];
}

-(void)sendRequsetWithTimeOutValue:(int)timeOutVal
{
	[self executeRequestWithTimeOut:timeOutVal];
}

-(void)downloadExpenseTypesByProjectSelectionwithId:(NSString *)projectIdentity
{
    ProjectPermissionType projPermissionType = [G2PermissionsModel getProjectPermissionType];
    if (projPermissionType == PermType_ProjectSpecific || projPermissionType == PermType_Both)	{
		//NSMutableArray *projectsArray=[expensesModel getExpenseProjectsFromDatabase];//if projects available then fetch project expenseTypes......
		
        totalRequestsSent++;
        NSMutableArray *projIdsArr=[NSMutableArray arrayWithObjects:projectIdentity, nil];
        
        
        if ([projIdsArr count]>0)
        {
            
            
            [[G2RepliconServiceManager expensesService]sendRequestToGetExpenseTypesWithTaxCodesWithQueryType:@"ProjectByIds" WithDomain:@"Replicon.Project.Domain.Project"  withProjectIDs:projIdsArr  WithDelegate:self];
        }
                
		
	}
}


@end
