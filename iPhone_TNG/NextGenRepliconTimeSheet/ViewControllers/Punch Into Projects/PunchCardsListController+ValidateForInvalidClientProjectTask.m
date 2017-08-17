//
//  PunchCardsListController+ValidateForInvalidClientProjectTask.m
//  NextGenRepliconTimeSheet

#import "PunchCardsListController+ValidateForInvalidClientProjectTask.h"
#import "PunchCardStorage.h"
#import "BookmarkValidationRepository.h"
#import <KSDeferred/KSDeferred.h>
#import "TimeLinePunchesStorage.h"

@implementation PunchCardsListController (ValidateForInvalidClientProjectTask)

#pragma mark - Helper Methods

- (void)checkBookmarksValidityAndRefreshList {

    NSArray *bookmarks = [self.punchCardStorage getPunchCards];

    if([bookmarks count] == 0) {
        return;
    }

    KSPromise *promise = [self.bookmarkValidationRepository validateBookmarks];

    [promise then:^id (NSArray *validBookmarksArray) {

        if(!validBookmarksArray) {
            return nil;
        }

        NSArray *freshBookmarks = [self.punchCardStorage getCPTMap];

        if([validBookmarksArray count] == [freshBookmarks count]) {
            return nil;
        }

        NSMutableSet *invalidBookmarks = [self getInvalidBookmarksFrom:validBookmarksArray bookmarksFromDB:freshBookmarks];

        [self identifyInvalidBookmarksDeleteAndRefreshTableViewWith:invalidBookmarks];

        return nil;

    } error:^id (NSError *error) {
        return nil;
    }];
}

#pragma mark -

- (NSMutableSet *)getInvalidBookmarksFrom:(NSArray*)validBookmarksArrayFromService bookmarksFromDB:(NSArray *)bookmarksFromDB {

    NSMutableSet *invalidBookmarks = [NSMutableSet new];

    NSSet *validBookmarksFromService = [NSSet setWithArray:validBookmarksArrayFromService];
    NSMutableSet *validBookmarksFromDB = [NSMutableSet setWithArray:bookmarksFromDB];
    [validBookmarksFromDB minusSet:validBookmarksFromService];
    invalidBookmarks = validBookmarksFromDB;

    return invalidBookmarks;
}

- (void)identifyInvalidBookmarksDeleteAndRefreshTableViewWith:(NSMutableSet *)invalidBookmarkSet {

    for (NSDictionary *cptMap in invalidBookmarkSet) {

        NSDictionary *client = cptMap[@"client"];
        NSDictionary *project = cptMap[@"project"];
        NSDictionary *task = cptMap[@"task"];

        PunchCardObject *cardObject = [self.punchCardStorage getPunchCardObjectWithClientUri:client[@"uri"] projectUri:project[@"uri"] taskUri:task[@"uri"]];

        [self.punchCardStorage deletePunchCard:cardObject];

        [self.timeLinePunchStorage updateIsTimeEntryAvailableColumnMatchingClientUri:client[@"uri"] projectUri:project[@"uri"] taskUri:task[@"uri"] isTimeEntryAvailable:NO];

        [self.delegate punchCardsListController:self didFindPunchCardAsInvalidPunchCard:cardObject];

        NSInteger index = [self.tableRows indexOfObject:cardObject];
        if(NSNotFound != index) {
            [self.tableRows removeObjectAtIndex:index];

            [self.tableView beginUpdates];

            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            [self.tableView endUpdates];
        }
    }
}


@end
