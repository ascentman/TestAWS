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
        let data = json.data(using: .utf8)
        do {
            let result = try JSONDecoder().decode(FotaSettings.self, from: data!)
            onCompletion?(result)
        } catch(let error) {
            print(error)
        }
//        transferUtility.downloadData(fromBucket: Const.bucketName,
//                                     key: Const.sotaFileName,
//                                     expression: nil) { (task, url, data, error) in
//                                        if let error = error {
//                                            debugPrint(error)
//                                        }
//                                        do {
//                                            let result = try JSONDecoder().decode(FotaSettings.self, from: data!)
//                                            print(result)
//                                            self.delegate?.dataLoaded(fotaSettings: result)
//                                        } catch {
//                                            debugPrint(error)
//                                        }
//        }
    }
}

struct FotaSettings: Decodable {
    let versionsListByTeams: [Int: Team]; struct Team: Decodable {
        var fotaEnabled: Bool
        var version: String
        var info: HWVersion?; struct HWVersion: Decodable {
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
    }
}

struct UnknownVersionCodingKey: CodingKey {

    init?(stringValue: String) { self.stringValue = stringValue }
    let stringValue: String

    init?(intValue: Int) {return nil }
    var intValue: Int? { return nil }
}

let json = """
{
   "fotaEnabled  ":true,
   "fotaSpeed  ":0.040,
   "fotaBleAvailableConnections  ":2,
   "versionsListByHWVersion  ":{
      "V1.0.5":{
         "version":"v1.1.0_3.3.1  ",
         "binFile":"https://pm-interviews.s3.amazonaws.com/uSensor_v1_STM32_3_3_1_compressed.bin  ",
         "jsonFile":"https://pm-interviews.s3.amazonaws.com/uSensor_v1_STM32_3_3_1_compressed.json  "
      }
   },
   "versionsListByTeams":{
      "1155":{
         "fotaEnabled":true,
         "V1.0.4":{
            "version":"v1.1.0_3.2.1  ",
            "binFile":"https://pm-interviews.s3.amazonaws.com/uSensor_v1_STM32_3_2_1_compressed.bin  ",
            "jsonFile":"https://pm-interviews.s3.amazonaws.com/uSensor_v1_STM32_3_2_1_compressed.json  "
         }
      },
      "675":{
         "fotaEnabled  ":true,
         "V1.0.5":{
            "version":"v1.1.0_3.3.1  ",
            "binFile":"https://pm-interviews.s3.amazonaws.com/uSensor_v1_STM32_3_3_1_compressed.bin  ",
            "jsonFile":"https://pm-interviews.s3.amazonaws.com/uSensor_v1_STM32_3_3_1_compressed.json  "
         }
      },
      "1154":{
         "fotaEnabled  ":true,
         "V1.0.5":{
            "version":"v1.1.0_3.3.1  ",
            "binFile":"https://pm-interviews.s3.amazonaws.com/uSensor_v1_STM32_3_3_1_compressed.bin  ",
            "jsonFile":"https://pm-interviews.s3.amazonaws.com/uSensor_v1_STM32_3_3_1_compressed.json  "
         }
      },
      "1163":{
         "fotaEnabled  ":true,
         "V1.0.6":{
            "version":"v1.1.0_3.3.1  ",
            "binFile":"https://pm-interviews.s3.amazonaws.com/uSensor_v1_STM32_3_3_1_compressed.bin  ",
            "jsonFile":"https://pm-interviews.s3.amazonaws.com/uSensor_v1_STM32_3_3_1_compressed.json  "
         }
      },
      "1150":{
         "fotaEnabled":true,
         "V1.0.5":{
            "version":"v1.1.0_3.2.1  ",
            "binFile":"https://pm-interviews.s3.amazonaws.com/uSensor_v1_STM32_3_2_1_compressed.bin  ",
            "jsonFile":"https://pm-interviews.s3.amazonaws.com/uSensor_v1_STM32_3_2_1_compressed.json  "
         }
      }
   }
}
"""
