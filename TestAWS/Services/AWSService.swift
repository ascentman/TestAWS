//
//  AWSService.swift
//  TestAWS
//
//  Created by Volodymyr Rykhva on 07.07.2020.
//  Copyright © 2020 Volodymyr Rykhva. All rights reserved.
//

import Foundation
import AWSS3

protocol AWSServiceDelegate: class {
    func dataLoaded(fotaSettings: FotaSettings)
}

final class AWSService {
    private enum Const {
        static let accessKey = "AKIA5JJ3DDVW7ZQN6BH6"
        static let secretKey = "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"
        static let bucketName = "pm-interviews"
        static let sotaFileName = "FotaSettings.json"
    }

    private let transferUtility: AWSS3TransferUtility

    init() {
        let credentialProvider = AWSStaticCredentialsProvider(accessKey: Const.accessKey,
                                                              secretKey: Const.secretKey)
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
        AWSServiceManager.default()?.defaultServiceConfiguration = configuration
        transferUtility = AWSS3TransferUtility.default()
    }

    func download(onCompletion: ((FotaSettings) -> Void)?) {
        transferUtility.downloadData(fromBucket: Const.bucketName,
                                     key: Const.sotaFileName,
                                     expression: nil) { (task, url, data, error) in
                                        if let error = error {
                                            debugPrint(error)
                                        }
                                        do {
                                            let result = try JSONDecoder().decode(FotaSettings.self, from: data!)
                                            print(result)
                                            onCompletion?(result)
                                        } catch {
                                            debugPrint(error)
                                        }
        }
    }

    func upload(newSettings: FotaSettings,onCompletion: @escaping () -> Void) {
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(newSettings)
            let jsonString = String(data: jsonData, encoding: .utf8)

            guard let text = jsonString else { return }

            let filename = getDocumentsDirectory().appendingPathComponent("FotaSettings-Volodymyr-Rykhva.json")
            transferUtility.uploadFile(filename,
                                       bucket: Const.bucketName,
                                       key: Const.sotaFileName,
                                       contentType: "json",
                                       expression: nil) { task, error in
                                        if let error = error {
                                            debugPrint(error)
                                        }
                                        onCompletion()
            }
            do {
                try text.write(to: filename, atomically: true, encoding: .utf8)
            } catch {
                debugPrint(error)
            }
        } catch {
            debugPrint(error)
        }
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

struct FotaSettings: Codable {
    let versionsListByTeams: [Int: Team]; struct Team: Codable {
        var fotaEnabled: Bool
        var version: String
        var info: HWVersion?; struct HWVersion: Codable {
            let version: String
            let binFile: String
            let jsonFile: String
        }

        init(from decoder: Decoder) throws {
            self.fotaEnabled = true
            self.version = ""

            let container = try decoder.container(keyedBy: UnknownVersionCodingKey.self)
            for key in container.allKeys {
                if let boolValue = try? container.decode(Bool.self, forKey: key) {
                    self.fotaEnabled = boolValue
                } else if let dataValue = try? container.decode(HWVersion.self, forKey: key) {
                    self.version = key.stringValue
                    self.info = dataValue
                } else {
                    continue
                }
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: UnknownVersionCodingKey.self)
            if let fotaKey = UnknownVersionCodingKey(stringValue: "fotaEnabled") {
                try container.encode(fotaEnabled, forKey: fotaKey)
            }
            if let versionKey = UnknownVersionCodingKey(stringValue: version) {
                try container.encode(info, forKey: versionKey)
            }
        }
    }
}

struct UnknownVersionCodingKey: CodingKey {

    init?(stringValue: String) { self.stringValue = stringValue }
    let stringValue: String

    init?(intValue: Int) {return nil }
    var intValue: Int? { return nil }
}
