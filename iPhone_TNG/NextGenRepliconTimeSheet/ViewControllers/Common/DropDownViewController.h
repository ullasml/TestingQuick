//
//  DropDownViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 15/05/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol UpdateDropDownFieldProtocol;
@interface DropDownViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
   
    NSMutableArray *dropDownOptionList;
    UITableView *dropDownOptionTableView;
    id <UpdateDropDownFieldProtocol> __weak entryDelegate;
    NSMutableArray *arrayOfCharacters;
    NSMutableDictionary *objectsForCharacters;
    
    NSString *dropDownUri;
   

    NSString *selectedDropDownString;
    

    
}
@property (nonatomic,strong)NSString *dropDownName;
@property (nonatomic,strong)NSMutableArray *dropDownOptionList;
@property (nonatomic,strong)UITableView *dropDownOptionTableView;
@property(nonatomic,weak) id <UpdateDropDownFieldProtocol>entryDelegate;
@property(nonatomic,strong)NSMutableArray *arrayOfCharacters;
@property(nonatomic,strong)NSMutableDictionary *objectsForCharacters;
@property (nonatomic,strong)NSString *dropDownUri;
@property(nonatomic,assign)BOOL isGen4Timesheet;
-(void)createDropDownOptionList;
@property(nonatomic,strong)NSString *selectedDropDownString;
@end


@protocol UpdateDropDownFieldProtocol <NSObject>

-(void)updateDropDownFieldWithFieldName:(NSString*)fieldName andFieldURI:(NSString*)fieldUri;
@end