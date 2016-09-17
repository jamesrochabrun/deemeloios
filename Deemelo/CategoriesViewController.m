//
//  CategoriesViewController.m
//  Deemelo
//
//  Created by Cesar Ortiz on 20-05-13.
//  Copyright (c) 2013 Acid. All rights reserved.
//

#import "CategoriesViewController.h"

@implementation CategoriesViewController

@synthesize categorias, filtroCategorias;
@synthesize isFiltered;
@synthesize searchFilterBar;
@synthesize table;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Vitrinea" image:nil tag:1];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"vitrina_activo.png"]
                      withFinishedUnselectedImage:[UIImage imageNamed:@"vitrina.png"]];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, 0, 0);
        self.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -3);
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    searchFilterBar.delegate = self;
    
    self.navigationItem.titleView = [CustomBarButtonItems titleView:self.navigationController.navigationBar view:self.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // traer categorías
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([[appDelegate categories] count] > 0) {
        
        self.categorias = appDelegate.categories;
        
    } else {
        // mostrar el indicador de cargando
        [SVProgressHUD show];
        
        // cargar categorías
        [APIProvider getCategoriesWithSuccess:^(NSMutableArray *collection) {
            [appDelegate setCategories:collection];
            self.categorias = appDelegate.categories;
            [[self table] reloadData];
            
            //NSLog(@"Cargó categorías");
            
            [SVProgressHUD dismiss];
        }
                                  withFailure:^{
                                      //NSLog(@"Error al cargar categorías");
                                      
                                      [SVProgressHUD dismiss];
                                  }];
    }
    
    // limpiar celda previamente seleccionada del tableview
    [[self table] deselectRowAtIndexPath:[[self table] indexPathForSelectedRow] animated:animated];
    
    // si estamos en el flujo para agregar nuevo producto,
    // agregar el botón "volver" al navbar
    if ([appDelegate isAddingNewProduct]) {
        UIImage *backImage = [UIImage imageNamed:@"back.png"];
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setBounds:CGRectMake( 0, 0, [backImage size].width, [backImage size].height)];
        [backButton setImage:backImage
                    forState:UIControlStateNormal];
        
        [backButton addTarget:self
                       action:@selector(backFromNewProductCategorySelection:)
             forControlEvents:UIControlEventTouchDown];
        
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        [[self navigationItem] setLeftBarButtonItem:backButtonItem];
    } else {
        [[self navigationItem] setLeftBarButtonItem:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rowCount;
    if(self.isFiltered)
        rowCount = filtroCategorias.count;
    else
        rowCount = categorias.count;
    
    return rowCount;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // apunto en el appdelegate a la instancia de store seleccionada
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Categories *categorySelected;
    if (isFiltered)
        categorySelected = ((Categories *)[filtroCategorias objectAtIndex:indexPath.row]);
    else
        categorySelected = ((Categories *)[categorias objectAtIndex:indexPath.row]);
    
    // escondo el teclado si es que está siendo mostrado
    [[self searchFilterBar] resignFirstResponder];
    
    if (![appDelegate isAddingNewProduct]) {
        
        // Si no estoy agregando un nuevo producto (entonces estoy consultando el bar button de categorías "Vitrina")
        
        // selecciono la categoría
        [appDelegate setCategorySelected:categorySelected];
        
        // muestro el listado de fotos de la categoría
        CategoryImagesViewController *categoryImagesVC =
            [[CategoryImagesViewController alloc] initWithNibName:nil bundle:nil];
        
        [categoryImagesVC setMyStoryboard:[self storyboard]];
        [categoryImagesVC setSelectedCategory:[appDelegate categorySelected]];
        
        [[self navigationController] pushViewController:categoryImagesVC animated:YES];
        
    } else {
        
        // Si estoy agregando un nuevo producto (entonces estoy dentro del flujo del bar button de la cámara)
        
        // agrego la categoría al producto
        [[appDelegate aNewProduct] setCategoryName:[categorySelected name]];
        
        // preguntar si agrega una ubicación al producto
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:@"¿Deseas agregar una ubicación?"
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"No", @"Sí", nil];
        [av setAlertViewStyle:UIAlertViewStyleDefault];
        [av show];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *simpleIdentifier = [NSString stringWithFormat:@"TableItem"];
    Categories *cat = [[Categories alloc] init];
    if(isFiltered)
        cat = ((Categories *)[filtroCategorias objectAtIndex:indexPath.row]);
    else
        cat = ((Categories *)[categorias objectAtIndex:indexPath.row]);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleIdentifier];
    }
    // setear el selected view
    UIView *selectedView = [[UIView alloc] init];
    [selectedView setBackgroundColor:[UIColor colorWithRed:(236/255.0)
                                                     green:(100/255.0)
                                                      blue:(114/255.0)
                                                     alpha:1]];
    [cell setSelectedBackgroundView:selectedView];
    
    // setear los datos de la celda
    cell.textLabel.text = cat.name;
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", cat.slug]];
    [cell.textLabel setTextColor:[UIColor grayColor]];
    return cell;
}

#pragma mark - UISearchBar Delegate Methods

- (void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0) {
        isFiltered = FALSE;
    } else {
        isFiltered = TRUE;
        filtroCategorias = [[NSMutableArray alloc] init];
        
        for (Categories* cat in categorias) {
            NSRange nameRange = [cat.name rangeOfString:text options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound) {
                [filtroCategorias addObject:cat];
            }
        }
    }
    [self.table reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self.table reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar setText:@""];
    [self searchBar:searchBar textDidChange:[searchBar text]];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

#pragma mark - métodos para usar en creación de nuevo producto

- (void)backFromNewProductCategorySelection:(id)sender
{
    // si cancelamos la toma de imagen, eliminar el nuevo producto que estábamos creando
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setIsAddingNewProduct:NO];
    [appDelegate setANewProduct:nil];
    
    //NSLog(@"\n\nPRESENTING VIEWCONTROLLER: %@\n\n", [self presentingViewController]);
    //NSLog(@"\n\nnPRESENTED VIEWCONTROLLER TO DISMISS: %@\n\n", [[self presentingViewController] presentedViewController]);
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
        // llamar al action sheet para crear imagen
        [appDelegate tabBarController:[appDelegate tabController]
           shouldSelectViewController:[appDelegate aNewProductNavController]];
    }];
}

#pragma mark - métodos para uialertviewdelegate
// flujo crear nuevo producto: alertview preguntó si quiere escoger tiendq
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // si clickee sí, entonces cargar viewcontroller de tienda
    if (buttonIndex == 1) {
        // cargar el viewcontroller del seleccionador de tiendas
        UIViewController *storeVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"newProductStore"];
        [[self navigationController] pushViewController:storeVC animated:YES];
    }
    
    // si clickeé no, entonces cargar subir nuevo producto
    if (buttonIndex == 0) {
        
        // agregar al property de tienda del producto un valor "en blanco"
        [[appDelegate aNewProduct] setStoreName:@""];
        
        [SVProgressHUD showWithStatus:@"Subiendo la imagen..."];
        
        // subir el nuevo producto
        [APIProvider createProduct:[appDelegate aNewProduct]];
        
        //[SVProgressHUD dismiss];//el dismiss lo hace el callback block que va en createProduct:
        
        //NSLog(@"\n\nPRESENTING VIEWCONTROLLER: %@\n\n", [self presentingViewController]);
        //NSLog(@"\n\nnPRESENTED VIEWCONTROLLER TO DISMISS: %@\n\n", [[self presentingViewController] presentedViewController]);
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
            // ir al perfil del usuario
            [[appDelegate tabController] setSelectedIndex:4];
            // eliminar referencia en el appdelegate respecto al nuevo producto que estábamos creando
            [appDelegate setIsAddingNewProduct:NO];
            [appDelegate setANewProduct:nil];
        }];
    }
}

@end
