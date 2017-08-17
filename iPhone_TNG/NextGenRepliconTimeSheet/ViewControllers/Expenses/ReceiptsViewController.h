//
//  ReceiptsViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta R on 26/03/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"ExpenseModel.h"
#import "Constants.h"
#import "Util.h"
#import "FrameworkImport.h"
@interface ReceiptsViewController : UIViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate,UIScrollViewDelegate> {
	UIImageView *receiptImageView;
    UIScrollView *scrollView;
	
	NSString *sheetId;
	NSString *entryId;
    NSString *receiptName;
	
	id __weak recieptDelegate;
	BOOL inNewEntry;
	NSThread *recThread;
	//id editDelegate;
	NSString *defaultValue;
	
	NSString *receiptURI;
	
	BOOL canNotDelete;
	BOOL isPictureFromCamera;
	NSString *b64String;
    //Impelemnted for Pdf Receipt //JUHI
    UIWebView *receiptWebView;
    NSData *receiptData;
     NSString                *receiptFileType;
}
@property  BOOL canNotDelete;
@property(nonatomic,strong)UIImageView *receiptImageView;
@property(nonatomic,strong)UIScrollView *scrollView;
@property BOOL inNewEntry;
@property(nonatomic,weak)	id recieptDelegate;

@property(nonatomic,strong)	NSString *defaultValue;
@property(nonatomic,strong)	NSString *receiptURI;
@property(nonatomic,strong)	NSString *sheetId;
@property(nonatomic,strong)	NSString *entryId;
@property(nonatomic,strong)	NSString *receiptName;
@property (nonatomic, strong) NSString *b64String;
//Impelemnted for Pdf Receipt //JUHI
@property(nonatomic,strong) UIWebView *receiptWebView;
@property(nonatomic,strong) NSData *receiptData;
@property(nonatomic,strong) NSString *receiptFileType;

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
//Impelemnted for Pdf Receipt //JUHI
-(void)initializeImageView;
-(void)initializeWebViewWithData:(NSData *)pdfData;
@end