#import <Foundation/Foundation.h>

@protocol Cursor <NSObject>

- (BOOL)canMoveForwards;
- (BOOL)canMoveBackwards;

@end
