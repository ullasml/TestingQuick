
#import "ActualsByPayCodeDeserializer.h"
#import "Paycode.h"

@implementation ActualsByPayCodeDeserializer

- (Paycode *)deserializeForPayCodeDictionary:(NSDictionary *)actualsByPayCodeDictionary
{
    if (!actualsByPayCodeDictionary || actualsByPayCodeDictionary == (id)[NSNull null])
    {
        return nil;
    }
    if (actualsByPayCodeDictionary[@"moneyValue"]!=nil && actualsByPayCodeDictionary[@"moneyValue"]!=(id)[NSNull null]) {
        NSDictionary *currencyValueDictionary;
        NSDictionary *currencyDictionary;
        NSString *amount=nil;
        NSString *symbol=nil;
        NSString *currencyText=nil;
        NSString *amountString = nil;
        if(actualsByPayCodeDictionary[@"moneyValue"][@"multiCurrencyValue"]!=nil && actualsByPayCodeDictionary[@"moneyValue"][@"multiCurrencyValue"]!=(id)[NSNull null])
        {
            NSArray *moneyValue = actualsByPayCodeDictionary[@"moneyValue"][@"multiCurrencyValue"];
            if(moneyValue.count>0 && moneyValue!=nil && moneyValue!=(id)[NSNull null])
            {
                currencyValueDictionary = moneyValue.firstObject;
                if (currencyValueDictionary!=nil && currencyValueDictionary!=(id)[NSNull null]) {
                    currencyDictionary = currencyValueDictionary[@"currency"];
                    symbol = currencyDictionary[@"symbol"];
                    if(currencyValueDictionary[@"amount"]!=nil && currencyValueDictionary[@"amount"]!=(id)[NSNull null])
                    {
                        amount = currencyValueDictionary == (id)[NSNull null] ? @0 : currencyValueDictionary[@"amount"];
                        CGFloat amountFloat = [currencyValueDictionary[@"amount"] floatValue];
                        amountString =[NSString stringWithFormat:@"%@%.2f",symbol,amountFloat] ;
                    }
                    
                }
            }
        }
        
        NSDictionary *payCodeTitle = actualsByPayCodeDictionary[@"payCode"];
        if(payCodeTitle!=nil&&payCodeTitle!=(id)[NSNull null])
        {
            currencyText =  payCodeTitle == (id)[NSNull null] ? @"" : payCodeTitle[@"displayText"] ;
        }
        if(amountString!=nil && currencyText!=nil)
        {
            return [[Paycode alloc] initWithValue:amountString title:currencyText timeSeconds:nil];
        }
    }
    
    return nil;
}

@end
