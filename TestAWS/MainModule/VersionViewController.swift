//
//  VersionViewController.swift
//  TestAWS
//
//  Created by Volodymyr Rykhva on 09.07.2020.
//  Copyright © 2020 Volodymyr Rykhva. All rights reserved.
//

import UIKit

final class VersionViewController: UIViewController {

    typealias Version = MainTableViewController.Props.Team.Version

    @IBOutlet private weak var majorVersionLabel: UILabel!
    @IBOutlet private weak var fotaEnabledSwitch: UISwitch!
    @IBOutlet private weak var versionTextField: UITextField!
    @IBOutlet private weak var binFileTextField: UITextField!
    @IBOutlet private weak var jsonFileTextField: UITextField!

    private var majorVersion: Version = .defaultValue
    private var isFotaEnabled: Bool = false

    var onUpdate: (Version, Bool) -> () = {_,_ in }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = majorVersion.id
        majorVersionLabel.text = majorVersion.id
        fotaEnabledSwitch.isOn = isFotaEnabled
        versionTextField.text = majorVersion.version
        binFileTextField.text = majorVersion.binFile
        jsonFileTextField.text = majorVersion.jsonFile
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        onUpdate(majorVersion, isFotaEnabled)
    }

    func setup(version: Version, isFotaEnabled: Bool) {
        self.majorVersion = version
        self.isFotaEnabled = isFotaEnabled
    }

    @IBAction private func switchDidToggle(_ sender: Any) {
        isFotaEnabled = fotaEnabledSwitch.isOn
    }
}

extension VersionViewController: UITextFieldDelegate {

    // MARK - UITextFieldDelegate

    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case versionTextField:
            majorVersion.version = textField.text ?? ""
        case binFileTextField:
            majorVersion.binFile = textField.text ?? ""
        case jsonFileTextField:
            majorVersion.jsonFile = textField.text ?? ""
        default:
            assertionFailure("Unhandled TextField")
        }
        textField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}
