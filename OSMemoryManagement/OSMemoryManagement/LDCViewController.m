//
//  LDCViewController.m
//  OSMemoryManagement
//
//  Created by 大畅 on 13-11-18.
//  Copyright (c) 2013年 大畅. All rights reserved.
//

#import "LDCViewController.h"

@interface LDCViewController ()

@end

@implementation LDCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _process = [[LDCProcessModel alloc] init];
    _process.instructList = [[NSMutableArray alloc] initWithObjects:nil];
    _process.info = [[NSMutableArray alloc] initWithObjects:nil];
    _process.memoryList = [[NSMutableArray alloc] initWithObjects:nil];
    
    _process.lackCount = 0;
    _process.runningTime = 0.1f;
    _process.oldestPage = 0;
    _process.numOfCode = 320;
    
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        [self createInstructList];
        dispatch_async(dispatch_get_main_queue(), ^{
            _process.runTimer = [NSTimer scheduledTimerWithTimeInterval:_process.runningTime target:self selector:@selector(generateInstruct) userInfo:nil repeats:YES];
        });
    });
}

- (void)createInstructList
{
    int tempNumber;
    NSString *tempString;
    BOOL isEqualOrNot;
    
    do{
        tempNumber = (arc4random() % (_process.numOfCode));
        tempString = [NSString stringWithFormat:@"%i", tempNumber];
        isEqualOrNot = YES;
        
        for (_process.countNum = 0; _process.countNum < [_process.instructList count]; _process.countNum++)
        {
            if ([tempString isEqualToString:[_process.instructList objectAtIndex:_process.countNum]])
            {
                isEqualOrNot = NO;
                break;
            }
        }
        if (isEqualOrNot == YES)
        {
            [_process.instructList addObject:tempString];
        }
    } while ([_process.instructList count] < _process.numOfCode);
}

- (void)generateInstruct
{
    if([_process.instructList count] > 0)
    {
        _process.instructNumber = [[_process.instructList objectAtIndex:0] intValue];
        _process.pageNumber = _process.instructNumber/10;
        _process.pageString = [NSString stringWithFormat:@"%i", _process.pageNumber];
        _instructLabel.text = [NSString stringWithFormat:@"第%i页,第%i条指令", _process.pageNumber,_process.instructNumber];
        [_process.info addObject:[NSString stringWithFormat:@"第%i页,第%i条指令", _process.pageNumber,_process.instructNumber]];
        //[self loadToMemory];
        [_process.instructList removeObjectAtIndex:0];
    }
    else
    {
        _instructLabel.text = @"本次运行结束";
        _lackPageLabel.text = [NSString stringWithFormat:@"缺页率:%i/%i",_process.lackCount,_process.numOfCode];
        _result = [[UITableView alloc] initWithFrame:CGRectMake(20, 377, 429, 348) style:UITableViewStylePlain];
        _result.delegate = self;
        _result.dataSource = self;
        _result.contentSize = CGSizeMake(429, 30*320);
        [self.view addSubview:_result];
        [_process.runTimer invalidate];
    }
}

- (void)loadToMemory
{
    if ([_process.memoryList count] == 0)
    {
        [_process.memoryList addObject:[NSString stringWithFormat:@"%i", _process.pageNumber]];
        NSString *tempString = [_process.info objectAtIndex:[_process.info count] - 1];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
