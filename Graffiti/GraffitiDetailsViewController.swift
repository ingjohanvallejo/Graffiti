//
//  GraffitiDetailsViewController.swift
//  Graffiti
//
//  Created by Johan Vallejo on 13/12/16.
//  Copyright © 2016 kijho. All rights reserved.
//

import UIKit

protocol GraffitiDetailsViewControllerDelegate: class {
    func graffitiDidFinishGetTagged(sender: GraffitiDetailsViewController, taggedGraffiti : Graffiti)
}

class GraffitiDetailsViewController: UIViewController {
    
    weak var delegate : GraffitiDetailsViewControllerDelegate?

    @IBOutlet var imgGraffiti: UIImageView!
    @IBOutlet var lblLongitude: UILabel!
    @IBOutlet var lblLatitude: UILabel!
    @IBOutlet var btnSave: UIBarButtonItem!
    @IBOutlet var lblAddress: UILabel!

    var taggedGraffiti : Graffiti?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        //Se agrega una imagen como título
        let image = #imageLiteral(resourceName: "img_navbar_title")
        self.navigationItem.titleView = UIImageView(image: image)

        let takePictureGesture = UITapGestureRecognizer(target: self, action: #selector(takePictureTapped))
        self.imgGraffiti.addGestureRecognizer(takePictureGesture)
        configureLabels()
    }

    func configureLabels() {
        lblLatitude.text = String(format: "%.8f", (taggedGraffiti?.coordinate.latitude)!)
        lblLongitude.text = String(format: "%.8f", (taggedGraffiti?.coordinate.longitude)!)
        lblAddress.text = taggedGraffiti?.graffitiAddress
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func btnSavePressed(_ sender: UIBarButtonItem) {
        if let image = imgGraffiti.image {
            let randomName = UUID().uuidString.appending(".png")
            if let url = GraffitiManager.sharedInstance.imageURL()?.appendingPathComponent(randomName), let imageData = UIImagePNGRepresentation(image) {
                do {
                   try imageData.write(to: url)
                } catch (let error) {
                    print("Se ha presentado un error guardando la imagen \(error)")
                }
            }

            taggedGraffiti = Graffiti(address: lblAddress.text!, latitude: Double(lblLatitude.text!)!, longitude: Double(lblLongitude.text!)!, imageName: randomName)
            if let taggedGraffiti = taggedGraffiti {
                delegate?.graffitiDidFinishGetTagged(sender: self, taggedGraffiti: taggedGraffiti)
            }
        }
        dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension GraffitiDetailsViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func takePictureTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        let takePhotoAction = UIAlertAction(title: "Tomar Foto", style: .default) { _ in
            self.takePhotoWithCamera()
        }
        let chooseFromLibraryAction = UIAlertAction(title: "Elegir de la libreria", style: .default) { _ in
            self.choosePhotoFromLibrary()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(chooseFromLibraryAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }

    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageTaken = info[UIImagePickerControllerEditedImage] as? UIImage
        imgGraffiti.image = imageTaken
        btnSave.isEnabled = true
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

