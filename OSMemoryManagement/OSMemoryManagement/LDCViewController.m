//
//  LDCViewController.m
//  OSMemoryManagement
//
//  Created by 大畅 on 13-11-18.
//  Copyright (c) 2013年 大畅. All rights reserved.
//

#import "LDCViewController.h"

@interface LDCViewController ()
{
    int _memoryPageAgeCount[4];
}
@end

@implementation LDCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _process = [[LDCProcessModel alloc] init];
    _process.instructList = [[NSMutableArray alloc] initWithObjects:nil];
    _process.resultDataSource = [[NSMutableArray alloc] initWithObjects:nil];
    _process.memoryList = [[NSMutableArray alloc] initWithObjects:nil];
    
    _process.lackCount = 0;
    _process.runningTime = 0.1f;
    _process.oldestPage = 0;
    _process.totalNumOfInstruct = 320;
    
    for (int i = 0; i < 4; i++)
    {
        _memoryPageAgeCount[i] = 0;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self createInstructList];
        dispatch_async(dispatch_get_main_queue(), ^{
            _process.runTimer = [NSTimer scheduledTimerWithTimeInterval:_process.runningTime target:self selector:@selector(showInstruct) userInfo:nil repeats:YES];
        });
    });
}

#pragma mark - create instruct list

- (void)createInstructList
{
    int tempNumber;
    NSString *tempString;
    BOOL isEqualOrNot;
    
    do{
        tempNumber = (arc4random() % (_process.totalNumOfInstruct));
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
    } while ([_process.instructList count] < _process.totalNumOfInstruct);
}

#pragma mark - call instruct & show current instuct info & add result(log) data source

- (void)showInstruct
{
    if([_process.instructList count] > 0)
    {
        _process.instructNumber = [[_process.instructList objectAtIndex:0] intValue];
        _process.pageNumber = _process.instructNumber/10;
        _process.pageString = [NSString stringWithFormat:@"%i", _process.pageNumber];
        _instructLabel.text = [NSString stringWithFormat:@"第%i页,第%i条指令", _process.pageNumber,_process.instructNumber];
        [_process.resultDataSource addObject:[NSString stringWithFormat:@"第%i页,第%i条指令", _process.pageNumber,_process.instructNumber]];
        [self loadToMemory];
        [_process.instructList removeObjectAtIndex:0];
    }
    else
    {
        _instructLabel.text = @"本次运行结束";
        _lackPageLabel.text = [NSString stringWithFormat:@"缺页率:%i/%i",_process.lackCount,_process.totalNumOfInstruct];
        _result = [[UITableView alloc] initWithFrame:CGRectMake(20, 377, 429, 348) style:UITableViewStylePlain];
        _result.delegate = self;
        _result.dataSource = self;
        _result.contentSize = CGSizeMake(429, 30*320);
        [self.view addSubview:_result];
        [_process.runTimer invalidate];
    }
}

#pragma mark - load instruct to memory & swap pages when page-lacking

- (void)loadToMemory
{
    if ([_process.memoryList count] == 0)
    {
        [_process.memoryList addObject:[NSString stringWithFormat:@"%i", _process.pageNumber]];
        _memoryPageAgeCount[0] = 0;
        _memoryPageAgeCount[0]++;
        NSString *tempStringOne = [_process.resultDataSource objectAtIndex:[_process.resultDataSource count] - 1];
        [_process.resultDataSource replaceObjectAtIndex:[_process.resultDataSource count] - 1 withObject:[tempStringOne stringByAppendingString:@"   缺页"]];
    }
    if ([_process.memoryList count] < 4 && [_process.memoryList count] > 0)
    {
        BOOL add = YES;
        int nextNum = 0;
        for (int i = 0; i < [_process.memoryList count]; i++)
        {
            if (_process.pageNumber == [[_process.memoryList objectAtIndex:i] intValue])
            {
                _memoryPageAgeCount[i]++;
                add = NO;
                nextNum = i;
            }
        }
        if (add == YES)
        {
            [_process.memoryList addObject:[NSString stringWithFormat:@"%i", _process.pageNumber]];
            _memoryPageAgeCount[nextNum+1]++;
            NSString *tempStringTwo = [_process.resultDataSource objectAtIndex:[_process.resultDataSource count] - 1];
            [_process.resultDataSource replaceObjectAtIndex:[_process.resultDataSource count] - 1 withObject:[tempStringTwo stringByAppendingString:@"   缺页"]];
        }
    }
    if ([_process.memoryList count] == 4)
    {
        if ([_process.pageString isEqualToString:[_process.memoryList objectAtIndex:0]] || [_process.pageString isEqualToString:[_process.memoryList objectAtIndex:1]] || [_process.pageString isEqualToString:[_process.memoryList objectAtIndex:2]] || [_process.pageString isEqualToString:[_process.memoryList objectAtIndex:3]])
        {
            if ([_process.pageString isEqualToString:[_process.memoryList objectAtIndex:0]])
            {
                _memoryPageAgeCount[0]++;
            }
            if ([_process.pageString isEqualToString:[_process.memoryList objectAtIndex:1]])
            {
                _memoryPageAgeCount[1]++;
            }
            if ([_process.pageString isEqualToString:[_process.memoryList objectAtIndex:2]])
            {
                _memoryPageAgeCount[2]++;
            }
            if ([_process.pageString isEqualToString:[_process.memoryList objectAtIndex:3]])
            {
                _memoryPageAgeCount[3]++;
            }
        }
        else
        {
            int maxNum = _memoryPageAgeCount[0];
            int maxIndex = 0;
            for (int i = 0; i < 4; i++)
            {
                if (_memoryPageAgeCount[i]>maxNum)
                {
                    maxNum = _memoryPageAgeCount[i];
                    maxIndex = i;
                }
            }
            [_process.memoryList replaceObjectAtIndex:maxIndex withObject:_process.pageString];
            _memoryPageAgeCount[maxIndex] = 1;
//            if (_process.oldestPage == 3)
//            {
//                _process.oldestPage = 0;
//            }
//            else if (_process.oldestPage < 3)
//            {
//                _process.oldestPage++;
//            }
            NSString *tempStringThree = [_process.resultDataSource objectAtIndex:[_process.resultDataSource count] - 1];
            [_process.resultDataSource replaceObjectAtIndex:[_process.resultDataSource count] - 1 withObject:[tempStringThree stringByAppendingString:@"   缺页"]];
            _process.lackCount++;
        }
    }
    if ([_process.memoryList count] >= 1)
    {
        _memoryLabelOne.text = [_process.memoryList objectAtIndex:0];
    }
    if ([_process.memoryList count] >= 2)
    {
        _memoryLabelTwo.text = [_process.memoryList objectAtIndex:1];
    }
    if ([_process.memoryList count] >= 3)
    {
        _memoryLabelThree.text = [_process.memoryList objectAtIndex:2];
    }
    if ([_process.memoryList count] >= 4)
    {
        _memoryLabelFour.text = [_process.memoryList objectAtIndex:3];
    }
}

#pragma mark - UI Logic implementations

- (IBAction)restart:(id)sender
{
    [_process.instructList removeAllObjects];
    [_process.memoryList removeAllObjects];
    [_process.resultDataSource removeAllObjects];
    _memoryLabelOne.text = @"NULL";
    _memoryLabelTwo.text = @"NULL";
    _memoryLabelThree.text = @"NULL";
    _memoryLabelFour.text = @"NULL";
    _process.oldestPage = 0;
    _process.lackCount = 0;
    _lackPageLabel.text = @"缺页率: ";
    [_result removeFromSuperview];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self createInstructList];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_process.runTimer invalidate];
            _process.runTimer = [NSTimer scheduledTimerWithTimeInterval:_process.runningTime target:self selector:@selector(showInstruct) userInfo:nil repeats:YES];
        });
    });
}

- (IBAction)changeTime:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    switch (btn.tag)
    {
        case 1:
            _process.runningTime = 0.1f;
            break;
        case 2:
            _process.runningTime = 0.5f;
            break;
        case 3:
            _process.runningTime = 1.0f;
            break;
        default:
            break;
    }
    _runningTimeLabel.text = [NSString stringWithFormat:@"每条指令执行时间：%0.1fs", _process.runningTime];
}

- (IBAction)changeNum:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    switch (btn.tag)
    {
        case 4:
            _process.totalNumOfInstruct = 240;
            break;
        case 5:
            _process.totalNumOfInstruct = 320;
            break;
        case 6:
            _process.totalNumOfInstruct = 480;
            break;
        default:
            break;
    }
    _numOfInstructLabel.text = [NSString stringWithFormat:@"指令总数: %i条", _process.totalNumOfInstruct];
}

#pragma mark - Table View DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _process.totalNumOfInstruct;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *text;
    text = [[NSString stringWithFormat:@"%i     ",indexPath.row+1] stringByAppendingString:[_process.resultDataSource objectAtIndex:indexPath.row]];
    cell.textLabel.text = text;
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
