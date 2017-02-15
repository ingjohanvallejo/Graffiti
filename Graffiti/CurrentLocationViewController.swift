//
//  CurrentLocationViewController.swift
//  Graffiti
//
//  Created by Johan Vallejo on 13/12/16.
//  Copyright © 2016 kijho. All rights reserved.
//

import UIKit
import MapKit

class CurrentLocationViewController: UIViewController {


    @IBOutlet var getButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tagButton: UIBarButtonItem!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    let graffitiManager = GraffitiManager.sharedInstance
    var selectedCalloutImage : UIImage?
    var graffiti : Graffiti?
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var updatingLocation : Bool = false {
        didSet {
            if updatingLocation {
                getButton.setImage(#imageLiteral(resourceName: "btn_localizar_off"), for: .normal)
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                getButton.isUserInteractionEnabled = false
            } else {
                getButton.setImage(#imageLiteral(resourceName: "btn_localizar_on"), for: .normal)
                activityIndicator.isHidden = true
                activityIndicator.stopAnimating()
                getButton.isUserInteractionEnabled = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        graffitiManager.load()
        let image = #imageLiteral(resourceName: "img_navbar_title")
        self.navigationItem.titleView = UIImageView(image: image)
        updatingLocation = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.delegate = self
        mapView.addAnnotations(graffitiManager.graffitis)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func getLocationPressed(_ sender: UIButton) {
        startLocationManager()
    }

    //Iniciar la localizacion con presición de 10 metros
    func startLocationManager() {
        let authStatus = CLLocationManager.authorizationStatus()
        switch authStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            showLocationServicesDeniedAlert()
        default:
            if CLLocationManager.locationServicesEnabled() {
                self.updatingLocation = true
                self.tagButton.isEnabled = false
                locationManager.delegate = self
                locationManager.desiredAccuracy =  kCLLocationAccuracyNearestTenMeters
                locationManager.requestLocation()
                //Hacemos zoom sobre la localización del ususario
                let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
                mapView.setRegion(mapView.regionThatFits(region), animated: true)
            }
        }
    }

    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Localización Desactivada",
                                      message: "Por favor activa la localización para esta app en ajustes",
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        var line1 = ""
        if let s = placemark.thoroughfare {
            line1 += s + ", "
        }
        if let s = placemark.subThoroughfare {
            line1 += s
        }

        var line2 = ""
        if let s = placemark.postalCode {
            line2 += s + " "
        }
        if let s = placemark.locality {
            line2 += s
        }
        
        var line3 = ""
        if let s = placemark.administrativeArea {
            line3 += s + ", "
        }
        if let s = placemark.subAdministrativeArea {
            line3 += s
        }

        return line1 + "\n" + line2 + "\n" + line3
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tagGraffity" {
            let navigationController = segue.destination as! UINavigationController
            let detailsVC = navigationController.topViewController as! GraffitiDetailsViewController
            detailsVC.taggedGraffiti = self.graffiti
            detailsVC.delegate = self
        }
        if segue.identifier == "showPinImage" {
            let navigationController = segue.destination as! UINavigationController
            let graffitiImageVC = navigationController.topViewController as! GraffitiImageViewController
            graffitiImageVC.selectedCallout = selectedCalloutImage
            
        }
    }
}

extension CurrentLocationViewController : GraffitiDetailsViewControllerDelegate {
    func graffitiDidFinishGetTagged(sender: GraffitiDetailsViewController, taggedGraffiti: Graffiti) {
        graffitiManager.graffitis.append(taggedGraffiti)
        graffitiManager.save()
    }
}

extension CurrentLocationViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error en CoreLocation")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        }
        let latitude = Double(newLocation.coordinate.latitude)
        let longitude = Double(newLocation.coordinate.longitude)
        self.geocoder.reverseGeocodeLocation(newLocation) { (placemarks, error) in
            if error == nil {
                var address = "No se ha podido determinar"
                if let placemark = placemarks?.last {
                    address = self.stringFromPlacemark(placemark: placemark)
                }
                self.graffiti = Graffiti(address: address, latitude: latitude, longitude: longitude, imageName: "")
            }
            self.updatingLocation = false
            self.tagButton.isEnabled = true
        }
    }
}

extension CurrentLocationViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "graffitiPin")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "graffitiPin")
        } else {
            annotationView?.annotation = annotation
        }

        if let place = annotation as? Graffiti {
            let imageName = place.graffitiImageName
            if let imagesURL = graffitiManager.imageURL() {
                let imageData = try! Data(contentsOf: imagesURL.appendingPathComponent(imageName))
                selectedCalloutImage = UIImage(data: imageData)
                let image = reSizeImage(image: selectedCalloutImage!, newWidth: 40.0)
                let btnImageView = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                btnImageView.setImage(image, for: .normal)
                annotationView?.leftCalloutAccessoryView = btnImageView
                annotationView?.image = #imageLiteral(resourceName: "img_pin")
                annotationView?.canShowCallout = true
            }
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.leftCalloutAccessoryView {
            performSegue(withIdentifier: "showPinImage", sender: view)
        }
    }
    
    func reSizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

