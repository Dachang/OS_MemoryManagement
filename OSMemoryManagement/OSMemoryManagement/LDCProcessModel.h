//
//  LDCMemoryModel.h
//  OSMemoryManagement
//
//  Created by 大畅 on 13-11-18.
//  Copyright (c) 2013年 大畅. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDCProcessModel : NSObject

@property (strong, nonatomic) NSMutableArray *instructList;    //指令列表
@property (nonatomic) int countNum;

@property (strong, nonatomic) NSMutableArray *resultDataSource;      //输出结果信息保存
@property (strong, nonatomic) NSMutableArray *memoryList;  //内存块表

@property (strong, nonatomic) NSTimer *runTimer;    //运行时钟

@property (nonatomic) int instructNumber;   //指令编号
@property (nonatomic) int pageNumber;   //指令所属页号
@property (strong, nonatomic) NSString *codeString;    //指令信息字符串
@property (strong, nonatomic) NSString *pageString;    //页号信息字符串

@property (nonatomic) double runningTime;    //运行时
@property (nonatomic) int lackCount;       //缺页数
@property (nonatomic) int oldestPage;     //最早到达的页
@property (nonatomic) int totalNumOfInstruct;     //总页数

@end
