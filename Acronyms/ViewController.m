//
//  ViewController.m
//  Acronyms
//
//  Created by Naresh Kalakuntla on 10/13/15.
//  Copyright (c) 2015 Madhumitha. All rights reserved.
//

#import "ViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>


@interface ViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *fullformsTableView;

@property (strong, nonatomic) NSMutableArray *listArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.fullformsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.listArray = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Searchbar delegates

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    if (searchBar.text && searchBar.text.length > 0) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Do something...
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=%@",searchBar.text];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];

            [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
                NSMutableData *data = responseObject;
                NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                [self _updateTableWithData:jsonData];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });

            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });

            }];
            
        });

    }
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [self.listArray objectAtIndex:indexPath.row];
    
    return cell;
    
}


- (void)_updateTableWithData:(NSArray *)data {
    
    NSMutableArray *tempArray = [NSMutableArray array];
    NSArray *dataArray = [data[0] objectForKey:@"lfs"];
    if (dataArray && dataArray.count > 0) {
        for (NSDictionary *listDic in dataArray) {
            if ([listDic objectForKey:@"lf"] && ((NSString *)[listDic objectForKey:@"lf"]).length > 0) {
                [tempArray addObject:[listDic objectForKey:@"lf"]];
            }
        }
    }
    self.listArray = [tempArray copy];
    [self.fullformsTableView reloadData];
    
}


@end
