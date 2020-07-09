//
//  ViewController.swift
//  TestAWS
//
//  Created by Volodymyr Rykhva on 06.07.2020.
//  Copyright © 2020 Volodymyr Rykhva. All rights reserved.
//

import UIKit

final class MainTableViewController: UITableViewController {

    private var props: Props = .defaultValue
    private var awsService: AWSService = AWSService()

    func render(props: Props) {
        guard isViewLoaded else { return }

        tableView.reloadData()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Teams"
        tableView.tableFooterView = UIView(frame: .zero)

        awsService.download(onCompletion: { [weak self] fotaSettings in
            self?.props = Props(fotaSettings: fotaSettings, isLoading: false)
        })
    }
}

extension MainTableViewController {

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

extension MainTableViewController {

    // MARK: UITableViewDataSource & UITableViewDelegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return props.versionListByTeams.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamTableViewCell") as? TeamTableViewCell
        cell?.setupCell(team: props.versionListByTeams[indexPath.row])
        cell?.onUpdateFota = { [weak self] isFotaEnabled in
            self?.props.versionListByTeams[indexPath.row].fotaEnabled = isFotaEnabled
            self?.render(props: self?.props ?? .defaultValue)
        }
        return cell ?? UITableViewCell()
    }

    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails_segue",
        let viewController = segue.destination as? VersionViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                viewController.setup(version: props.versionListByTeams[indexPath.row].majorVersion,
                                     isFotaEnabled: props.versionListByTeams[indexPath.row].fotaEnabled)
                viewController.onUpdate = { [weak self] (majorVersion, isFotaEnabled) in
                    self?.props.versionListByTeams[indexPath.row].majorVersion = majorVersion
                    self?.props.versionListByTeams[indexPath.row].fotaEnabled = isFotaEnabled
                    self?.render(props: self?.props ?? .defaultValue)
                }
            }
        }
    }
}

extension MainTableViewController.Props {
    init(fotaSettings: FotaSettings?, isLoading: Bool) {
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

