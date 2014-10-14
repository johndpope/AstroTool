//
//  MDSMainViewController.m
//  MDS9
//
//  Created by Hengchu Zhang on 10/8/14.
//  Copyright (c) 2014 Hengchu Zhang. All rights reserved.
//

#import "MDSCenterViewController.h"
#import "MDSFrameView.h"

@interface MDSCenterViewController ()

@property (weak) IBOutlet NSTextFieldCell *urlLabel;
@property (weak) IBOutlet MDSFrameView *frameView;
@property (nonatomic, strong) FITSFile *currentOpenFile;

@end

@implementation MDSCenterViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do view setup here.
  [self.urlLabel setStringValue:@"Select a file..."];
}

#pragma mark - Setters

- (void)setCurrentOpenFile:(FITSFile *)currentOpenFile
{
  if (_currentOpenFile) {
    [_currentOpenFile close];
  }
  _currentOpenFile = currentOpenFile;
}

#pragma mark - Menu Controller delegate methods

- (void)didOpenFileWithURL:(NSURL *)url
{
  NSString *fileName = [url lastPathComponent];
  [self.urlLabel setStringValue:fileName];
  
  FITSFile *fitsFile = [FITSFile FITSFileWithURL:url];
  
  [fitsFile open];
  [fitsFile syncLoadDataOfHDUAtIndex:0];
  self.currentOpenFile = fitsFile;
  
  FITSImage *image = [fitsFile HDUAtIndex:0].image;
  
  self.frameView.imageView = [[FITSImageView alloc] initWithFITSImage:image];
  
  [self.frameView zoomImageToFit];
}

@end
