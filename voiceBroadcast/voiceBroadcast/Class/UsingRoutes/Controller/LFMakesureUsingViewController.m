//
//  LFMakesureUsingViewController.m
//  voiceBroadcast
//
//  Created by apple on 2017/11/13.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//

#import "LFMakesureUsingViewController.h"
#import <MapKit/MapKit.h>
#import "NewAnnotation.h"
#import "BXChooseRouteModel.h"
#import "LFPlayAudioViewController.h"
#import "BXLocationManager.h"

@interface LFMakesureUsingViewController ()<MKMapViewDelegate>
@property(nonatomic,strong)MKMapView *mapView;
@property (strong,nonatomic) NSMutableArray *routesArrayM;
@end

@implementation LFMakesureUsingViewController
- (NSMutableArray *)routesArrayM{
    if (!_routesArrayM) {
        _routesArrayM = [NSMutableArray new];
    }
    return _routesArrayM;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLocationManagerProperty];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.whichWay;
    [self creatMapView];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self postToServiceForSourcedata];
    });
}




#pragma mark -- 创建地图
- (void)creatMapView {
    _mapView = [[MKMapView alloc] init];
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    _mapView.mapType = MKMapTypeStandard;
    _mapView.pitchEnabled = NO;//禁止3D旋转
    [self.view addSubview:_mapView];

    UIButton *makesureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [makesureBtn setBackgroundColor:THEMECOLOR];
    NSAttributedString *titleAttri = [[NSAttributedString alloc] initWithString:@"开始模拟考试" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [makesureBtn setAttributedTitle:titleAttri forState:UIControlStateNormal];
    [makesureBtn addTarget:self action:@selector(makesureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:makesureBtn];

    CLLocation *location = [[CLLocation alloc] init];
    location = [location locationMarsFromEarth];//转火星坐标
    MKCoordinateRegion region =MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.000001,0.000001));
    [_mapView setRegion:region animated:YES];


    [makesureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.height.mas_equalTo(50);
    }];
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.offset(0);
        make.bottom.mas_equalTo(makesureBtn.mas_top).offset(0);
    }];

}
- (void)makesureBtnClick{
    LFPlayAudioViewController *playAudioVC = [LFPlayAudioViewController new];
    playAudioVC.usingRouteInfoArray = self.routesArrayM;
    [self.navigationController pushViewController:playAudioVC animated:YES];
}
- (void)setLocationManagerProperty{
    [[BXLocationManager manager] requestWhenInUseAuthorization];
}



-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView * result = nil;
    if([annotation isKindOfClass:[MKUserLocation class]])
    {
        MKAnnotationView *iAnnotation=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation2"];
        iAnnotation.image = [UIImage imageNamed:@"car_icon"];
        iAnnotation.canShowCallout=NO;
        return iAnnotation;
    }

    if([mapView isEqual:self.mapView] == NO)
    {
        return result;
    }
    NewAnnotation *annotationView =
    annotationView = [[NewAnnotation alloc]initWithAnnotation:annotation reuseIdentifier:@"otherAnnotationView"];
    return annotationView;
}

#pragma mark -- 从服务器获取到当前的选择的路线的经纬度
- (void)postToServiceForSourcedata{
    __weak typeof(self)weakSelf = self;
    [[BXHttpManager manager] POST:@"http://www.baixinxueche.com/index.php/Home/Apitokenptchoose/sendRoute" parameters:[NSString stringWithFormat:@"id=%@",self.routeID] Success:^(id responseObject) {
        NSLog(@"获取到该路线的内容  -- %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if ([[NSString stringWithFormat:@"%@",dic[@"code"]] isEqualToString:@"200"]) {
            //路线获取成功
            NSArray *array = [NSArray arrayWithArray:dic[@"result"]];
            for (int i= 0; i<array.count; i++) {
                BXChooseRouteModel *model = [BXChooseRouteModel initWithDic:array[i]];
                [weakSelf.routesArrayM addObject:model];
            }


            [weakSelf.mapView removeAnnotations:weakSelf.mapView.annotations];
            [weakSelf.mapView removeOverlays:weakSelf.mapView.overlays];
            NSMutableArray *latlonArrayM = [NSMutableArray new];
            for (int j=0; j<weakSelf.routesArrayM.count; j++) {
                BXChooseRouteModel *model = weakSelf.routesArrayM[j];
                NSArray *lat_lonArray = [model.lat_lon componentsSeparatedByString:@","];
                NSMutableDictionary *dicM = [NSMutableDictionary new];
                [dicM setValue:lat_lonArray[1] forKey:@"latitude"];
                [dicM setValue:lat_lonArray[0] forKey:@"longitude"];
                [latlonArrayM addObject:dicM];

                CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([lat_lonArray[1] doubleValue], [lat_lonArray[0] doubleValue]);
                MyAnnotation * myAnnotation = [[MyAnnotation alloc] initWithCoordinates:coor title:[NSString stringWithFormat:@"%d.%@",j+1,model.name] subTitle:@""];
                [weakSelf.mapView addAnnotation:myAnnotation];

                if (j==0) {
                    //将路线最后一个点的位置作为整个地图的正中心的位置
                    [weakSelf.mapView setCenterCoordinate:coor];
                }

            }

            [weakSelf drawline:latlonArrayM];
        }

    } andFailure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络错误"];
        [weakSelf performSelector:@selector(dismissHUD) withObject:nil afterDelay:2];
    }];
}

- (void)dismissHUD{
    [SVProgressHUD dismiss];
}
-(void) drawline: (NSArray*)nowRoadArrary
{
    //  将array中的信息点转换成CLLocationCoordinate2D数组
    CLLocationCoordinate2D coords[nowRoadArrary.count];

    int i = 0;
    for (NSDictionary *newDic in nowRoadArrary) {
        CLLocationCoordinate2D annotationCoord;
        id lat =  [newDic objectForKey:@"latitude"];
        annotationCoord.latitude = [lat doubleValue];
        annotationCoord.longitude = [[newDic objectForKey:@"longitude"] doubleValue];
        coords[i] = annotationCoord;
        i++;
    }

    //用MKPolyline画线并作为overlay添加进mapView
    MKPolyline *cc = [MKPolyline polylineWithCoordinates:coords count:nowRoadArrary.count];
    [self.mapView addOverlay:cc];
}
//完成MapView的delegate
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        //如果有MKPloylineView的overlay,将其画出
        MKPolylineView *lineview=[[MKPolylineView alloc]initWithOverlay:overlay] ;
        //路线颜色
        lineview.strokeColor=[UIColor orangeColor];
        lineview.lineWidth=8.0;
        return lineview;
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
