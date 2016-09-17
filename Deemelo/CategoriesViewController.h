//
//  CategoriesViewController.h
//  Deemelo
//
//  Created by Cesar Ortiz on 20-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomBarButtonItems.h"
#import "AppDelegate.h"
#import "CategoryImagesViewController.h"

@interface CategoriesViewController : UIViewController<UITabBarControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *categorias, *filtroCategorias;
@property (nonatomic, weak) IBOutlet UISearchBar *searchFilterBar;
@property (nonatomic, weak) IBOutlet UITableView *table;
@property (nonatomic, assign) Boolean isFiltered;

- (void)backFromNewProductCategorySelection:(id)sender;

@end
