//
//  PictureCollectionViewController.h
//  Deemelo
//
//  Created by Pablo Branchi on 6/24/13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICollectionViewWaterfallLayout.h"
#import "UICollectionViewWaterfallCell.h"
#import "ItemDetailViewController.h"
#import <SSPullToRefresh/SSPullToRefresh.h>
#import "SVPullToRefresh.h"

@interface PictureCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateWaterfallLayout, UICollectionViewDelegateFlowLayout, SSPullToRefreshViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *collection;
@property (weak, nonatomic) UIStoryboard *myStoryboard;
@property (strong, nonatomic) NSMutableArray *pendingImageViews;

@property (nonatomic, strong) SSPullToRefreshView *pullToRefreshView;

@end

// protocolo con los métodos requeridos para quienes hereden
@protocol PictureCollectionViewControllerDatasource

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

// método para cargar más elementos a la colección iniciado desde el control de infinite scrolling
//
// IMPORTANTE: la clase que implemente esté método debe ocuparse
// de
// 1) agregar más datos a la colección
// 2) insertar nuevas celdas al final del collectionview
// 3) desactivar el indicador de infinite scrolling mediante [tableView.infiniteScrollingView stopAnimating]
// como en el siguiente ejemplo:
//
// - (void)loadMoreCollectionItemsFromOffset:(NSNumber *)offset
// {
//     if ([self collection]) {
//         // cargar más fotos de la comunidad de la tienda
//         [APIProvider getStoreProfileCommunityPicturesFromStoreDisplayName:[[self selectedStore] name]
//                                                                    offset:[offset intValue]
//                                                               withSuccess:^(NSMutableArray *collection) {
//                                                                   [[self collection] addObjectsFromArray:collection];
//
//                                                                   [[self collectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
//
//                                                                   NSLog(@"Cargó las fotos de la comunidad de la tienda");
//
//                                                                   [[self pullToRefreshView] finishLoading];
//                                                                   [[[self collectionView] infiniteScrollingView] stopAnimating];
//                                                               }
//                                                                   failure:^{
//                                                                       NSLog(@"Error al cargar las fotos de la comunidad de la tienda");
//
//                                                                       [[self pullToRefreshView] finishLoading];
//                                                                       [[[self collectionView] infiniteScrollingView] stopAnimating];
//                                                                   }];
//     }
// }
- (void)loadMoreCollectionItemsFromOffset:(NSNumber *)offset;

@end
