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
    [_process initProcessModel];
    [self initUI];
    
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

#pragma mark - UI init
- (void)initUI
{
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"memory_UI_BG"]];
    bgImage.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
    [self.view addSubview:bgImage];
    [self.view sendSubviewToBack:bgImage];
}

#pragma mark - create instruct list

- (void)createInstructList
{
    int tempNumber;
    int tempNext;
    NSString *tempString;
    NSString *tempStringNext;
    BOOL isEqualOrNot;
    
    do{
        tempNumber = (arc4random() % (_process.totalNumOfInstruct));
        tempNext = tempNumber + 1;
        tempString = [NSString stringWithFormat:@"%i", tempNumber];
        tempStringNext = [NSString stringWithFormat:@"%i",tempNext];
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
            int randomTemp  = arc4random()%3;
            if (randomTemp == 0 || randomTemp == 1)
            {
                [_process.instructList addObject:tempString];
            }
            else
            {
                [_process.instructList addObject:tempString];
                [_process.instructList addObject:tempStringNext];
            }
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
        _result = [[UITableView alloc] initWithFrame:CGRectMake(30, 410, 510, 348) style:UITableViewStylePlain];
        _result.backgroundView = nil;
        _result.separatorStyle = UITableViewCellSeparatorStyleNone;
        _result.backgroundColor = [UIColor clearColor];
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
        NSString *tempStringOne = [_process.resultDataSource objectAtIndex:[_process.resultDataSource count] - 1];
        [_process.resultDataSource replaceObjectAtIndex:[_process.resultDataSource count] - 1 withObject:[tempStringOne stringByAppendingString:@"   缺页"]];
    }
    if ([_process.memoryList count] < 4 && [_process.memoryList count] > 0)
    {
        BOOL add = YES;
        for (int i = 0; i < [_process.memoryList count]; i++)
        {
            if (_process.pageNumber == [[_process.memoryList objectAtIndex:i] intValue])
            {
                _memoryPageAgeCount[i] = 0;
                for (int j=0; j<i;j++)
                {
                    _memoryPageAgeCount[j]++;
                }
                for (int k=i+1; k<[_process.memoryList count]; k++)
                {
                    _memoryPageAgeCount[k]++;
                }
                add = NO;
            }
        }
        if (add == YES)
        {
            [_process.memoryList addObject:[NSString stringWithFormat:@"%i", _process.pageNumber]];
            _memoryPageAgeCount[[_process.memoryList count] - 1] = 0;
            for (int i=0; i<[_process.memoryList count]-1; i++)
            {
                _memoryPageAgeCount[i]++;
            }
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
                _memoryPageAgeCount[0] = 0;
                _memoryPageAgeCount[1]++;
                _memoryPageAgeCount[2]++;
                _memoryPageAgeCount[3]++;
            }
            if ([_process.pageString isEqualToString:[_process.memoryList objectAtIndex:1]])
            {
                _memoryPageAgeCount[1] = 0;
                _memoryPageAgeCount[0]++;
                _memoryPageAgeCount[2]++;
                _memoryPageAgeCount[3]++;
            }
            if ([_process.pageString isEqualToString:[_process.memoryList objectAtIndex:2]])
            {
                _memoryPageAgeCount[2] = 0;
                _memoryPageAgeCount[0]++;
                _memoryPageAgeCount[1]++;
                _memoryPageAgeCount[3]++;
            }
            if ([_process.pageString isEqualToString:[_process.memoryList objectAtIndex:3]])
            {
                _memoryPageAgeCount[3] = 0;
                _memoryPageAgeCount[0]++;
                _memoryPageAgeCount[1]++;
                _memoryPageAgeCount[2]++;
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
                    NSLog(@"%d",maxIndex);
                }
            }
            [_process.memoryList replaceObjectAtIndex:maxIndex withObject:_process.pageString];
            _memoryPageAgeCount[maxIndex] = 0;
            for (int j=0; j<maxIndex;j++)
            {
                _memoryPageAgeCount[j]++;
            }
            for (int k=maxIndex+1; k<[_process.memoryList count]; k++)
            {
                _memoryPageAgeCount[k]++;
            }
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
    _memoryLabelOne.text = @"空";
    _memoryLabelTwo.text = @"空";
    _memoryLabelThree.text = @"空";
    _memoryLabelFour.text = @"空";
    _process.oldestPage = 0;
    _process.lackCount = 0;
    _lackPageLabel.text = @"";
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
    _runningTimeLabel.text = [NSString stringWithFormat:@"%0.1fs", _process.runningTime];
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
    _numOfInstructLabel.text = [NSString stringWithFormat:@"%i条", _process.totalNumOfInstruct];
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
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
