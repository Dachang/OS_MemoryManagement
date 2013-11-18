//
//  LDCViewController.h
//  OSMemoryManagement
//
//  Created by 大畅 on 13-11-18.
//  Copyright (c) 2013年 大畅. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDCProcessModel.h"

@interface LDCViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    LDCProcessModel *_process;
    UITableView *_result;
}

//UI Elements;
@property (strong, nonatomic) IBOutlet UILabel *instructLabel;
@property (strong, nonatomic) IBOutlet UILabel *lackPageLabel;

@property (strong, nonatomic) IBOutlet UILabel *runningTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *numOfInstructLabel;

@property (strong, nonatomic) IBOutlet UILabel *memoryLabelOne;
@property (strong, nonatomic) IBOutlet UILabel *memoryLabelTwo;
@property (strong, nonatomic) IBOutlet UILabel *memoryLabelThree;
@property (strong, nonatomic) IBOutlet UILabel *memoryLabelFour;

- (IBAction)restart:(id)sender;
- (IBAction)changeTime:(id)sender;
- (IBAction)changeNum:(id)sender;

@end
