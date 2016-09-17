//
//  UserCollectionViewController.m
//  Deemelo
//
//  Created by Marcelo Espina on 01-07-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "UserCollectionViewController.h"

#import "ProfileViewController.h"
#import "UserTableViewCell.h"

@interface UserCollectionViewController ()

@end

@implementation UserCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // necesario para que no se creen celdas vacías
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    [[self tableView] setTableFooterView:footer];
    
    // Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"UserTableViewCell" bundle:nil];
    
    // Register this NIB which contains the cell
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"UserTableViewCell"];
    
    // agregar control para pull to refresh del collectionview
    [self setPullToRefreshView:[[SSPullToRefreshView alloc] initWithScrollView:[self tableView] delegate:self]];
    
    // ejecutar el método requerido por el protocolo para cargar la colección
    [self performSelector:@selector(loadCollection)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // limpiar celda previamente seleccionada del tableview
    [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:animated];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self collection] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserTableViewCell"];
    
    // Setear el selected view con los colores corporativos
    UIView *selectedView = [[UIView alloc] init];
    [selectedView setBackgroundColor:[UIColor colorWithRed:(236/255.0)
                                                     green:(100/255.0)
                                                      blue:(114/255.0)
                                                     alpha:1]];
    [cell setSelectedBackgroundView:selectedView];
    
    // Obtengo una referencia al usuario (follower) que se va a mostrar en la cell
    User *user = [[self collection] objectAtIndex:[indexPath row]];
    
    [[cell nameLabel] setText:[user name]];
    [[cell avatarImageView] setImageWithURL:[NSURL URLWithString:[user routeThumbnail]]];
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Cargo una referencia a la vista del Storyborad que muestra un perfil de usuario
    ProfileViewController *profileViewController = [[self myStoryboard] instantiateViewControllerWithIdentifier:@"profileViewController"];
    
    // A la vista del perfil le indico que email debe utilizar para cargarse
    [profileViewController setCurrentEmail:[[[self collection] objectAtIndex:[indexPath row]] email]];
    
    // Muestro la prenda en la vista previamente cargada
    [[self navigationController] pushViewController:profileViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61;
}

#pragma mark - SSPullToRefreshView Delegate Methods
- (BOOL)pullToRefreshViewShouldStartLoading:(SSPullToRefreshView *)view
{
    return YES;
}

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view
{
    [self setCollection:nil];
    
    // Muestro el indicador de cargando
    [[self pullToRefreshView] startLoading];

    [self performSelector:@selector(refreshCollection)];
}

- (void)pullToRefreshViewDidFinishLoading:(SSPullToRefreshView *)view
{
    //NSLog(@"FinishLoading");
}

@end
