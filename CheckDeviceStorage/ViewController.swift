//
//  ViewController.swift
//  CheckDeviceStorage
//
//  Created by ykkd on 2021/12/03.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkDeviceStorage()
    }
}

extension ViewController {
    
    private func checkDeviceStorage() {
        var text = String()
        
        do {
            let bytes = try self.getAvailableDiskCapacityViaFileManager()
            text += "[getAvailableDiskCapacityViaFileManager] \n \(ByteCountFormatter.string(fromByteCount: bytes, countStyle: .decimal)), \n (\(bytes)) \n"
        } catch {
            text += "[getAvailableDiskCapacityViaFileManager] \n\(error.localizedDescription)"
        }
        
        do {
            try text += "[getAvailableDiskCapacityViaFileManager]\n \(self.getAvailableDiskCapacityViaURL()) \n"
        } catch {
            text += "[getAvailableDiskCapacityViaFileManager]\n error: \(error.localizedDescription) \n"
        }
        
        print("results: \(text)")
        self.label.text = text
    }
    
    private func getAvailableDiskCapacityViaFileManager() throws -> Int64 {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
            let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
            return freeSpace!
        } catch {
            throw DiskCapacityError.fileManager
        }
    }
    
    private func getAvailableDiskCapacityViaURL() throws -> String {
        let url = URL(fileURLWithPath: NSHomeDirectory())
        do {
            let result = try url.resourceValues(
                forKeys: [
                    // Key for the volume’s available capacity in bytes (read-only).
                    .volumeAvailableCapacityKey,
                    // Key for the volume’s available capacity in bytes for storing important resources (read-only).
                    .volumeAvailableCapacityForImportantUsageKey,
                    // Key for the volume’s available capacity in bytes for storing nonessential resources (read-only).
                    .volumeAvailableCapacityForOpportunisticUsageKey,
                    // NSURLVolumeTotalCapacityKey
                    .volumeTotalCapacityKey
                ]
            )
            
            var text = String()
            
            result.allValues.forEach { key, value in
                text += "- \(key) \n \(ByteCountFormatter.string(fromByteCount: value as! Int64, countStyle: .decimal)), \n \(value) \n"
            }
            return text
        } catch {
            throw DiskCapacityError.url
        }
    }
    
    
}

extension ViewController {
    
    enum DiskCapacityError: Error {
        case fileManager
        case url
    }
}
