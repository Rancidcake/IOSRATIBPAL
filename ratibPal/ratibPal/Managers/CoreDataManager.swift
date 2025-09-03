//
//  CoreDataManager.swift
//  ratibPal
//
//  Created by AI Assistant on 03/09/25.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    // MARK: - Core Data Stack
    private var _persistentContainer: NSPersistentContainer?
    
    lazy var persistentContainer: NSPersistentContainer = {
        if let container = _persistentContainer {
            return container
        }
        
        let container = NSPersistentContainer(name: "RatibPal") // .xcdatamodeld name
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        
        // Enable automatic merging of changes from parent
        container.viewContext.automaticallyMergesChangesFromParent = true
        _persistentContainer = container
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Background context for data operations
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    
    // MARK: - Save Context
    func saveContext() {
        let context = mainContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func saveBackgroundContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Background save error: \(error)")
            }
        }
    }
    
    // MARK: - Profile Management (Following Documentation)
    func saveProfile(_ profileData: Profile, completion: @escaping (Bool) -> Void) {
        let backgroundContext = newBackgroundContext()
        
        backgroundContext.perform {
            // Delete existing profile data
            self.deleteExistingProfile(uid: profileData.uid, in: backgroundContext)
            
            // Create new profile using Core Data entity
            let profile = CDProfile(context: backgroundContext)
            profile.uid = profileData.uid
            profile.mno = profileData.mno
            profile.off = profileData.off
            profile.nam = profileData.nam
            profile.eml = profileData.eml
            profile.img = profileData.img
            profile.irl = profileData.irl
            profile.blk = profileData.blk
            profile.pid = profileData.pid
            profile.stk = profileData.stk
            profile.plc = profileData.plc
            profile.pns = profileData.pns
            profile.ca = profileData.ca
            profile.cb = profileData.cb
            profile.ua = profileData.ua
            profile.ub = profileData.ub
            profile.d = profileData.d
            profile.e = false // Not edited locally
            
            // Save supplier data if exists
            if let supplierData = profileData.sup {
                let supplier = CDSupplier(context: backgroundContext)
                supplier.uid = profileData.uid
                supplier.mod = supplierData.mod
                supplier.bnm = supplierData.bnm
                supplier.bpr = supplierData.bpr
                supplier.sdc = supplierData.sdc
                supplier.sos = supplierData.sos
                supplier.ovd = supplierData.ovd
                supplier.ccos = supplierData.ccos
                supplier.ent = supplierData.ent
                supplier.cat = supplierData.cat
                supplier.scl = Int16(supplierData.scl)
                supplier.vtl = Int16(supplierData.vtl)
                supplier.dcn = supplierData.dcn
                supplier.ucn = supplierData.ucn
                
                profile.supplier = supplier
            }
            
            // Save locations
            if let locationsData = profileData.lcs {
                let locationSet = NSMutableSet()
                for locationData in locationsData {
                    let location = CDLocation(context: backgroundContext)
                    location.lid = locationData.lid
                    location.uid = profileData.uid
                    location.hno = locationData.hno
                    location.adr = locationData.adr
                    location.lt = locationData.lt
                    location.ct = locationData.ct
                    location.st = locationData.st
                    location.pin = locationData.pin
                    location.glt = locationData.glt ?? "Point"
                    location.typ = locationData.typ
                    location.rad = locationData.rad
                    
                    // Convert geolocation
                    if let glc = locationData.glc {
                        location.gll = "\(glc.coordinates[1]),\(glc.coordinates[0])" // lat,lng format
                    }
                    
                    location.profile = profile
                    locationSet.add(location)
                }
                profile.locations = locationSet
            }
            
            self.saveBackgroundContext(backgroundContext)
            
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    private func deleteExistingProfile(uid: String, in context: NSManagedObjectContext) {
        // Delete existing profile
        let profileFetch = CDProfile.fetchRequest()
        profileFetch.predicate = NSPredicate(format: "uid == %@", uid)
        
        do {
            let existingProfiles = try context.fetch(profileFetch)
            for profile in existingProfiles {
                context.delete(profile)
            }
        } catch {
            print("Error deleting existing profile: \(error)")
        }
        
        // Delete existing locations (should cascade, but ensure cleanup)
        let locationFetch = CDLocation.fetchRequest()
        locationFetch.predicate = NSPredicate(format: "uid == %@", uid)
        
        do {
            let existingLocations = try context.fetch(locationFetch)
            for location in existingLocations {
                context.delete(location)
            }
        } catch {
            print("Error deleting existing locations: \(error)")
        }
        
        // Delete existing supplier (should cascade, but ensure cleanup)
        let supplierFetch = CDSupplier.fetchRequest()
        supplierFetch.predicate = NSPredicate(format: "uid == %@", uid)
        
        do {
            let existingSuppliers = try context.fetch(supplierFetch)
            for supplier in existingSuppliers {
                context.delete(supplier)
            }
        } catch {
            print("Error deleting existing supplier: \(error)")
        }
    }
    
    func fetchProfile(uid: String, completion: @escaping (Profile?) -> Void) {
        let backgroundContext = newBackgroundContext()
        
        backgroundContext.perform {
            let request = CDProfile.fetchRequest()
            request.predicate = NSPredicate(format: "uid == %@", uid)
            request.fetchLimit = 1
            
            // Prefetch relationships
            request.relationshipKeyPathsForPrefetching = ["supplier", "locations"]
            
            do {
                guard let profileEntity = try backgroundContext.fetch(request).first else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                
                let profile = self.convertEntityToProfile(profileEntity)
                DispatchQueue.main.async { completion(profile) }
                
            } catch {
                print("Error fetching profile: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
    
    private func convertEntityToProfile(_ profileEntity: CDProfile) -> Profile? {
        guard let uid = profileEntity.uid else {
            return nil
        }
        
        // Convert supplier if present
        var supplier: Supplier?
        if let supplierEntity = profileEntity.supplier {
            supplier = Supplier(
                uid: supplierEntity.uid,
                mod: supplierEntity.mod,
                bnm: supplierEntity.bnm,
                bpr: supplierEntity.bpr,
                sdc: supplierEntity.sdc,
                sos: supplierEntity.sos,
                ovd: supplierEntity.ovd,
                ccos: supplierEntity.ccos,
                ent: supplierEntity.ent,
                cat: supplierEntity.cat,
                scl: Int(supplierEntity.scl),
                vtl: Int(supplierEntity.vtl),
                dcn: supplierEntity.dcn,
                ucn: supplierEntity.ucn
            )
        }
        
        // Convert locations if present
        var locations: [Location]?
        if let locationEntities = profileEntity.locations {
            locations = locationEntities.compactMap { entity in
                guard let locationEntity = entity as? CDLocation,
                      let lid = locationEntity.lid else {
                    return nil
                }
                
                // Convert gll (lat,lng CSV) back to GeoLocation
                var geoLocation: GeoLocation?
                if let gll = locationEntity.gll {
                    let components = gll.split(separator: ",")
                    if components.count == 2,
                       let lat = Double(components[0]),
                       let lng = Double(components[1]) {
                        geoLocation = GeoLocation(type: "Point", coordinates: [lng, lat]) // [lng, lat] format
                    }
                }
                
                return Location(
                    lid: lid,
                    uid: locationEntity.uid,
                    hno: locationEntity.hno,
                    adr: locationEntity.adr,
                    lt: locationEntity.lt,
                    ct: locationEntity.ct,
                    st: locationEntity.st,
                    pin: locationEntity.pin,
                    glt: locationEntity.glt,
                    gll: locationEntity.gll,
                    typ: locationEntity.typ,
                    rad: locationEntity.rad,
                    glc: geoLocation
                )
            }
        }
        
        return Profile(
            uid: uid,
            mno: profileEntity.mno,
            nam: profileEntity.nam,
            eml: profileEntity.eml,
            img: profileEntity.img,
            irl: profileEntity.irl,
            pid: profileEntity.pid,
            stk: profileEntity.stk ?? "",
            plc: profileEntity.plc,
            pns: profileEntity.pns,
            blk: profileEntity.blk,
            off: profileEntity.off,
            sup: supplier,
            lcs: locations,
            ca: profileEntity.ca,
            cb: profileEntity.cb,
            ua: profileEntity.ua,
            ub: profileEntity.ub,
            d: profileEntity.d
        )
    }
    
    func clearAllData() {
        // Use main context for synchronous operation during logout
        let context = persistentContainer.viewContext
        
        // Get all entity names
        let entityNames = persistentContainer.managedObjectModel.entities.compactMap { $0.name }
        
        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                if let objectIDs = result?.result as? [NSManagedObjectID] {
                    // Merge changes to update the context
                    let changes = [NSDeletedObjectsKey: objectIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
                }
            } catch {
                print("Error clearing \(entityName): \(error)")
            }
        }
        
        // Synchronously save the context
        do {
            try context.save()
        } catch {
            print("Error saving context after clearing: \(error)")
        }
    }
    
    // MARK: - Safe Database Shutdown for Logout
    func shutdownDatabase() {
        // Reset the persistent container to close all connections
        // This ensures all SQLite connections are properly closed
        _persistentContainer = nil
    }
}
