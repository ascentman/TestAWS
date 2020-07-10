//
//  SettingsDataProvider.swift
//  TestAWS
//
//  Created by Volodymyr Rykhva on 09.07.2020.
//  Copyright © 2020 Volodymyr Rykhva. All rights reserved.
//

import UIKit

protocol SettingsDataProviderDelegate: class {
    func goToVersion(index: Int)
    func render()
}

final class SettingsDataProvider: NSObject {

    var props: Props = .defaultValue
    private var awsService: AWSService = AWSService()
    weak var delegate: SettingsDataProviderDelegate?

    func load() {
        awsService.download(onCompletion: { [weak self] fotaSettings in
            self?.props = SettingsDataProvider.Props(fotaSettings: fotaSettings)
            self?.delegate?.render()
        })
    }

    func update(onCompletion: @escaping () -> Void) {
        let fotaSettings = FotaSettings(props: props)
        awsService.upload(newSettings: fotaSettings, onCompletion: onCompletion)
    }
}

extension SettingsDataProvider {

    // MARK: Props

    struct Props {
        var versionListByTeams: [Team]; struct Team {
            let id: Int
            var fotaEnabled: Bool
            var majorVersion: Version; struct Version {
                let id: String
                var version: String
                var binFile: String
                var jsonFile: String

                static let defaultValue = Version(id: "", version: "", binFile: "", jsonFile: "")
            }
        }
        static let defaultValue = Props(versionListByTeams: [])
    }
}

extension SettingsDataProvider.Props {
    init(fotaSettings: FotaSettings?) {
        var teamsArray: [Team] = []

        guard let fotaSettings = fotaSettings else {
            self.versionListByTeams = []
            return
        }

        for (teamKey, teamValue) in fotaSettings.versionsListByTeams {
            let teamVersion = Team.Version(id: teamValue.version,
                                           version: teamValue.info?.version ?? "",
                                           binFile: teamValue.info?.binFile ?? "",
                                           jsonFile: teamValue.info?.jsonFile ?? "")
            teamsArray.append(Team(id: teamKey,
                                   fotaEnabled: teamValue.fotaEnabled,
                                   majorVersion: teamVersion))
        }
        self.versionListByTeams = teamsArray
    }
}

extension FotaSettings {
    init(props: SettingsDataProvider.Props) {
        let teamsDict = props.versionListByTeams.reduce([Int: FotaSettings.Team]()) { (dict, team) -> [Int : FotaSettings.Team] in
            var dict = dict
            dict[team.id] = FotaSettings.Team(team: team)
            return dict
        }
        self.versionsListByTeams = teamsDict
    }
}

extension FotaSettings.Team {
    init(team: SettingsDataProvider.Props.Team) {
        let hwVersion = FotaSettings.Team.HWVersion(version: team.majorVersion.version,
                                                    binFile: team.majorVersion.binFile,
                                                    jsonFile: team.majorVersion.jsonFile)
        self.version = team.majorVersion.id
        self.fotaEnabled = team.fotaEnabled
        self.info = hwVersion
    }
}

extension SettingsDataProvider: UITableViewDelegate, UITableViewDataSource {

    // MARK: UITableViewDataSource & UITableViewDelegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return props.versionListByTeams.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamTableViewCell") as? TeamTableViewCell
        cell?.setupCell(team: props.versionListByTeams[indexPath.row])
        cell?.onUpdateFota = { [weak self] isFotaEnabled in
            self?.props.versionListByTeams[indexPath.row].fotaEnabled = isFotaEnabled
        }
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.goToVersion(index: indexPath.row)
    }
}
