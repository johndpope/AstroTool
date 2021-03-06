//
//  MDSHeaderTableViewController.m
//  MDS9
//
//  Created by Hengchu Zhang on 10/16/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "MDSHeaderTableViewController.h"
#import "MDSHeaderTableRowView.h"
#import "MDSTheme.h"
#import "MDSDisclosureView.h"
#import "NSArray+Map.h"
#import <PureLayout/PureLayout.h>
#import <ReactiveCocoa/ReactiveCocoa.h>


@interface MDSHeaderTableViewController () <NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) NSArray *headers;

@end

@implementation MDSHeaderTableViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do view setup here.
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.backgroundColor = [MDSTheme panelColor];
  self.tableView.headerView = nil;
  
  [[[RACObserve(self, openFile)
     skip:1]
    map:^id(id value) {
      FITSFile *file = value;
      [file syncLoadHeaderOfMainHDU];
      return [[[[file mainHDU] header] lines] mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
        FITSHeaderLine *line = obj;
        return RACTuplePack(line.key, line.value, line.comment);
      }];
    }] subscribeNext:^(id x) {
      self.headers = x;
      [self.tableView reloadData];
      [self.tableView sizeLastColumnToFit];
      [self.tableView sizeToFit];
    }];
}

#pragma mark - Table view datasource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return (self.headers.count) ? self.headers.count : 1;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
  if (self.headers.count) {
    
    RACTupleUnpack(NSString *key, NSString *value, NSString *comment) = self.headers[row];
    
    MDSHeaderTableRowView *view = [[MDSHeaderTableRowView alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
    
    view.key     = key;
    view.value   = value;
    view.comment = comment;
    
    NSSize size  = view.intrinsicContentSize;
    
    return size.height;
    
  } else {
    
    NSTextField *textLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
    textLabel.stringValue = @"No Open File";
    textLabel.font = [NSFont systemFontOfSize:22.0];
    textLabel.alignment = NSCenterTextAlignment;
    [textLabel sizeToFit];
    return textLabel.frame.size.height;
    
  }
}

#pragma mark - Table view delegate

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
  if (self.headers.count) {
    RACTupleUnpack(NSString *key, NSString *value, NSString *comment) = self.headers[row];
    
    MDSHeaderTableRowView *view = [[MDSHeaderTableRowView alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
    
    view.key                   = key;
    view.value                 = value;
    view.comment               = comment;
    view.wantsLayer            = YES;
    view.layer.backgroundColor = [NSColor clearColor].CGColor;
    
    NSSize size = view.intrinsicContentSize;
    view.frame = NSMakeRect(0, 0, size.width, size.height);
    
    return view;
  } else {
    NSTextField *textLabel    = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
    textLabel.stringValue     = @"No Open File";
    textLabel.font            = [NSFont fontWithName:@"HelveticaNeue-Light" size:22.0];
    textLabel.alignment       = NSCenterTextAlignment;
    textLabel.bordered        = NO;
    textLabel.editable        = NO;
    textLabel.selectable      = NO;
    textLabel.textColor       = [NSColor lightGrayColor];
    textLabel.backgroundColor = [NSColor clearColor];
    return textLabel;
  }
}


@end
