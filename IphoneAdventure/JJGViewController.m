//
//  JJGViewController.m
//  IphoneAdventure
//
//  Created by Jeff Gayle on 5/20/14.
//  Copyright (c) 2014 Jeff Gayle. All rights reserved.
//

#import "JJGViewController.h"

@interface JJGViewController () <CLLocationManagerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKLocalSearchResponse *response;

@end

@implementation JJGViewController

- (void)setResponse:(MKLocalSearchResponse *)response
{
    if (_response != response) {
        _response = response;
        
        // As soon as _response is set, reload the tableView
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 100;
    self.locationManager.desiredAccuracy = 5;
    
    [self.locationManager startUpdatingLocation];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", locations.lastObject);
    CLLocation *location = locations.lastObject;
    
    CLLocationCoordinate2D coordinate = location.coordinate;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 250, 250);
    
    [self.mapView setRegion:region animated:YES];
}

# pragma mark - SearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    
    [request setRegion:self.mapView.region];
    [request setNaturalLanguageQuery:searchBar.text];
    
    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        
        if (error) {
            NSLog(@"%@", [error localizedDescription]); return;
        }
        
        if (!response.mapItems.count) {
            NSLog(@"No results found"); return;
        }
        
        self.response = response;
    }];
}

#pragma mark = TableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.response.mapItems count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifer"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"identifer"];
    }
    
    MKMapItem *item = self.response.mapItems[indexPath.row];
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.placemark.addressDictionary[@"Street"];
    
    return cell;
}

#pragma mark - TableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchDisplayController setActive:NO animated:YES];
    [self.mapView addAnnotation:[self.response.mapItems[indexPath.row]placemark]];
}






@end
