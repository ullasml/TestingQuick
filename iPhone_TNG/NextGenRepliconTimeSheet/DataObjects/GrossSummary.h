#import <Foundation/Foundation.h>
@class CurrencyValue;
@class GrossHours;
@protocol GrossSummary <NSObject>

- (CurrencyValue *) totalPay;
- (NSArray *) actualsByPayCode;
- (NSArray *) actualsByPayDuration;
- (GrossHours *) totalHours;
- (BOOL)payAmountDetailsPermission;
- (BOOL)payHoursDetailsPermission;
- (NSString *)scriptCalculationDate;

@end
