//
//  LDCMemoryModel.m
//  OSMemoryManagement
//
//  Created by 大畅 on 13-11-18.
//  Copyright (c) 2013年 大畅. All rights reserved.
//

#import "LDCProcessModel.h"

@implementation LDCProcessModel

-(void)initProcessModel
{
    _instructList = [[NSMutableArray alloc] initWithObjects:nil];
    _resultDataSource = [[NSMutableArray alloc] initWithObjects:nil];
    _memoryList = [[NSMutableArray alloc] initWithObjects:nil];
    
    _lackCount = 0;
    _runningTime = 0.1f;
    _oldestPage = 0;
    _totalNumOfInstruct = 320;
}

@end
