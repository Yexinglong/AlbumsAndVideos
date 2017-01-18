//
//  test.m
//  DDNM-NY
//
//  Created by 叶星龙 on 2017/1/17.
//  Copyright © 2017年 北京叮咚柠檬科技有限公司. All rights reserved.
//

#import "test.h"
#import "View+MASAdditions.h"
@interface test ()

@end

@implementation test

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *label =[UILabel new];
    label.numberOfLines=0;
    label.kFont(@12);
    label.kTextColor([UIColor blackColor]);
    label.kText([NSString stringWithFormat:@"%@",[self.selectArray componentsJoinedByString:@"\n"]]);
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    NSLog(@"test 选中了数组     %@",self.selectArray);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
