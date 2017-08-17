#import "ImageStripper.h"
#import "JsonWrapper.h"


@implementation ImageStripper

//Strip of Base64 data from a string

+(NSString *)removeImageDataFromString:(NSString *)originalString
{
    NSData *data = [originalString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    NSMutableDictionary *finalDict=[NSMutableDictionary dictionary];

    if (json!=nil && [json isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict=(NSDictionary *)json;
        NSArray *arrKeys=[dict allKeys];


        for (int i=0; i<[arrKeys count]; i++)
        {
            id value=[dict objectForKey:[arrKeys objectAtIndex:i]];

            if (value!=nil && [value isKindOfClass:[NSDictionary class]])
            {
                NSMutableDictionary *valueDict=(NSMutableDictionary *)[value mutableCopy];
                if ([[valueDict allKeys] containsObject:@"auditImage"])
                {
                    if ([valueDict objectForKey:@"auditImage"]!=nil && ![[valueDict objectForKey:@"auditImage"] isKindOfClass:[NSNull class]])
                    {
                        NSMutableDictionary *auditImageDict=[[valueDict objectForKey:@"auditImage"]mutableCopy];
                        if (auditImageDict!=nil)
                        {
                            [auditImageDict setObject:@"Image Data Removed" forKey:@"base64ImageData"];
                            [valueDict setObject:auditImageDict forKey:@"auditImage"];
                        }
                    }

                }
                else if ([[valueDict allKeys] containsObject:@"errors"])
                {
                    if ([valueDict objectForKey:@"errors"]!=nil && ![[valueDict objectForKey:@"errors"] isKindOfClass:[NSNull class]])
                    {
                        NSMutableArray *errorArr=[[valueDict objectForKey:@"errors"]mutableCopy];

                        for (int count = 0; count<errorArr.count; count++)
                        {
                            NSDictionary *error = errorArr[count];
                            NSMutableDictionary *errorDict = [error mutableCopy];
                            if (errorDict!=nil)
                            {
                                if ([errorDict objectForKey:@"parameter"]!=nil && ![[errorDict objectForKey:@"parameter"] isKindOfClass:[NSNull class]])
                                {
                                    NSMutableDictionary *parameterDict=[[errorDict objectForKey:@"parameter"]mutableCopy];
                                    if (parameterDict!=nil)
                                    {
                                        if ([errorDict objectForKey:@"parameter"]!=nil && ![[errorDict objectForKey:@"parameter"] isKindOfClass:[NSNull class]])
                                        {
                                            NSMutableDictionary *parameterDict=[[errorDict objectForKey:@"parameter"]mutableCopy];
                                            if (parameterDict!=nil)
                                            {
                                                if ([parameterDict objectForKey:@"audit"]!=nil && ![[parameterDict objectForKey:@"audit"] isKindOfClass:[NSNull class]])
                                                {
                                                    NSMutableDictionary *auditImageDict=[[parameterDict objectForKey:@"audit"]mutableCopy];
                                                    if (auditImageDict!=nil)
                                                    {
                                                        if ([auditImageDict objectForKey:@"auditImage"]!=nil && ![[auditImageDict objectForKey:@"auditImage"] isKindOfClass:[NSNull class]])
                                                        {
                                                            NSMutableDictionary *auditImageInDict=[[auditImageDict objectForKey:@"auditImage"]mutableCopy];
                                                            if (auditImageInDict!=nil)
                                                            {
                                                                if ([auditImageInDict objectForKey:@"image"]!=nil && ![[auditImageInDict objectForKey:@"image"] isKindOfClass:[NSNull class]])
                                                                {
                                                                    NSMutableDictionary *auditRealImageInDict=[[auditImageInDict objectForKey:@"image"]mutableCopy];
                                                                    if (auditRealImageInDict!=nil)
                                                                    {
                                                                        [auditRealImageInDict setObject:@"Image Data Removed" forKey:@"base64ImageData"];
                                                                        [auditImageInDict setObject:auditRealImageInDict forKey:@"image"];
                                                                        [auditImageDict setObject:auditImageInDict forKey:@"auditImage"];
                                                                        [parameterDict setObject:auditImageDict forKey:@"audit"];

                                                                        [errorDict setObject:parameterDict forKey:@"parameter"];
                                                                        [errorArr replaceObjectAtIndex:count withObject:errorDict];

                                                                    }
                                                                }

                                                            }
                                                        }

                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                [valueDict setObject:errorArr forKey:@"errors"];
                            }

                        }
                    }

                }
                else if ([[valueDict allKeys] containsObject:@"entries"])
                {
                    NSMutableArray *allEntriesArr=[valueDict objectForKey:@"entries"];
                    if (allEntriesArr.count>0)
                    {
                        NSMutableDictionary *entriesDict=[[allEntriesArr objectAtIndex:0]mutableCopy];

                        if ([[entriesDict allKeys] containsObject:@"expenseReceipt"])
                        {
                            if ([entriesDict objectForKey:@"expenseReceipt"]!=nil && ![[entriesDict objectForKey:@"expenseReceipt"] isKindOfClass:[NSNull class]])
                            {
                                NSMutableDictionary *expenseReceiptDict=[[entriesDict objectForKey:@"expenseReceipt"]mutableCopy];
                                if (expenseReceiptDict!=nil)
                                {
                                    if ([[expenseReceiptDict allKeys] containsObject:@"image"])
                                    {
                                        NSMutableDictionary *imageDict=[[expenseReceiptDict objectForKey:@"image"]mutableCopy];
                                        if (imageDict!=nil)
                                        {
                                            [imageDict setObject:@"Image Data Removed" forKey:@"base64ImageData"];
                                            [expenseReceiptDict setObject:imageDict forKey:@"image"];
                                            [entriesDict setObject:expenseReceiptDict forKey:@"expenseReceipt"];

                                            [valueDict setObject:[NSMutableArray arrayWithObject:entriesDict ] forKey:@"entries"];
                                        }


                                    }


                                }

                            }

                        }

                    }

                }

                [finalDict setObject:valueDict forKey:[arrKeys objectAtIndex:i]];

            }
            else if (value!=nil && [value isKindOfClass:[NSArray class]])
            {
                NSMutableArray *valueArr=(NSMutableArray *)[value mutableCopy];
                for (int count = 0; count<valueArr.count; count++)
                {
                    NSDictionary *valueDict = valueArr[count];
                    if (valueDict!=nil && [valueDict isKindOfClass:[NSDictionary class]])
                    {
                        NSMutableDictionary *valueinDict=(NSMutableDictionary *)[valueDict mutableCopy];
                        if ([[valueinDict allKeys] containsObject:@"audit"])
                        {
                            if ([valueinDict objectForKey:@"audit"]!=nil && ![[valueinDict objectForKey:@"audit"] isKindOfClass:[NSNull class]])
                            {
                                NSMutableDictionary *auditImageDict=[[valueinDict objectForKey:@"audit"]mutableCopy];
                                if (auditImageDict!=nil)
                                {
                                    if ([auditImageDict objectForKey:@"auditImage"]!=nil && ![[auditImageDict objectForKey:@"auditImage"] isKindOfClass:[NSNull class]])
                                    {
                                        NSMutableDictionary *auditImageInDict=[[auditImageDict objectForKey:@"auditImage"]mutableCopy];
                                        if (auditImageInDict!=nil)
                                        {
                                            if ([auditImageInDict objectForKey:@"image"]!=nil && ![[auditImageInDict objectForKey:@"image"] isKindOfClass:[NSNull class]])
                                            {
                                                NSMutableDictionary *auditRealImageInDict=[[auditImageInDict objectForKey:@"image"]mutableCopy];
                                                if (auditRealImageInDict!=nil)
                                                {
                                                    [auditRealImageInDict setObject:@"Image Data Removed" forKey:@"base64ImageData"];
                                                    [auditImageInDict setObject:auditRealImageInDict forKey:@"image"];
                                                    [auditImageDict setObject:auditImageInDict forKey:@"auditImage"];
                                                    [valueinDict setObject:auditImageDict forKey:@"audit"];

                                                }
                                            }

                                        }
                                    }

                                }
                            }

                        }

                        [valueArr replaceObjectAtIndex:count withObject:valueinDict];


                    }

                    [finalDict setObject:valueArr forKey:[arrKeys objectAtIndex:i]];
                }

            }
            else if (value!=nil)
            {
                [finalDict setObject:value forKey:[arrKeys objectAtIndex:i]];
            }

        }
    }

    NSString *datetoLogStr=@"";

    if (finalDict!=nil && [finalDict isKindOfClass:[NSDictionary class]])
    {
        NSError *err = nil;
        datetoLogStr = [JsonWrapper writeJson:finalDict error:&err];
    }
    else
    {
        datetoLogStr=originalString;
    }

    return datetoLogStr;
}

@end
