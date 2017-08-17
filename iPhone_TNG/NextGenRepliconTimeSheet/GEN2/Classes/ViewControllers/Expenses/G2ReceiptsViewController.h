//
//  ReceiptsViewController.h
//  Replicon
//
//  Created by Manoj  on 03/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"G2ExpensesModel.h"
#import "G2Constants.h"
#import "G2Util.h"
#import "FrameworkImport.h"
@interface G2ReceiptsViewController : UIViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate,UIScrollViewDelegate> {
	UIImageView *receiptImageView;
    UIScrollView *scrollView;
	
	NSString *sheetId;
	NSString *entryId;
	
	id __weak recieptDelegate;
	BOOL inNewEntry;
	NSThread *recThread;
	//id editDelegate;
	NSString *defaultValue;
	
	NSString *sheetStatus;
	
	BOOL canNotDelete;
	BOOL isPictureFromCamera;
	NSString *b64String;
}
@property  BOOL canNotDelete;
@property(nonatomic,strong)UIImageView *receiptImageView;
@property(nonatomic,strong)UIScrollView *scrollView;
@property BOOL inNewEntry;
@property(nonatomic,weak)	id recieptDelegate;

@property(nonatomic,strong)	NSString *defaultValue;
@property(nonatomic,strong)	NSString *sheetStatus;
//@property BOOL isPictureFromCamera;
@property (nonatomic, strong) NSString *b64String;


-(void)deleteAction:(id)sender;
-(void)saveAction:(id)sender;
-(void)confirmAlert:(NSString *)_buttonTitle confirmMessage:(NSString*)message;
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
-(void)pushToEntryView;
-(void)makeMyImageSave;
-(void)setImageOnEditing:(NSData *)decodedImage;
-(void)setImage:(UIImage*)image;
-(void)resetScrollView;
-(void)showErrorAlert:(NSError *) error;
@end