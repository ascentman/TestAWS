//
//  TeamTableViewCell.swift
//  TestAWS
//
//  Created by Volodymyr Rykhva on 09.07.2020.
//  Copyright © 2020 Volodymyr Rykhva. All rights reserved.
//

import UIKit

final class TeamTableViewCell: UITableViewCell {

    typealias Team = MainTableViewController.Props.Team

    @IBOutlet private weak var teamIdLabel: UILabel!
    @IBOutlet private weak var majorVersionLabel: UILabel!
    @IBOutlet private weak var fotaEnabledSwitch: UISwitch!

    var onUpdateFota: (Bool) -> Void = { _ in }

    override func prepareForReuse() {
        super.prepareForReuse()

        teamIdLabel.text = ""
        majorVersionLabel.text = ""
        fotaEnabledSwitch.isOn = true
    }

    func setupCell(team: Team) {
        teamIdLabel.text = String(team.id)
        majorVersionLabel.text = team.majorVersion.id
        fotaEnabledSwitch.isOn = team.fotaEnabled
    }

    @IBAction private func fotaDidToggle(_ sender: Any) {
        onUpdateFota(fotaEnabledSwitch.isOn)
    }
}
