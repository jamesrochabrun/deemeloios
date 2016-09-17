//
//  FrontViewController.h
//  Deemelo
//
//  Created by Cesar Ortiz on 20-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomBarButtonItems.h"
#import "MHTabBarController.h"
#import "UIViewController+KNSemiModal.h"
@class FrontSearchViewController;

typedef enum {
    FrontSearchTypeClothing,
    FrontSearchTypeStore,
    FrontSearchTypePerson
} FrontSearchType;

@interface FrontViewController : UIViewController
{
    FrontSearchViewController *frontSearchVC;
}

@property (weak, nonatomic) IBOutlet UIView *frontContainerView;
@property (strong, nonatomic) MHTabBarController *tab;

// crear botón de notificaciones
- (UIBarButtonItem *)notifButtonWithCount:(int)count;

// actualizar botón de notificaciones
- (void)updateNotifButton;

// abrir notificaciones
- (void)notifButtonTapped:(id)sender;

// abrir buscador de prendas, tiendas, personas
- (void)searchButtonTapped:(id)sender;

// ejecutar tipo de búsqueda por tipo y string
- (void)showSearchResultForType:(FrontSearchType)searchType
                   searchString:(NSString *)searchString;

@end