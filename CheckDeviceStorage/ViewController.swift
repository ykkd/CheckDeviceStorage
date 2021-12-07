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

// MARK: - Tap Action
extension ViewController {
    
    @IBAction func didTapAddDataButton(_ sender: Any) {
        self.addDataAtDocumentDir()
    }
    
    @IBAction func didTapRefreshButton(_ sender: Any) {
        self.checkDeviceStorage()
    }
}

// MARK: - Get Storage Info
extension ViewController {
    
    private func checkDeviceStorage() {
        var text = String()
        
        do {
            let bytes = try self.getAvailableDiskCapacityViaFileManager()
            text += "[getAvailableDiskCapacityViaFileManager] \n \(ByteCountFormatter.string(fromByteCount: bytes, countStyle: .decimal)), \n (\(bytes)) \n\n\n"
        } catch {
            text += "[getAvailableDiskCapacityViaFileManager] \n\(error.localizedDescription)\n\n\n"
        }
        
        do {
            try text += "[getAvailableDiskCapacityViaURL]\n \(self.getAvailableDiskCapacityViaURL()) \n"
        } catch {
            text += "[getAvailableDiskCapacityViaURL]\n error: \(error.localizedDescription) \n\n\n"
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
            
            result.allValues
                .filter { $0.key == .volumeAvailableCapacityKey }
                .forEach { key, value in
                    text += "- \(key) \n \(ByteCountFormatter.string(fromByteCount: value as! Int64, countStyle: .decimal)), \n \(value) \n\n\n"
                }
            
            result.allValues
                .filter { $0.key == .volumeAvailableCapacityForImportantUsageKey }
                .forEach { key, value in
                    text += "- \(key) \n \(ByteCountFormatter.string(fromByteCount: value as! Int64, countStyle: .decimal)), \n \(value) \n\n\n"
                }
            
            result.allValues
                .filter { $0.key == .volumeAvailableCapacityForOpportunisticUsageKey }
                .forEach { key, value in
                    text += "- \(key) \n \(ByteCountFormatter.string(fromByteCount: value as! Int64, countStyle: .decimal)), \n \(value) \n\n\n"
                }
            
            result.allValues
                .filter { $0.key == .volumeTotalCapacityKey }
                .forEach { key, value in
                    text += "- \(key) \n \(ByteCountFormatter.string(fromByteCount: value as! Int64, countStyle: .decimal)), \n \(value) \n\n\n"
                }
            
            return text
        } catch {
            throw DiskCapacityError.url
        }
    }
}

// MARK: - Add Data
extension ViewController {
    
    private func addDataAtDocumentDir() {
        DispatchQueue.main.async {
            let d = Data.init(repeating: 100, count: 1000000000)
            do {
                let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let destinationPath = documentPath.appendingPathComponent("\(Date())")
                try d.write(to: destinationPath)
            } catch {
                print("error: \(error)")
            }
        }
    }
}

// MARK: - Error
extension ViewController {
    
    enum DiskCapacityError: Error {
        case fileManager
        case url
    }
}
