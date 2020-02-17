//
//  ACLocationSelectionViewController.swift
//  alltimecommunicator
//
//  Created by Nishanth Kumar N S on 29/04/19.
//  Copyright © 2019 Droid5. All rights reserved.
//

import Alamofire
import GoogleMaps
import GooglePlaces
import MapKit
import UIKit

protocol locationDataDelegate: AnyObject {
    func userLocationData(info: String, locationId: String, address: String)
}

class ACLocationSelectionViewController: UIViewController, GMSMapViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, DataEnteredDelegate {
    @IBOutlet var closebutton: UIButton!

    @IBOutlet var tickImage: UIImageView!
    @IBOutlet var confirmBtn: UIButton!
    @IBOutlet var clearbutton: UIButton!
    @IBOutlet var shadowView: GradientView!
    @IBOutlet var verifyButton: UIButton!
    @IBOutlet var resultsTableView: UITableView!
    @IBOutlet var customView: UIStackView!
    // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
    let token = GMSAutocompleteSessionToken()

    @IBOutlet var searchView: UIView!

    @IBOutlet var selectCityView: UIView!
    @IBOutlet var citySearchTf: PaddedTextField!

    @IBOutlet var changeBtn: UIButton!

    @IBOutlet var verifyView: UIView!

    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var searchBar: UITextField!

    var searchResults = [GMSAutocompletePrediction]()
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?

    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0

    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    var mapPlaces: NSArray = []

    // The currently selected place.
    var selectedPlace: GMSPlace?
    var groupLocationId: String = ""
    var address: String = ""
    var locationName = ""
    
    // Create a type filter.
    let filter = GMSAutocompleteFilter()
    var delegate = UIApplication.shared.delegate as? AppDelegate
    weak var datadelegate: locationDataDelegate?
    var currentCoordinate = CLLocationCoordinate2D()

    override func viewDidLoad() {
        super.viewDidLoad()
        filter.type = .noFilter
        resultsTableView.tableFooterView = UIView(frame: .zero)
        resultsTableView.backgroundColor = .clear
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        customView.backgroundColor = .clear
        verifyView.isHidden = true

        searchBar.delegate = self
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.delegate = self
        navigationController?.navigationBar.isHidden = true
        confirmBtn.isEnabled = false
        confirmBtn.backgroundColor = .gray

        placesClient = GMSPlacesClient.shared()

        let camera = GMSCameraPosition.camera(withLatitude: 47.603,
                                              longitude: -122.331,
                                              zoom: 14)
        mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true

        if let city = UserDefaults.standard.string(forKey: "usercity") {
            if let cityid = UserDefaults.standard.string(forKey: "usercityid") {
                citySearchTf.text = city
                searchView.isHidden = false
                changeBtn.isHidden = false
            } else {
                searchView.isHidden = true
                changeBtn.isHidden = true
            }

        } else {
            searchView.isHidden = true
            changeBtn.isHidden = true
        }

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_: Bool) {
        view.addSubview(mapView)
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()

            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }

        if let mylocation = mapView.myLocation {
            print("User's location: \(mylocation)")
        } else {
            print("User's location is unknown")
        }

        view.bringSubviewToFront(customView)
        view.bringSubviewToFront(verifyView)
        view.bringSubviewToFront(shadowView)
        view.bringSubviewToFront(closebutton)
    }

    // Declare GMSMarker instance at the class level.
    let infoMarker = GMSMarker()

    // Attach an info window to the POI using the GMSMarker.

    func mapView(_: GMSMapView, didTapPOIWithPlaceID placeID: String,
                 name: String, location: CLLocationCoordinate2D) {
        print("You tapped \(name): \(placeID), \(location.latitude)/\(location.longitude)")

        getDetailsFOrPlaceId(placeId: placeID)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn _: NSRange, replacementString _: String) -> Bool {
        verifyView.isHidden = true

        searchBasedOfPredicates(keywird: textField.text!)

        return true
    }

    func searchBasedOfPredicates(keywird: String) {
        let filter = GMSAutocompleteFilter()
        filter.country = "IN"
        filter.type = .establishment
        var viewPort: GMSCoordinateBounds = GMSCoordinateBounds()
        let sneLat = UserDefaults.standard.double(forKey: "northEastLat")
        let sneLng = UserDefaults.standard.double(forKey: "northEastLng")
        let sswLat = UserDefaults.standard.double(forKey: "southWestLat")
        let sswLng = UserDefaults.standard.double(forKey: "southWestLng")
        let ne = CLLocationCoordinate2D(latitude: sneLat, longitude: sneLng)
        let sw = CLLocationCoordinate2D(latitude: sswLat, longitude: sswLng)
        viewPort = viewPort.includingCoordinate(ne)
        viewPort = viewPort.includingCoordinate(sw)

        placesClient?.findAutocompletePredictions(fromQuery: keywird,
                                                  bounds: viewPort,
                                                  boundsMode: GMSAutocompleteBoundsMode.restrict,
                                                  filter: filter,
                                                  sessionToken: token,
                                                  callback: { results, error in
                                                      if let error = error {
                                                          print("Autocomplete error: \(error)")
                                                      }
                                                      if let results = results {
                                                          self.searchResults = results
                                                          if self.searchResults.count > 0 {
                                                              self.resultsTableView.isHidden = false
                                                          } else {}
                                                          self.resultsTableView.reloadData()
                                                          for result in results {
                                                              print("Result \(result.attributedFullText) with placeID \(result.placeID)")
                                                          }
                                                      }
        })
    }

    func searchLocationBasedOnKeyword(keywird: String) {
        let requestModel = mapSearchRequestModel()
        requestModel.auth = DefaultDataProcessor().getAuthDetails()
        requestModel.lat = String(currentCoordinate.latitude)
        requestModel.lon = String(currentCoordinate.longitude)
        requestModel.keyword = keywird

        NetworkingManager.searchLocation(getGroupModel: requestModel) { (result: Any, sucess: Bool) in
            if let result = result as? NSDictionary, sucess {
                let stat = result["status"] as! String
                if stat == "OK" {
                    self.mapPlaces = result["results"] as! NSArray
                    if self.mapPlaces.count > 0 {
                        self.resultsTableView.isHidden = false
                    } else {
                        self.resultsTableView.isHidden = true
                    }
                    self.resultsTableView.reloadData()
                } else {
                    self.resultsTableView.isHidden = true
                }
            }
        }
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.attributedText = searchResults[indexPath.row].attributedFullText
        cell.detailTextLabel?.text = searchResults[indexPath.row].placeID
        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        getDetailsFOrPlaceId(placeId: searchResults[indexPath.row].placeID)

        infoMarker.snippet = searchResults[indexPath.row].placeID
        //        infoMarker.position = searchResults[indexPath.row]
        infoMarker.title = searchResults[indexPath.row].attributedPrimaryText.string
        infoMarker.opacity = 0
        infoMarker.infoWindowAnchor.y = 1
        infoMarker.map = mapView
        mapView.selectedMarker = infoMarker
        resultsTableView.isHidden = true
        searchBar.text = searchResults[indexPath.row].attributedFullText.string
        searchBar.resignFirstResponder()
    }

    @IBAction func closeViewBtn(_: Any) {
        navigationController?.navigationBar.isHidden = false

        navigationController?.popViewController(animated: true)
    }

    @IBAction func onCLickOfCloseButton(_: Any) {
        resultsTableView.isHidden = true
        searchBar.text = ""
    }

    let requestModel = TwilioRequestModel()

    @IBAction func onClickOfVerifyButton(_: Any) {
        if delegate != nil {
            if (delegate?.isInternetAvailable)! {
                if let cityId = UserDefaults.standard.string(forKey: "usercityid") {
                    requestModel.auth = DefaultDataProcessor().getAuthDetails()

                    let countyCode = UserDefaults.standard.string(forKey: UserKeys.countryCode)
                    let length = UserDefaults.standard.string(forKey: UserKeys.numberLength)

                    var contactNumber = phoneNumberLabel.text!.extStrippedSpecialCharactersFromNumbers
                    if contactNumber.count == Int(length ?? "") {
                        contactNumber = (countyCode ?? "") + contactNumber
                    }
                    //                requestModel.phone = contactNumber
                    requestModel.phone = "+" + UserDefaults.standard.string(forKey: UserKeys.userPhoneNumber)!
                    requestModel.cityId = cityId

                    NetworkingManager.TwilioGetOTP(getGroupModel: requestModel) { (result: Any, sucess: Bool) in
                        if let result = result as? UpdateOtpResponse, sucess {
                            if result.status == "Success" {
                                let storyBoard = UIStoryboard(name: "OnBoarding", bundle: nil)
                                if let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ACVerifyBusinessOtpViewController") as? ACVerifyBusinessOtpViewController {
                                    nextViewController.requestModel = self.requestModel
                                    nextViewController.datadelegate = self
                                    UserDefaults.standard.set(self.nameLabel.text!, forKey: "locationname")

                                    self.present(nextViewController, animated: true, completion: nil)
                                }

                            } else {
                                if result.status == "Exception" {
                                    let errorMsg = result.errorMsg[0]
                                    print("Login error:", errorMsg)
                                    self.alert(message: errorMsg)
                                }
                            }
                        }
                    }

                } else {
                    alert(message: "Select your city to verify")
                }
            }
        }
    }

    @IBAction func onCLickOfConfirmButton(_: Any) {
        navigationController?.navigationBar.isHidden = false

        datadelegate?.userLocationData(info: locationName, locationId: groupLocationId, address: self.requestModel.address)
        navigationController?.popViewController(animated: true)
    }

    func getDetailsFOrPlaceId(placeId: String) {
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue) | UInt(GMSPlaceField.phoneNumber.rawValue) | UInt(GMSPlaceField.formattedAddress.rawValue) | UInt(GMSPlaceField.addressComponents.rawValue))!

        placesClient?.fetchPlace(fromPlaceID: placeId, placeFields: fields, sessionToken: nil, callback: {
            (place: GMSPlace?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            if let place = place {
                self.infoMarker.snippet = place.formattedAddress
                self.infoMarker.position = place.coordinate
                self.infoMarker.title = place.name
                self.infoMarker.opacity = 0
                self.infoMarker.infoWindowAnchor.y = 1
                self.infoMarker.map = self.mapView
                self.mapView.selectedMarker = self.infoMarker
                let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 16)
                self.mapView?.camera = camera
                self.mapView?.animate(to: camera)

                self.nameLabel.text = place.name
                self.phoneNumberLabel.text = place.phoneNumber
                if self.phoneNumberLabel.text == "" || place.phoneNumber == nil {
                    self.phoneNumberLabel.text = "(Phone number is not available)"
                    self.verifyButton.isHidden = true
                } else {
                    self.verifyButton.isHidden = false
                }

                let addressComponents = place.addressComponents
                for components in addressComponents! {
                    if components.types[0] == "country" {
                        self.requestModel.country = components.name
                    }
                    if components.types[0] == "sublocality_level_1" {
                        self.requestModel.subLocality = components.name
                    }

                    if components.types[0] == "postal_code" {
                        self.requestModel.zip = components.name
                    }

                    if components.types[0] == "administrative_area_level_1" {
                        self.requestModel.state = components.name
                        self.requestModel.stateShortName = components.shortName ?? ""
                    }

                    if components.types[0] == "administrative_area_level_1" {
                        self.requestModel.postalTown = components.name
                    }

                    if components.types[0] == "locality" {
                        self.requestModel.locality = components.name
                    }
                }
                self.requestModel.latitude = String(place.coordinate.latitude)
                self.requestModel.longitude = String(place.coordinate.longitude)
                self.requestModel.address = place.formattedAddress!
                self.requestModel.mapLocationId = place.placeID!
                self.requestModel.mapServiceProvider = "1"
                self.requestModel.verifyMethod = "1"

                self.searchBar.text = (place.name ?? "") + ", " + (place.formattedAddress ?? "")

                print(place.phoneNumber)
                self.locationName = place.name ?? ""
//                self.updateSelctedPlace(place)
                print("The selected place is: \(place.name ?? "")")
                self.verifyButton.setTitle("Verify", for: .normal)
                self.verifyButton.isUserInteractionEnabled = true
                self.confirmBtn.isEnabled = false
                self.confirmBtn.backgroundColor = .gray
                self.verifyView.isHidden = false
            }
        })
    }

    func userDidEnterInformation(info: String) {
        verifyButton.setTitle("Verified", for: .normal)
        verifyButton.isUserInteractionEnabled = false
        confirmBtn.isEnabled = true
        confirmBtn.backgroundColor = UIColor(r: 33, g: 140, b: 141)
        groupLocationId = info
    }

    @IBAction func onClickOfAutoSearch(_: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self

        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.viewport.rawValue) | UInt(GMSPlaceField.formattedAddress.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteController.placeFields = fields

        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.country = "IN"
        filter.type = .city
        autocompleteController.autocompleteFilter = filter

        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
}

extension ACLocationSelectionViewController: CLLocationManagerDelegate {
    // Handle incoming location events.
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        currentCoordinate = location.coordinate
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)

        mapView?.animate(to: camera)

        // Finally stop updating location otherwise it will come again and again in this delegate
        locationManager.stopUpdatingLocation()
    }

    // Handle authorization for the location manager.
    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }

    // Handle location manager errors.
    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

class MapUtil {
    class func translateCoordinate(coordinate: CLLocationCoordinate2D, metersLat: Double, metersLong: Double) -> (CLLocationCoordinate2D) {
        var tempCoord = coordinate

        let tempRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: metersLat, longitudinalMeters: metersLong)
        let tempSpan = tempRegion.span

        tempCoord.latitude = coordinate.latitude + tempSpan.latitudeDelta
        tempCoord.longitude = coordinate.longitude + tempSpan.longitudeDelta

        return tempCoord
    }
}

extension ACLocationSelectionViewController: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.
    fileprivate func updateSelctedPlace(_ place: GMSPlace) {
        UserDefaults.standard.setValue(place.name, forKey: "usercity")
        UserDefaults.standard.setValue(place.placeID, forKey: "usercityid")
        UserDefaults.standard.setValue(place.phoneNumber, forKey: "userLocationPhNo")
        UserDefaults.standard.setValue(place.viewport?.northEast.latitude, forKey: "northEastLat")
        UserDefaults.standard.setValue(place.viewport?.northEast.longitude, forKey: "northEastLng")
        UserDefaults.standard.setValue(place.viewport?.southWest.latitude, forKey: "southWestLat")
        UserDefaults.standard.setValue(place.viewport?.southWest.longitude, forKey: "southWestLng")
        selectedPlace = place
    }

    func viewController(_: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place ID: \(place.placeID)")

        updateSelctedPlace(place)
        searchView.isHidden = false
        citySearchTf.text = place.name
        changeBtn.isHidden = false

        dismiss(animated: true, completion: nil)
    }

    func viewController(_: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }

    // User canceled the operation.
    func wasCancelled(_: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }

    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(_: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
