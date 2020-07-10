//
//  ViewController.swift
//  TestAWS
//
//  Created by Volodymyr Rykhva on 09.07.2020.
//  Copyright © 2020 Volodymyr Rykhva. All rights reserved.
//

import UIKit

final class MainTableViewController: UITableViewController {

    @IBOutlet var dataProvider: SettingsDataProvider!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Teams"
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)

        dataProvider.delegate = self
        dataProvider.load()
    }

    // MARK - Private

    @objc private func onRefresh() {
        dataProvider.load()
        tableView.refreshControl?.endRefreshing()
    }
}

extension MainTableViewController: SettingsDataProviderDelegate {

    func goToVersion(index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "VersionViewController") as? VersionViewController
        viewController?.setup(version: dataProvider.props.versionListByTeams[index].majorVersion,
                              isFotaEnabled: dataProvider.props.versionListByTeams[index].fotaEnabled)
        viewController?.onUpdate = { [weak self] (majorVersion, isFotaEnabled) in
            self?.dataProvider.props.versionListByTeams[index].majorVersion = majorVersion
            self?.dataProvider.props.versionListByTeams[index].fotaEnabled = isFotaEnabled
            self?.render()
        }
        if let viewController = viewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    func render() {
        guard isViewLoaded else { return }

        tableView.reloadData()
    }
}

