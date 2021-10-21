//
//  ViewController.swift
//  BGUploader
//
//  Created by Ruben Nine on 20/10/21.
//

import UIKit

class ViewController: UIViewController {
    lazy var uploadButton = UIButton(type: .system)
    lazy var stackView = UIStackView(arrangedSubviews: [uploadButton])

    let urlsToUpload = [
        Bundle.main.url(forResource: "pic1", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic2", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic3", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic4", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic5", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic1", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic2", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic3", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic4", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic5", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic1", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic2", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic3", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic4", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic5", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic1", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic2", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic3", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic4", withExtension: "jpg")!,
        Bundle.main.url(forResource: "pic5", withExtension: "jpg")!
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.translatesAutoresizingMaskIntoConstraints = false
        uploadButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        uploadButton.setTitle("Upload", for: .normal)
        uploadButton.addTarget(self, action: #selector(upload(_:)), for: .primaryActionTriggered)

        stackView.axis = .vertical

        let guide = view.safeAreaLayoutGuide

        stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true

        stackView.addArrangedSubview(uploadButton)
    }
}

extension ViewController {
    @IBAction func upload(_ sender: Any) {
        for url in urlsToUpload {
            bgUploadService.upload(url: url)
        }
    }
}
