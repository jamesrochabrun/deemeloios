//
//  UserCollectionViewController.h
//  Deemelo
//
//  Created by Marcelo Espina on 01-07-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSPullToRefresh/SSPullToRefresh.h>

@interface UserCollectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SSPullToRefreshViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSString *email;
@property (strong, nonatomic) NSMutableArray *collection;
@property (weak, nonatomic) UIStoryboard *myStoryboard;

@property (nonatomic, strong) SSPullToRefreshView *pullToRefreshView;

@end

// protocolo con los métodos requeridos para quienes hereden
@protocol UserCollectionViewController

@required

// método para cargar inicialmente la colección
- (void)loadCollection;

// método para recargar la colección iniciado desde el control de pull to refresh
//
// IMPORTANTE: la clase que implemente esté método debe ocuparse
// de activar y desactivar el indicador de pulltorefresh (pullToRefreshView)
// como en el siguiente ejemplo:
//
//  - (void)refreshCollection
//  {
//      [[self pullToRefreshView] startLoading];
//
//      // ejecutar el método requerido por el protocolo para cargar la colección
//      [self metodoDeEjemploParaRecargargarLaColección];
//
//      [[self pullToRefreshView] finishLoading];
//  }
- (void)refreshCollection;

@end
