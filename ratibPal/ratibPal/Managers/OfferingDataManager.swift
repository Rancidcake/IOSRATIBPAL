import Foundation
import CoreData

class OfferingDataManager {
    static let shared = OfferingDataManager()
    private init() {}
    
    private var context: NSManagedObjectContext {
        return CoreDataManager.shared.mainContext
    }
    
    private func backgroundContext() -> NSManagedObjectContext {
        return CoreDataManager.shared.newBackgroundContext()
    }
    
    // MARK: - GSU Operations
    
    func saveGSU(_ gsu: CDGSU) throws {
        try context.save()
    }
    
    func createGSU(from response: GSUResponse, userId: String) -> CDGSU {
        let gsu = CDGSU(context: context)
        gsu.gid = response.gid
        gsu.sid = response.sid ?? userId
        gsu.gci = response.gci
        gsu.nam = response.nam
        gsu.shn = response.shn
        gsu.dsc = response.dsc
        gsu.img = response.img
        gsu.ul = response.ul
        gsu.cl = response.cl
        gsu.cc = response.cc
        gsu.pub = response.pub
        gsu.anp = response.anp
        gsu.sdt = response.sdt
        gsu.edt = response.edt
        gsu.ca = response.ca
        gsu.cb = response.cb
        gsu.ua = response.ua
        gsu.ub = response.ub
        gsu.d = response.d
        gsu.e = false // Not edited locally
        
        // Save variants
        if let variants = response.variants {
            let variantSet = NSMutableSet()
            for variantResponse in variants {
                let variant = createVariant(from: variantResponse, gsu: gsu)
                variantSet.add(variant)
            }
            gsu.variants = variantSet
        }
        
        // Save prices
        if let prices = response.prices {
            let priceSet = NSMutableSet()
            for priceResponse in prices {
                let price = createPrice(from: priceResponse, gsu: gsu)
                priceSet.add(price)
            }
            gsu.prices = priceSet
        }
        
        // Save sources
        if let sources = response.sources {
            let sourceSet = NSMutableSet()
            for sourceResponse in sources {
                let source = createGSUSource(from: sourceResponse, gsu: gsu)
                sourceSet.add(source)
            }
            gsu.sources = sourceSet
        }
        
        return gsu
    }
    
    func fetchMyOfferings(userId: String) -> [CDGSU] {
        let request: NSFetchRequest<CDGSU> = CDGSU.fetchRequest()
        request.predicate = NSPredicate(format: "sid == %@ AND d == FALSE", userId)
        request.sortDescriptors = [NSSortDescriptor(key: "nam", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching offerings: \(error)")
            return []
        }
    }
    
    func fetchOfferingsByCategory(
        userId: String,
        categoryFilter: String? = nil,
        searchText: String? = nil
    ) -> [CDGSU] {
        let request: NSFetchRequest<CDGSU> = CDGSU.fetchRequest()
        var predicates: [NSPredicate] = [
            NSPredicate(format: "sid == %@ AND d == FALSE", userId)
        ]
        
        if let category = categoryFilter, !category.isEmpty {
            predicates.append(NSPredicate(format: "sdc == %@", category))
        }
        
        if let search = searchText, !search.isEmpty {
            let searchPredicate = NSPredicate(
                format: "nam CONTAINS[cd] %@ OR bcd CONTAINS[cd] %@ OR dsc CONTAINS[cd] %@",
                search, search, search
            )
            predicates.append(searchPredicate)
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: "nam", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching filtered offerings: \(error)")
            return []
        }
    }
    
    func fetchOffering(by gid: String) -> CDGSU? {
        let request: NSFetchRequest<CDGSU> = CDGSU.fetchRequest()
        request.predicate = NSPredicate(format: "gid == %@", gid)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching offering by ID: \(error)")
            return nil
        }
    }
    
    func deleteOffering(_ gsu: CDGSU) throws {
        gsu.d = true
        gsu.e = true
        gsu.ua = Int64(Date().timeIntervalSince1970 * 1000)
        try context.save()
    }
    
    func fetchDirtyOfferings(userId: String) -> [CDGSU] {
        let request: NSFetchRequest<CDGSU> = CDGSU.fetchRequest()
        request.predicate = NSPredicate(format: "sid == %@ AND e == TRUE", userId)
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching dirty offerings: \(error)")
            return []
        }
    }
    
    // MARK: - Variant Operations
    
    func createVariant(from response: VariantResponse, gsu: CDGSU) -> CDVariant {
        let variant = CDVariant(context: context)
        variant.vid = response.vid
        variant.gid = response.gid
        variant.vnm = response.vnm
        variant.bcd = response.bcd
        variant.img = response.img
        variant.cl = response.cl
        variant.cc = response.cc
        variant.pub = response.pub
        variant.s = response.s
        variant.gsu = gsu
        return variant
    }
    
    func saveVariant(_ variant: CDVariant, for gsu: CDGSU) throws {
        variant.gsu = gsu
        try context.save()
    }
    
    func fetchVariants(for gsuId: String) -> [CDVariant] {
        let request: NSFetchRequest<CDVariant> = CDVariant.fetchRequest()
        request.predicate = NSPredicate(format: "gid == %@", gsuId)
        request.sortDescriptors = [NSSortDescriptor(key: "s", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching variants: \(error)")
            return []
        }
    }
    
    // MARK: - Price Operations
    
    func createPrice(from response: PriceResponse, gsu: CDGSU) -> CDPrice {
        let price = CDPrice(context: context)
        if let id = response.id {
            price.id = id
        }
        price.gid = response.gid
        price.vid = response.vid
        price.odt = response.odt
        price.trm = response.trm
        price.bp = response.bp
        price.sp = response.sp
        price.stp = response.stp
        price.pp = response.pp
        price.dco = response.dco
        price.dcm = response.dcm
        price.dbps = response.dbps
        price.dsps = response.dsps
        price.dtps = response.dtps
        price.dpps = response.dpps
        price.tcss = response.tcss
        price.gsu = gsu
        return price
    }
    
    func savePrice(_ price: CDPrice, for gsu: CDGSU) throws {
        price.gsu = gsu
        try context.save()
    }
    
    func fetchPrices(for gsuId: String, variantId: String? = nil) -> [CDPrice] {
        let request: NSFetchRequest<CDPrice> = CDPrice.fetchRequest()
        var predicates: [NSPredicate] = [NSPredicate(format: "gid == %@", gsuId)]
        
        if let vid = variantId {
            predicates.append(NSPredicate(format: "vid == %@", vid))
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: "odt", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching prices: \(error)")
            return []
        }
    }
    
    func getCurrentPrice(for gsuId: String, variantId: String? = nil, date: Date = Date()) -> CDPrice? {
        let currentDateInt = Int32(DateFormatter.yyyyMMdd.string(from: date)) ?? 0
        let prices = fetchPrices(for: gsuId, variantId: variantId)
        
        return prices.first { $0.odt <= currentDateInt }
    }
    
    // MARK: - GSU Source Operations
    
    func createGSUSource(from response: GSUSourceResponse, gsu: CDGSU) -> CDGSUSource {
        let source = CDGSUSource(context: context)
        if let id = response.id {
            source.id = id
        }
        source.gid = response.gid
        source.vid = response.vid
        source.sai = response.sai
        source.sgi = response.sgi
        source.svi = response.svi
        source.npc = response.npc
        source.qdi = response.qdi
        source.gsu = gsu
        return source
    }
    
    // MARK: - Category Operations
    
    func saveCategories(_ categories: [CategoryResponse]) throws {
        let backgroundContext = backgroundContext()
        
        backgroundContext.perform {
            // Clear existing categories
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: CDCategory.fetchRequest())
            do {
                try backgroundContext.execute(deleteRequest)
            } catch {
                print("Error deleting categories: \(error)")
            }
            
            // Add new categories
            for categoryResponse in categories {
                let category = CDCategory(context: backgroundContext)
                category.gci = categoryResponse.gci
                category.cnm = categoryResponse.cnm
                category.typ = categoryResponse.typ
                category.stp = categoryResponse.stp
                category.bannerId = categoryResponse.bannerId
                category.iconId = categoryResponse.iconId
                category.iconGreyId = categoryResponse.iconGreyId
                category.seq = categoryResponse.seq
                category.ca = categoryResponse.ca
                category.cb = categoryResponse.cb
                category.ua = categoryResponse.ua
                category.ub = categoryResponse.ub
                category.d = categoryResponse.d
            }
            
            CoreDataManager.shared.saveBackgroundContext(backgroundContext)
        }
    }
    
    func fetchCategories() -> [CDCategory] {
        let request: NSFetchRequest<CDCategory> = CDCategory.fetchRequest()
        request.predicate = NSPredicate(format: "d == FALSE")
        request.sortDescriptors = [NSSortDescriptor(key: "seq", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    // MARK: - Synchronization Helpers
    
    func syncOfferings(from serverData: [GSUResponse], userId: String) throws {
        let backgroundContext = backgroundContext()
        
        backgroundContext.perform {
            for offeringResponse in serverData {
                // Check if offering exists
                let request: NSFetchRequest<CDGSU> = CDGSU.fetchRequest()
                request.predicate = NSPredicate(format: "gid == %@", offeringResponse.gid)
                
                do {
                    let existingOfferings = try backgroundContext.fetch(request)
                    if let existingOffering = existingOfferings.first {
                        // Update existing offering if server data is newer
                        if offeringResponse.ua > existingOffering.ua || !existingOffering.e {
                            self.updateGSU(existingOffering, from: offeringResponse, in: backgroundContext)
                        }
                    } else {
                        // Create new offering
                        _ = self.createNewGSU(from: offeringResponse, userId: userId, in: backgroundContext)
                    }
                } catch {
                    print("Error syncing offering \(offeringResponse.gid): \(error)")
                }
            }
            
            CoreDataManager.shared.saveBackgroundContext(backgroundContext)
        }
    }
    
    private func updateGSU(_ gsu: CDGSU, from response: GSUResponse, in context: NSManagedObjectContext) {
        gsu.gci = response.gci
        gsu.nam = response.nam
        gsu.shn = response.shn
        gsu.dsc = response.dsc
        gsu.img = response.img
        gsu.ul = response.ul
        gsu.cl = response.cl
        gsu.cc = response.cc
        gsu.pub = response.pub
        gsu.anp = response.anp
        gsu.sdt = response.sdt
        gsu.edt = response.edt
        gsu.ua = response.ua
        gsu.ub = response.ub
        gsu.d = response.d
        // Don't update 'e' flag - preserve local edit status
    }
    
    private func createNewGSU(from response: GSUResponse, userId: String, in context: NSManagedObjectContext) -> CDGSU {
        let gsu = CDGSU(context: context)
        gsu.gid = response.gid
        gsu.sid = response.sid ?? userId
        gsu.gci = response.gci
        gsu.nam = response.nam
        gsu.shn = response.shn
        gsu.dsc = response.dsc
        gsu.img = response.img
        gsu.ul = response.ul
        gsu.cl = response.cl
        gsu.cc = response.cc
        gsu.pub = response.pub
        gsu.anp = response.anp
        gsu.sdt = response.sdt
        gsu.edt = response.edt
        gsu.ca = response.ca
        gsu.cb = response.cb
        gsu.ua = response.ua
        gsu.ub = response.ub
        gsu.d = response.d
        gsu.e = false
        
        return gsu
    }
    
    // MARK: - Model Conversion Helpers
    
    func convertToModel(_ gsu: CDGSU) -> OfferingModel {
        let variants = (gsu.variants?.allObjects as? [CDVariant] ?? [])
            .sorted { $0.s < $1.s }
            .map(convertToModel)
        
        let prices = (gsu.prices?.allObjects as? [CDPrice] ?? [])
            .sorted { $0.odt > $1.odt }
            .map(convertToModel)
        
        let sources = (gsu.sources?.allObjects as? [CDGSUSource] ?? [])
            .map(convertToModel)
        
        let imageIds = (gsu.img ?? "").split(separator: ",").map(String.init)
        
        return OfferingModel(
            gid: gsu.gid ?? "",
            name: gsu.nam ?? "",
            shortName: gsu.shn,
            description: gsu.dsc,
            barcode: (gsu.variants?.first(where: { ($0 as? CDVariant)?.bcd != nil }) as? CDVariant)?.bcd ?? "",
            imageIds: imageIds,
            unitLabel: gsu.ul,
            crateLabel: gsu.cl,
            crateCapacity: gsu.cc,
            isPublic: gsu.pub,
            availableSlots: gsu.anp,
            startDate: gsu.sdt,
            endDate: gsu.edt,
            category: gsu.gci,
            supplierDefinedCategory: "",
            variants: variants,
            prices: prices,
            sources: sources
        )
    }
    
    func convertToModel(_ variant: CDVariant) -> VariantModel {
        let imageIds = (variant.img ?? "").split(separator: ",").map(String.init)
        
        return VariantModel(
            vid: variant.vid ?? "",
            name: variant.vnm ?? "",
            barcode: variant.bcd,
            imageIds: imageIds,
            crateLabel: variant.cl,
            crateCapacity: variant.cc,
            isPublic: variant.pub,
            sequence: variant.s
        )
    }
    
    func convertToModel(_ price: CDPrice) -> PriceModel {
        return PriceModel(
            id: price.id,
            variantId: price.vid,
            applicableDate: price.odt,
            termMonths: price.trm,
            basePrice: price.bp,
            sellPrice: price.sp,
            strikeThroughPrice: price.stp,
            purchasePrice: price.pp,
            deliveryChargePerOrder: price.dco,
            deliveryChargePerMonth: price.dcm,
            dayWiseBasePrices: parsePriceJSON(price.dbps),
            dayWiseSellPrices: parsePriceJSON(price.dsps),
            dayWiseStrikePrices: parsePriceJSON(price.dtps),
            dayWisePurchasePrices: parsePriceJSON(price.dpps),
            taxCodes: parseTaxCodes(price.tcss)
        )
    }
    
    func convertToModel(_ source: CDGSUSource) -> GSUSourceModel {
        return GSUSourceModel(
            id: source.id,
            variantId: source.vid,
            sourceAffiliateId: source.sai,
            sourceGSUId: source.sgi,
            sourceVariantId: source.svi,
            needPercentage: source.npc,
            quantityDivision: source.qdi
        )
    }
    
    // MARK: - JSON Parsing Helpers
    
    private func parsePriceJSON(_ jsonString: String?) -> [String: Double]? {
        guard let jsonString = jsonString,
              let data = jsonString.data(using: .utf8) else { return nil }
        
        return try? JSONSerialization.jsonObject(with: data) as? [String: Double]
    }
    
    private func parseTaxCodes(_ jsonString: String?) -> [String]? {
        guard let jsonString = jsonString,
              let data = jsonString.data(using: .utf8) else { return nil }
        
        return try? JSONSerialization.jsonObject(with: data) as? [String]
    }
    
    // MARK: - Helper Methods
    
    func saveContext() throws {
        try CoreDataManager.shared.saveContext()
    }
}