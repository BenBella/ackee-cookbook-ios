//
//  EditViewModel.swift
//  Cookbook
//
//  Created by Lukáš Andrlik on 10/03/2018.
//  Copyright © 2018 Dominik Vesely. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import Unbox
import Result

class EditViewModel {
    
    // MARK: - Dependencies
    var api: CookbookAPIService
    
    // MARK: - Output
    let title = "edit.create.title".localized
    let alertMessageSignal: Signal<RequestError, NoError>
    
    // MARK: - Input / Output
    let inputIsValid = MutableProperty<Bool>(false)
    let name = MutableProperty<String>("")
    let duration = MutableProperty<Int>(0)
    let score = MutableProperty<Double>(0.0)
    let info = MutableProperty<String>("")
    let description = MutableProperty<String>("")
    let ingredients = MutableProperty<[String]>([])
    
    private let alertMessageObserver: Signal<RequestError, NoError>.Observer
    
    // Actions
    lazy var saveAction: Action<Void, Any?, RequestError> = { [unowned self] in
        return Action(enabledIf: self.inputIsValid) { [unowned self] _ in
            let parameters = RecipeParameters(
                name: self.name.value,
                description: self.description.value,
                ingredients: self.ingredients.value,
                duration: self.duration.value,
                info: self.info.value
            )
            return self.api.createRecipe(parameters)
        }
    }()
    
    lazy var updateAction: Action<Void, Any?, RequestError> = { [unowned self] in
        return Action(enabledIf: self.inputIsValid) { [unowned self] _ in
            return self.api.updateRecipe(id: "")
        }
    }()
    
    // MARK: - Lifecycle
    
    init(api: CookbookAPIService) {
        self.api = api
        
        let (alertMessageSignal, alertMessageObserver) = Signal<RequestError, NoError>.pipe()
        self.alertMessageSignal = alertMessageSignal
        self.alertMessageObserver = alertMessageObserver
        
        // Feed deletion errors into alert message signal
        
        updateAction.errors.observe(alertMessageObserver)
    }
    
}
    

