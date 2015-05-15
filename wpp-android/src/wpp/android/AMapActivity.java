package wpp.android;

import android.os.Bundle;
import android.app.Activity;
import android.view.View;
import android.widget.Button;
import android.view.View.OnClickListener;
import android.widget.Toast;
import com.amap.api.maps2d.AMap;
import com.amap.api.location.AMapLocation;
import com.amap.api.maps2d.AMap.OnCameraChangeListener;
import com.amap.api.maps2d.AMap.OnMapLongClickListener;
import com.amap.api.maps2d.MapView;
import com.amap.api.maps2d.model.CameraPosition;
import com.amap.api.maps2d.model.TileOverlay;
import com.amap.api.maps2d.model.UrlTileProvider;
import com.amap.api.maps2d.model.LatLng;
import com.amap.api.services.core.LatLonPoint;
import com.amap.api.services.geocoder.GeocodeAddress;
import com.amap.api.services.geocoder.GeocodeQuery;
import com.amap.api.services.geocoder.GeocodeResult;
import com.amap.api.services.geocoder.GeocodeSearch;
import com.amap.api.services.geocoder.GeocodeSearch.OnGeocodeSearchListener;
import com.amap.api.services.geocoder.RegeocodeQuery;
import com.amap.api.services.geocoder.RegeocodeResult;
import com.amap.api.maps2d.model.Marker;
import com.amap.api.maps2d.model.MarkerOptions;
import com.amap.api.maps2d.CameraUpdateFactory;
import com.amap.api.maps2d.model.BitmapDescriptorFactory;
import com.amap.api.location.AMapLocationListener;
import com.amap.api.maps2d.LocationSource;
import com.amap.api.location.LocationManagerProxy;
import com.amap.api.maps2d.model.MyLocationStyle;
import android.location.Location;
import android.graphics.Color;
import com.amap.api.location.LocationProviderProxy;
import com.amap.api.maps2d.AMap.InfoWindowAdapter;
import android.widget.TextView;
import android.text.SpannableString;
import android.text.style.ForegroundColorSpan;
import android.content.Intent;

public class AMapActivity extends Activity implements OnMapLongClickListener,
OnGeocodeSearchListener, LocationSource, AMapLocationListener, InfoWindowAdapter {
    private MapView mapView;
    private AMap aMap;
    private LatLonPoint latLonPoint;
    private GeocodeSearch geocoderSearch;
    private String addressName;
    private Marker geoMarker;
    private Marker regeoMarker;
    private OnLocationChangedListener mListener;
    private LocationManagerProxy mAMapLocationManager;
    private Button confirmBtn;

    @Override
    public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(wpp.android.R.layout.amap_activity);
            mapView = (MapView) findViewById(wpp.android.R.id.map);
            mapView.onCreate(savedInstanceState);// 此方法必须重写

            confirmBtn = (Button) findViewById(wpp.android.R.id.confirm_location);

            init();
    }

    public void backBtnClicked(View view) {
        finish();
    }

    /**
     * 初始化AMap对象
     */
    private void init() {
        if (aMap == null) {
            aMap = mapView.getMap();

            // 自定义系统定位小蓝点
            MyLocationStyle myLocationStyle = new MyLocationStyle();
            myLocationStyle.myLocationIcon(BitmapDescriptorFactory
                            .fromResource(wpp.android.R.drawable.location_marker));// 设置小蓝点的图标
            myLocationStyle.strokeColor(Color.BLACK);// 设置圆形的边框颜色
            myLocationStyle.radiusFillColor(Color.argb(100, 0, 0, 180));// 设置圆形的填充颜色
            // myLocationStyle.anchor(int,int)//设置小蓝点的锚点
            myLocationStyle.strokeWidth(1.0f);// 设置圆形的边框粗细
            aMap.setMyLocationStyle(myLocationStyle);
            aMap.setLocationSource(this);// 设置定位监听
            aMap.getUiSettings().setMyLocationButtonEnabled(true);// 设置默认定位按钮是否显示
            aMap.setMyLocationEnabled(true);// 设置为true表示显示定位层并可触发定位，false表示隐藏定位层并不可触发定位，默认是false

            geoMarker = aMap.addMarker(new MarkerOptions().anchor(0.5f, 0.5f)
                            .icon(BitmapDescriptorFactory
                                            .defaultMarker(BitmapDescriptorFactory.HUE_BLUE)));
            regeoMarker = aMap.addMarker(new MarkerOptions().anchor(0.5f, 0.5f)
                            .icon(BitmapDescriptorFactory
                                            .defaultMarker(BitmapDescriptorFactory.HUE_RED)));

            aMap.setOnCameraChangeListener(new OnCameraChangeListener() {

                @Override
                public void onCameraChangeFinish(CameraPosition cameraPosition) {

                    System.out.println("zoom level is:"+cameraPosition.tilt );

                }

                @Override
                public void onCameraChange(CameraPosition arg0) {


                }
            });
            aMap.setOnMapLongClickListener(this);// 对amap添加长按地图事件监听器
            aMap.setInfoWindowAdapter(this);// 设置自定义InfoWindow样式

            confirmBtn.setOnClickListener(new OnClickListener() {

                    @Override
                    public void onClick(View v) {
                            // 把地址信息传递到c++并显示在qml中
//                            Toast.makeText(AMapActivity.this, "commingsoon======(addressname)===>"+addressName, Toast.LENGTH_SHORT).show();
                        Intent resultIntent = new Intent();
                        resultIntent.putExtra("addressName", addressName);
                        resultIntent.putExtra("latitude", String.valueOf(latLonPoint.getLatitude()));
                        resultIntent.putExtra("longitude", String.valueOf(latLonPoint.getLongitude()));
//                        Toast.makeText(AMapActivity.this, "latitude===>"+latLonPoint.getLatitude(), Toast.LENGTH_SHORT).show();
//                        Toast.makeText(AMapActivity.this, "longitude===>"+latLonPoint.getLongitude(), Toast.LENGTH_SHORT).show();
                        setResult(Activity.RESULT_OK, resultIntent);
                        finish();
                    }

            });

            geocoderSearch = new GeocodeSearch(this);
            geocoderSearch.setOnGeocodeSearchListener(this);
        }
    }

    /**
     * 方法必须重写
     */
    @Override
    protected void onResume() {
        super.onResume();
        mapView.onResume();
    }

    /**
     * 方法必须重写
     */
    @Override
    protected void onPause() {
        super.onPause();
        mapView.onPause();
    }

    /**
     * 方法必须重写
     */
    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        mapView.onSaveInstanceState(outState);
    }

    /**
     * 方法必须重写
     */
    @Override
    protected void onDestroy() {
        super.onDestroy();
        mapView.onDestroy();
    }

    /**
     * 对长按地图事件回调
     */
    @Override
    public void onMapLongClick(LatLng point) {
            //Toast.makeText(this, "long pressed, point=" + point, Toast.LENGTH_SHORT).show();
            latLonPoint = new LatLonPoint(point.latitude, point.longitude);
            getAddress(latLonPoint);
    }

    /**
     * 响应逆地理编码
     */
    public void getAddress(final LatLonPoint latLonPoint) {
            RegeocodeQuery query = new RegeocodeQuery(latLonPoint, 200,
                            GeocodeSearch.AMAP);// 第一个参数表示一个Latlng，第二参数表示范围多少米，第三个参数表示是火系坐标系还是GPS原生坐标系
            geocoderSearch.getFromLocationAsyn(query);// 设置同步逆地理编码请求
    }

    /**
     * 地理编码查询回调
     */
    @Override
    public void onGeocodeSearched(GeocodeResult result, int rCode) {

//            if (rCode == 0) {
//                    if (result != null && result.getGeocodeAddressList() != null
//                                    && result.getGeocodeAddressList().size() > 0) {
//                            GeocodeAddress address = result.getGeocodeAddressList().get(0);
//                            aMap.animateCamera(CameraUpdateFactory.newLatLngZoom(
//                                            AMapUtil.convertToLatLng(address.getLatLonPoint()), 15));
//                            geoMarker.setPosition(AMapUtil.convertToLatLng(address
//                                            .getLatLonPoint()));
//                            addressName = "经纬度值:" + address.getLatLonPoint() + "\n位置描述:"
//                                            + address.getFormatAddress();
//                            ToastUtil.show(GeocoderActivity.this, addressName);
//                    } else {
//                            ToastUtil.show(GeocoderActivity.this, R.string.no_result);
//                    }

//            } else if (rCode == 27) {
//                    ToastUtil.show(GeocoderActivity.this, R.string.error_network);
//            } else if (rCode == 32) {
//                    ToastUtil.show(GeocoderActivity.this, R.string.error_key);
//            } else {
//                    ToastUtil.show(GeocoderActivity.this,
//                                    getString(R.string.error_other) + rCode);
//            }
    }

    /**
     * 逆地理编码回调
     */
    @Override
    public void onRegeocodeSearched(RegeocodeResult result, int rCode) {

            if (rCode == 0) {
                    if (result != null && result.getRegeocodeAddress() != null
                                    && result.getRegeocodeAddress().getFormatAddress() != null) {
                            addressName = result.getRegeocodeAddress().getFormatAddress()
                                            + "附近";
                            aMap.animateCamera(CameraUpdateFactory.newLatLngZoom(
                                            AMapUtil.convertToLatLng(latLonPoint), 15));
                            regeoMarker.setPosition(AMapUtil.convertToLatLng(latLonPoint));
                            regeoMarker.setTitle(addressName);
//                            Toast.makeText(AMapActivity.this, addressName, Toast.LENGTH_SHORT).show();
                            //ToastUtil.show(AMapActivity.this, addressName);
                            regeoMarker.showInfoWindow();// 设置默认显示一个infowinfow
                            if (!confirmBtn.isShown()) confirmBtn.setVisibility(View.VISIBLE);
                    } else {
                            //ToastUtil.show(GeocoderActivity.this, wpp.android.R.string.no_result);
                    }
            } else if (rCode == 27) {
                    //ToastUtil.show(GeocoderActivity.this, wpp.android.R.string.error_network);
            } else if (rCode == 32) {
                    //ToastUtil.show(GeocoderActivity.this, wpp.android.R.string.error_key);
            } else {
                    //ToastUtil.show(GeocoderActivity.this,
                                    //getString(wpp.android.R.string.error_other) + rCode);
            }
    }

    /**
     * 此方法已经废弃
     */
    @Override
    public void onLocationChanged(Location location) {
    }

    @Override
    public void onProviderDisabled(String provider) {
    }

    @Override
    public void onProviderEnabled(String provider) {
    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {
    }

    /**
     * 定位成功后回调函数
     */
    @Override
    public void onLocationChanged(AMapLocation aLocation) {
            if (mListener != null && aLocation != null) {
                    mListener.onLocationChanged(aLocation);// 显示系统小蓝点
            }
    }

    /**
     * 激活定位
     */
    @Override
    public void activate(OnLocationChangedListener listener) {
            mListener = listener;
            if (mAMapLocationManager == null) {
                    mAMapLocationManager = LocationManagerProxy.getInstance(this);
                    /*
                     * mAMapLocManager.setGpsEnable(false);
                     * 1.0.2版本新增方法，设置true表示混合定位中包含gps定位，false表示纯网络定位，默认是true Location
                     * API定位采用GPS和网络混合定位方式
                     * ，第一个参数是定位provider，第二个参数时间最短是2000毫秒，第三个参数距离间隔单位是米，第四个参数是定位监听者
                     */
                    mAMapLocationManager.requestLocationUpdates(
                                    LocationProviderProxy.AMapNetwork, 2000, 10, this);
            }
    }

    /**
     * 停止定位
     */
    @Override
    public void deactivate() {
            mListener = null;
            if (mAMapLocationManager != null) {
                    mAMapLocationManager.removeUpdates(this);
                    mAMapLocationManager.destory();
            }
            mAMapLocationManager = null;
    }

    /**
     * 监听自定义infowindow窗口的infocontents事件回调
     */
    @Override
    public View getInfoContents(Marker marker) {
            View infoContent = getLayoutInflater().inflate(
                            wpp.android.R.layout.custom_info_contents, null);
            render(marker, infoContent);
            return infoContent;
    }

    /**
     * 监听自定义infowindow窗口的infowindow事件回调
     */
    @Override
    public View getInfoWindow(Marker marker) {
            View infoWindow = getLayoutInflater().inflate(
                            wpp.android.R.layout.custom_info_window, null);

            render(marker, infoWindow);
            return infoWindow;
    }

    /**
     * 自定义infowinfow窗口
     */
    public void render(Marker marker, View view) {
            String title = marker.getTitle();
            TextView titleUi = ((TextView) view.findViewById(wpp.android.R.id.title));
            if (title != null) {
                    SpannableString titleText = new SpannableString(title);
                    titleText.setSpan(new ForegroundColorSpan(Color.RED), 0,
                                    titleText.length(), 0);
                    titleUi.setTextSize(15);
                    titleUi.setText(titleText);

            } else {
                    titleUi.setText("");
            }
            String snippet = marker.getSnippet();
            TextView snippetUi = ((TextView) view.findViewById(wpp.android.R.id.snippet));
            if (snippet != null) {
                    SpannableString snippetText = new SpannableString(snippet);
                    snippetText.setSpan(new ForegroundColorSpan(Color.GREEN), 0,
                                    snippetText.length(), 0);
                    snippetUi.setTextSize(20);
                    snippetUi.setText(snippetText);
            } else {
                    snippetUi.setText("");
            }
    }

}

