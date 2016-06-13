//
//  GEAutocompleteTextSearch.m
//  GoEuro
//
//  Created by GIB on 6/13/16.
//
//

#import <QuartzCore/QuartzCore.h>
#import "GEAutocompleteTextSearch.h"
#import "GELocationSearchProtocol.h"
#import "GESearchLocationManager.h"
#import "GELocation.h"
#import "GEUtility.h"

#define ROW_HEIGHT  30.0f
#define MIN_ROWS    5

@interface GEAutocompleteTextSearch() <UITableViewDataSource ,UITableViewDelegate, GESearchLocationDelegate>

@property (strong, nonatomic) UITableView *autocompleteTableView;
@property (strong, nonatomic) NSMutableArray *autocompleteArray;
@property (strong, nonatomic) GESearchLocationManager *searchManager;

// UI properties
@property (nonatomic, assign) CGRect autoCompleteTableFrame;
@property (assign) CGSize autoCompleteTableOriginOffset;
@property (assign) CGSize autoCompleteTableSizeOffset;


@end

@implementation GEAutocompleteTextSearch

#pragma mark - lazy properties
- (GESearchLocationManager*)searchManager {
    if (_searchManager == nil) {
        _searchManager = [[GESearchLocationManager alloc] initWithDelegate:self];
    }
    return _searchManager;
}


#pragma mark - UI related methods
- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [self initializeView];
}

- (void)initializeView {
    
    self.autocompleteTableView = [self newAutoCompleteTableViewForTextField:self];
    [self setTableStyle:self.autocompleteTableView];
    [self.superview insertSubview:self.autocompleteTableView aboveSubview:self];
}

#pragma mark - public methods
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    [self.searchManager startFetchingWithQuery:substring locale:[GEUtility currentLocale]];
}

- (void)closeTableView {
    
    // should perform following tasks
    // 1. select the top location if there is no option selected
    // 2. flush all data
    // 3. hide the tableview
    // 4. close keyboard
    
    if ([self hasAutocompleteData] && ![self hasSelection]) {
        [self selectTopLocation];
    }
    
    [self flushAutocompleteData];
    [self reloadData];
    self.autocompleteTableView.hidden = YES;
    [self resignFirstResponder];
}

#pragma mark - Helper methods
- (UITableView *)newAutoCompleteTableViewForTextField:(GEAutocompleteTextSearch *)textField {
    CGRect dropDownTableFrame = [self autoCompleteTableViewFrameForTextField:textField];
    
    UITableView *newTableView = [[UITableView alloc] initWithFrame:dropDownTableFrame];
    [newTableView setDelegate:self];
    [newTableView setDataSource:self];
    [newTableView setScrollEnabled:YES];
    [newTableView setUserInteractionEnabled:YES];
    [newTableView setHidden:YES];
    [newTableView setAllowsMultipleSelection:NO];
    [newTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [newTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    return newTableView;
}

- (void)setTableStyle:(UITableView*)tableView {
    CALayer *layer = tableView.layer;
    [layer setMasksToBounds:YES];
    [layer setCornerRadius: 4.0];
    [layer setBorderWidth:1.0];
    [layer setBorderColor:[[UIColor colorWithWhite: 0.8 alpha: 1.0] CGColor]];
}

- (CGRect)autoCompleteTableViewFrameForTextField:(GEAutocompleteTextSearch *)textField {
    CGRect frame = CGRectZero;
    
    if (CGRectGetWidth(self.autoCompleteTableFrame) > 0){
        frame = self.autoCompleteTableFrame;
    } else {
        frame = textField.frame;
        frame.origin.y += CGRectGetHeight(textField.frame);
    }
    
    frame.origin.x += textField.autoCompleteTableOriginOffset.width;
    frame.origin.y += textField.autoCompleteTableOriginOffset.height;
    
    
    frame.size.height = ROW_HEIGHT*2;
    frame.size.width = textField.frame.size.width;
    frame = CGRectInset(frame, 1, 0);
    
    return frame;
}

- (void)reloadData {
    [self.autocompleteTableView reloadData];
}

#pragma mark - Utility methods
- (BOOL)hasSelection {
    NSString *selectedLocation = self.text;
    for (GELocation *location in self.autocompleteArray) {
        if ([selectedLocation isEqualToString:location.name]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasAutocompleteData {
    return (self.autocompleteArray != nil && [self.autocompleteArray count] > 0) ? YES: NO;
}

- (void)selectTopLocation {
    GELocation *loc = [self.autocompleteArray firstObject];
    self.text = loc.name;
}

- (void)removeSelection {
    self.text = @"";
}
- (void)flushAutocompleteData {
    if ([self hasAutocompleteData]) {
        [self.autocompleteArray removeAllObjects];
    }
}

#pragma mark - GESearchLocationDelegate
- (void)didCompleteSearchWithSortedArray:(NSArray*)locationArray {
    self.autocompleteArray = [locationArray mutableCopy];
    self.autocompleteTableView.hidden = NO;
    [self reloadData];
    
}

- (void)didFailedWithError:(NSString*)error {
    [self closeTableView];
    [self removeSelection];
    [GEUtility displayAlertWithTitle:@"Error" message:error delegate:nil];
}

#pragma mark UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    return self.autocompleteArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *AutoCompleteRowIdentifier = @"GEAutoCompleteRowIdentifier";
    
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:AutoCompleteRowIdentifier];
    }
    cell.userInteractionEnabled = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    GELocation* loc = [self.autocompleteArray objectAtIndex:indexPath.row];
    cell.textLabel.text = loc.name;
    return cell;
}

#pragma mark UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    self.text = selectedCell.textLabel.text;
    [self closeTableView];
    
}

@end
